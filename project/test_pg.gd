extends Node3D

var tiles: Array[MeshInstance3D] = []

var current_player_idx: int = -1
var player_nodes: Array[MeshInstance3D] = []
var current_player_tile: Array[int] = []
var player_currency_major: Array[int] = []
var player_currency_minor: Array[int] = []

var current_turn_state = 0
enum TurnStates {
  START_OF_TURN,
  ROLL_DICE,
  MOVE,
  BATTLE_CHECK,
  MINIGAME_CHECK,
  END_OF_TURN,
}

var remaining_step_count = 0
var step_timer = 0

var main_bus = null

func get_main_eventbus(bus: String) -> void:
  main_bus = EventBus.get_bus(bus)

func _ready() -> void:
  tiles.push_back($PlusTile)
  tiles.push_back($MinusTile)
  tiles.push_back($PlusTile2)
  tiles.push_back($MinusTile2)

  for node in [$Player1, $Player2, $Player3]:
    player_nodes.push_back(node)
    current_player_tile.push_back(-1)
    player_currency_major.push_back(0)
    player_currency_minor.push_back(0)

  current_player_idx = 0
  current_turn_state = TurnStates.START_OF_TURN

func _process(delta: float) -> void:
  if current_turn_state == TurnStates.START_OF_TURN:
    prints("Player", current_player_idx + 1, "start! Press Enter to roll dice")
    current_turn_state = TurnStates.ROLL_DICE
  if current_turn_state == TurnStates.ROLL_DICE:
    _state_roll_dice()
  elif current_turn_state == TurnStates.MOVE:
    _state_move(delta)
  elif current_turn_state == TurnStates.BATTLE_CHECK:
    _state_battle_check()
  elif current_turn_state == TurnStates.MINIGAME_CHECK:
    _state_minigame_check()
  elif current_turn_state == TurnStates.END_OF_TURN:
    _state_end_of_turn()

func _state_roll_dice() -> void:
    if Input.is_key_pressed(Key.KEY_ENTER):
      remaining_step_count = (randi() % 9) + 1
      prints("Rolled", remaining_step_count)
      current_turn_state = TurnStates.MOVE

func _state_move(delta: float) -> void:
    if step_timer > 0:
      # Playing moving to tile animation
      step_timer -= delta
    elif remaining_step_count == 0:
      # Landed on tile
      var tile = tiles[current_player_tile[current_player_idx]]
      player_currency_minor[current_player_idx] += 1 if tile in [$PlusTile, $PlusTile2] else -1
      prints("Player", current_player_idx + 1, "minor currency changed to", player_currency_minor[current_player_idx])
      current_turn_state = TurnStates.BATTLE_CHECK
    else:
      # Move to the next tile
      remaining_step_count -= 1
      step_timer = 0.5
      prints("Remaining steps", remaining_step_count)

      current_player_tile[current_player_idx] = (current_player_tile[current_player_idx] + 1) % len(tiles)
      player_nodes[current_player_idx].position.x = tiles[current_player_tile[current_player_idx]].position.x
      player_nodes[current_player_idx].position.z = tiles[current_player_tile[current_player_idx]].position.z

func _state_battle_check() -> void:
  current_turn_state = TurnStates.MINIGAME_CHECK # Set this here so it is this state when we get back from the battle game
  var battle_between := []
  for other_player_idx in range(len(player_nodes)):
    if current_player_idx == other_player_idx:
      battle_between.push_back(other_player_idx)
      continue

    if current_player_tile[current_player_idx] == current_player_tile[other_player_idx]:
      battle_between.push_back(other_player_idx)

  if len(battle_between) > 1:
    var tmp := ""
    for idx in battle_between:
      if len(tmp) > 0: tmp += ", "
      tmp += str(idx)
    prints("Time for battle minigame between players", tmp)
    main_bus.send({'action': 'start_battle_minigame'})

func _state_minigame_check() -> void:
  current_turn_state = TurnStates.END_OF_TURN # Set this here so it is this state when we get back from the minigame
  if current_player_idx == len(player_nodes) - 1:
    prints("Time for minigame")
    main_bus.send({'action': 'start_minigame'})

func _state_end_of_turn() -> void:
  current_player_idx = (current_player_idx + 1) % len(player_nodes)
  current_turn_state = TurnStates.START_OF_TURN
