extends CharacterBody3D

@onready var input_component: BasicRpgInputComponent = $BasicRpgInputComponent
@onready var movement_component: BasicRpgMovementComponent = $BasicRpgMovementComponent


var current_state: BasicRpgGeneral.PlayerMovementStates = BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_IDLE

func change_state(new_state: BasicRpgGeneral.PlayerMovementStates):
	
	current_state = new_state
	
	pass
	
func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if input_component.is_jump_pressed:
		movement_component.jump()
		
	if input_component.is_sprint_pressed:
		movement_component.is_currently_sprinting = true
	else:
		movement_component.is_currently_sprinting = false
	
	movement_component.movement_direction = input_component.move_direction
	movement_component.look(input_component.look_vector.y, input_component.look_vector.x )

	
		
	$Camera3D.rotation.x = clampf($Camera3D.rotation.x, -1.5, 1.5)
	# print(input_component.move_direction)
	
	match current_state:
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_IDLE:
			pass
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_JUMP:
			pass
		BasicRpgGeneral.PlayerMovementStates.IN_AIR_FROM_KNOCKBACK:
			pass
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_NORMAL:
			pass
		BasicRpgGeneral.PlayerMovementStates.ON_FLOOR_MOVEMENT_SPRINTING:
			pass
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	pass
