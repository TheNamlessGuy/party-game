class_name UnitTestAddonTests
extends UnitTestBaseClass

func test_UnitTestsCanAccessGlobalScripts() -> void:
  assertNotNull(get_tree(), "No tree defined")
  assertNotNull(get_tree().root, "No root of the tree defined")
  assertTrue(get_tree().root.has_node('Global'), "Global scripts not loaded")

func test_UnitTestsCanAccessAddons() -> void:
  assertTrue(ClassDB.class_exists('LuaState'), "Addons not loaded")
