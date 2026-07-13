extends Node

## A class for being an Autoload. The global timer host for everything 
## cyclic. The magic tick comes from here, as well as fast regeneration timers
## for Reserves. 

# has a very fast timer:
# 0.1 seconds

# Has three fast timers:
# - 0.333 seconds
# - 0.25 seconds
# - 0.2 seconds

# three medium fast timers:
# - 0.5 seconds -> From this timer comes the Magic tick.
# - 0.75 seconds
# - 0.6 seconds

# four slow timers:
# - 1 second
# - 2 seconds
# - 3 seconds
# - 5 seconds

# three very slow timers:
# - 10 seconds
# - 20 seconds
# - 30 seconds


# Will have a random value slightly offsetting every timer after a very long period of time.
# So we need a timer for the periodical offsetting.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
