class_name BasicRpgReserveSlim extends RefCounted

## UNTESTED - A basic reserve class, for storing a maximum value and a current value.

var max_value: int = 100
var current_value: int = 100

signal values_changed(new_current_value: int, new_max_value: int)
signal value_at_maximum()
signal value_depleted()

## Will set both stored values. Will first clamp the new max value above 1, then clamp 
## the new current value between 0 and new max value. 
## Will emit the value depleted signal if the new current value is zero after clamping.
func set_values(new_current_value: int, new_max_value: int):
	new_max_value = _clamp_max_value(new_max_value)
	max_value = new_max_value
	
	new_current_value = _clamp_current_value(new_current_value)
	current_value = new_current_value
	
	_emit_signals()
	
## Will set the currently stored value. Will first clamp the incoming 
## new value between 0 and the maximum value, then assign it and emit the value 
## changed signal, and, if the new current value is zero, emit the depleted signal.
## Won't emit any signals if the new current value is equal to the current stored value.
func set_current_value(new_current_value: int):
	
	
	new_current_value = _clamp_current_value(new_current_value)
	if new_current_value == current_value:
		return
	current_value = new_current_value
	
	_emit_signals()
	
## Will set the maximum value. Will first clamp the incoming new value above 1,
## then assign it and clamp the currently stored value between 0 and the new maximum value.
## Lastly it will emit the value changed signal.
## Won't emit any signals if the new max value is equal to the current max value.
func set_max_value(new_max_value: int):
	
	
	new_max_value = _clamp_max_value(new_max_value)
	if max_value == new_max_value:
		return
	max_value = new_max_value
	current_value = _clamp_current_value(current_value)
	
	_emit_value_changed()
	
## Will set the maximum value and keep the fill percentage, that means if the
## current value was 25% of the maximum value before setting the maximum value
## by using this function, it will be 25% of the maximum value afterwards as well.
## This function will make sure the current value will not go below 1 point IF it was 
## a number above 0 when calling this function.
## Won't emit any signals if the new max value is equal to the current max value.
func set_max_value_keep_percentage(new_max_value: int):
	
	new_max_value = _clamp_max_value(new_max_value)
	if max_value == new_max_value:
		return
	var fracture = _get_fill_percentage()
	max_value = new_max_value
	
	if current_value != 0:
		current_value = max_value * fracture
		if current_value == 0:
			current_value = 1
			
			
	_emit_value_changed()
	

## Reduces the currently stored value by the given amount. Will not go below zero.
## Note that it is not possible to increase the stored value with this function, using negative numbers. 
## The function will simply return if the given amount is below 1, and it won't emit emit any signals.
## If you want to achieve this effect, use the change value function instead.
## Won't emit any signals if the currently stored value already is at 0.
func damage(amount: int):
	
	if amount < 1 or current_value == 0:
		return
	
	current_value -= amount
	
	current_value = _clamp_current_value(current_value)
	
	_emit_signals()


## Increases the currently stored value by the given amount. Will not go above the 
## maximum value. 
## Note that it is not possible to reduce the value using this function by using
## negative numbers. It will simmply return if the given amount is below 1, and it won't emit emit any signals.
## If you want to achieve this effect, use the change value function instead.
## Won't emit any signals if the currently stored value already is at maximum.
func heal(amount: int):
	
	if amount < 1 or current_value == max_value:
		return
	
	current_value += amount
	
	current_value = _clamp_current_value(current_value)
	
	_emit_signals()
	
	
## Increases the currently stored value by the given amount. Will not go above the 
## maximum value. Reduces it if you use negative numbers instead of positive.
## Note that if you enter a 0 as argument, it will do nothing and won't emit any signals.
## Also this function won't emit signals if the argument wouldn't change the current value because it's already 
## at maximum (in case of a positive argument) or at zero (in case of a negative argument)
func change_value(amount: int):
	
	if amount == 0:
		return
	
	if amount > 0 and current_value == max_value:
		return
	
	if amount < 0 and current_value == 0:
		return
	
	
	current_value += amount
	
	current_value = _clamp_current_value(current_value)
	
	_emit_signals()
	
	

## Increases the maximum value by the given amount. Will keep the fill percentage, that means if the
## current value was 25% of the maximum value before setting the maximum value
## by using this function, it will be 25% of the maximum value afterwards as well.
## This function will make sure the current value will not go below 1 point IF it was 
## a number above 0 when calling this function.
## Won't do anything and won't emit signals if the given argument is below 1.
func bloat(amount: int):
	
	if amount < 1:
		return
	
	var new_max_value = max_value + amount
	
	var fracture = _get_fill_percentage()
	
	max_value = new_max_value
	
	if current_value != 0:
		current_value = max_value * fracture
		if current_value == 0:
			current_value = 1
			
	_emit_value_changed()
	

	
## Reduces the maximum value by the given amount. Will keep the fill percentage, that means if the
## current value was 25% of the maximum value before setting the maximum value
## by using this function, it will be 25% of the maximum value afterwards as well.
## This function will make sure the current value will not go below 1 point IF it was 
## a number above 0 when calling this function.
## Won't do anything and won't emit signals if the given argument is below 1.
func shrink(amount: int):
	
	if amount > 1 or max_value == 1:
		return
		
	var new_max_value = max_value - amount
	
	new_max_value = _clamp_max_value(new_max_value)
	
	var fracture = _get_fill_percentage()
	
	max_value = new_max_value
	
	if current_value != 0:
		current_value = max_value * fracture
		if current_value == 0:
			current_value = 1
			
	_emit_value_changed()
	
	
#region INTERNAL

func _get_fill_percentage() -> float:
	
	var max_value_as_float: float = max_value
	var current_value_as_float: float = current_value
	
	var percentage: float = current_value_as_float / max_value_as_float
	
	return percentage

func _clamp_max_value(new_max_value: int) -> int:
	
	if new_max_value < 1:
		new_max_value = 1
		
	return new_max_value

func _clamp_current_value(new_current_value: int) -> int:
	
	if new_current_value < 0:
		new_current_value = 0
	elif new_current_value > max_value:
		new_current_value = max_value
		
	return new_current_value

func _emit_value_changed():
	values_changed.emit(current_value, max_value)

func _emit_value_at_max():
	
	if current_value == max_value:
		value_at_maximum.emit()

func _emit_value_depleted():
	if current_value == 0:
		value_depleted.emit()

func _emit_signals():
	values_changed.emit(current_value, max_value)
	
	if current_value == 0:
		value_depleted.emit()
		
	if current_value == max_value:
		value_at_maximum.emit()
	
#endregion INTERNAL
