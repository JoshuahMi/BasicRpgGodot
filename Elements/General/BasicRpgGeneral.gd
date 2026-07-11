# Copyright 2026 Joshuah Skyseed, all rights reserved  

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

# -----------------------------------------------------------------------------------------------------------
# --------------------- PLANNING ----------------------------------------------------------------------------
# -----------------------------------------------------------------------------------------------------------

# PLACE STATE
# On ground		- when landing
# On Wall		- when touching a wall mid air -- jump charges get replenished in order to be able to perform a wall jump.
# in air		- when jumping, falling or getting knocked back
# underwater 	- when entering/exiting a water volume

# MOVEMENT STYLE STATE
# normal		- the usual.
# levitating	- when levitating using a spell
# gliding		- when using wings

# EFFORT STATE - is completely dependant on input and parameters, see below.
# Idle			- movement_direction.length() < 0.01
# regular		- movement_direction.length() == movement_speed
# sprinting		- movement_direction.length() == movement_speed * sprint_modifier
# dash			- movement_direction.length() > movement_speed * sprint_modifier

# in air -- normal -- idle: just falling
# in air -- normal -- regular: interpolated movement, depending on movement_strength_while_jumping
# in air -- normal -- sprinting: interpolated movement, depending on movement_strength_while_jumping + sprint_modifier
# in air --- normal -- dash: can't change direction anymore.

# The disadvantage of this is that in every frame the movement speed has to be determined in order to determine the effort state.
# isn't this a feedback loop? No, but:
# 				-> input movement_direction * movement speed * sprint + dash (somehow) -> movement vector gets calculated -> it determines the state -> the move() function moves the body accordingly. It can't be dependant on the state, because the state itself is dependant on the input and the parameters.

# ---------------------------------------------------------------------------------------------------------
# -------------------- Applying the concepts --------------------------------------------------------------
# ---------------------------------------------------------------------------------------------------------

enum MovementPlaceState {
	
# On Wall		- when touching a wall mid air -- jump charges get replenished in order to be able to perform a wall jump.
# in air		- when jumping, falling or getting knocked back
# underwater 	- when entering/exiting a water volume
	
	
	GROUND,			## On ground - when landing
	WALL,			## when touching a wall mid air -- jump charges get replenished in order to be able to perform a wall jump.
	AIR,			## when jumping, falling or getting knocked back
	SWIMMING,		## when inside a water volume, but the head (camera) is above the water surface
	UNDERWATER,		## when inside a water volume, but the head (camera) is under the water volume
	
}

enum MovementStyleState {

	NORMAL,			# the usual type of movement of a humanoid or animal
	LEVITATE,		# when levitating using a spell
	GLIDE,			# when using wings
	
}

enum MovementEffortState {

	IDLE,			# movement_direction.length() < 0.01
	REGULAR,		# movement_direction.length() == movement_speed
	SPRINT,			# movement_direction.length() == movement_speed * sprint_modifier
	DASH,			# movement_direction.length() > movement_speed * sprint_modifier
	
}
