/*

  Snacker Tracker - IoT (SKRTKR-IoT)
  Molnar Lab 2023
  Marissa Mueller 

  SKRTKR - Real-Time Self-Contained Food Measuring Device
  SnackerTracker_V10-IoT

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

/* 

  Sketch generated by the Arduino IoT Cloud Thing "SnackerTracker"
  https://create.arduino.cc/cloud/things/51ac8abe-e3f8-4d83-bfb5-e18ece5e40a0 

  Arduino IoT Cloud Variables description

  The following variables are automatically generated and updated when changes are made to the Thing

  float load_Cell;
  int lDR;
  int switch_1;
  int switch_2;

*/

#include "thingProperties.h"
#include <Q2HX711.h>
#include <SPI.h>
#include <SD.h>
#include <RTCZero.h>
// Set the time delay by which data is to be collected 
// (frequency = 1000/timedelay recordings per second) 
const int timedelay = 10000;
// Calibration mass to be overwritten
float cal_mass = 6.1;
// Set the current (initial) time and date
const byte seconds = 0;
const byte minutes = 45;
const byte hours = 23;
const byte day = 27;
const byte month = 7;
const byte year = 23;
// The chip select pin for the MEM shield
const int chipSelect = 4;
// Set pin for HX711 clock registration (SCK)
const byte hx711_clock_pin = 2;
// Set pin for HX711 data input (DT)
const byte hx711_data_pin = 3;
// Set pin for LDR data input
int sensorPin = A0;
// Temporary calibration variable
long x1 = 0L;
// Temporary calibration variable
long x0 = 0L;
// Number of values to be averaged for each mass measurement
float avg_size = 10.0;
// Initialise column headers
String columnheaders = "";
// Initialise looped data row entries
String dataString = "";
// Prepare the HX711
Q2HX711 hx711(hx711_data_pin, hx711_clock_pin);
// Create an RTC object
RTCZero rtcZero;
// Create the file to be saved on the SD card
File dataFile;

void setup() {
  // Initialize serial and wait for port to open:
  Serial.begin(9600);
  // This delay gives the chance to wait for a Serial Monitor without blocking if none is found
  delay(1500); 
  // Defined in thingProperties.h
  initProperties();
  // Connect to Arduino IoT Cloud
  ArduinoCloud.begin(ArduinoIoTPreferredConnection);
  /*
     The following function allows you to obtain more information
     related to the state of network and IoT Cloud connection and errors
     the higher number the more granular information you’ll get.
     The default is 0 (only errors).
     Maximum is 4
 */
  setDebugMessageLevel(2);
  ArduinoCloud.printDebugInfo();
  // Proceed with setup code
  // Set pin for switch 1 (top) input (event marker)
  pinMode(6, INPUT_PULLUP);
  // Set pin for switch 2 (bottom) input (wireless connection)
  pinMode(7, INPUT_PULLUP);
  Serial.println();
  Serial.println("SnackerTracker Calibration");
  // Tare the configuration
  for (int ii = 0; ii < int(avg_size); ii++) {
    delay(10);
    x0 += hx711.read();
  }
  x0 /= long(avg_size);
  Serial.println();
  // Add calibration mass for system configuration
  Serial.println("Add calibrated mass...");
  // Calibrating to cal_mass
  delay(5000);
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
  dataFile = SD.open("skrtkr.txt", FILE_WRITE);
  // Check that the file can be opened, then proceed with recordings
  if (!dataFile) { 
    // Print an error message if the file is not available
    Serial.println("Error opening file");
    return;
  }
  Serial.println("Begin recording.");
  Serial.println("If you wish to record wirelessly, first ensure that a charged LiPo battery is plugged in, then disconnect the USB cable.");
  Serial.println();
  // Create column headings
  columnheaders = "rtc_date_yyyy-mm-dd,rtc_time_h:m:s,s1_em_status,s2_wl_status,lc_mass,ldr_reading";
  // Print column headers to the SD card data file
  dataFile.println(columnheaders);
  dataFile.flush();
  // Initialise the RTC and associated variables
  rtcZero.begin(); 
  // Set the time
  rtcZero.setHours(hours);
  rtcZero.setMinutes(minutes);
  rtcZero.setSeconds(seconds);
  // Set the date
  rtcZero.setDay(day);
  rtcZero.setMonth(month);
  rtcZero.setYear(year);

}

void loop() {
  
  ArduinoCloud.update();
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
  load_Cell = cal_mass * ratio;
  switch_1 = digitalRead(6);
  switch_2 = digitalRead(7);
  lDR = analogRead(A0);
  // Add timestamp information to dataString for the present input line to be logged
  dataString = "20";
  dataString += rtcZero.getYear();
  dataString += "-";
  dataString += rtcZero.getMonth();
  dataString += "-";
  dataString += rtcZero.getDay();
  dataString += ",";
  dataString += rtcZero.getHours();
  dataString += ":";
  dataString += rtcZero.getMinutes();
  dataString += ":";
  dataString += rtcZero.getSeconds();
  dataString += ",";
  dataString += switch_1;
  dataString += ",";
  dataString += switch_2;
  dataString += ",";
  dataString += load_Cell;
  dataString += ",";
  dataString += lDR;
  // Check if the data file is open. If not, open it.
  if (!dataFile) {
    dataFile = SD.open("skrtkr.txt", FILE_WRITE);
  }
  // Log data if the SD file is available
  if (dataFile) {
    dataFile.println(dataString);
    dataFile.flush();
  }
  // Change depending on the frequency at which data should be recorded
  delay(timedelay);
  
}
