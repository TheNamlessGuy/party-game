extends Node

var _buses: Dictionary[String, Bus] = {}

func construct_bus(key: String) -> Bus:
  if key in _buses:
    # Global.fatal_error(["Bus with key '", key, "' already exists"]) # TODO: Discuss
    return

  _buses[key] = Bus.new()
  return _buses[key]

func get_bus(key: String) -> Bus:
  if key not in _buses:
    # Global.fatal_error(["Bus with key '", key, "' doesn't exist"]) # TODO: Discuss
    return null

  return _buses[key]

func destruct_bus(key: String) -> void:
  if key not in _buses:
    # Global.fatal_error(["Bus with key '", key, "' doesn't exist"]) # TODO: Discuss
    return

  _buses.erase(key)

class Bus:
  var _messages := []

  func send(msg) -> void:
    _messages.push_back(msg)

  func poll(last_read_idx: int) -> Array:
    return _messages.slice(last_read_idx)
