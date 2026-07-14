# Copyright 2026 Joshuah Skyseed, all rights reserved  

@abstract
class_name BasicRpgMovementState extends RefCounted

var state_machine: BasicRpgMovementStateMachine = null
var body: CharacterBody3D = null
var camera: Camera3D = null

signal transitioned(From: BasicRpgMovementStateMachine.States, To: BasicRpgMovementStateMachine.States)

# -----------------------------------------------------------------------------
@abstract
func enter()

@abstract
func exit()

@abstract
func update(delta: float)

@abstract
func physics_update(delta: float)
	
