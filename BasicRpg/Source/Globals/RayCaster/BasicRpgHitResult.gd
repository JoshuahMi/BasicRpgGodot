class_name BasicRpgHitResult extends RefCounted

## If the actual Hit result is valid, i.e. if the ray cast actually hit something
var valid: bool

## If valid, this represents the length of the ray cast that was cast, so the distance between the starting point and the hit point
var length: float

## Where the hit result is 
var position: Vector3

## The normal of the face that was hit by the ray
var normal: Vector3


# ---------- INFORMATION ABOUT THE ORIGINAL RAY ------------------

var original_ray_begin: Vector3
var original_ray_target: Vector3
var original_ray_direction: Vector3
var original_ray_length: float
