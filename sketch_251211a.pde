import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
void setup(){
  size(400,400);
  rect(100,100,100,100);
  try{
            URL url = new URL("http://api.open-notify.org/iss-now.json");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("GET");
            conn.connect();
     
            // Check if connection is successful (HTTP response code 200 OK)
            int responseCode = conn.getResponseCode();
            if (responseCode != 200) {
                throw new RuntimeException("HttpResponseCode: " + responseCode);
            } 
            else {
                
                
                
                BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
                String inputLine;
                StringBuilder content = new StringBuilder();

                while ((inputLine = in.readLine()) != null) {
                    content.append(inputLine);
                }
                
                in.close();
                conn.disconnect();

    
                System.out.println("JSON Response: " + content.toString());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    
