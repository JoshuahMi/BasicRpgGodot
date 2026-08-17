class_name BasicRpgLedgeRepresentator extends Node3D

## A class for representing the point that is detected by the ledge detector.


var point: Vector3 = Vector3.ZERO


## making sure the ledge indicator in the HUD hides properly when the detected point isn't on screen.
var is_on_screen_notifier: VisibleOnScreenNotifier3D = VisibleOnScreenNotifier3D.new()

var is_on_screen: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	add_child(is_on_screen_notifier)
	
	top_level = true
	
	is_on_screen_notifier.top_level = false
	
	is_on_screen_notifier.global_scale(Vector3(0.1, 0.1, 0.1))
	is_on_screen_notifier.screen_entered.connect(_on_screen_entered)
	is_on_screen_notifier.screen_exited.connect(_on_screen_exited)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func set_point(new_position: Vector3):
	
	point = new_position
	
	global_position = point
	
	#is_on_screen_notifier.global_position = point
	
func _on_screen_entered():
	#print("From Ledge Representator: Screen entered!")
	is_on_screen = true
	
func _on_screen_exited():
	#print("From Ledge Representator: Screen exited...")
	is_on_screen = false
	
