# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

class Example:
  var x = 0
  var y = 0

  func _init(new_x: int, new_y: int):
    x = new_x
    y = new_y

func _godot_api(obj: Example, value: int):
  var new_obj = Example.new(obj.y, value)
  return new_obj

func run_plugin(path: String):
  var _lua_state = LuaState.new()
  # GODOT_VARIANT allows types to be converted from GDScript to Lua automatically
  # when calling Lua functions. Also allows access to GDScript variant tupes in
  # Lua (as listed in https://docs.godotengine.org/en/stable/classes/class_variant.html).
  _lua_state.open_libraries(LuaState.Library.LUA_BASE | LuaState.Library.GODOT_VARIANT)
  _lua_state.globals["godot_api"] = _lua_state.create_function(_godot_api)
  _lua_state.do_file(path)
  var new_obj = _lua_state.globals["lua_api"].invoke(Example.new(10, 20))
  print("x: ", new_obj.x, ", y: ", new_obj.y)

# Usage example
func _ready() -> void:
  run_plugin("res://example_plugin.lua")
