import java.net.*;
import java.io.*;

// Original variable names for the current display position
float issLat = 0;
float issLon = 0;

// New variables needed to "cache" the incoming data
float targetLat = 0;
float targetLon = 0;

float lerpAmt = 0.05; // Smoothing speed
boolean firstUpdate = true;
boolean isFetching = false;

PImage earthMap;
PFont font;

void setup() {
  // size(800, 400);
  fullScreen();
  earthMap = loadImage("earth_map.png");
  
  // Start the thread using your original function name
  thread("updateISSPosition");
}

void draw() {
  // --- 1. Draw Map ---
  if (earthMap != null) {
    image(earthMap, 0, 0, width, height);
  } else {
    background(0);
  }

  // --- 2. Calculate Smooth Movement ---
  if (!firstUpdate) {
    // We move issLat (current) toward targetLat (cached network data)
    issLat = lerp(issLat, targetLat, lerpAmt);
    issLon = lerp(issLon, targetLon, lerpAmt);
    
    // Fix for the Dateline (jumping from 180 to -180)
    if (dist(issLat, issLon, targetLat, targetLon) > 100) {
      issLat = targetLat;
      issLon = targetLon;
    }
  }

  // --- 3. Trigger Update ---
  if (frameCount % 60 == 0 && !isFetching) {
    thread("updateISSPosition");
  }

  // --- 4. Draw ISS using original variables ---
  
  // Map longitude (-180 to 180) and latitude (-90 to 90) to screen coordinates
  float x = map(issLon, -180, 180, 0, width);
  float y = map(issLat, 90, -90, 0, height); 
  
  // Draw the ISS
  fill(255);
  noStroke();
  rectMode(CENTER); // Centers the rect on the coordinate
  rect(x, y, 10, 10);
  
  // Display coordinates
  fill(255);
  stroke(0);
  strokeWeight(4);
  textAlign(LEFT);
  textSize(20);
  text("Lat: " + issLat, 20, 40);
  text("Lon: " + issLon, 20, 80);
  
  if(firstUpdate && issLat == 0){
    isLoading();
  }
}

// This function now runs in the background thread
void updateISSPosition() {
  isFetching = true;
  try {
    // We use Processing's built-in JSON loader (safer than manual string parsing)
    JSONObject json = loadJSONObject("http://api.open-notify.org/iss-now.json");
    JSONObject position = json.getJSONObject("iss_position");
    
    // Store the fresh data in "target" variables
    float newLat = position.getFloat("latitude");
    float newLon = position.getFloat("longitude");
    
    if (firstUpdate) {
      // If first time, snap issLat directly to target so it doesn't slide from 0,0
      issLat = newLat;
      issLon = newLon;
      targetLat = newLat;
      targetLon = newLon;
      firstUpdate = false;
    } else {
      // Otherwise, update the target cache
      targetLat = newLat;
      targetLon = newLon;
    }
    
    println("Updated Cache -> Lat: " + targetLat + ", Lon: " + targetLon);
    
  } catch (Exception e) {
    println("Error fetching ISS position: " + e);
  }
  isFetching = false;
}

void isLoading(){
  fill(255);
  stroke(0);
  strokeWeight(5);
  textAlign(LEFT);
  text("LOADING...", 20, 120);
}
