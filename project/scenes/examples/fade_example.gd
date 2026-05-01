# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

@onready var fader : ColorFader = $ColorFader

func _ready() -> void:
  fader.faded_in.connect(_on_faded_in)
  fader.faded_out.connect(_on_faded_out)
  fader.fade_out()

func _on_faded_out():
  fader.fade_in()

func _on_faded_in():
  fader.fade_out()
