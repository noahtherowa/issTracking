/*
 * Name: Noah Blum
 * Date: 1/23/26
 *  ISS Tracker Project
 */

import java.net.*;
import java.io.*;

float issLat = 0;
float issLon = 0;
float targetLat = 0;
float targetLon = 0;

// mcst coords maybe
float homeLat = 40.8785;
float homeLon = -74.4791;

float lerpAmt = 0.05; 
boolean firstUpdate = true;
boolean isFetching = false;

PImage earthMap;
PImage issIcon;
PFont font;

int currentState = 0; 
/**
 * Sets up the application environment.
 * Initializes the window to full screen, loads image assets,
 * and starts the initial data fetching thread.
 */
void setup() {
  fullScreen();
  earthMap = loadImage("earth_map.png"); 
  issIcon = loadImage("iss.png");
  thread("updateISSPosition");
}
/**
 * The main animation loop.
 * Clears the background and delegates rendering to specific methods
 * based on the current program state (Menu or Tracker).
 */
void draw() {
  background(0);

  switch(currentState) {
    case 0:
      drawMenu();
      break;
    case 1:
      drawTracker();
      break;
    default:
      println("uhoh broken");
      break;
  }
}
/**
 * Renders the main menu interface.
 * Displays the title and instructions for user input.
 */
void drawMenu() {
  textAlign(CENTER, CENTER);
  fill(255);
  textSize(40);
  text("ISS TRACKER", width/2, height/2 - 50);
  
  textSize(20);
  text("Press 'ENTER' to Start Tracking", width/2, height/2 + 20);
  text("Press 'E' to Exit Program", width/2, height/2 + 50);
}

/**
 * Renders the primary tracking interface.
 * Handles map display, coordinate interpolation, map projection logic,
 * and icon rendering.
 */
void drawTracker() {
  if (earthMap != null) {
    imageMode(CORNER);
    image(earthMap, 0, 0, width, height);
  }

  if (!firstUpdate) {
    issLat = lerp(issLat, targetLat, lerpAmt);// lerp to move iss smoothly
    issLon = lerp(issLon, targetLon, lerpAmt); 
    
    // Fix for Dateline crossing (ai)
    // --- Dateline Crossing Fix ---
    // If the ISS moves from 179 longitude to -179 (crossing the date line),
    // LERP will try to animate all the way across the screen. 
    // If distance is too large, snap immediately to the new position.
    if (dist(issLat, issLon, targetLat, targetLon) > 100) {
      issLat = targetLat;
      issLon = targetLon;
    }
  }

  if (frameCount % 60 == 0) {
    updateISSPosition();
  }

  float x = map(issLon, -180, 180, 0, width);  // Map longitude (-180 to 180) to screen width (0 to width)
  float y = map(issLat, 90, -90, 0, height); // Map latitude (90 to -90) to screen height (0 to height)
   
   //fill(255, 0, 0);       
  //noStroke();            
  //rectMode(CENTER);     
  //rect(x, y, 15, 15);    
  
   if (issIcon != null) {// upload iss incon
    imageMode(CENTER);
    image(issIcon, x, y, 20, 20); 
  } else {
    fill(255, 0, 0);
    rectMode(CENTER);
    rect(x, y, 15, 15);
  }
  float distToHome = calculateDistToHome(issLat, issLon);  
  drawHUD(issLat, issLon, distToHome);
}

/**
 * Renders the Heads-Up Display (HUD) overlay.
 * Shows text statistics regarding location and distance.
 *
 * @param lat      The current latitude of the ISS.
 * @param lon      The current longitude of the ISS.
 * @param distance The calculated distance from Home in miles.
 */

void drawHUD(float lat, float lon, float distance) {
  
  fill(255);
  textAlign(LEFT);
  textSize(18);
 
  text(String.format("Lat:  %.4f", lat), 20, 60); //boom formatting
  text(String.format("Lon:  %.4f", lon), 20, 90);
  
  // Display the calculation from our return method
  fill(0, 255, 0);
  text(String.format("Dist to MCST: %.2f miles", distance), 20, 120);
  
  if(firstUpdate) {
    fill(255, 255, 0);
    text("getting darta...", 20, 180);
  }
  
  textSize(14);
  fill(200);
  text("Press 'M' for Menu", 20, height - 30);
}
/**
 * Calculates the Great Circle distance between the ISS and the Home location
 * using the Haversine formula.
 *
 * @param currentLat The latitude of the ISS.
 * @param currentLon The longitude of the ISS.
 * @return The distance in miles.
 */

float calculateDistToHome(float currentLat, float currentLon) { // 100% ai generated fucntion
  float R = 3958.8; // Radius of the earth in miles
  
  float dLat = radians(homeLat - currentLat);
  float dLon = radians(homeLon - currentLon);
  
  float a = sin(dLat/2) * sin(dLat/2) +
            cos(radians(currentLat)) * cos(radians(homeLat)) * 
            sin(dLon/2) * sin(dLon/2);
            
  float c = 2 * atan2(sqrt(a), sqrt(1-a)); 
  float d = R * c; // Distance in mi
  
  return d; 
}
/**
 * Connects to the Open Notify API to retrieve the current JSON data.
 * Updates the global targetLat and targetLon variables.
 * Handles JSON parsing and potential network exceptions.
 */
void updateISSPosition() {
  isFetching = true;
  try {
    JSONObject json = loadJSONObject("http://api.open-notify.org/iss-now.json");
    JSONObject position = json.getJSONObject("iss_position");
    
    float newLat = position.getFloat("latitude");
    float newLon = position.getFloat("longitude");
    
    if (firstUpdate) {
      issLat = newLat;
      issLon = newLon;
      targetLat = newLat;
      targetLon = newLon;
      firstUpdate = false;
    } else {
      targetLat = newLat;
      targetLon = newLon;
    }
    
  } catch (Exception e) {
    println("Error: " + e);
  }
  isFetching = false;
}

/**
 * Handles keyboard input events.
 * Controls state switching between Menu and Tracker, and exiting the app.
 */
void keyPressed() {
  if (currentState == 0) {
    if (key == ENTER || key == RETURN) {
      currentState = 1; // Switch to Tracker
    }
    if (key == 'e' || key == 'E') {
      exit(); // RUBRIC: Clear exit condition
    }
  } else if (currentState == 1) {
    if (key == 'm' || key == 'M') {
      currentState = 0; // Switch back to Menu
    }
  }
}

