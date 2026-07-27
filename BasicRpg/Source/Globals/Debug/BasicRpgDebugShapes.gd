extends Node3D


## An array of 8 red spheres. 
@onready var red_spheres: Array[MeshInstance3D]

## can have values between 0 and 7, indicating the indices of the *red spheres* array.
## The "place a red sphere" function will place the state's index of the *red spheres* array to the given point
## and advances the state.
var red_spheres_state = 0

@onready var sphere_red: MeshInstance3D


# --------------------------------------------------------

## An array of 8 green spheres. 
@onready var green_spheres: Array[MeshInstance3D]

## can have values between 0 and 7, indicating the indices of the *green spheres* array.
## The "place a green sphere" function will place the state's index of the *green spheres* array to the given point
## and advances the state.
var green_spheres_state = 0

@onready var sphere_green: MeshInstance3D

# ---------------------------------------------------------

## An array of 8 blue spheres. 
@onready var blue_spheres: Array[MeshInstance3D]

## can have values between 0 and 7, indicating the indices of the *blue spheres* array.
## The "place a blue sphere" function will place the state's index of the *blue spheres* array to the given point
## and advances the state.
var blue_spheres_state = 0

@onready var sphere_blue: MeshInstance3D

# -----------------------------------------------------------------------------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


## Places the single red sphere, not from the array.
## If you want to place one from the array, use *place A red sphere"
func place_the_red_sphere(point: Vector3):
	
	sphere_red.global_position = point
	sphere_red.visible = true
	
	pass


## Places a red sphere from the array of the red spheres. There are only 8 red spheres!
## If you want to place the single red sphere, use *place THE red sphere*
func place_a_red_sphere(point: Vector3):
	
	red_spheres[red_spheres_state].global_position = point
	
	red_spheres[red_spheres_state].visible = true
	
	red_spheres_state += 1
	if red_spheres_state > 7:
		red_spheres_state = 0
	
	if red_spheres_state < 0:
		red_spheres_state = 0
	
	pass





func debug_initialize_shape(size: float, colour: Color) -> MeshInstance3D:
	
	var mesh_instance = MeshInstance3D.new()
	
	var debug_sphere_0 := SphereMesh.new()
	
	var debug_material := StandardMaterial3D.new()
	debug_material.albedo_color = colour
	
	mesh_instance.mesh = debug_sphere_0
	mesh_instance.material_override = debug_material
	
	add_child(mesh_instance)
	mesh_instance.top_level = true
	mesh_instance.scale = Vector3(size, size, size)
	
	return mesh_instance
	
func debug_initialize_debug_shapes():
	
	sphere_red = debug_initialize_shape(0.15, Color.RED)
	sphere_blue = debug_initialize_shape(0.15, Color.BLUE)
	
	var star_color = Color.CHARTREUSE
	
