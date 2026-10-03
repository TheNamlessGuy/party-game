set dotenv-load

# START: Setup
[group("Setup")]
[doc("Does all initial setup")]
initial-setup: copy-env install-dependencies cache-setup

[group("Setup")]
[doc("Sets up caches for the repository")]
[script('bash')]
cache-setup:
  set -euo pipefail
  "${GODOT_BINARY}" --headless --path "./project/" --import # This should generate ./project/.godot/extension_list.cfg, which is needed for unit tests (and probably other stuff)

[group("Setup")]
[doc("Installs all dependencies for you")]
[script('bash')]
install-dependencies:
  set -euo pipefail

  dir="./project/addons/lua-gdextension"
  if [[ ! -d "${dir}" ]]; then
    echo "Installing addon lua-gdextension (https://github.com/gilzoide/lua-gdextension) to '${dir}'"

    tmpdir="$(mktemp -d)" || {
      echo >&2 "  Couldn't create a temporary directory"
      exit 1
    }

    tmpdir_ext="${tmpdir}/extracted"
    mkdir -p "${tmpdir_ext}"

    url="https://github.com/gilzoide/lua-gdextension/releases/download/${LUA_GDEXTENSION_VERSION}/lua-gdextension.zip"
    echo "  Downloading '${url}' to ${tmpdir}"
    wget --quiet --directory-prefix "${tmpdir}" "${url}"

    echo "  Unzipping '${tmpdir}/lua-gdextension.zip' to ${tmpdir_ext}"
    unzip -qq "${tmpdir}/lua-gdextension.zip" -d "${tmpdir_ext}"

    echo "  Moving relevant plugin files to where they should be"
    mkdir -p "${dir}"
    shopt -s dotglob
    mv "${tmpdir_ext}/addons/lua-gdextension/"* "${dir}/"
    shopt -u dotglob

    echo "  Removing any leftover files"
    rm -rf "${tmpdir}"
  fi

  echo "All dependencies installed!"

[group("Setup")]
[doc("Copies .env.example to .env")]
[script('bash')]
copy-env:
  set -euo pipefail

  if [[ -f ".env" ]]; then
    echo ".env already exists"
    exit 0
  fi

  if [[ ! -f ".env.example" ]]; then
    echo >&2 "Can't find .env.example"
    exit 1
  fi

  cp '.env.example' '.env'
  echo "Remember to update your shiny new .env file!"
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
[doc("Diffs the .env file against .env.example")]
[script('bash')]
diff-env:
  mapfile -t example_keys < <(grep -E '^[^=]+=' '.env.example' | cut -d= -f1 | sort)
  mapfile -t actual_keys < <(grep -E '^[^=]+=' '.env' | cut -d= -f1 | sort)

  header_printed=""
  for example_key in "${example_keys[@]}"; do
    echo "${actual_keys[@]}" | grep "${example_key}" > /dev/null
    if [[ "$?" == "1" ]]; then
      if [[ -z "${header_printed}" ]]; then
        echo "Missing keys:"
        header_printed="-"
      fi

      echo "  ${example_key}"
    fi
  done

  header_printed=""
  for actual_key in "${actual_keys[@]}"; do
    echo "${example_keys[@]}" | grep "${actual_key}" > /dev/null
    if [[ "$?" == "1" ]]; then
      if [[ -z "${header_printed}" ]]; then
        echo "Old keys:"
        header_printed="-"
      fi

      echo "  ${actual_key}"
    fi
  done

[group("Misc")]
[doc("Updates .env values that should always match .env.example")]
[script('bash')]
update-env:
  just _update-env-key 'LUA_GDEXTENSION_VERSION'
# END: Misc

# START: Internal
[script('bash')]
_get-env-key file key:
  grep -E "^{{key}}=" "{{file}}" | tail -n 1 | sed -E 's/^[^=]+=//' # Find the line that starts with "{{key}}=", strip "{{key}}=" and print the result

[script('bash')]
_set-env-key file key value:
  touch '{{file}}'
  if grep -qE "^{{key}}=" "{{file}}"; then # If the value already exists
    sed -i -E "s|^{{key}}=.*|{{key}}={{value}}|" "{{file}}" # Overwrite the line "{{key}}=..." with "{{key}}={{value}}"
  else
    echo "{{key}}={{value}}" >> "{{file}}" # If the value isn't in the file, just append it at the end
  fi

[script('bash')]
_update-env-key key:
  example_value="$(just _get-env-key '.env.example' '{{key}}')"
  actual_value="$(just _get-env-key '.env' '{{key}}')"

  if [[ "${example_value}" == "${actual_value}" ]]; then
    exit 0 # No change needed
  fi

  echo "Updating {{key}}..."
  just _set-env-key '.env' '{{key}}' "${example_value}"
# END: Internal
