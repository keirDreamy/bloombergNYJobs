 /***************************************************
  used Limor Fried/Ladyada from Adafruit Industries code as a template
  
 ****************************************************/

#include <SPI.h>
#include "Adafruit_MAX31855.h"


//thermocouples
#define MAXDO   12 
#define MAXCLK  2 //for spi clock 
#define MAXCS1  4 //for thermo 1 pin
#define MAXCS2  5 //for thermo 2 pin



// Thermocouple class objects
 Adafruit_MAX31855 thermocouple_1(MAXCLK, MAXCS1, MAXDO);
 Adafruit_MAX31855 thermocouple_2(MAXCLK, MAXCS2, MAXDO);
 


// variables that need to be adjusted for each test

 
  String thruster = "thurster_1"; //enter thruster being run
  double read_time = 1000; //how often should a sample be taken in milliseconds
  int start_time = 0; //  leave this as 0. 
  String date = "07/13/22"; //enter the date of the run. This is for record keeping
  

//system assignments, do not change these
double current_time = start_time;  

void setup() {
  

  //start serial buss
  
  Serial.begin(9600);
  
  while (!Serial) delay(1); // wait for Serial 

  Serial.println("MAX31855 test");
  // wait for MAX to be ready
  delay(500);
  Serial.print("Initializing sensors...");
  if (!thermocouple_1.begin()) { 
    Serial.println("ERROR on sensor 1");
    while (1) delay(10);
  }
 
  if (!thermocouple_2.begin()) { 
    Serial.println("ERROR on sensor 2");
    while (1) delay(10);
  }

 
  Serial.println("All sensors are ready! DONE.");
}

void loop() {
  // boot:  print the current temp


// Getting data reads ready for input 
 bool read_sensor_set1 = true; //leave this as true unless you want to stop the sensor readings
 double sensor_list_value[][2] ={{-99,-99}, {-99,-99}}; // array to read the sensor  values
 String sensor_name[]= {"sens 1","sens 2"};
 
 Serial.println(sensor_name[1]);
 
 
  Serial.println("thruster_name, date, run_time, sensor1, sensor2, internal_temp1, internal_temp2"); 

  //read sensors and check that data was collected

  
  
  while (read_sensor_set1 == true )
  {

   
      sensor_list_value[0][0] = thermocouple_1.readCelsius();
      sensor_list_value[0][1] = thermocouple_1.readInternal();
      sensor_list_value[1][0] = thermocouple_2.readCelsius();
      sensor_list_value[1][1] = thermocouple_2.readInternal();
      

        
//print the data if it was collected
 
  Serial.print((String)date+", ");
      
      //temp measure
      Serial.print(" "+sensor_name[0]+", ext:celsius, ");
      Serial.print(sensor_list_value[0][0]);
      Serial.print(", "+sensor_name[1]+", ext:celsius, ");
      Serial.print(sensor_list_value[1][0]);
    
      Serial.print(", " +sensor_name[0]+ " int:celsius ,");
      Serial.print(sensor_list_value[0][1]); //internal temp"
      Serial.print(", " +sensor_name[1]+ " int:celsius ,");
      Serial.print(sensor_list_value[1][1]); //internal temp"
   
 Serial.println("");
 

    //Dealy before next read
    delay(read_time); //pause and wait for next run time
    current_time = current_time + read_time; //tracking current run time

     }//end while loop that is responsible for collecting the data

    
  }//end while
  
