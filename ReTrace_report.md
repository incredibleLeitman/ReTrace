# ReTrace
You are a happy factory worker. Go to work and regulate pipes while the grateful guards watch over you. And don't forget to eat your delicious sandwiches! Who knows what horrors you might encounter if you don't...

## Group Members
- Bittner Karl, if17b005
- Leithner Michael, if17b051
- Palluch Leon, if17b033
- Schmidt Nino, if17b037

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

## Time Spent report
A detailed report is at our GitLab issues with time tracking records. The following is a summary:

- Everyone: Programming and level design
- BK, PL, SN: 3D modelling
- BK: Audio
- LM: Most AI work
- PL: Pipe game
- SN: Particles

Most time was spent on programming. 3D Modeling and level design were roughly equal, followed by audio.

We saved about half of the work until a "game jam" shortly before the assignment (a few days of intensive work), so we mostly stayed in the budget. In the end, we were a bit over budget because of last-minute motivation and bugfixing.

### Total time spent
- BK: 46h
- LM: 40h
- PL: 50h
- SN: 40h

## Problems and Challenges
- Switching scenes while (sometimes) preserving the player state was challenging. In the end, we used singletons for most properties which need to be persistent.
- Level design is hard! Especially if you're designing 2 worlds at once which are blended depending on the player's health.
- Predictable (as in non-frustrating) AI behavior was tricky. If the gaze even slightly goes through a wall, it feels like the enemy cheated...
- Rigging in Blender

## Resources, Sources, References and Links
Everything except for the logger (https://godotengine.org/asset-library/asset/362) and the annoying cock crow (https://www.salamisound.de/1304440-hahn-kraehen-kikeriki) is by us. We used:

- Godot (Engine) and the docs: http://docs.godotengine.org/
- Blender (3D Modeling)
- GIMP (Particle textures)
- Ardour (Music)
- Audacity (Sound effects)

## Self Assesment
Game Design: 35
Technical/Unity Features: 30/0
meta: 15

total: 80