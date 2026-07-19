# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node3D

@export var speed: float = -3.5

func _process(delta: float) -> void:
  rotate_y(speed * delta)
