class_name BasicRpgGeneral extends Node

## We can distinguish two groups of states: the ones on the floor and the ones in the air.
enum PlayerMovementStates {
	
	ON_FLOOR_IDLE,					# IDLE means that the player is on the floor and the movement direction is at zero
	ON_FLOOR_MOVEMENT_NORMAL,		# This means that the player is on the floor and the movement direction is not zero
	ON_FLOOR_MOVEMENT_SPRINTING,		# this means that the player is on the floor, the movement direction is not zero and sprinting is true
	IN_AIR_FROM_JUMP,		# this means that the player is NOT on the floor and he jumped beforehand
	IN_AIR_FROM_KNOCKBACK,	# this means that the player is NOT on the floor and he got in the air from knockback
	IN_AIR_FROM_FALLING,	# this means that the player is NOT on the floor and he got in the air from falling
	
	DASH,					# This is for the dash.
	
	ON_WALL_LADDER,			# While on a ladder.
	ON_WALL_NORMAL,			# Walljump / wallrun
	ON_WALL_LEDGE_GRAB,		# When ledge grabbing
	
	UNDERWATER_IDLE,		# When the player is underwater but does nothing
	UNDERWATER_NORMAL,		# when the player is underwater and moves without sprinting
	UNDERWATER_SPRINTING,	# when the player is underwater and sprints
	
	
	
	
}

## The Movement Position. Used to tell if the player is in the air from different causes.
## Used in the Movement component internally
enum MovementPosition {
	
	MP_ON_SURFACE,
	MP_IN_AIR_FROM_KNOCKBACK,
	MP_IN_AIR_FROM_JUMP,
	MP_IN_AIR_FROM_FALLING,
	
}

## Used inside the MovementComponent to determine the state. The determine_state function there needs the information 
## about what exactly has changed to respond accordingly.
enum CharacterMovementEvent {
	
	NOTHING,				# For the rare situation the function gets called and nothing happened.
	
	ME_NORMAL_MOVEMENT_POSSIBLE_CHANGED,
	ME_MOVEMENT_POSITION_CHANGED,
	
	ME_HAS_JUST_LANDED,
	ME_HAS_JUST_LEFT_GROUND,
	
}
