# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

# TODO: Should perhaps not call these "resources" to avoid confusion
# with the built-in Godot class of the same name.

# TODO: Is this code safe from people doing strange things with
# symlinks?

# TODO: Make this usable from the Lua API

const BASE_RESOURCE_PATH = "./res/"

## Tree-structure containing the complete set of resource files used
## by the game. Resource lookup in Lua scripts is done by consulting
## this data structure rather than using the filesystem directly.
## Resource loading is done lazily using path strings like
## "textures/texture.png".
class ResourceTree:
  var _tree = {}

  ## Loads a resource file. Subsequent accesses to the same resource
  ## file is cached.
  func access(path: String):
    # TODO: Actually load the file
    pass

  ## Returns true if the specified resource file exists.
  func exists(path: String) -> bool:
    var dir = self._tree
    for component in path.split("/"):
      if component in dir:
        dir = dir[component]
      else:
        return false
    return true

## Reference to a resource file that has not been loaded yet. If
## [member archive] is null, [member filename] points to the
## underlying filename, otherwise [member filename] points to a file
## located in the archive file in question.
class ResourceRef:
  var _filename = null
  var _archive = null

  func _init(filename, archive = null):
    self._filename = filename
    self._archive = archive

  func _to_string():
    if self._archive == null:
      return "<ResourceRef:%s>" % self._filename
    else:
      return "<ResourceRef:%s:%s>" % [self._archive, self._filename]

## Queries the base resource path for all available resource files,
## including those present in archive files, and constructs the
## appropriate [ResourceTree]. This does not actually load any file
## contents. Rather, this is done lazily whenever Lua scripts tries to
## access the files.
func create_resource_tree() -> ResourceTree:
  var tree = ResourceTree.new()

  var res_dir = DirAccess.open(BASE_RESOURCE_PATH)
  for d in res_dir.get_directories():
    var subdir = res_dir.get_current_dir().path_join(d)
    tree._tree[d] = _load_dir(DirAccess.open(subdir))
  var zip_files = []
  for f in res_dir.get_files():
    if f.ends_with(".zip"):
      zip_files.append(f)
    else:
      var filename = res_dir.get_current_dir().path_join(f)
      tree._tree[f] = ResourceRef.new(filename)

  for zip_file in zip_files:
    var reader = ZIPReader.new()
    var zip_path = res_dir.get_current_dir().path_join(zip_file)
    reader.open(zip_path)
    for file in reader.get_files():
      if file.ends_with("/"):
        continue
      if tree.exists(file):
        # Ignore duplicate files
        print("warning: path %s already loaded" % file)
        continue
      var current = tree._tree
      var components = file.split("/")
      for component in components.slice(0, -1):
        if component not in current:
          current[component] = {}
        current = current[component]
      current[components[-1]] = ResourceRef.new(file, zip_path)

  return tree

func _load_dir(dir: DirAccess):
  var tree = {}
  for d in dir.get_directories():
    var subdir = dir.get_current_dir().path_join(d)
    tree[d] = _load_dir(DirAccess.open(subdir))
  for f in dir.get_files():
    var filename = dir.get_current_dir().path_join(f)
    tree[f] = ResourceRef.new(filename)
  return tree
