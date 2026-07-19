# SPDX-License-Identifier: AGPL-3.0-or-later
class_name MainManager
extends Node

@onready var party_game_manager: PartyGameManager = $PartyGameManager
@onready var minigame_manager: MinigameManager = $MinigameManager

func _on_start_minigame() -> void:
  party_game_manager.process_mode = Node.PROCESS_MODE_DISABLED
  minigame_manager.load_minigame()

func _on_minigame_finished() -> void:
  party_game_manager.process_mode = Node.PROCESS_MODE_INHERIT
  party_game_manager.resume_party_game()

func _ready() -> void:
  party_game_manager.start_minigame.connect(_on_start_minigame)
  minigame_manager.minigame_finished.connect(_on_minigame_finished)
  party_game_manager.load_party_game()
