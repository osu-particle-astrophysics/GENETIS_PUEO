/**
 * Creates the sensors that measure the fields (and gain).
 *
 * Open question: Do we need to remake the sensor for each antenna?
 *
 */
function CreateSensors()
{
	var sensorDataDefinitionList = App.getActiveProject().getSensorDataDefinitionList();
	sensorDataDefinitionList.clear();
	// Create a sensor
	var farSensor = new FarZoneSensor();
	farSensor.retrieveSteadyStateData = true;
	farSensor.name = "Far Zone Sensor";
	// We increment in steps of 5 degrees
	farSensor.setAngle1IncrementRadians(Math.PI/36.0);
	farSensor.setAngle2IncrementRadians(Math.PI/36.0);
	// We can also set the stopping angles to limit the range:
	//farSensor.setAngle1StopRadians(Math.PI/2);
	//farSensor.setAngle2StopRadians(Math.PI/2);
	var FarZoneSensorList = App.getActiveProject().getFarZoneSensorList();
	FarZoneSensorList.clear();
	FarZoneSensorList.addFarZoneSensor( farSensor );
}
