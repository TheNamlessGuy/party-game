-- SPDX-License-Identifier: AGPL-3.0-or-later

function lua_api(obj)
  obj.y = obj.y + 5
  local new_obj = godot_api(obj, 50)
  return new_obj
end
