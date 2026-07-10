extends CharacterBody3D

@onready var input_component: BasicRpgInputComponent = $BasicRpgInputComponent
@onready var movement_component: BasicRpgMovementComponent = $BasicRpgMovementComponent
	
func _ready() -> void:
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass
	
func _process(delta: float) -> void:
	

	if input_component.is_test_just_pressed:
		movement_component.wants_to_dash = true
	
	if input_component.is_jump_pressed:
		movement_component.wants_to_jump = true
		
	if input_component.is_sprint_pressed:
		movement_component.wants_to_sprint = true
	else:
		movement_component.wants_to_sprint = false
	
	movement_component.movement_direction = input_component.move_direction
	movement_component.look(input_component.look_vector.y, input_component.look_vector.x )
