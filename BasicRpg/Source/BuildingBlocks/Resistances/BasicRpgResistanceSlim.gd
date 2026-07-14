class_name BasicRpgResistanceSlim extends RefCounted

## A class for implementing an elemental resistance.

## The value stored by the resistance. Using the functions, it cannot go higher than 200 (if can heal is true)
## and lower that -100 (if can be weakness is true).
var current_value: int = 0 

## If true, the value can be effectively higher than 100.
var can_heal: bool = true

## If true, the value can be effectively lower than 0.
var can_be_weakness: bool = true

## Returns the value as a damage multiplier, so 0.75 at 25, 0.0 at 100, -0.5 at 150, -1.0 at 200, IF *can heal* is true.
## If *can be weakness* is true, it doubles the damage when it's -100, and returns 1.5 when it's -50...
func get_multiplier() -> float:
	
	var current_value_clamped: int = 0
	
	if can_heal == true and can_be_weakness == true:
		
		current_value_clamped = clampi(current_value, -100, 200)
		
		pass
	elif can_heal == true and can_be_weakness == false:
		
		current_value_clamped = clampi(current_value, 0, 200)
		
		pass
	elif can_heal == false and can_be_weakness == true:
		
		current_value_clamped = clampi(current_value, -100, 100)
		
		pass
	else:
		current_value_clamped = clampi(current_value, 0, 100)
		
		pass
	
	
	var current_value_local: float = float(current_value_clamped) * 0.01
	var out: float
	
	if current_value < 100:
	
		out = 1.0 - current_value_local 
		
	elif current_value > 100:
		
		current_value_local -= 1.0
		
		out = current_value_local * -1.0
		
		pass
	
	# The last possibility is that current value is equal to 100.
	else:
		out = 0.0
	return out
