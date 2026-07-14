extends Node

## A class for being an Autoload. The global timer host for everything 
## cyclic. The magic tick comes from here, as well as fast and slow regeneration timers
## for Reserves. 
## The times are a bit odd because I want to make sure that 2 timers don't fire 
## in the same frame

## Actually there should be functionality that prevents unconnected timer from running,
## and to let them start on demand.

# has a very fast timer:
# 0.1 seconds
var timer_very_fast: Timer = Timer.new()
var timer_very_fast_time: float = 0.1025:
	set(new_value):
		timer_very_fast_time = new_value
		timer_very_fast.wait_time = timer_very_fast_time
		timer_very_fast.start(timer_very_fast_time)

# Has three fast timers:

var timer_fast_0: Timer = Timer.new()
var timer_fast_0_time: float = 0.2551:
	set(new_value):
		timer_fast_0_time = new_value
		timer_fast_0.wait_time = timer_fast_0_time
		timer_fast_0.start(timer_fast_0_time)

var timer_fast_1: Timer = Timer.new()
var timer_fast_1_time: float = 0.25552:
	set(new_value):
		timer_fast_1_time = new_value
		timer_fast_1.wait_time = timer_fast_1_time
		timer_fast_1.start(timer_fast_1_time)

var timer_fast_2: Timer = Timer.new()
var timer_fast_2_time: float = 0.3335533:
	set(new_value):
		timer_fast_2_time = new_value
		timer_fast_2.wait_time = timer_fast_2_time
		timer_fast_2.start(timer_fast_2_time)

# three medium fast timers:
# - 0.5 seconds -> From this timer comes the Magic tick.
var timer_medium_0: Timer = Timer.new()
var timer_medium_0_time: float = 0.5005:
	set(new_value):
		timer_medium_0_time = new_value
		timer_medium_0.wait_time = timer_medium_0_time
		timer_medium_0.start(timer_medium_0_time)

var timer_medium_1: Timer = Timer.new()
var timer_medium_1_time: float = 0.6005:
	set(new_value):
		timer_medium_1_time = new_value
		timer_medium_1.wait_time = timer_medium_1_time
		timer_medium_1.start(timer_medium_1_time)

var timer_medium_2: Timer = Timer.new()
var timer_medium_2_time: float = 0.75005:
	set(new_value):
		timer_medium_2_time = new_value
		timer_medium_2.wait_time = timer_medium_2_time
		timer_medium_2.start(timer_medium_2_time)

# four slow timers:
# - 1 second
var timer_slow_0: Timer = Timer.new()
var timer_slow_0_time: float = 1.005:
	set(new_value):
		timer_slow_0_time = new_value
		timer_slow_0.wait_time = timer_slow_0_time
		timer_slow_0.start(timer_slow_0_time)
# - 2 seconds
var timer_slow_1: Timer = Timer.new()
var timer_slow_1_time: float = 2.005:
	set(new_value):
		timer_slow_1_time = new_value
		timer_slow_1.wait_time = timer_slow_1_time
		timer_slow_1.start(timer_slow_1_time)
# - 3 seconds
var timer_slow_2: Timer = Timer.new()
var timer_slow_2_time: float = 3.005:
	set(new_value):
		timer_slow_2_time = new_value
		timer_slow_2.wait_time = timer_slow_2_time
		timer_slow_2.start(timer_slow_2_time)
# - 5 seconds
var timer_slow_3: Timer = Timer.new()
var timer_slow_3_time: float = 5.005:
	set(new_value):
		timer_slow_3_time = new_value
		timer_slow_3.wait_time = timer_slow_3_time
		timer_slow_3.start(timer_slow_3_time)

# three very slow timers:
# - 10 seconds
var timer_very_slow_0: Timer = Timer.new()
var timer_very_slow_0_time: float = 10.005:
	set(new_value):
		timer_very_slow_0_time = new_value
		timer_very_slow_0.wait_time = timer_very_slow_0_time
		timer_very_slow_0.start(timer_very_slow_0_time)
# - 20 seconds
var timer_very_slow_1: Timer = Timer.new()
var timer_very_slow_1_time: float = 20.005:
	set(new_value):
		timer_very_slow_1_time = new_value
		timer_very_slow_1.wait_time = timer_very_slow_1_time
		timer_very_slow_1.start(timer_very_slow_1_time)
# - 30 seconds
var timer_very_slow_2: Timer = Timer.new()
var timer_very_slow_2_time: float = 30.005:
	set(new_value):
		timer_very_slow_2_time = new_value
		timer_very_slow_2.wait_time = timer_very_slow_2_time
		timer_very_slow_2.start(timer_very_slow_2_time)


# Will have a random value slightly offsetting every timer after a very long period of time.
# So we need a timer for the periodical offsetting.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# First add all timers as children. Then start them.
	
	add_child(timer_very_fast)
	timer_very_fast.wait_time = timer_very_fast_time
	timer_very_fast.start(timer_very_fast_time)
	
	add_child(timer_fast_0)
	timer_fast_0.wait_time = timer_fast_0_time
	timer_fast_0.start(timer_fast_0_time)
	add_child(timer_fast_1)
	timer_fast_1.wait_time = timer_fast_1_time
	timer_fast_1.start(timer_fast_1_time)
	add_child(timer_fast_2)
	timer_fast_2.wait_time = timer_fast_2_time
	timer_fast_2.start(timer_fast_2_time)
	
	add_child(timer_medium_0)
	timer_medium_0.wait_time = timer_medium_0_time
	timer_medium_0.start(timer_medium_0_time)
	add_child(timer_medium_1)
	timer_medium_1.wait_time = timer_medium_1_time
	timer_medium_1.start(timer_medium_1_time)
	add_child(timer_medium_2)
	timer_medium_2.wait_time = timer_medium_2_time
	timer_medium_2.start(timer_medium_2_time)
	
	add_child(timer_slow_0)
	timer_slow_0.wait_time = timer_slow_0_time
	timer_slow_0.start(timer_slow_0_time)
	add_child(timer_slow_1)
	timer_slow_1.wait_time = timer_slow_1_time
	timer_slow_1.start(timer_slow_1_time)
	add_child(timer_slow_2)
	timer_slow_2.wait_time = timer_slow_2_time
	timer_slow_2.start(timer_slow_2_time)
	add_child(timer_slow_3)
	timer_slow_3.wait_time = timer_slow_3_time
	timer_slow_3.start(timer_slow_3_time)
	
	add_child(timer_very_slow_0)
	timer_very_slow_0.wait_time = timer_very_slow_0_time
	timer_very_slow_0.start(timer_very_slow_0_time)
	add_child(timer_very_slow_1)
	timer_very_slow_1.wait_time = timer_very_slow_1_time
	timer_very_slow_1.start(timer_very_slow_1_time)
	add_child(timer_very_slow_2)
	timer_very_slow_2.wait_time = timer_very_slow_2_time
	timer_very_slow_2.start(timer_very_slow_2_time)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
