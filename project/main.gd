extends Node

var pg_scene = preload("res://test_pg.tscn")
var pg_node = null
var bus = null
var last_bus_idx = 0

var in_minigame = false

func _ready() -> void:
  bus = EventBus.construct_bus("test_pg")

  pg_node = pg_scene.instantiate()
  pg_node.get_main_eventbus("test_pg")
  get_tree().get_current_scene().add_child(pg_node)

func _process(_delta: float) -> void:
  if in_minigame:
    if Input.is_key_pressed(Key.KEY_ENTER):
      prints("MINIGAME OVER")
      set_pause_state(pg_node, false)
      in_minigame = false
  else:
    var messages = bus.poll(last_bus_idx)
    if len(messages) > 0:
      if messages[0]['action'] in ['start_minigame', 'start_battle_minigame']:
        prints("STARTING MINIGAME - PRESS ENTER TO SAY WHEN IT'S OVER")
        set_pause_state(pg_node, true)
        in_minigame = true
    last_bus_idx += len(messages)

func set_pause_state(node: Node, state: bool) -> void:
  node.set_process(!state)
  node.set_process_input(!state)
  node.set_process_internal(!state)
  node.set_process_unhandled_input(!state)
  node.set_process_unhandled_key_input(!state)
