# SPDX-License-Identifier: AGPL-3.0-or-later
extends BaseMinigame

@export var timeout : float = 2.0
@onready var countdown_label = $CountdownLabel

func setup() -> void:
  pass

func start() -> void:
  super()
  countdown_label.visible = true;

func _process(delta: float) -> void:
  if(!_started || _finished):
    return

  timeout -= delta
  countdown_label.text = str(abs(timeout)).pad_decimals(1)

  if(timeout <= 0):
    countdown_label.visible = false
    _finished = true
    minigame_finished.emit()
