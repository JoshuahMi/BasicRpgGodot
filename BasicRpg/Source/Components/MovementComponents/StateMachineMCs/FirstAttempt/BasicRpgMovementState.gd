@abstract
class_name BasicRpgMovementState extends Node

#region INPUT






#endregion INPUT




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
# -----------------------------------------------------------------------------
@abstract
func enter()

@abstract
func exit()

@abstract
func update()

@abstract
func move()

@abstract
func apply_gravity()
	
