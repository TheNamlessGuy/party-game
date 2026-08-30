class_name RunTest_CoolTest
extends UnitTestBaseClass

func test_CoolTest3() -> void:
  assertTrue(true, "test_CoolTest3: This is defined before 1 and 2 - which runs first?")

func test_CoolTest1() -> void:
  assertTrue(true, "test_CoolTest1: true is true")

func test_CoolTest2() -> void:
  assertTrue(false, "test_CoolTest2: false is false")

func test_CoolTest4() -> void:
  assertTrue(true, "test_CoolTest4: true is true")

func test_CoolTest5() -> void:
  assertNotNull(get_tree(), "No tree defined")
  assertNotNull(get_tree().root, "No root of the tree defined")
  assertTrue(get_tree().root.has_node('Global'), "Global scripts not loaded")

func test_CoolTest6() -> void:
  assertTrue(ClassDB.class_exists('LuaState'), "Addons not loaded")
