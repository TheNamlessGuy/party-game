# SPDX-License-Identifier: AGPL-3.0-or-later
class_name ColorFader
extends ColorRect

@export var fade_time = 0.75
signal faded_out
signal faded_in

func fade_out() -> void:
  await _perform_fade(1, fade_time)
  faded_out.emit()

func fade_in() -> void:
  await _perform_fade(0, fade_time)
  faded_in.emit()

func _perform_fade(target, time) -> void:
  var tween = get_tree().create_tween()
  await tween.tween_property(self, "modulate:a", target, time).finished
