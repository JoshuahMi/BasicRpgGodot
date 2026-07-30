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
	
	initialize_debug_shapes()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


## Places the single red sphere, not from the array.
## If you want to place one from the array, use *place A red sphere"
func place_the_red_sphere(point: Vector3):
	
	sphere_red.global_position = point
	sphere_red.visible = true
	
	pass

func hide_the_red_sphere():
	sphere_red.visible = false
	pass



func place_the_green_sphere(point: Vector3):
	
	sphere_green.global_position = point
	sphere_green.visible = true
	
	pass
	
func hide_the_green_sphere():
	sphere_green.visible = false
	pass
	
func place_the_blue_sphere(point: Vector3):
	
	sphere_blue.global_position = point
	sphere_blue.visible = true
	
	pass
	
func hide_the_blue_sphere():
	sphere_blue.visible = false
	pass

## Places a red sphere from the array of the red spheres. There are only 8 red spheres!
## If you want to place the single red sphere, use *place THE red sphere*
func place_a_red_sphere(point: Vector3):
	
	# BUG: Invalid access of index '0' on a base object of type 'Array[MeshInstance3D]'
	red_spheres[red_spheres_state].global_position = point
	
	red_spheres[red_spheres_state].visible = true
	
	red_spheres_state += 1
	if red_spheres_state > 7:
		red_spheres_state = 0
	
	if red_spheres_state < 0:
		red_spheres_state = 0
	
	pass

func hide_red_spheres():
	
	for sphere in red_spheres:
		sphere.visible = false
	
	pass

func place_a_green_sphere(point: Vector3):
	
	green_spheres[green_spheres_state].global_position = point
	
	green_spheres[green_spheres_state].visible = true
	
	green_spheres_state += 1
	if green_spheres_state > 7:
		green_spheres_state = 0
	
	if green_spheres_state < 0:
		green_spheres_state = 0
	
	pass

func hide_green_spheres():
	
	for sphere in green_spheres:
		sphere.visible = false
	
	pass


func place_a_blue_sphere(point: Vector3):
	
	blue_spheres[blue_spheres_state].global_position = point
	
	blue_spheres[blue_spheres_state].visible = true
	
	blue_spheres_state += 1
	if blue_spheres_state > 7:
		blue_spheres_state = 0
	
	if blue_spheres_state < 0:
		blue_spheres_state = 0
	
	pass

func hide_blue_spheres():
	
	for sphere in blue_spheres:
		sphere.visible = false
	
	pass


func initialize_shape(size: float, colour: Color) -> MeshInstance3D:
	
	var mesh_instance = MeshInstance3D.new()
	
	var debug_sphere_0 := SphereMesh.new()
	
	var debug_material := StandardMaterial3D.new()
	debug_material.albedo_color = colour
	
	mesh_instance.mesh = debug_sphere_0
	mesh_instance.material_override = debug_material
	
	add_child(mesh_instance)
	mesh_instance.top_level = true
	mesh_instance.scale = Vector3(size, size, size)
	
	mesh_instance.visible = false
	
	return mesh_instance
	
func initialize_debug_shapes():
	
	sphere_red = initialize_shape(0.15, Color.RED)
	sphere_green = initialize_shape(0.15, Color.GREEN)
	sphere_blue = initialize_shape(0.15, Color.BLUE)
	
	for index in range(0, 8):
		
		red_spheres.append(initialize_shape(0.1, Color.RED))
		green_spheres.append(initialize_shape(0.1, Color.GREEN))
		blue_spheres.append(initialize_shape(0.1, Color.BLUE))
		
		pass
	
	
	
	var _star_color = Color.CHARTREUSE
	
	
	
	
func hide_all():
	
	hide_blue_spheres()
	hide_green_spheres()
	hide_red_spheres()
	
	hide_the_blue_sphere()
	hide_the_green_sphere()
	hide_the_red_sphere()
	
	
	
	
	
	
	
	
