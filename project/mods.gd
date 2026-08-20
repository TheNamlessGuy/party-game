# SPDX-License-Identifier: AGPL-3.0-or-later
extends Node

# TODO: Add support for mod versioning

class ModMetadata:
  var name: String
  var author: String
  var dependencies: Array

  func _init(name: String, author: String, dependencies: Array):
    self.name = name
    self.author = author
    self.dependencies = dependencies

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
  }

  var reason: Reason
  var target: String

  func _init(reason: Reason, target: String):
    self.reason = reason
    self.target = target

static func load_all():
  var metadata = _load_all_metadata()
  if metadata is LoadError:
    Global.fatal_error(["Could not load mod metadata"])

  var load_queue = _resolve_load_order(metadata)
  if load_queue is LoadError:
    Global.fatal_error(["Could not resolve mod load order"])

  for mod in load_queue:
    _load_mod(mod)

static func _load_all_metadata():
  var mods_path = "./mods/"

  var metadata: Array[ModMetadata] = []

  var mod_dirs = DirAccess.open(mods_path).get_directories()
  for mod_dir in mod_dirs:
    var metadata_path = mods_path + mod_dir + "/metadata.toml"

    if not FileAccess.file_exists(metadata_path):
      return LoadError.new(LoadError.Reason.NO_METADATA, mod_dir)

    var data = _load_metadata(metadata_path)
    if data is LoadError:
      return data

    metadata.append(data)

  return metadata

# TODO: Use third-party .toml parser instead?
static func _load_metadata(path):
  var cfg = ConfigFile.new()
  cfg.load(path)

  if not cfg.has_section_key("general", "name"):
    return LoadError.new(LoadError.Reason.BAD_METADATA, path)
  var name = cfg.get_value("general", "name").to_lower()

  if not cfg.has_section_key("general", "author"):
    return LoadError.new(LoadError.Reason.BAD_METADATA, path)
  var author = cfg.get_value("general", "author")

  var dependencies: Array = cfg.get_value("general", "dependencies", [])
  if not dependencies.all(func(x): return x is String):
    return LoadError.new(LoadError.Reason.BAD_METADATA, path)
  dependencies = dependencies.map(func(x): return x.to_lower())

  return ModMetadata.new(name, author, dependencies)

static func _resolve_load_order(metadata):
  var remaining_mods = metadata.duplicate()

  # The order in which mods should be loaded
  var load_queue = []

  # Keep track of which mods have been added to the load queue
  var resolved = {}
  for mod in remaining_mods:
    resolved[mod.name] = false

  # Add mods to the load queue one at a time
  while len(remaining_mods) > 0:
    var successfully_loaded = false

    for i in range(len(remaining_mods)):
      var mod = remaining_mods[i]

      # Check if all dependencies of this mod has been added to the load queue
      var all_deps_loaded = true
      for dep in mod.dependencies:
        if dep not in resolved:
          # The dependency could not be found
          return LoadError.new(LoadError.Reason.DEPENDENCIES_NOT_AVAILABLE, "")
        if not resolved[dep]:
          # If a dependency has not been added to the load queue, we cannot yet add this mod
          all_deps_loaded = false
          break

      # If all dependencies checks out, add this mod to the load queue
      if all_deps_loaded:
        load_queue.append(mod)
        resolved[mod.name] = true
        remaining_mods.remove_at(i)
        successfully_loaded = true
        break

    # If no mod could be added to the load queue, something went wrong (circular dependencies, for example)
    if not successfully_loaded:
      return LoadError.new(LoadError.Reason.DEPENDENCY_RESOLUTION_FAILURE, "")

  return load_queue

static func _load_mod(metadata: ModMetadata):
  # TODO: Load the mod
  print(metadata.name)
