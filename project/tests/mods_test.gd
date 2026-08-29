# SPDX-License-Identifier: AGPL-3.0-or-later
class_name RunTest_ModsTest
extends UnitTestBaseClass

const Mods = preload("res://mods.gd")

func assertModLoadOrder(actual, expected):
  assertEquals(len(actual), len(expected))
  for i in range(len(actual)):
    assertEquals(actual[i], expected[i])

func create_mod(id: String, deps: Array):
  return Mods.ModMetadata.new(id, id, "author", deps, [id])

func test_ResolveLoadOrder_SuccessSingle() -> void:
  var mod_a = create_mod("a", [])

  var input = [
    mod_a,
  ]

  var expected_output = [
    mod_a,
  ]

  assertModLoadOrder(Mods._resolve_load_order(input), expected_output)

func test_ResolveLoadOrder_SuccessMulti() -> void:
  var mod_a = create_mod("a", [])
  var mod_b = create_mod("b", ["a"])
  var mod_c = create_mod("c", ["a"])
  var mod_d = create_mod("d", ["b", "c"])
  var mod_e = create_mod("e", ["c", "d"])

  var input = [
    mod_d,
    mod_b,
    mod_e,
    mod_a,
    mod_c
  ]

  var expected_output = [
    mod_a,
    mod_b,
    mod_c,
    mod_d,
    mod_e
  ]

  assertModLoadOrder(Mods._resolve_load_order(input), expected_output)

func test_ResolveLoadOrder_SuccessTags() -> void:
  var mod_a = create_mod("a", [])
  mod_a.tags = ["tag_1", "tag_2"]
  var mod_b = create_mod("b", ["tag_2"])
  mod_b.tags = ["tag_3", "tag_4"]
  var mod_c = create_mod("c", ["tag_3"])

  var input = [
    mod_c,
    mod_b,
    mod_a
  ]

  var expected_output = [
    mod_a,
    mod_b,
    mod_c
  ]

  assertModLoadOrder(Mods._resolve_load_order(input), expected_output)

func test_ResolveLoadOrder_FailMissingDependency() -> void:
  var mod_a = create_mod("a", [])
  var mod_b = create_mod("b", ["c"])

  var input = [
    mod_a,
    mod_b
  ]

  var output = Mods._resolve_load_order(input)
  assertTrue(output is Mods.LoadError)
  assertEquals(output.reason, Mods.LoadError.Reason.DEPENDENCIES_NOT_AVAILABLE)

func test_ResolveLoadOrder_FailCircularDependency() -> void:
  var mod_a = create_mod("a", [])
  var mod_b = create_mod("b", ["a", "d"])
  var mod_c = create_mod("c", ["b"])
  var mod_d = create_mod("d", ["c"])

  var input = [
    mod_a,
    mod_b,
    mod_c,
    mod_d,
  ]

  var output = Mods._resolve_load_order(input)
  assertTrue(output is Mods.LoadError)
  assertEquals(output.reason, Mods.LoadError.Reason.DEPENDENCY_RESOLUTION_FAILURE)

func test_ResolveLoadOrder_FailDuplicateTags() -> void:
  var mod_a = create_mod("a", [])
  mod_a.tags = ["the_tag"]
  var mod_b = create_mod("b", [])
  mod_b.tags = ["the_tag"]

  var input = [
    mod_a,
    mod_b
  ]

  var output = Mods._resolve_load_order(input)
  assertTrue(output is Mods.LoadError)
  assertEquals(output.reason, Mods.LoadError.Reason.DUPLICATE_TAGS)
