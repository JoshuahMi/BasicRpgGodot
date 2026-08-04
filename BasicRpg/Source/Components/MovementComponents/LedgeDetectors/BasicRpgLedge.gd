class_name BasicRpgLedge extends RefCounted

## A representation of a ledge the grappling hook can hang onto.
## Represented by two hit results, the one under the ledge and the one above it.
## Can further approximate itself 

## If this is a valid ledge
var valid: bool = false

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


## Checks if the "under" point has a normal that points either upwards or has no y, so is horizontal
## Then checks if the above is either invalid or the distance between the two points is, relative to the two normals, valid.
func validate():
	
	if not under.valid:
		valid = false
		return
	
	if not above.valid:
		
		print("From Ledge: Above invalid, so under automatically valid!")
		
		valid = true
		return
	
	
	
	
	
	# If the normal is horizontal
	if Math.equal_float(under.normal.y, 0.0, 0.01):
		print("From Ledge: normal horizontal!")
		if (under.position - above.position).length() > 0.1:
			
			
			
			
			valid = true
			return
			
	elif under.normal.y < 0.0:
		print("From Ledge: Normal pointing downwards! ")
		valid = false
		return
	
	# Now here is the dificult part. If the normal of the ledge is pointing upwards, then it should point extremely upwards and the *above* position should be relatively far away.
	
	else:
		
		if under.normal.y > 0.7 and distance_between() > 1.0:
			print("From Ledge: VALID with strongly up pointing normal")
			valid = true
			return
		else:
			valid = false
			return
		
	
func distance_between() -> float:
	if above.valid: 
		return (under.position - above.position).length()
	else:
		return 10.0	
		
		
		
