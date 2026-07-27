# What?
This is a party game heavily inspired by the early entries to the Mario Party series. However, the game itself is more of a framework for mods - the entire game should be 100% moddable.

## General user flow
A very broad event list of how a game would go.

1) User boots up game
2) User starts a new game
    * At this point, other users can join locally, or be invited remotely at virtually any point during the setup. "User" will therefore be "users" from now on.
    * Also, at any point here, the users can go into a submenu to modify things you might not want to most times - what items are available, what tiles, what minigames, etc. See the same types of settings in something like Smash Bros.
3) Users select a party game from the list of party games (a list of mods, essentially)
4) Users each pick a character (also a list of mods)
5) Users start the game
6) Users roll dice to determine turn order
7) The users take turns to roll a die, which determines how far they move, and what tile they land on
    * During their turns, they collect secondary currency, which they can use to buy primary currency
8) Depending on the tile, something happens when they either step on it, or land (run out of steps) on it
9) Once all users have had a turn, the game enters a minigame phase - what minigame to play is determined, and the scene is moved to said minigame.
10) Once the minigame is done, the results are applied, and then the next turn starts.
11) Steps 7-10 repeat until all turns have played out, after which the game is over
12) Before the winner is chosen, users are given extra primary currency based on arbitrary metrics
13) A winner is determined
14) The users are booted back to step 3

Note that this is by no means meant to describe _all_ games. It should be just as valid to:

* Have a party game that's just a list of minigames that are played through in order
* Have more or less than two types of currencies
* Have the only minigame be a death match that takes place on the board itself, where everyone starts where they are, and people who get killed get brought back to the starting platform

and whatever else you can think of.

# General
* The base game should make as few assumptions about what people will want to do as possible
    * This does not mean it should compromise on security. It should not allow mods to directly access other mods, it should not allow mods to access the internet, and so on.
* All content provided by default should be in the form of "official mods" - the engine itself should contain as little as possible.

## Overall control flow
TODO: PartyGameManager, MinigameManager, etc

# Party game
A party game is the basis of the game actually played by the users. A party game is in control of starting minigames, tracking player progress, determining winners, and so on. Basically everything that isn't sandboxed in the other forms.

# Minigame
A minigame is started from a party game. It probably has an introduction, a tutorial, the actual game loop, and then some end result. The result is communicated back to the party game, which then alters the state accordingly.

# Mods
* Mods are handled through lua integration
    * Depending on the type of mod, they will get a different setup of functions to use. For example, a "tile" mod should only really care about what happens when a user steps on or lands on it.
* Mods require a top-level `metadata.toml` file
* Mods require a top-level `setup.lua` file, which is automatically loaded and ran as a "setup" type mod

Q: How do we stop a mod from just going `while true: noop`? A timeout? If so, what should the timeout be (probably different per call)? Should we enforce a minimum frame rate?

Q: Should people be able to publish mods hotfixing other mods? How would we let them "replace just file X" or whatever?

Q: Load order. Do we care? How would we implement it?

## Metadata file
The file should contain:
* The name of the author
* Any dependencies it has
* What engine API version should be used

### Dependencies
Dependencies should be handled through tags. A mod can "provide" certain tags, and "require" certain tags. The tags themselves should just be case-insensitive strings.

A tile mod can have a requirement for "my-specific-board:version-1.2.4" and/or "uses-secondary-currency".

Q: Should we have "hard" and "soft" dependencies?

## Types
### Setup
The setup type mods should only ever be the initial scripts that set a mod up. This type of mod should only have access to a bunch of `register_*` functions - for example:

* `register_party_game(...)`
* `register_player_character(...)`

Q: Should the script fail if it tries to call multiple `register_*` functions? Should the engine require separate mods for a party game and its unique tiles? Should we have a `register_mod(...)` for modpacks?

#### Control flow
TODO: Graph

### Party game
The basis of a party game mod is a class definition. Here, the engine provides two levels of abstraction:
* `BasePartyGame` - The very bare minimum. Only has `setup`, `frame`, and `teardown` callbacks. The mod is _required_ to be inheriting from this class.
* `Base*PartyGame` (`BaseBoardPartyGame`, for example) - Very hardcoded to the type of party game it's named after. Has a bunch of functions the user can override (including the ones from `BasePartyGame`), so they can change as much or as little functionality as they want.
    * Just want to change the board itself? Override the `setup_board` function, and the default function implementations will handle the rest of the logic.

#### Control flow
TODO: Graph

### Minigame
TODO

#### Control flow
TODO: Graph

### Tile
TODO

#### Control flow
TODO: Graph

### Dice
TODO

#### Control flow
TODO: Graph

### Player character
TODO

#### Control flow
TODO: Graph

### Item
TODO

#### Control flow
TODO: Graph

## API
* Each mod gets access to a specific API depending on what it's registered as, and what version the metadata file specified.

### Versioning
* The lua scripts themselves shouldn't be aware of version numbers. That should all be handled through the mod metadata file, and the engine itself

### Mod deprecation
* Mods should be marked as "For older version" when they rely on an engine API that's a major version that's less than the current one
* Mods should be marked as "Outdated" when they rely on an engine API version that's no longer supported, and should no longer be possible to use.

## Cross-mod communication
A party game will have to talk with a minigame in some way, for example. This will be done though event buses, where you can push a message and poll messages.

Generally, we should encourage users to make many small event buses, rather than having a few long lived ones.

### Kinds
#### Storage
* Holds all messages under its entire lifespan
* Users say "give me all messages" with an optional "after this index"

#### Storage-free
* Frees all read messages

#### One-time
* Automatically deletes itself as soon as X messages have been read, where x defaults to 1

#### 

# Goals
TODO

## MVP
* Local multiplayer only
* All the content should be made of mods
* Only have pre-provided two simple boards
* Two characters
* Three tiles - "Plus secondary currency", "Minus secondary currency", "Chance"
* Bots
    * They should be very rudimentary - just random inputs
* Simple mod selection menu
    * No consideration for versioning, compatibility, etc.

## First public release
* Have two very distinct and different feeling sets of mods: one cartoony, and one gritty.
    * Both of these must be equally good to play, including the expected feeling and theming of each
