set dotenv-load

# START: Setup
[group("Setup")]
[doc("Does all inital setup")]
initial-setup: copy-env install-dependencies

[group("Setup")]
[doc("Installs all dependencies for you")]
install-dependencies:
  -

[group("Setup")]
[doc("Copies .env.example to .env")]
[script('bash')]
copy-env:
  echo "Remember to update your shiny new .env!"
# END: Setup

# START: Tests
[group("Tests")]
[doc("Runs all available tests")]
[script('bash')]
run-tests:
  "${GODOT_BINARY}" --path "./project/" --headless --script "addons/unit-tests/run-tests.gd" -- --dir "tests"

[group("Tests")]
[doc("Runs the given test")]
[arg("which", help="Specified in format '<Name of test file>' or '<Name of test file>::<Name of test>'")]
[script('bash')]
run-test which:
  "${GODOT_BINARY}" --path "./project/" --headless --script "addons/unit-tests/run-tests.gd" -- --dir "tests" --filter '{{which}}'
# END: Tests

# START: Misc
[default]
[group("Misc")]
[doc("List all available commands - like you're doing now!")]
list:
  @just --list --justfile {{justfile()}}

[group("Misc")]
[doc("Diffs the .env file with it's .env.example counterpart")]
diff-env:
  -
# END: Misc
