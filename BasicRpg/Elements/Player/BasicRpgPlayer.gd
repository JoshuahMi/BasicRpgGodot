# Copyright 2026 Joshuah Skyseed, all rights reserved  

extends CharacterBody3D

@onready var input_component: BasicRpgInputComponent = $BasicRpgInputComponent
@onready var movement_component: BasicRpgMovementComponentNew = $BasicRpgMovementComponentNew

func _ready() -> void:
	
	var res = BasicRpgResistanceSlim.new()
	
	res.current_value = 200
	res.can_be_weakness = true
	res.can_heal = false
	print(res.get_multiplier())
	
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	pass
	
func _process(delta: float) -> void:
	
	#print(Engine.get_frames_per_second())

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
