extends Node

## A class for being an Autoload. Holds a random number generator for everything 
## random.

var generator: RandomNumberGenerator = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	_initialize_rng()

	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass

## Will do a dice roll with a die with the given number of sides.
func roll(dice: int) -> int:
	
	var out: int = generator.randi_range(1, dice)
	return out


func _initialize_rng():
	
	generator.seed = Time.get_datetime_string_from_system().hash()
	pass
	
