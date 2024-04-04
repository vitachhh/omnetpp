import os


project_name = "WeatherStationSimulation"
base_dir = os.path.join(os.getcwd(), project_name)
os.makedirs(base_dir, exist_ok=True)
src_dir = os.path.join(base_dir, "src")
os.makedirs(src_dir, exist_ok=True)


files = {
    "WeatherStation.ned": """
simple WeatherStation {
    parameters:
        double initialTemperature = default(20);
        double initialHumidity = default(50);
    gates:
        output out;
}
""",
    "WeatherData.msg": """
message WeatherData {
    double temperature;
    double humidity;
}
""",
    "WeatherStation.h": """
#ifndef WEATHERSTATION_H_
#define WEATHERSTATION_H_

#include <omnetpp.h>
#include "WeatherData_m.h"

using namespace omnetpp;

class WeatherStation : public cSimpleModule {
  protected:
    virtual void initialize() override;
    virtual void handleMessage(cMessage *msg) override;
};

#endif /* WEATHERSTATION_H_ */
""",
    "WeatherStation.cc": """
#include "WeatherStation.h"
#include "WeatherData_m.h"

Define_Module(WeatherStation);

void WeatherStation::initialize() {
    // Schedule the first message to trigger periodic sending
    cMessage *timerMsg = new cMessage("timer");
    scheduleAt(simTime() + 1.0, timerMsg); // Sends data every second
}

void WeatherStation::handleMessage(cMessage *msg) {
    if (msg->isSelfMessage()) {
        // Create new WeatherData message with fixed data
        WeatherData *weatherData = new WeatherData();
        weatherData->setTemperature(20.0); // Fixed temperature
        weatherData->setHumidity(50.0); // Fixed humidity

        // Send out the message
        send(weatherData, "out");

        // Schedule next send
        scheduleAt(simTime() + 1.0, msg);
    }
}
""",
    "Receiver.h": """
#ifndef RECEIVER_H_
#define RECEIVER_H_

#include <omnetpp.h>
#include "WeatherData_m.h"

using namespace omnetpp;

class Receiver : public cSimpleModule {
  protected:
    virtual void handleMessage(cMessage *msg) override;
};

#endif /* RECEIVER_H_ */
""",
    "Receiver.cc": """
#include "Receiver.h"
#include "WeatherData_m.h"

Define_Module(Receiver);

void Receiver::handleMessage(cMessage *msg) {
    WeatherData *weatherData = dynamic_cast<WeatherData *>(msg);
    if (weatherData != nullptr) {
        // Log received temperature and humidity
        EV << "Received weather data - Temperature: " << weatherData->getTemperature() 
           << "°C, Humidity: " << weatherData->getHumidity() << "%" << endl;
    }
    delete msg;
}
""",
    "omnetpp.ini": """
[General]
network = WeatherNetwork
**.initialTemperature = 22
**.initialHumidity = 60
sim-time-limit = 5s

[Config WeatherStation]
description = "Simple weather station simulation"
""",
    "WeatherNetwork.ned": """
simple Receiver
{
    parameters:
        @display("i=device/laptop");
    gates:
        input in; // Ulazni gate za primanje podataka
}
network WeatherNetwork {
    submodules:
        weatherStation: WeatherStation {
            parameters:
                initialTemperature = default(22);
                initialHumidity = default(60);
            @display("p=100,100");**.initialTemperature = 22
        };
        receiver: Receiver {
            @display("p=100,300");
        };
    connections:
        weatherStation.out --> receiver.in;
}
"""
}


for filename, content in files.items():
    with open(os.path.join(src_dir, filename), 'w') as f:
        f.write(content)

print(f"Project {project_name} has been generated at {base_dir}")
