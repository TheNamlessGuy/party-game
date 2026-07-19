# SPDX-License-Identifier: AGPL-3.0-or-later
class_name BaseMinigame
extends Node

signal minigame_finished

var _started = false
var _finished = false

func setup() -> void:
  pass

func start() -> void:
  _started = true
