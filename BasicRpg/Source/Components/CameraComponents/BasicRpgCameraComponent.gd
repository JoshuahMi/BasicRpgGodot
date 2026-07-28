class_name BasicRpgCameraComponent extends Node3D


var camera: Camera3D = Camera3D.new()
var perception_point: Node3D = Node3D.new()

@export var perception_length: float = 100.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	_initialize_children()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _initialize_children():
	
	add_child(camera)
	camera.current = true
	
	
	add_child(perception_point)
	perception_point.position = Vector3(0.0, 0.0, perception_length)
