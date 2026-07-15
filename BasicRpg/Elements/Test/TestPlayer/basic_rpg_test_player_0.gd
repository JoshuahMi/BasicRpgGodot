extends CharacterBody3D
@onready var input_component: BasicRpgInputComponent = $BasicRpgInputComponent
@onready var movement_component: BasicRpgMovementStateMachine = $BasicRpgMovementStateMachine
@onready var hud: Control = $BasicRpgTestHud



const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _ready() -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	movement_component.state_changed.connect(_on_state_changed)

func _physics_process(delta: float) -> void:
	
	if input_component.is_test_just_pressed:
		movement_component.wants_to_dash = true
	else:
		movement_component.wants_to_dash = false
	
	if input_component.is_jump_pressed:
		movement_component.wants_to_jump = true
	else:
		movement_component.wants_to_jump = false
		
	if input_component.is_sprint_pressed:
		movement_component.wants_to_sprint = true
	else:
		movement_component.wants_to_sprint = false
	
	movement_component.movement_direction = input_component.movement_direction
	movement_component.look_direction = input_component.look_vector
	
	
	
	
	
	
	
	
	
	
	
	
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("Jump") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir := Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackwards")
	#var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
	
func _on_state_changed(new_state):
	hud.update_state_label(new_state)
	pass
