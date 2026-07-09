class_name BasicRpgInputComponent extends Node

var look_vector: Vector2 = Vector2.ZERO
var move_direction: Vector2 = Vector2.ZERO:
	set(new_value):
		if move_direction.length_squared() > 0.01 and new_value.length_squared() < 0.01:
			has_just_stopped = true
		else:
			has_just_stopped = false
			
		if move_direction.length_squared() < 0.01 and new_value.length_squared() > 0.01:
			has_just_moved = true
		else:
			has_just_moved = false
			
		move_direction = new_value
		

var is_jump_pressed: bool = false
var is_sprint_pressed: bool = false
		
var is_sprint_just_pressed: bool = false

var is_sprint_just_released: bool = false

## if the player just went from staying still to moving, i.e. input from WASD just came from having no input at all
var has_just_moved: bool = false
		
## If the player just went from moving to stopping, so WASD-input isn't there. This variable is true the first frame where there's no WASD-input only.
var has_just_stopped: bool = false

var is_test_pressed: bool = false
var is_test_just_pressed: bool = false

func _input(event: InputEvent) -> void:
	
	# looking around
	if event is InputEventMouseMotion:
		look_vector = Vector2(event.relative.x, event.relative.y)
	else:
		look_vector = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# moving
	move_direction = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBackwards")
	
	
	if Input.is_action_just_pressed("Jump"):
		is_jump_pressed = true
	else:
		is_jump_pressed = false
	
	if Input.is_action_pressed("Sprint"):
		is_sprint_pressed = true
	else:
		is_sprint_pressed = false
		
		
	if Input.is_action_just_pressed("Sprint"):
		is_sprint_just_pressed = true
	else:
		is_sprint_just_pressed = false
		
		
	if Input.is_action_just_released("Sprint"):
		is_sprint_just_released = true
	else:
		is_sprint_just_released = false
		
		
	if Input.is_action_pressed("Test"):
		is_test_pressed = true

	if Input.is_action_just_pressed("Test"):
		is_test_just_pressed = true
	
	look_vector = Vector2.ZERO
	
	pass
	
func _physics_process(_delta: float) -> void:
	pass
