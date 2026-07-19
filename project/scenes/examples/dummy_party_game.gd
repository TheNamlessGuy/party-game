# SPDX-License-Identifier: AGPL-3.0-or-later
extends BasePartyGame

var next_mg: float = 0.0
var active: bool = false

func resume() -> void:
  next_mg = Time.get_ticks_msec() + 1400
  active = true

func start() -> void:
  resume()

func _process(delta: float) -> void:
  if active and Time.get_ticks_msec() > next_mg:
    active = false
    start_minigame.emit()
