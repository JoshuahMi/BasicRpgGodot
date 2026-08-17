class_name BasicRpgGrapplingHook extends CharacterBody3D

enum GrapplingHookState {
	
	AT_PLAYER_IDLE,
	TRAVELING_TO_TARGET,
	CONNECTED,
	TRAVELING_TO_PLAYER
	
	
	
}

@export var mesh: MeshInstance3D = MeshInstance3D.new()
@export var mesh_material: Material = Material.new()
@export var rope_material: Material = Material.new()

@export var travelling_speed: float = 100.0

var debug: bool = true

## The Ledge Representator this Grappling Hook will travel to.
var target: Node3D


## TODO: This point will be set when *initiate use* is called, and all functionality will refer to this point.
var target_point: Vector3

var player: Node3D

var current_state: GrapplingHookState = GrapplingHookState.AT_PLAYER_IDLE

signal ejected
signal connected
signal disconnected
signal returned

func _ready() -> void:
	#print("From Grappling Hook: Ready! ")
	var hook := SphereMesh.new()
	
	mesh.mesh = hook
	mesh.scale = Vector3(0.01, 0.01, 0.01)
	top_level = true
	
	add_child(mesh)
	mesh.visible = false
	
	
	
	


func update(delta: float):
	
	match current_state:
		
		GrapplingHookState.AT_PLAYER_IDLE:
			
			pass
		GrapplingHookState.TRAVELING_TO_TARGET:
			if target == null:
				return
			
			
			if debug:
				DebugShapes.place_the_blue_sphere(global_position)
			
			velocity = global_position.direction_to(target_point).normalized() * travelling_speed
			
			
			if global_position.distance_to(player.global_position) >= target_point.distance_to(player.global_position):
				# Reached target
				# change state to connected
				
				global_position = target_point
				
				
				current_state = GrapplingHookState.CONNECTED
				connected.emit()
				pass
			
			move_and_slide()
			
			
			
		GrapplingHookState.CONNECTED:
			#print("From Grappling Hook: Connected State! ")
			if debug:
				DebugShapes.place_the_blue_sphere(global_position)
				
			#print("From Grappling Hook: Ledge position: " + str(target.global_position))
			#print("From Grappling Hook: Hook position: " + str(global_position))
				
			#print("From Grappling Hook: Distance to ledge: " + str(global_position.distance_to(target.global_position)))
			
			pass
			
		GrapplingHookState.TRAVELING_TO_PLAYER:
			#print("From Grappling Hook: Returning State! ")
			if player == null:
				return
				
			if debug:
				DebugShapes.place_the_blue_sphere(global_position)
				
			velocity = global_position.direction_to(player.global_position) * travelling_speed
			
			if global_position.distance_to(target_point) > target_point.distance_to(player.global_position):
				#reached player
				# change state to at player idle
				mesh.visible = false
				current_state = GrapplingHookState.AT_PLAYER_IDLE
				returned.emit()
			
			move_and_slide()

	
	
	pass


func _physics_process(delta: float) -> void:
	
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	update(delta)
	
	
## Use this function to use the grappling hook.
func initiate_use():
	
	position = player.global_position
	
	if not current_state == GrapplingHookState.AT_PLAYER_IDLE:
		return
	
	current_state = GrapplingHookState.TRAVELING_TO_TARGET
	
	target_point = target.global_position
	
	mesh.visible = true
	
	ejected.emit()
	pass

func return_to_player():
	
	if not current_state == GrapplingHookState.CONNECTED:
		return
	
	current_state = GrapplingHookState.TRAVELING_TO_PLAYER
	
	disconnected.emit()
	
