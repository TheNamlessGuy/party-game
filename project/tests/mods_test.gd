# SPDX-License-Identifier: AGPL-3.0-or-later
class_name RunTest_ModsTest
extends UnitTestBaseClass

const Mods = preload("res://mods.gd")

func assertModLoadOrder(actual, expected):
  assertEquals(len(actual), len(expected))
  for i in range(len(actual)):
    assertEquals(actual[i], expected[i])

func test_ResolveLoadOrder_SuccessSingle() -> void:
  var mod_a = Mods.ModMetadata.new("A", "author", [])

  var input = [
    mod_a,
  ]

  var expected_output = [
    mod_a,
  ]

  assertModLoadOrder(Mods._resolve_load_order(input), expected_output)

func test_ResolveLoadOrder_SuccessMulti() -> void:
  var mod_a = Mods.ModMetadata.new("A", "author", [])
  var mod_b = Mods.ModMetadata.new("B", "author", ["A"])
  var mod_c = Mods.ModMetadata.new("C", "author", ["A"])
  var mod_d = Mods.ModMetadata.new("D", "author", ["B", "C"])
  var mod_e = Mods.ModMetadata.new("E", "author", ["C", "D"])

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

func test_ResolveLoadOrder_FailMissingDependency() -> void:
  var mod_a = Mods.ModMetadata.new("A", "author", [])
  var mod_b = Mods.ModMetadata.new("B", "author", ["C"])

  var input = [
    mod_a,
    mod_b
  ]

  var output = Mods._resolve_load_order(input)
  assertTrue(output is Mods.LoadError)
  assertEquals(output.reason, Mods.LoadError.Reason.DEPENDENCIES_NOT_AVAILABLE)

func test_ResolveLoadOrder_FailCircularDependency() -> void:
  var mod_a = Mods.ModMetadata.new("A", "author", [])
  var mod_b = Mods.ModMetadata.new("B", "author", ["A", "D"])
  var mod_c = Mods.ModMetadata.new("C", "author", ["B"])
  var mod_d = Mods.ModMetadata.new("D", "author", ["C"])

  var input = [
    mod_a,
    mod_b,
    mod_c,
    mod_d,
  ]

  var output = Mods._resolve_load_order(input)
  assertTrue(output is Mods.LoadError)
  assertEquals(output.reason, Mods.LoadError.Reason.DEPENDENCY_RESOLUTION_FAILURE)
