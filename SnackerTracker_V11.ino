/*

  Snacker Tracker (SKRTKR)
  Molnar Lab 2024
  Marissa Mueller 

  SKRTKR - Real-Time Self-Contained Food Measuring Device
  SnackerTracker_V11

*/

/*

  Code adapted from the following sources:
  https://makersportal.com/blog/2019/5/12/arduino-weighing-scale-with-load-cell-and-hx711
  https://docs.arduino.cc/tutorials/mkr-mem-shield/mkr-mem-shield-data-logger

  Overview:

  1) Device Calibration: The user first enters the known mass of the  
   food which is to be used for calibration. The device then reads force
   measurements from a load cell and HX711 adapter and calibrates
   the system accordingly.

  2) SD Initialisation: The device initialises, opens, and formats
   a micro-SD card on the stacked Arduino MKR MEM Shield (atop the 
   Arduino MKR WiFi 1010) for subsequent recording.

  3) Continuous Data Recording and Relay: Real-time mass, light, and 
   time measurements are saved locally to the SD card in a .csv format 
   which is compatible with the subsequent MATLAB analysis script. 
   Information regarding the status of two switches on the device are 
   also included as an optional means of marking events and filtering 
   data (also in the MATLAB script). Additionally, in this script, the 
   device is linked to the Arduino IoT such that data is relayed via 
   WiFi to the Cloud. Data can be visualised in real-time through any 
   linked device for monitoring purposes and, in the future, to enable 
   read-write capabilities.

*/

#include <Q2HX711.h>
#include <SPI.h>
#include <SD.h>
#include <RTCZero.h>
// The chip select pin for the MEM shield
const int chipSelect = 4;
// Set pin for HX711 clock registration (SCK)
const byte hx711_clock_pin = 2;
// Set pin for HX711 data input (DT)
const byte hx711_data_pin = 3;
// Set pin for LDR data input
int sensorPin = A0;
// Maximum number of input characters
const byte numChars = 32;
// Character array for input
char receivedChars[numChars];
// Character array for a temporary copy of input
char tempChars[numChars];
// Float variable to be populated with input
float floatFromPC = 0.0;
// Character array to hold measurement units
char messageFromPC[numChars] = {0};
// Boolean for new data control
boolean newData = false;
// Calibration mass to be overwritten
float cal_mass = 10;
// Temporary calibration variable
long x1 = 0L;
// Temporary calibration variable
long x0 = 0L;
// Number of values to be averaged for each mass measurement
float avg_size = 10.0;
// Prepare the HX711
Q2HX711 hx711(hx711_data_pin, hx711_clock_pin);
// Initialise column headers
String columnheaders = "";
// Set the current (initial) time and date
const byte seconds = 0;
const byte minutes = 0;
const byte hours = 12;
const byte day = 1;
const byte month = 1;
const byte year = 24;
// Set the time delay by which data is to be collected (frequency = 1/(timedelay/1000) recordings per second) 
const int timedelay = 1000;
// Initialise looped data row entries
String dataString = "";
// Initialise sensor values
int sensor1Val = 0;
int sensor2Val = 0;
// Create an RTC object
RTCZero rtc;

void setup() {
  
  // Delay to stabilise connection
  delay(1000);
  // Prepare the serial port and prompt for input
  Serial.begin(9600);
  // Set pin for switch 1 (top) input (event marker)
  pinMode(6, INPUT_PULLUP);
  // Set pin for switch 2 (bottom) input (wireless connection)
  pinMode(7, INPUT_PULLUP);
  while (!Serial);
  Serial.println("Enter the calibration mass (e.g., for 24.08 g, enter '<24.08,g>')");
  Serial.println();
  // Until input is provided
  while (Serial.available() == 0) {}
  // Refer to end-of-script functions
  recvWithStartEndMarkers();
  // Retrieving and separating input data
  if (newData == true) {
    // Creating a temporary copy to protect original data
    strcpy(tempChars, receivedChars);
    // Separate input components
    parseData();
    // Display parsed inputs
    showParsedData();
    newData = false;
  }
  // Assign calibration mass
  cal_mass = floatFromPC;
  // Tare the configuration
  for (int ii = 0; ii < int(avg_size); ii++) {
    delay(10);
    x0 += hx711.read();
  }
  x0 /= long(avg_size);
  Serial.println();
  // Add calibration mass for system configuration
  Serial.println("Add calibrated mass...");
  // Calibrating to cal_mass. Enter 180000 to allow 3 minutes to do so (a good number)
  delay(180000);
  int ii = 1;
  while (true) {
    if (hx711.read() < x0 + 10000) {
    } else {
      ii++;
      delay(2000);
      for (int jj = 0; jj < int(avg_size); jj++) {
        x1 += hx711.read();
      }
      x1 /= long(avg_size);
      break;
    }
  }
  Serial.println("Calibration Complete");
  Serial.println();
  // Initialise the SD card
  Serial.println("Initializing SD card...");
  // Determine if the card is present and if it can be initialised
  if (!SD.begin(chipSelect)) {
    Serial.println("Card failed, or not present.");
    // Remain in this loop
    while (1);
  }
  Serial.println("Card initialized.");
  Serial.println();
  // Check if file "skrtkr.txt" exists. If it does, delete it
  if (SD.exists("skrtkr.txt")) {
    // Delete, if it exists
    SD.remove("skrtkr.txt");
    Serial.println("'skrtkr.txt' detected and cleared from the SD card.");
  }
  // Check if file "skrtkr.csv" exists. If it does, delete it as well
  if (SD.exists("skrtkr.csv")) {
    // Delete, if it exists
    SD.remove("skrtkr.csv");
  }
  // Create and open the file to be saved on the SD card
  File dataFile = SD.open("skrtkr.txt", FILE_WRITE);
  // Check that the file can be opened, then proceed with recordings
  if (!dataFile) { 
    // Print an error message if the file is not available
    Serial.println("Error opening file");
    return;
  }
  Serial.println("Begin recording.");
  Serial.println();
  // Create column headings
  columnheaders = "rtc_date_yyyy-mm-dd,rtc_time_h:m:s,s1_em_status,s2_wl_status,lc_mass,ldr_reading";
  // Print column headers to the SD card data file
  dataFile.println(columnheaders);
  dataFile.close();
  // Initialise the RTC and associated variables
  rtc.begin(); 
  // Set the time
  rtc.setHours(hours);
  rtc.setMinutes(minutes);
  rtc.setSeconds(seconds);
  // Set the date
  rtc.setDay(day);
  rtc.setMonth(month);
  rtc.setYear(year);
  
}

void loop() {
  
  // Determine the HX711-LC reading by averaging
  long reading = 0;
  for (int jj = 0; jj < int(avg_size); jj++) {
    reading += hx711.read();
  }
  reading /= long(avg_size);
  // Calculate the mass according to the linear calibration model
  float ratio_1 = (float) (reading - x0);
  float ratio_2 = (float) (x1 - x0);
  float ratio = ratio_1 / ratio_2;
  float mass = cal_mass * ratio;
  sensor1Val = digitalRead(6);
  if (sensor1Val == 1) { 
    sensor1Val = 0;
  }
  else if (sensor1Val == 0) { 
    sensor1Val = 1;
  }
  sensor2Val = digitalRead(7);
  if (sensor2Val == 1) { 
    sensor2Val = 0;
  }
  else if (sensor2Val == 0) { 
    sensor2Val = 1;
  }
  // Add timestamp information to dataString for the present input line to be logged
  dataString = "20";
  dataString += rtc.getYear();
  dataString += "-";
  dataString += rtc.getMonth();
  dataString += "-";
  dataString += rtc.getDay();
  dataString += ",";
  dataString += rtc.getHours();
  dataString += ":";
  dataString += rtc.getMinutes();
  dataString += ":";
  dataString += rtc.getSeconds();
  dataString += ",";
  dataString += sensor1Val;
  dataString += ",";
  dataString += sensor2Val;
  dataString += ",";
  dataString += mass;
  dataString += ",";
  dataString += analogRead(A0);
  // Open the data file
  File dataFile = SD.open("skrtkr.txt", FILE_WRITE);
  // Log data if the SD file is available
  if (dataFile) {
    dataFile.println(dataString);
    dataFile.close();
  }
  // Change depending on the frequency at which data should be recorded
  delay(timedelay);
  
}

// Function to accept user input according to the specified format
void recvWithStartEndMarkers() {
  static boolean recvInProgress = false;
  static byte ndx = 0;
  char startMarker = '<';
  char endMarker = '>';
  char rc;
  while (Serial.available() > 0 && newData == false) {
    rc = Serial.read();
    if (recvInProgress == true) {
      if (rc != endMarker) {
        // Register input character
        receivedChars[ndx] = rc;
        // Increment character index
        ndx++;
        if (ndx >= numChars) {
          ndx = numChars - 1;
        }
      }
      else {
        // Terminate the input array
        receivedChars[ndx] = '\0';
        recvInProgress = false;
        ndx = 0;
        newData = true;
      }
    }
    else if (rc == startMarker) {
      recvInProgress = true;
    }
  }
}
// Function to separate input elements
void parseData() {
  char * strtokIndx;
  // Retrieve the first part of the input (float)
  strtokIndx = strtok(tempChars, ",");
  // Convert this first part to a float
  floatFromPC = atof(strtokIndx);
  // Continue where the previous extraction ended
  strtokIndx = strtok(NULL, ",");
  // Copy input to messageFromPC
  strcpy(messageFromPC, strtokIndx);
}
// Function to display parsed input information
void showParsedData() {
  Serial.print("Calibration mass: ");
  // Mass
  Serial.print(floatFromPC);
  Serial.print(" ");
  // Units
  Serial.print(messageFromPC);
  Serial.println();
}
