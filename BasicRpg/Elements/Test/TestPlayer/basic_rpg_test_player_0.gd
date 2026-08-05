extends CharacterBody3D
@onready var input_component: BasicRpgInputComponent = $BasicRpgInputComponent
@onready var movement_component: BasicRpgMovementStateMachine = $BasicRpgMovementStateMachine
@onready var hud: Control = $BasicRpgTestHud
@onready var camera_component: BasicRpgCameraComponent = $BasicRpgCameraComponent
@onready var grappling_hook_edge_detector: BasicRpgGrapplingHookEdgeDetector = $BasicRpgGrapplingHookEdgeDetector

func _ready() -> void:
	
	hud.state_machine = movement_component
	hud.input_component = input_component
	hud.camera_component = camera_component
	hud.edge_detector = grappling_hook_edge_detector
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	movement_component.state_changed.connect(_on_state_changed)

func _physics_process(delta: float) -> void:
	
	if input_component.is_test_just_pressed:
		movement_component.wants_to_dash = true
	else:
		movement_component.wants_to_dash = false
	
	if input_component.jump_window:
		movement_component.wants_to_jump = true
	else:
		movement_component.wants_to_jump = false
		
	if input_component.is_sprint_pressed:
		movement_component.wants_to_sprint = true
	else:
		movement_component.wants_to_sprint = false
	
	if input_component.is_dash_just_pressed:
		movement_component.wants_to_dash = true
	else:
		movement_component.wants_to_dash = false
	
	movement_component.movement_direction = input_component.movement_direction
	movement_component.look_direction = input_component.look_vector
	
	hud.place_grappling_hook_edge_indicator(grappling_hook_edge_detector.detected_platform_point)
	
	
	
func _on_state_changed(_new_state):
	
	pass
