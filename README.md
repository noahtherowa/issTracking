Date: 1/23/26
Language: Java (Processing)

Description
The ISS Tracker is a visualization application built in the Processing environment. It connects to the Open Notify API to fetch the real-time latitude and longitude of the International Space Station. The application plots the station's location on a global map and calculates the live distance (in miles) between the ISS and a specific home location (MCST).

Features
Real-Time Tracking: Fetches live JSON data from api.open-notify.org every 60 frames (~1 second).
Data Visualization: Maps geographic coordinates (Latitude/Longitude) to screen pixels over an equirectangular earth map.
Smooth Animation: Uses Linear Interpolation (LERP) to animate the ISS icon smoothly between coordinate updates.
Distance Calculation: Implements the Haversine Formula to accurately calculate the Great Circle distance between the ISS and the target home coordinates.
Interactive UI: Features a start menu, a Heads-Up Display (HUD) with live stats, and keyboard navigation.
Installation & Setup
Prerequisites:

Download and install Processing 4.
Ensure you have an active internet connection (required for API data).
Folder Structure:
Create a folder named ISSTracker. Inside that folder, ensure your file structure looks like this:

text

ISSTracker/
├── ISSTracker.pde       # The main source code
├── data/                # Required folder for assets
│   ├── earth_map.png    # Background map image
│   └── iss.png          # Icon for the space station
└── README.md
Running the Code:

Open ISSTracker.pde in the Processing IDE.
Press the Play button (or Ctrl + R).
Controls
Key	Action	Context
ENTER	Start Tracking	Main Menu
E	Exit Program	Main Menu
M	Return to Menu	Tracker Screen
Configuration
To change the "Home" location for distance calculations, modify the following variables at the top of the code:

Java

// Coordinates for MCST (or your custom location)
float homeLat = 40.8785;
float homeLon = -74.4791;
Technical Details
API Used: Open Notify ISS Now
Edge Case Handling: Includes logic to handle the International Date Line crossing (prevents the icon from flying across the screen when longitude flips from 180 to -180).
Threading: The initial data fetch is threaded to prevent the application from freezing on startup.
Credits
Developer: Noah Blum
ISS Data: Open Notify API
Map/Icon Assets: https://www.pngitem.com/middle/JTxhii_international-space-station-icon-icon-hd-png-download/
                 https://en.wikipedia.org/wiki/World_map#/media/File:Mercator_projection_SW.jpg
