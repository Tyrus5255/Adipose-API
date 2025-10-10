# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
