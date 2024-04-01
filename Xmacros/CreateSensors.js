
// Make the sensors to detect the emitted signal
function CreateSensors()
{
    // Here we will create a sensor definition and attach it to a near-field sensor on the surface of one of our objects.

    var sensorDataDefinitionList = App.getActiveProject().getSensorDataDefinitionList();
        sensorDataDefinitionList.clear();

    // Create a sensor
        var farSensor = new FarZoneSensor();
    farSensor.retrieveSteadyStateData = true;
       farSensor.setAngle1IncrementRadians(Math.PI/36.0);
    farSensor.setAngle2IncrementRadians(Math.PI/36.0);
       farSensor.name = "Far Zone Sensor";


    var FarZoneSensorList = App.getActiveProject().getFarZoneSensorList();
       FarZoneSensorList.clear();
    FarZoneSensorList.addFarZoneSensor( farSensor );
}
