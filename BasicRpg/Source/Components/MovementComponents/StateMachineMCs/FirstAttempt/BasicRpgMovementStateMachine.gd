# Copyright 2026 Joshuah Skyseed, all rights reserved  

class_name BasicRpgMovementStateMachine extends Node

@export var body: CharacterBody3D = null
@export var camera: Camera3D = null

var jump_strength: float = 0.1
var jump_charges: int = 2
var dash_charges: int = 2

var movement_strength_while_jumping: float = 0.4
var movement_strength_while_air: float = 0.4

var is_normal_movement_possible: bool = true

var movement_speed: float = 10.0
const MOVEMENT_ACCELERATION = 1.0
@export var movement_acceleration = 4.0
@export var movement_deceleration_when_idle: float = 17.0
var sprint_multiplier: float =  1.8
var look_direction: Vector2

var has_just_moved: bool = false
var has_just_stopped: bool = false

var is_on_ground: bool = false:
	set(new_value):
		if new_value != is_on_ground:
			if new_value == true:
				has_just_landed = true
			else:
				has_just_left_ground = true
			is_on_ground = new_value
		else:
			is_on_ground = new_value
			has_just_landed = false
			has_just_left_ground = false
			
var has_just_left_ground: bool = false
var has_just_landed: bool = false

#region INPUT

var movement_direction: Vector2
var wants_to_jump: bool = false
var wants_to_sprint: bool = false
var wants_to_dash: bool = false
var wants_to_crouch: bool = false

var mouse_sensitivity: float = 1.0

#endregion INPUT

signal state_changed(new_state: States)


#region STATES

enum States {
	
	IDLE,
	GO,
	DASH,
	JUMP,
	AIR,
	WALL,
	KNOCKBACK,
	SLIDE,
	
	CLIMB,
	LEDGE_GRAB,
	
	SWIM,
	DIVE,
	
}

var states: Dictionary = {}

var current_state: States

#endregion STATES





# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	if body == null or camera == null:
		return 
	
	await body.ready
	
	states[States.IDLE] = BasicRpgMovementStateIdle.new()
	states[States.IDLE].body = body
	states[States.IDLE].camera = camera
	states[States.IDLE].state_machine = self
	states[States.IDLE].transitioned.connect(_on_state_transitioned)
	
	states[States.GO] = BasicRpgMovementStateGo.new()
	states[States.GO].body = body
	states[States.GO].camera = camera
	states[States.GO].state_machine = self
	states[States.GO].transitioned.connect(_on_state_transitioned)
	
	states[States.DASH] = BasicRpgMovementStateDash.new()
	states[States.DASH].body = body
	states[States.DASH].camera = camera
	states[States.DASH].state_machine = self
	states[States.DASH].transitioned.connect(_on_state_transitioned)
	
	states[States.JUMP] = BasicRpgMovementStateJump.new()
	states[States.JUMP].body = body
	states[States.JUMP].camera = camera
	states[States.JUMP].state_machine = self
	states[States.JUMP].transitioned.connect(_on_state_transitioned)
	
	states[States.AIR] = BasicRpgMovementStateAir.new()
	states[States.AIR].body = body
	states[States.AIR].camera = camera
	states[States.AIR].state_machine = self
	states[States.AIR].transitioned.connect(_on_state_transitioned)
	
	states[States.WALL] = BasicRpgMovementStateWall.new()
	states[States.WALL].body = body
	states[States.WALL].camera = camera
	states[States.WALL].state_machine = self
	states[States.WALL].transitioned.connect(_on_state_transitioned)
	
	states[States.KNOCKBACK] = BasicRpgMovementStateKnockback.new()
	states[States.KNOCKBACK].body = body
	states[States.KNOCKBACK].camera = camera
	states[States.KNOCKBACK].state_machine = self
	states[States.KNOCKBACK].transitioned.connect(_on_state_transitioned)
	
	states[States.SLIDE] = BasicRpgMovementStateSlide.new()
	states[States.SLIDE].body = body
	states[States.SLIDE].camera = camera
	states[States.SLIDE].state_machine = self
	states[States.SLIDE].transitioned.connect(_on_state_transitioned)
	
	states[States.CLIMB] = BasicRpgMovementStateClimb.new()
	states[States.CLIMB].body = body
	states[States.CLIMB].camera = camera
	states[States.CLIMB].state_machine = self
	states[States.CLIMB].transitioned.connect(_on_state_transitioned)
	
	states[States.LEDGE_GRAB] = BasicRpgMovementStateLedgeGrab.new()
	states[States.LEDGE_GRAB].body = body
	states[States.LEDGE_GRAB].camera = camera
	states[States.LEDGE_GRAB].state_machine = self
	states[States.LEDGE_GRAB].transitioned.connect(_on_state_transitioned)
	
	states[States.SWIM] = BasicRpgMovementStateSwim.new()
	states[States.SWIM].body = body
	states[States.SWIM].camera = camera
	states[States.SWIM].state_machine = self
	states[States.SWIM].transitioned.connect(_on_state_transitioned)
	
	states[States.DIVE] = BasicRpgMovementStateDive.new()
	states[States.DIVE].body = body
	states[States.DIVE].camera = camera
	states[States.DIVE].state_machine = self
	states[States.DIVE].transitioned.connect(_on_state_transitioned)
	
	_determine_initial_state()
	
	states[current_state].enter()
	

func _physics_process(delta: float) -> void:
	
	if states[current_state] == null:
		return
		
		
	happening_management()
	states[current_state].physics_update(delta)
	look()
	body.move_and_slide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if states[current_state] == null:
		return
		
	states[current_state].update(delta)
	
	
	
	pass
	
func happening_management():
	
	if body.is_on_floor():
		is_on_ground = true
	else:
		is_on_ground = false
	
	pass
	
func _on_state_transitioned(From: States, To: States):
	
	if From != current_state:
		return
		
	states[From].exit()	
	current_state = To
	states[To].enter()
	
	state_changed.emit(current_state)
	
	pass
	
func look():
	camera.rotation.x += (look_direction.y * -1.0 * mouse_sensitivity * 0.01)
	camera.rotation.x  = clampf(camera.rotation.x, -1.5, 1.5)
	camera.rotation.y += (look_direction.x * -1.0 * mouse_sensitivity * 0.01)
	pass
	
func _determine_initial_state():
	
	if body.is_on_floor():
		current_state = States.IDLE
	else:
		current_state = States.AIR
		
	state_changed.emit(current_state)
