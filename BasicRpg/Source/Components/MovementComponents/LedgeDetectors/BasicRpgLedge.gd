class_name BasicRpgLedge extends RefCounted

## A representation of a ledge the grappling hook can hang onto.
## Represented by two hit results, the one under the ledge and the one above it.
## Can further approximate itself 

## If this is a valid ledge
var valid: bool

## The hit result UNDER the ledge. Can't be invalid
var under: BasicRpgHitResult:
	set(new_value):
		under = new_value
		# If the hit result under the ledge is invalid, obviously there can't be a ledge
		if new_value.valid  == false:
			valid = false

## The hit result ABOVE the ledge. Can be invalid.
var above: BasicRpgHitResult

## How small the y window is in which this ledge was approximated
var y_tolerance
