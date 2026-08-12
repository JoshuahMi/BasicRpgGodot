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
	
	if under == null or above == null:
		return
	
	if not under.valid:
		
		#print("From Ledge: Under was invalid!")
		
		validity = Validity.INVALID
		valid = false
		return
	
	
	
	if not above.valid:
		
		# If we look at it too strong from the side, it's invalid.
		# COMMENTED OUT
		
		if not above.valid:
			if Math.equal_float(under.normal.dot(under.original_ray_direction.normalized()), 0.0, 0.3):
				
				#print("From Ledge: Invalid because dot product is zero!")
				validity = Validity.INVALID
				valid = false
				return
		
		else:
			if Math.equal_float(under.normal.dot(under.original_ray_direction.normalized()), 0.0, 0.3) and Math.equal_float(above.normal.dot(above.original_ray_direction.normalized()), 0.0, 0.3):
				#print("From Ledge: Invalid because dot product is zero!")
				validity = Validity.INVALID
				valid = false
				return
		
		
		
		if under.normal.y > 0.1:
			#print("From Ledge: Under is pointing upwards! ")
			validity = Validity.INVALID
			valid = false
			return
		else:
			validity = Validity.VALID
			valid = true
			return
			
		
	# If we hit something with both:	
	else:
		
		if under.normal.y < 0.1:
			
			if above.normal.y < 0.01:
				validity = Validity.VALID
				valid = true
				return
		
		
		
		
		pass
	
	
	#print("From Ledge: None of the cases were true!")
	validity = Validity.INVALID
	valid = false
	return
	


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
		
		
		
