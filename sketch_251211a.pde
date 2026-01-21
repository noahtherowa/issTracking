import java.net.*;
import java.io.*;

float issLat = 0;
float issLon = 0;
PImage earthMap;

void setup() {
  //size(800, 400);
  fullScreen();
  earthMap = loadImage("earth_map.png");
}

void draw() {
  // Draw the earth map as background (or black if no image loaded)
  if (earthMap != null) {
    image(earthMap, 0, 0, width, height);
  } else {
    background(0);
  }
  
  // Update ISS position every second
  if (frameCount % 60 == 0) {
    updateISSPosition();
  }
  
  // Map longitude (-180 to 180) and latitude (-90 to 90) to screen coordinates
  float x = map(issLon, -180, 180, 0, width);
  float y = map(issLat, 90, -90, 0, height); // Inverted because y increases downward
  
  // Draw the ISS as a white square
  fill(255);
  noStroke();
  rect(x - 5, y - 5, 10, 10);
  
  // Display coordinates in corner
  fill(255);
  stroke(0);
  strokeWeight(4);
  textAlign(LEFT);
  text("Lat: " + issLat, 10, 20);
  text("Lon: " + issLon, 10, 40);
  noStroke();
  
  if(issLat == 0 && issLon == 0){
    isLoading(issLat, issLon);
}
}
void updateISSPosition() {
  try {
    URL url = new URL("http://api.open-notify.org/iss-now.json");
    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
    conn.setRequestMethod("GET");
    
    BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
    String json = in.readLine();
    in.close();
    
    // Parse the JSON string
    issLat = parseValue(json, "latitude");
    issLon = parseValue(json, "longitude");
    
    println("Lat: " + issLat + ", Lon: " + issLon);
  } catch (Exception e) {
    println("Error fetching ISS position");
  }
}

float parseValue(String json, String key) {
  int start = json.indexOf("\"" + key + "\": \"") + key.length() + 5;
  int end = json.indexOf("\"", start);
  return Float.parseFloat(json.substring(start, end));
}
void isLoading(float x,float y){
  fill(255);
  stroke(0);
  strokeWeight(5);
  textAlign(LEFT);
  text("LOADING", issLat, issLon+60);

  
}
