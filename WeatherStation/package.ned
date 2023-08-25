import inet.applications.ethernet.EtherAppServer;
import inet.examples.inet.ipv4hook.MyHost;
import inet.examples.inet.ipv4hook.MyRouter;
import inet.node.base.GamingApp;
import inet.node.base.NetworkLayerNodeBase;
import inet.node.base.NodeBase;
import inet.node.contract.INetworkNode;
import inet.node.ethernet.Eth100M;
import inet.node.inet.SensorNode;
import inet.node.inet.StandardHost;
import inet.showcases.measurement.flow.MyStandardHost;
import inet.tutorials.protocol.Host;
import inet.tutorials.protocol.Node;


simple TemperatureSensor
{
    parameters:
        double minTemperature;
        double maxTemperature;
    gates:
        output out;
}

simple HumiditySensor
{
    parameters:
        double minHumidity;
        double maxHumidity;
    gates:
        output out;
}

simple UVSensor
{
    parameters:
        double minUVIndex;
        double maxUVIndex;
    gates:
        output out;
}
simple WindSpeedSensor
{
    parameters:
        double minSpeed;
        double maxSpeed;
    gates:
        output out;

}

module WeatherStation
{
    parameters:
        double minTemperature;
        double maxTemperature;
        double minHumidity;
        double maxHumidity;
        double minUVIndex;
        double maxUVIndex;
        double minSpeed;
        double maxSpeed;
    gates:
        output out @loose;
        inout port @allowUnconnected;
    submodules:
        temperatureSensor: TemperatureSensor {
            minTemperature = minTemperature;
            maxTemperature = maxTemperature;
            @display("p=334,264");
        }
        humiditySensor: HumiditySensor {
            minHumidity = minHumidity;
            maxHumidity = maxHumidity;
            @display("p=73,63");
        }
        UVSensor: UVSensor {
            minUVIndex = minUVIndex;
            maxUVIndex = maxUVIndex;
            @display("p=406,121");
        }
        WindSensor: WindSpeedSensor {
            minSpeed = minSpeed;
            maxSpeed = maxSpeed;

            @display("p=537,192");
        }

    connections allowunconnected:
        temperatureSensor.out --> out;
        humiditySensor.out --> out;
        UVSensor.out --> out;
        WindSensor.out --> out;
}



