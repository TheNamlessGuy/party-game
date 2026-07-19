# SPDX-License-Identifier: AGPL-3.0-or-later
class_name MinigameManager
extends Node

@onready var color_fader: ColorFader = $"../ColorFader"

signal minigame_finished

var scene : PackedScene
var minigame_instance : BaseMinigame

func load_minigame() -> void:
  # TODO: Add parameter that fetches minigame from some lookup store
  # hardcoded minigame scene load for now
  scene = load("res://scenes/test_minigame.tscn")
  minigame_instance = scene.instantiate()
  minigame_instance.minigame_finished.connect(_on_minigame_finished)
  add_child(minigame_instance)
  _on_minigame_loaded()

func _on_minigame_loaded() -> void:
  color_fader.faded_in.connect(_on_minigame_loaded_faded_in)
  color_fader.fade_in()

func _on_minigame_loaded_faded_in() -> void:
  color_fader.faded_in.disconnect(_on_minigame_loaded_faded_in)
  minigame_instance.start()

func _on_minigame_finished() -> void:
  color_fader.faded_out.connect(_on_minigame_finished_faded_out)
  color_fader.fade_out()

func _on_minigame_finished_faded_out() -> void:
  color_fader.faded_out.disconnect(_on_minigame_finished_faded_out)
  minigame_instance.queue_free()
  minigame_finished.emit()
