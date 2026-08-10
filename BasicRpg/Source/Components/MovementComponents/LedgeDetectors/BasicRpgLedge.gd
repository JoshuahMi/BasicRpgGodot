class_name BasicRpgLedge extends RefCounted

## A representation of a ledge the grappling hook can hang onto.
## Represented by two hit results, the one under the ledge and the one above it.

enum Validity {
	
	INVALID,
	INSECURE,
	VALID
	
	
}

## If this is a valid ledge
var valid: bool = false

## If this is a valid ledge!
var validity: Validity = Validity.INVALID

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




## Returns validity of the ledge by checking its distance to interval ratio
## Only makes sense when the ledge is on an angular surface
func validate_by_distance_ratio() -> bool:

	if above.valid:
		if under.length > above.length:
			return false
	
	var distance_y_ratio = distance_xz_between() / y_tolerance
	
	#print(distance_y_ratio)
	
	if distance_y_ratio > 1.0:
		return true
	else:
		return false
		


## Checks if the "under" point has a normal that points either upwards or has no y, so is horizontal
## Then checks if the above is either invalid or the distance between the two points is, relative to the two normals, valid.
func validate():
	
	if not under.valid:
		valid = false
		return
	
	if not above.valid:
		
		#print("From Ledge: Above invalid, so under automatically valid!")
		
		valid = true
		return
	
	# If the normal is horizontal
	if Math.equal_float(under.normal.y, 0.0, 0.1):
		#print("From Ledge: normal horizontal!")
		if (under.position - above.position).length() > 0.1:
			
			
			valid = true
			return
			
	elif under.normal.y < 0.0:
		#print("From Ledge: Normal pointing downwards! ")
		valid = false
		return
	
	# Now here is the dificult part. If the normal of the ledge is pointing upwards, then it should point extremely upwards and the *above* position should be relatively far away.
	
	else:
		
		if under.normal.y > 0.5 and validate_by_distance_ratio():
			
			valid = true
			return
		else:
			valid = false
			return
		
	


func determine_validity():
	
	if not under.valid:
		validity = Validity.INVALID
		return
	
	
	
	if not above.valid:
		
		# If we look at it too strong from the side, it's invalid.
		
		if under.normal.dot(under.original_ray_direction) > -0.5:
			validity = Validity.INVALID
			return
		
		
		
		
		
		if under.normal.y > 0.1:
			
			validity = Validity.INVALID
			return
		else:
			validity = Validity.VALID
			return
			
		
	# If we hit something with both:	
	else:
		
		if under.normal.y < 0.1:
			
			if above.normal.y < 0.01:
				validity = Validity.VALID
				return
		
		
		
		
		pass
	
	
	
	validity = Validity.INVALID
	return
	
	
	
	
	
	
	
	
	
	
	
	# If we hit one time and it's normal points sideways, it's a legitimate ledge.
	if Math.equal_float(under.normal.y, 0.0, 0.01) and not above.valid:
		validity = Validity.VALID
		return
	
	# If we hit one time and the under normal is pointing upwards, it's invalid.
	elif under.normal.y > 0.3 and not above.valid:
		validity = Validity.INVALID
		return
	
	
	if under.valid and above.valid:
	
		# If both are pointing sideways, and the distance between both is larger than a specific threshold, then it's valid.
		if Math.equal_float(under.normal.y, 0.0, 0.01) and Math.equal_float(above.normal.y, 0.0, 0.01) and distance_xz_between() > 0.1:
			validity = Validity.VALID
			return
	
	## If we come from below and only hit one time
	if not above.valid and under.original_ray_direction.y > 0.0:

		validity = Validity.INVALID
		
	
	
	
	pass

func distance_xz_between() -> float:
	
	if above.valid: 
		
		var position_above: Vector3 = Vector3(above.position.x, 0.0, above.position.z)
		var position_under: Vector3 = Vector3(under.position.x, 0.0, under.position.z)
		
		return (position_under - position_above).length()
	else:
		return -1.0
	
	
func distance_between() -> float:
	if above.valid: 
		return (under.position - above.position).length()
	else:
		return -1.0
		
		
		
