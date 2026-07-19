# SPDX-License-Identifier: AGPL-3.0-or-later
class_name PartyGameManager
extends Node

@onready var color_fader: ColorFader = $"../ColorFader"

signal start_minigame

var scene : PackedScene
var party_game_instance : BasePartyGame

func load_party_game() -> void:
  scene = load("res://scenes/examples/dummy_party_game.tscn")
  party_game_instance = scene.instantiate()
  party_game_instance.start_minigame.connect(_on_start_minigame)
  add_child(party_game_instance)
  _on_party_game_loaded()

func _on_party_game_loaded() -> void:
  color_fader.faded_in.connect(_on_party_game_loaded_faded_in)
  color_fader.fade_in()

func _on_party_game_loaded_faded_in() -> void:
  color_fader.faded_in.disconnect(_on_party_game_loaded_faded_in)
  party_game_instance.start()

func resume_party_game() -> void:
  color_fader.faded_in.connect(_on_resume_party_game_faded_in)
  color_fader.fade_in()

func _on_resume_party_game_faded_in() -> void:
  color_fader.faded_in.disconnect(_on_resume_party_game_faded_in)
  party_game_instance.resume()

func _on_start_minigame() -> void:
  color_fader.faded_out.connect(_on_start_minigame_faded_out)
  color_fader.fade_out()

func _on_start_minigame_faded_out() -> void:
  color_fader.faded_out.disconnect(_on_start_minigame_faded_out)
  start_minigame.emit()
