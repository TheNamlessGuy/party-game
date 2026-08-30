extends SceneTree

func _init() -> void:
  _ready.call_deferred()

func _ready() -> void:
  var args = _parse_args()
  if args == null:
    _teardown(0)
    return

  var tests = _get_tests(args)
  for test in tests:
    var instance = test['loaded_class'].new()
    root.add_child(instance)
    for testcase in test['cases']:
      prints("Running", test['class']['class'] + '::' + testcase['method']['name'])
      Callable(instance, testcase['method']['name']).call()
    instance.queue_free()

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

func _teardown(exitcode: int) -> void:
  quit(exitcode)
