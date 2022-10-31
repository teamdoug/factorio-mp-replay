

# factorio-mp-replay

This mod and tools can be used to simulate other players in a multiplayer game of Factorio,
intended for practicing MP speedruns without all the players.

## Player Usage


Take mp-replay_X.Y.Z.zip, where X.Y.Z is the version number, and put it in your
[mods folder](https://wiki.factorio.com/index.php?title=Application_directory).

You can then host or join a game where the other players will simulate the actions
of the other players. Make sure to use the same map settings as the copied replay!

When playing, there are several controls in the upper left. They can be used to
pause or affect the speed of the bots and control which players are controlled by bots.

In the left column, you can select who you are (your name will then be in parentheses
after the bot's name). This causes other bots to occasionally give you items that were
directly handed off in the replay. By default, when you select who you are, you also
cause that bot's actions to be ignored since you're controlling it. If you manually
unignore a bot after selecting it, it will highlight everything that bot places, which
can be useful for making guides.

## Developer Usage

### How It Works
There are three main components to this tool:

- [control.lua](./control.lua) can be inserted into a replay save file to dump the actions
  of users in a replay into the [Factorio log file](https://wiki.factorio.com/Log_file).
- [replay_mod_generator.py](./replay_mod_generator.py) turns the actions in the log into
  [mp-replay/player_events.lua](./mp-replay/player_events.lua), which is part of the mod.
- [mp-replay/control.lua](./mp-replay/control.lua) is the logic for the mod, which replays
  the actions from player_events.lua in an actual game.

  
### Setting New Players

Player mappings are controlled in two places:
- `player_mapping` in [control.lua](./control.lua) when dumping the replay. Changing the
  order here lets you have a consistent ordering for your group (since even if you're using
  your own replay, players join in a potentially random order).
- `player_names` in [mp-replay/control.lua](./mp-replay/control.lua) controls the names
  displayed for each player and lets players assume certain roles by default. Multiple players
  can share roles by splitting with `/`.

### Modifying Mod for a New Base Replay

#### Initial Setup

Install a self-contained installation of Factorio to `C:/Program Files/Factorio` (or fix
replay_mod_generator.py to take a path). This is where you will run the dev version of the
mod, so copy the [mp-replay](./mp-replay) folder to the `mods` folder for that installation.

There's some logic in [mp-replay/control.lua](mp-replay/control.lua) that enables speed
controls if your name is `heartosis`. You can update that to work for your player name too.

#### Every Time

First, make sure to grab the replay from the player who hosted the game. For other players,
player indexes seem to jump around as players join, but I haven't tested this extensively.

Then, copy the replay since you're going to modify it. Copy [control.lua](./control.lua) into
the replay file, overwriting the existing control.lua.

Load the replay file and run through it as fast as your computer can handle. Stop when the
rocket launches (or whenever you want bot actions to stop).

Open the [Factorio log file](https://wiki.factorio.com/Log_file) and find the last instance
of "Checksum" (case-sensitive). Copy the rest of the file into a file named "replay.log" in
the directory of this repo.

Run [replay_mod_generator.py](./replay_mod_generator.py). This will write player_events.lua
both to this repo and to the dev mod installed above in `C:/Program Files/Factorio`.

Then, you can run the Factorio binary from that installation and test the mod with all
players running as bots. Use the speed controls (enabled above) or `/c game.speed = 64`
to run through as fast as possible and make sure assembly lines are all working at the
end and at least most of the research happens. Make sure to stay out of bots' way since
you can prevent them building.

If the replay dumper isn't capturing some important actions from users, good luck
fixing it :) Sometimes, you can work around it by skipping or moving bad builds 
by modifying/forking `fix_event` in
[replay_mod_generator.py](./replay_mod_generator.py) to change what players do.
One notable caveat with fixing events is that sometimes players will later fix
what they broke the first time in a subtly different way, so you have to ignore
those future corrections as well.

Once you're happy with the logic of the mod, update
[mp-replay/info.json](./mp-replay/info.json) with a new version number. Make sure you
copied control.lua back from the mod directory if you changed it. Then zip `mp-replay`
and rename it to `mp-replay_X.Y.Z.zip`, where `X.Y.Z` is the version number in
info.json.

Distribute the zip. I usually copy it to my own default Factorio installation
(which I don't generally use for development) to make sure it works first.

### Updating the Mod Logic

Since the dev version of the mod in `C:/Program Files/Factorio` has a copy of control.lua,
I usually modify that logic directly (since you can restart the map to load a new version
of it). When I want to commit my changes, I copy that file back to the repo. Open to better
ideas here :)

### How the Mod Works

The mod itself loads player_events.lua as a series of actions for players to take. Then,
by registering an event handler for `on_tick`, it runs each tick, incrementing an internal
tick counter if bots aren't paused. It looks for any actions from player_events.lua that
bots should take in this new tick, then tries to execute each of them. Any that fail
are put in a list of failed actions, which are then retried every second for up to a
minute.

### List of Things to Implement
- Make this mod support multiple users and be more usable
  - Fewer hard-coded paths.
  - Have the player lists in a separate config file.
  - Make a script that writes into control.lua for the replay being duplicated.
  - Modify [replay_mod_generator.py](./replay_mod_generator.py) to read directly from the
    log file (and scan for "Checksum" to only read the last set of logs) and to have a flag
    to control which fixes to apply.
  - Modify replay_mod_generator.py or make a new script to package up the mod with a
    version number argument and different names for different groups.
- Better handling of when players help each other
  - Detect when an area is mostly done by one person but another person places some entities
    there. Then, set a `secondary_player_index` that will place the entity if it's unplaced
    a little while later (there are complications if things are supposed to get
    rotated/modified in some other way in the meanwhile, but that might be handled by
    the existing retry logic)
  - If two players place parts of the same belt line, add some slop in between that can be
    placed by either player, similar to previous entry.
- Have players simulate walking and dump location much less often
- Better grabbing of resources off belts (might not work at all?)
- Actually showing when other players fail to grab stuff?
- Map Visibility from other players? (use the radar entity?)
- Dupe entities?
- Deselect current player
- Cancel crafting should cancel stuff
- Actually track player crafting for better inventory management
- Generally track inventory of everything near players
- Remove items that are later picked up, as they are created
- Bars when settings pasted and guis closed and blueprint open
- Set bars and recipes more proactively while guis are open?
- blueprint splitter filter/priority?
- inserter filter filter slots past 1 and 2
- ghosts not getting destroyed by players
- Use can_place_entity correctly for ghosts (see [this forum thread](https://forums.factorio.com/viewtopic.php?f=25&t=103617))
- Flushing fluids