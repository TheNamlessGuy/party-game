extends SceneTree

func _init() -> void:
  prints("INIT")
  _ready.call_deferred()
  # var args = _parse_args()
  # if args == null:
  #   _teardown(0)
  #   return

  # var err = _load_addons()
  # if err != null:
  #   prints("Couldn't load addons:", err)
  #   _teardown(1)
  #   return

  # err = _load_global_scripts()
  # if err != null:
  #   prints("Couldn't load global scripts:", err)
  #   _teardown(1)
  #   return

  # var tests = _get_tests(args)

  # for test in tests:
  #   var instance = test['loaded_class'].new()
  #   for testcase in test['cases']:
  #     prints("Running", test['class']['class'] + '::' + testcase['method']['name'])
  #     Callable(instance, testcase['method']['name']).call()

  # _teardown(0)

func _ready() -> void:
  prints("READY")
  prints('Global', root.has_node('Global'))
  prints('LuaState', ClassDB.class_exists('LuaState'))
  _teardown(0)

func _parse_args():
  var retval = {
    'dirs': [],
    'filters': [],
  }

  var args = OS.get_cmdline_user_args()
  var i = 0
  while i < len(args):
    if args[i] == '--dir':
      i += 1
      if i >= len(args):
        prints("Flag '--dir' given no parameter")
        return null
      retval['dirs'].push_back("res://" + args[i] + "/")
    elif args[i] == '--filter':
      i += 1
      if i >= len(args):
        prints("Flag '--filter' given no parameter")
        return null
      retval['filters'].push_back(args[i].split('::'))
    else:
      prints("Unknown argument '" + args[i] + "'")
      return null

    i += 1

  return retval

func _get_tests(args) -> Array:
  var retval = []

  var classes = ProjectSettings.get_global_class_list()
  for clazz in classes:
    if not _class_matches_filters(clazz, args['filters']): continue

    for dir in args['dirs']:
      if not clazz['path'].begins_with(dir): continue

      var instance = {
        'class': clazz,
        'loaded_class': load(clazz['path']),
        'cases': [],
      }
      retval.push_back(instance)

      for method in instance['loaded_class'].get_script_method_list():
        if not method['name'].begins_with('test_'): continue
        if not _method_matches_filters(clazz, method, args['filters']): continue

        instance['cases'].push_back({'method': method})

  return retval

func _class_matches_filters(clazz, filters) -> bool:
  if len(filters) == 0: return true

  for filter in filters:
    if filter[0] == clazz['class']:
      return true

  return false

func _method_matches_filters(clazz, method, filters) -> bool:
  if len(filters) == 0: return true

  for filter in filters:
    if filter[0] != clazz['class']:
      continue
    elif len(filter) == 1:
      return true # No method filter specified - match entire file
    else: # Filter matches class, and a method filter was specified
      return filter[1] == method['name']

  return false

func _load_global_scripts():
  prints("Loading global scripts...")
  var projectfile := ConfigFile.new()
  var err = projectfile.load("res://project.godot")
  if err != OK:
    return err

  var autoloads := projectfile.get_section_keys("autoload")
  for autoload in autoloads:
    var uid := projectfile.get_value("autoload", autoload)
    uid = uid.trim_prefix("*")

    var actual_uid = ResourceUID.text_to_id(uid)
    if actual_uid == ResourceUID.INVALID_ID:
      return ''.join(["Invalid UID for ", autoload, ": ", uid])

    var path := ResourceUID.get_id_path(actual_uid)
    if path.is_empty():
      return ''.join(["No path found for ", autoload, ": ", uid, " ::: ", actual_uid])

    var script = load(path)
    var instance = script.new()
    instance.name = autoload
    root.add_child(instance)

  return null

var _loaded_addons: Array[String] = []
func _load_addons():
  prints("Loading addons...")
  var paths := ["res://addons/lua-gdextension/luagdextension.gdextension"] # TODO: Dynamic discovery
  for path in paths:
    if GDExtensionManager.is_extension_loaded(path):
      continue

    var status := GDExtensionManager.load_extension(path)
    if status != GDExtensionManager.LoadStatus.LOAD_STATUS_OK:
      return ''.join(["Failed to load extension '", path, "'. Status: ", status])

    _loaded_addons.push_back(path)

  prints("", "", len(_loaded_addons), "addon(s) loaded")
  return null

func _teardown(exitcode: int) -> void:
  for addon in _loaded_addons:
    GDExtensionManager.unload_extension(addon)

  quit(exitcode)
