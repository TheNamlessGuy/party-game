# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

# TODO: Add support for mod versioning

class ModMetadata:
  var id: String
  var name: String
  var author: String
  var dependencies: Array
  var tags: Array

  func _init(id: String, name: String, author: String, dependencies: Array, tags: Array):
    self.id = id
    self.name = name
    self.author = author
    self.dependencies = dependencies
    self.tags = tags

  # Return the list of tags in "mod:tag" name format
  func complete_tags() -> Array:
    var tags = []
    for tag in self.tags:
      tags.append(self.name + ":" + tag)
    return tags

class LoadError:
  enum Reason {
    # No metadata file was found
    NO_METADATA,

    # Metadata did not follow the expected format
    BAD_METADATA,

    # Mods dependencies could not be found
    DEPENDENCIES_NOT_AVAILABLE,

    # Dependency load order could not be resolved
    DEPENDENCY_RESOLUTION_FAILURE,

    # Several mods use the same id
    DUPLICATE_MODS,
  }

  var reason: Reason
  var target: String

  func _init(reason: Reason, target: String):
    self.reason = reason
    self.target = target

  func _to_string():
    match self.reason:
      Reason.NO_METADATA:
        return "Error when loading mod %s (no metadata file found)" % self.target
      Reason.BAD_METADATA:
        return "Error when loading mod %s (invalid metadata)" % self.target
      Reason.DEPENDENCIES_NOT_AVAILABLE:
        return "Error when loading mod %s (dependencies not available)" % self.target
      Reason.DEPENDENCY_RESOLUTION_FAILURE:
        return "Error when loading mods (could not resolve mod load order)"
      Reason.DUPLICATE_MODS:
        return "Error when loading mod %s (mod with same id already exists)" % self.target

static func load_all():
  var metadata = _load_all_metadata()
  if metadata is LoadError:
    # Global.fatal_error(["Could not load mod metadata"])
    return

  var load_queue = _resolve_load_order(metadata)
  if load_queue is LoadError:
    # Global.fatal_error(["Could not resolve mod load order"])
    return

  for mod in load_queue:
    _load_mod(mod)

static func _load_all_metadata() -> Variant:
  var mods_path = "res://mods/"

  var metadata: Array[ModMetadata] = []

  var mod_dirs = DirAccess.open(mods_path).get_directories()
  for mod_dir in mod_dirs:
    var metadata_path = mods_path.path_join(mod_dir).path_join("metadata.ini")

    if not FileAccess.file_exists(metadata_path):
      return LoadError.new(LoadError.Reason.NO_METADATA, mod_dir)

    var data = _load_metadata(metadata_path)
    if data is LoadError:
      return data

    metadata.append(data)

  return metadata

static func _load_metadata(path: String) -> Variant:
  var cfg = ConfigFile.new()
  cfg.load(path)

  if not cfg.has_section_key("general", "id"):
    return LoadError.new(LoadError.Reason.BAD_METADATA, path)
  var id = cfg.get_value("general", "id").to_lower()

  if not cfg.has_section_key("general", "name"):
    return LoadError.new(LoadError.Reason.BAD_METADATA, path)
  var name = cfg.get_value("general", "name")

  if not cfg.has_section_key("general", "author"):
    return LoadError.new(LoadError.Reason.BAD_METADATA, path)
  var author = cfg.get_value("general", "author")

  var dependencies: Array = cfg.get_value("general", "dependencies", [])
  if not dependencies.all(func(x): return x is String):
    return LoadError.new(LoadError.Reason.BAD_METADATA, path)
  dependencies = dependencies.map(func(x): return x.to_lower())

  var tags: Array = cfg.get_value("general", "tags", [])
  if len(tags) == 0:
    return LoadError.new(LoadError.Reason.BAD_METADATA, path)
  if not dependencies.all(func(x): return x is String):
    return LoadError.new(LoadError.Reason.BAD_METADATA, path)
  tags = tags.map(func(x): return x.to_lower())

  return ModMetadata.new(id, name, author, dependencies, tags)

static func _resolve_load_order(metadata: Array) -> Variant:
  # The order in which mods should be loaded
  var load_queue = []

  # Verify that no two mods use the same id.
  for i in range(len(metadata)):
    for j in range(i+1, len(metadata)):
      if metadata[i].name == metadata[j].name:
        return LoadError.new(LoadError.Reason.DUPLICATE_MODS, metadata[i].name)

  # Initialize a dictionary for keeping track of which mod tags have
  # been added to the load queue.
  var tag_loaded = {}
  for mod in metadata:
    for tag in mod.complete_tags():
      tag_loaded[tag] = false

  # Verify that mod dependencies are available
  for mod in metadata:
    for dep in mod.dependencies:
      if dep not in tag_loaded:
        return LoadError.new(LoadError.Reason.DEPENDENCIES_NOT_AVAILABLE, mod.name)

  # Add mods to the load queue one at a time
  var remaining_mods = metadata.duplicate()
  while len(remaining_mods) > 0:
    var mod_to_load = _find_loadable_mod(remaining_mods, tag_loaded)
    if mod_to_load == -1:
      # None of the remaining mods could be loaded.
      return LoadError.new(LoadError.Reason.DEPENDENCY_RESOLUTION_FAILURE, "")

    var mod = remaining_mods[mod_to_load]
    remaining_mods.remove_at(mod_to_load)

    load_queue.append(mod)
    for tag in mod.complete_tags():
      tag_loaded[tag] = true

  return load_queue

static func _find_loadable_mod(mods: Array, tag_loaded: Dictionary) -> int:
  for i in range(len(mods)):
    var mod = mods[i]

    # If the mod has at least one dependency that has not been loaded
    # yet, the mod is not loadable.
    var all_deps_loaded = true
    for dep in mod.dependencies:
      if not tag_loaded[dep]:
        all_deps_loaded = false
        break

    if all_deps_loaded:
      return i

  return -1

static func _load_mod(metadata: ModMetadata):
  # TODO: Load the mod
  print(metadata.name)
