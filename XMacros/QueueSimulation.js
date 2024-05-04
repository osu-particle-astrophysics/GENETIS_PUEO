function QueueSimulation()
{
   // Create and start the simulation. Project must be saved in order to run.
       var simulation = App.getActiveProject().createSimulation( false );

    Output.println( "Successfully created the simulation." );

    var projectId = simulation.getProjectId();
       var simulationId = simulation.getSimulationId();
    var numRuns = simulation.getRunCount();
}
