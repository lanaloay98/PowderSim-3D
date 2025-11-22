🌌 PowderSim-3D
A fully 3D voxel-based Powder Toy simulation — built in Godot 4

A real-time 3D voxel sandbox inspired by The Powder Toy, but completely reimagined in three dimensions.
Simulate sand, water, fire, oil, glass, ice, steam, wood, and more — all interacting through physics, temperature, and voxel logic.

📸 Preview
<p align="center"> <img src="https://github.com/user-attachments/assets/9944ce7d-30f3-4057-95e9-aa065b09055a" width="25%" /> <br /><br /> <img src="https://github.com/user-attachments/assets/3b6d4c82-6265-4d1a-8fa8-7c7b5fccc136" width="25%" /> <br /><br /> <img src="https://github.com/user-attachments/assets/a007cd6c-4492-479a-8a43-42707bb083f6" width="25%" /> <br /><br /> <img src="https://github.com/user-attachments/assets/69b7a835-c626-4957-b5fc-b657d1040184" width="25%" /> </p>
✨ Overview

PowderSim-3D is a real-time voxel simulation sandbox.
Every voxel behaves according to physical rules: falling, flowing, burning, melting, freezing, heating, cooling, and more.
You can place voxels freely, delete them, draw lines, build structures, or simply watch the chaos unfold.


🌟 Features
🧩 3D Voxel Simulation

50×50×50 simulation grid
![sandGIF](https://github.com/user-attachments/assets/a8f1c2b6-774c-4375-8e21-e383bd32a071)
![BedrockGlassGIF](https://github.com/user-attachments/assets/069abc72-420b-4d5f-b173-7589146df475)
![WoodSnowGIF](https://github.com/user-attachments/assets/a6ed462c-cf64-443e-94b1-a1d0d55b69b8)
![OilWaterGIF](https://github.com/user-attachments/assets/82636e4b-506e-4e60-aef3-008329a9068d)

Instant voxel placement & deletion

Line-mode placement (Shift + Click)

Ghost placement preview

Adjustable placement distance

First-person controller

🌡️ Temperature & State System

Each voxel has its own temperature

Fire heats surroundings

Water boils → steam

Water freezes → ice

Ice melts → water

Sand melts → glass

Heat diffusion across neighbors

Cooling & warming toward ambient

Hover thermometer (displays exact temp)

🌊 Liquid Physics

Water & oil flow & spread

Water floats above oil

Fire + water → steam

Steam rises and dissipates

Smooth liquid swapping logic

🔥 Fire Simulation

Burns wood

Ignites oil

Melts sand

Boils water

Temperature-driven spread

Fire lifetime & decay

Dynamic fire audio

🌲 Wood System

Voxel Wood — follows voxel rules

Physical Wood (RigidBody) — falls, rotates, burns

Both types burn and interact with fire & heat

🔊 Dynamic Audio

Fire loop

Steam hiss

Water/oil splashes

Sand drop

Ice crack

Glass click

Wood impact

Bedrock thud

Footsteps

Ambient background adjusts based on materials in scene

🧪 Available Elements
Element	Behavior	Emoji
Sand	Falls, slides, melts → glass	🏖️
Water	Flows, freezes, evaporates	💧
Oil	Flammable, flows	🛢️
Fire	Spreads, melts, ignites, heats	🔥
Ice	Freezes water, melts	🧊
Glass	Solid, formed from melted sand	🪟
Steam	Rises, dissipates	☁️
Wood	Burns (voxel + RigidBody)	🌲
Bedrock	Indestructible	🪨
🎮 Controls
Action	Input
Move	W A S D / Arrow Keys
Jump	Space
Look	Mouse
Enable mouse-look	R
Place block	Left Click
Delete block	Right Click
Line-mode	Shift + Left Click
Adjust placement distance	Mouse Wheel
Open element menu	Left Click
Show help/tooltips	Hover ?
📦 Project Structure
/ElementSim.gd      # Simulation engine (fire, water, oil, heat, logic)
/Player.gd          # FPS controller, placement, ghost preview
/UI/                # Menus, element selector UI
/Scenes/            # Voxel scenes (sand, water, fire, etc.)
/Audio/             # All sound effects

🛠 Installation
git clone https://github.com/lanaloay98/PowderSim-3D.git


Install Godot 4.x

Open the project

Run the main scene

Enjoy the sandbox 🔥💧🧊

🧭 Roadmap

Pressure simulation

Gas / smoke system

Electricity & conductivity

Explosions

Save / load system

More voxel materials

Improved UI

Performance improvements




