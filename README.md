🌌 PowderSim-3D

A fully 3D voxel-based Powder Toy–style simulation — built in Godot 4

A real-time 3D voxel sandbox inspired by The Powder Toy, rebuilt in three dimensions.
Simulate sand, water, fire, oil, glass, ice, steam, wood, and more — all interacting through physics, temperature, and voxel logic.

📸 Preview
<p align="center"> <img src="https://github.com/user-attachments/assets/9944ce7d-30f3-4057-95e9-aa065b09055a" width="45%" /> <img src="https://github.com/user-attachments/assets/3b6d4c82-6265-4d1a-8fa8-7c7b5fccc136" width="45%" /> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/a007cd6c-4492-479a-8a43-42707bb083f6" width="45%" /> <img src="https://github.com/user-attachments/assets/69b7a835-c626-4957-b5fc-b657d1040184" width="45%" /> </p>
✨ Overview

A real-time voxel simulation sandbox.
Every voxel follows physical rules: falling, flowing, burning, melting, freezing, heating, cooling, and reacting.

Place, delete, draw lines, build structures — or watch chaos unfold.

🌟 Features
🧩 3D Voxel Simulation

50×50×50 simulation grid

Instant voxel placement & deletion

Line-mode drawing (Shift + Click)

Ghost placement preview

Adjustable placement distance

First-person character controller

<p align="center"> <img src="https://github.com/user-attachments/assets/a8f1c2b6-774c-4375-8e21-e383bd32a071" width="45%" /> <img src="https://github.com/user-attachments/assets/069abc72-420b-4d5f-b173-7589146df475" width="45%" /> </p> <p align="center"> <!-- Sand falling --> <img src="https://github.com/user-attachments/assets/248d12b1-8030-4303-b68d-9bc97fed0912" width="45%"/> </p>
🌡️ Temperature & State System

Each voxel keeps its own temperature and reacts accordingly:

Water boils → steam

Water freezes → ice

Ice melts → water

Sand melts → glass

Fire heats surroundings

Heat diffuses between neighbors

Ambient cooling/warming

Hover thermometer shows exact temperature

🔥 Temperature / State GIFs
<p align="center"> <img src="https://github.com/user-attachments/assets/0fb182bb-2464-48c3-9e6e-5dbed5593b2f" width="45%" /> <img src="https://github.com/user-attachments/assets/bff8cd25-b61f-42be-a166-58160e6a2d3a" width="45%" /> </p> <p align="center"> <img src="https://github.com/user-attachments/assets/785ab0f2-96f8-46ac-9070-a470bacd628a" width="45%" /> <img src="https://github.com/user-attachments/assets/412efbc4-1cc9-48f2-a17a-11748757ca5e" width="45%" /> </p>
🌊 Liquid Physics

Water & oil flow and spread

Water floats above oil

Fire + water → steam

Steam rises & dissipates

Stable liquid-swapping logic

<p align="center"> <!-- oil floating, water interactions --> <img src="https://github.com/user-attachments/assets/28bc8b24-e43f-4eb4-b03a-9d9e564f5263" width="45%" /> </p>
🔥 Fire Simulation

Burns wood

Ignites oil

Melts sand

Boils water

Temperature-based fire spread

Fire decay system

Dynamic fire audio

🔥 Fire GIFs
<p align="center"> <img src="https://github.com/user-attachments/assets/5b0dcfbc-cf82-4c01-bad9-227f69723729" width="45%" /> <img src="https://github.com/user-attachments/assets/8c5f1549-dba2-46e3-9b82-a1068cbee3ef" width="45%" /> </p>
🌲 Wood System

Two wood types:

Voxel Wood

Behaves like other voxels

Burns, interacts with fire

RigidBody Wood

Falls, rotates, collides

Physically simulated

Burns dynamically

<p align="center"> <img src="https://github.com/user-attachments/assets/a6ed462c-cf64-443e-94b1-a1d0d55b69b8" width="45%" /> <img src="https://github.com/user-attachments/assets/82636e4b-506e-4e60-aef3-008329a9068d" width="45%" /> </p>
🔊 Dynamic Audio

Fire loop

Steam hiss

Water & oil splashes

Sand drops

Ice cracking

Glass clicking

Wood impact

Bedrock thud

Footsteps

Ambient audio adapts to materials

🧪 Available Elements
Element	Behavior	Emoji
Sand	Falls, slides, melts → glass	🏖️
Water	Flows, freezes, evaporates	💧
Oil	Flammable, flows	🛢️
Fire	Spreads, heats, ignites	🔥
Ice	Freezes water, melts	🧊
Glass	Solid, made from melted sand	🪟
Steam	Rises, dissipates	☁️
Wood	Burns (voxel & RigidBody)	🌲
Bedrock	Indestructible	🪨
🎮 Controls
Action	Input
Move	WASD / Arrow Keys
Jump	Space
Look	Mouse
Enable mouse-look	R
Place block	Left Click
Delete block	Right Click
Line-mode	Shift + Left Click
Adjust placement distance	Mouse Wheel
Open element menu	Left Click
Show help	Hover ?
📦 Project Structure
/ElementSim.gd      # Simulation engine (fire, liquids, heat, logic)
/Player.gd          # FPS controls, placement, ghost preview
/UI/                # Element picker, menus
/Scenes/            # Voxel element scenes
/Audio/             # Sound effects

🛠 Installation
git clone https://github.com/lanaloay98/PowderSim-3D.git


Install Godot 4.x

Open the project

Run the main scene

Enjoy your voxel sandbox 🔥💧🧊

🧭 Roadmap

Pressure simulation

Gas / smoke system

Electricity & conductivity

Explosions

Save / load system

More voxel materials

UI upgrades

Performance improvements
