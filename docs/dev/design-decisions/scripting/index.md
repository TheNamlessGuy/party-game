# Overview of scripting decisions

The decision was made to use lua integration for the scripting, for a few reasons:
1) Giving the modder full access to the GDScript suite would easily resolve in people accessing the internet for telemetry or installing spyware, or what have you. By keeping a tight control of what the scripts can actually do, mods are safer to use overall
2) Lua is a well known language, especially among modding communities
3) There already existed a few lua integrations ready for Godot

## Scripting API
For information about the scripting API, see [the relevant documentation](./api.md).
