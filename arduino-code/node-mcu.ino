/*
https://medium.com/p/1b0724a78a7b/edit
*/
// Import required libraries
#include <ESP8266WiFi.h>
#define PubNub_BASE_CLIENT WiFiClient
#define PUBNUB_DEFINE_STRSPN_AND_STRNCASECMP
#include <PubNub.h>
#include <ArduinoJson.h>
#include <SimpleTimer.h>

// WiFi parameters
const char* ssid = "AirTies_Air5760_PRX6";
const char* password = "xxxx";

// PubNub Settings
const char* channel = "ProjectChannel";
char stateBuffer[550];
WiFiClient *client;

// Pin Settings
int pinCount = 4;
int pins[] = {5, 4, 0, 2};

// Timers
SimpleTimer sendTimer;
SimpleTimer recvTimer;


void setup(void)
{
  // Start Serial
  Serial.begin(115200);

  // Connect to WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");

  PubNub.begin("your-pub-key", "your-sub-key");

  // Print the IP address
  Serial.println(WiFi.localIP());

  // Setup pins as output
  for(int i=0;i<pinCount; i++) {
    pinMode(pins[i], OUTPUT);
  }

  // Setup Timers
  //sendTimer.setInterval(10000, sendPinStatus);
  //recvTimer.setInterval(500, handleCommands);
}

void sendPinStatus() {
  StaticJsonBuffer<550> jsonBuffer;
  JsonObject& root = jsonBuffer.createObject();
  JsonArray& devices = root.createNestedArray("devices");
  for(int i=0;i<pinCount; i++) {
    JsonObject& element = devices.createNestedObject();
    int val = digitalRead(pins[i]);
    element["p"] = pins[i];
    element["s"] = val;
  }
  root.printTo(stateBuffer, sizeof(stateBuffer));
  client = PubNub.publish(channel, stateBuffer);
  if (!client) {
    Serial.println("publishing error");
    return;
  }
  client->stop();
  Serial.println();
}

void handleCommands() {
  PubSubClient *pclient = PubNub.subscribe(channel);
  if (!pclient) {
      Serial.println("subscription error");
      delay(1000);
      return;
  }
  char buffer[64]; size_t buflen = 0;
  while (pclient->wait_for_data()) {
    buffer[buflen++] = pclient->read();
  }
  buffer[buflen] = 0;
  pclient->stop();
  Serial.println(buffer);

  if(buflen < 4) {
    Serial.println("Buffer length below 4");
    return;
  }
  
  // Parse
  const size_t bufferSize = JSON_ARRAY_SIZE(1) + JSON_OBJECT_SIZE(2) + 20;
  DynamicJsonBuffer jsonBuffer(bufferSize);
  
  JsonArray& root = jsonBuffer.parseArray(buffer);
  
  bool root_s = root[0]["s"]; // false
  int root_p = root[0]["p"]; // 3

  if(root_p == -1) {
    sendPinStatus();
    return;
  }

  digitalWrite(pins[root_p], root_s);

  Serial.println(root_s);
  Serial.println(root_p);
}

void loop() {
  handleCommands();
}

