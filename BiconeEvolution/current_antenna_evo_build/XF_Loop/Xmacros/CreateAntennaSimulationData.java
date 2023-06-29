/**
 * Sets up the storage of data for each new simulation
 *
 */
function CreateAntennaSimulationData()
{
	// This function modifies the NewSimulationData parameters of the project.
	// They're called "New" because they get applied every time we create an instance of this
	// project and place it on our simulation queue.
	var simData = App.getActiveProject().getNewSimulationData();
	var FOI = simData.getFOIParameters();
	FOI.clearAllSpecifiedFrequencies();
	FOI.foiSource = 1;
	for(var k = 0;k < 131;k++) 
	{
		FOI.addSpecifiedFrequency(freq[k] + " MHz");
	}
	// These should already be set, however just to make sure the current project is set up correctly
	simData.excitationType = NewSimulationData.DiscreteSources;
	simData.enableSParameters = true;
}
