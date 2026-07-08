class_name UnitTestBaseClass
extends Node

func _array_to_string(array: Array) -> String:
  var retval := ""
  for item in array:
    retval += str(item)
  return retval

func _get_message(message: Array, user_submitted_message: String) -> String:
  return user_submitted_message + ("\n" if len(message) > 0 else "") + _array_to_string(message)

func assertTrue(condition: bool, message: String = "") -> void:
  assert(condition, _get_message(["Failed to assert that ", condition, " was ", true], message))

func assertFalse(condition: bool, message: String = "") -> void:
  assert(not condition, _get_message(["Failed to assert that ", condition, " was ", false], message))

func assertEquals(value, expected, message: String = "") -> void:
  assert(value == expected, _get_message(["Failed to assert that ", value, " equals ", expected], message))

func assertNotEquals(value, expected, message: String = "") -> void:
  assert(value != expected, _get_message(["Failed to assert that ", value, " doesn't equal ", expected], message))
