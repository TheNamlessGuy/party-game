class_name UnitTestBaseClass
extends Node

func atos(array: Array) -> String:
  var retval := ""
  for item in array:
    retval += str(item)
  return retval

func _get_message(message: Array, user_submitted_message: String) -> String:
  var traces = Engine.capture_script_backtraces()
  var trace = null
  for t in traces:
    if t.get_language_name() == 'GDScript':
      trace = t # We WILL get here
      break

  var idx = 0
  var current_file = trace.get_frame_file(0)
  while trace.get_frame_file(idx) == current_file:
    idx += 1

  var msg = atos([trace.get_frame_file(idx), ' :: ', trace.get_frame_function(idx), ' @ ', trace.get_frame_line(idx)])
  if len(user_submitted_message) > 0:
    msg += "\n" + user_submitted_message
  if len(message) > 0:
    msg += "\n" + atos(message)
  return msg

func assertTrue(condition: bool, message: String = "") -> void:
  assert(condition, _get_message(["Failed to assert that ", condition, " was ", true], message))

func assertFalse(condition: bool, message: String = "") -> void:
  assert(not condition, _get_message(["Failed to assert that ", condition, " was ", false], message))

func assertNull(value, message: String = "") -> void:
  assert(value == null, _get_message(["Failed to assert that ", value, " was null"], message))

func assertNotNull(value, message: String = "") -> void:
  assert(value != null, _get_message(["Failed to assert that ", value, " was not null"], message))

func assertEquals(value, expected, message: String = "") -> void:
  assert(value == expected, _get_message(["Failed to assert that ", value, " equals ", expected], message))

func assertNotEquals(value, expected, message: String = "") -> void:
  assert(value != expected, _get_message(["Failed to assert that ", value, " doesn't equal ", expected], message))
