extends Node

# Note: This only exits on the next frame. Seems this is the best global exit Godot can do
func exit(exit_code: int) -> void:
  var tree := get_tree()
  tree.root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
  tree.quit(exit_code)

func fatal_error(msg: Array) -> void:
  OS.alert(array_to_string(msg), "Internal fatal error")
  exit(1)

func array_to_string(array: Array) -> String:
  var retval := ""
  for item in array:
    retval += str(item)
  return retval

func prints(msg: Array) -> void:
  prints(array_to_string(msg))
