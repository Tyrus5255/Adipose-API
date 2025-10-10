# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-10-10

### Changes
- Fully refactored code to distill the library to its essentials. This library will now act as framework for the upcoming helper script which can be found at [Tyrus5255/Adipose-API](https://github.com/Tyrus5255/Adipose-API) (name soon to be changed).
- Made `adipose.granularWeight` and `adipose.stuffed` public variables.
- Made `adipose.setWeight` a ping, named `pings.AdiposeSetWeight`, and cleaned its code:
  - Check whether there are stages or not. If there aren't, abort.
  - Check whether the player is loaded before getting the saturation, fixing a crash that would occur when the host isn't loaded for other clients.
  - Enforced loading, saving and usage of integer values for weight, to reduce ping size to 4 bytes.
- Updated `adipose.weightStage():newStage` metatable to now accept `scalingList`, helper table to store extra scaling information (specifically made to make scaling easier with the [Pehkui Figura](https://github.com/nexidict/Pehkui-Figura) script), and made `granularAnim` and `stuffedAnim` set `nil` to allow null check instead of strings checks.

### Added
- Added `adipose.onStageChange` lambda function, allowing to assign behavior externally upon weight stage change.
- Added death check, sending a ping on respawn.
- Added `doTimer` function to standardize timer usage.
- Added proximity update and ping system: this makes the script send ping whenever new players get near the host, making sure that the model is properly updated for everyone involved.
- Added `events.tick` for model initialization, running only for the host, delaying the first update ping upon model loading.
- Added `setScaling` function to accomodate the addition of weight stage metatable.

### Removed
- Specific Adipose Config removed: the model will now create its own config instead, and every Adipose value will now be saved in there.
- Removed Pehkui support: this in place of the new script at [Pehkui Figura](https://github.com/nexidict/Pehkui-Figura), removing the need of hardcoding. Handling Pehkui scaling will be done by the handler script in the future.
- Removed `checkFood` function: this was causing issues to the data passed for pings. This will be completely replaced by the helper script.
- Removed Gluttonous Growth (GG) compatibility: this will be handled by the helper script instead.
- Removed lots of outdated logic for deprecated functionality.

## [1.2.0] - 2025-10-08

### Bugs Fixed

- Add fallback for `gg:curcalories`.
- Address documentation warnings from [Figura VS Code Docs](https://github.com/GrandpaScout/FiguraRewriteVSDocs/).
- Fix error caused by using `player:getpermissionlevel()` with Essential mod.
- Animations in stages other than the current one no longer play.
- Stuffed value is now expressed as a global variable.
- Animation fixes.

### New Features

- Mention Figura settings in README to enable chat messages for commands to work.
- Organise README like Figura docs.

### Changes

- Delete Universal WG Model

## [1.1.0] - 2025-07-03

### Bugs Fixed

- Changes to Adipose in the universal WG model were not merged with the top-level file.

### New Features

- Made `adipose.setScale` public.
- Add `currentWeightStage` to config file.

## [1.0.1] - 2025-06-23

### Bugs Fixed

- `setHitboxState` set the hitbox width value for both width and height, instead of setting their respective scaling options.

## [1.0.0] - 2025-06-04

- First release.

### New Features 

- Staged WG
- Granular WG
- Visual stuffed belly
- Saved weight between model reloads
- Customizable hitboxes (when pehkui or pehkui4all is installed)
- Optional Overstuffed compatibility
