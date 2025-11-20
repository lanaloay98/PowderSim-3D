🌌 PowderSim-3D — Advanced Element Sandbox
A mini Powder Toy game, but in full 3D — with sand, glass,  wood, bedrock, oil, fire, water, steam, ice, melting, freezing & voxel physics
Built in Godot 4

✨ About the Project

3D Mini Powder Toy is a real-time voxel-based element simulation sandbox.
It takes the core idea of the classic Powder Toy — sand, water, fire, physics —
and expands it into a fully interactive 3D world with temperature, melting, freezing, liquids, fire spread, steam, and more.

You can place elements, stack them, burn them, melt them, cool them, or simply watch them react.

Think “The Powder Toy”, but completely 3D.

🔥 Core Features
🧩 3D Voxel Simulation Engine

50×50×50 simulation grid

Place and delete elements freely

Line-mode placement (Shift + Click)

Ghost preview voxel

Adjustable placement distance

FPS player controller

🌡️ Temperature & State System

Every element has its own temperature:

Fire heats surroundings

Water boils → Steam

Water freezes → Ice

Ice melts → Water

Sand melts → Glass

Heat spreads between neighbors

Elements cool/heat toward ambient temperature

Mouse hover shows exact local temperature.

🌊 Fluid Simulation

Water and oil flow downward & sideways

Water floats above oil

Fire + Water → Steam

Steam rises and dissipates after a short lifetime

🔥 Fire Simulation

Burns wood

Ignites oil

Melts sand

Boils water

Temperature-driven spread

Fire has lifetime decay

Audio reacts to fire activity

🌲 Wood System

Voxel wood + physical RigidBody wood

Both flammable

Turns into fire when burned

Plays impact/wood audio

🔊 Full Audio System

Each element has sound effects:

Fire loop

Steam hiss

Water/oil splash

Glass place sound

Sand drop

Ice crack

Bedrock thunk

Wood impact

Footsteps

Air & sea sound in the background

Audio reacts dynamically based on which elements exist.

🧪 Available Elements
Element	Description	Emoji
Sand	Falls, slides, melts → glass	🏖️
Water	Flows, freezes, evaporates	💧
Oil	Flammable, flows	🛢️
Fire	Spreads, melts, boils	🔥
Ice	Freezes water, melts	🧊
Glass	Solid from melted sand	🪟
Steam	Created by boiling water	☁️
Wood	Burns, physical or voxel	🌲
Bedrock	Indestructible	🪨
🎮 Controls
Action	Input
Move	WASD and arows
Jump	Space
Look around	Mouse and R to allow it
Place block	Left Click
Delete block	Right Click
Line mode	Shift + Place
Adjust distance	Mouse Wheel
Open element menus	Left Click
Hover over ? to get a explanation to the game
📦 Project Structure
/ElementSim.gd     - Full simulation engine (fire, water, steam, temp, physics)
/Player.gd         - FPS controller, placement, deletion, ghost preview
/UI                - Menus and element selection system
/Scenes            - Elements (sand, water, fire, glass, etc.)
/Audio             - Sound effects for elements

🛠 Installation

Install Godot 4.x

Clone this repository:

git clone https://github.com/lanaloay98/PowderSim-3D.git


Open the project in Godot

Run the main scene

Enjoy the sandbox 🔥💧🧊

📅 Roadmap

Pressure simulation

Gas/smoke system

Electricity & conductive materials

Explosions

World saving/loading

More voxel elements

UI improvements

📜 License

MIT License

⭐ Support

If you found this interesting:

Leave a star ⭐

Share it

Contribute ideas or fixes


