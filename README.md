# Retrace

You are a happy factory worker. Go to work and regulate pipes while the grateful guards watch over you. And don't forget to eat your delicious sandwiches! Who knows what horrors you might encounter if you don't...

![retrace screenshot](https://github.com/incredibleLeitman/ReTrace/blob/main/screenshot.png "ReTrace Screenshot")

## Controls
- standard fps: walk with WASD, look around with mouse
- eat delicious sandwich 'F'
- interact with objects 'E'
- close game 'Esc'

## Gameplay Features
- day-night cycle
- multiple areas
- AI
    - motivation controlled
    - only act if player within gaze
    - walk along pre-defined path, follow player or run after and catch player
- custom sounds
- custom models
- main menu
- world changes depending on health
- regulate health by eating sandwiches
- doors with keycards (minimum level required) or keys (exact level requried)
- minigame for regulating and mixing pipes to get the desired color

## Technical Features (Unity and other)
- Godot :D
- Main menu
- In-game UI
- Particles
- Pathfinding using Paths (to walk along) and NavMesh (to avoid obstacles)
- AudioMixer for blending and manipulating audio based on health
- Blending different views
    - VisualLayers for choosing which view a mesh or light belongs to
    - Shader for blending views based on health
- Different collision layers based on health
- Various materials
- Animations (player nodding while walking, main menu text appearance, ...)
- Different kinds of light (directional, spotlight, omnilight)
