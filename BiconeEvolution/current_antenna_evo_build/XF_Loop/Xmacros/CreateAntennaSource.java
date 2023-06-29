/**
 * Makes the power sources (in the future, maybe loads) for the antenna.
 *
 * @param h_or_v	flag for hpol or vpol channel
 * @param x 			distance of the center of the bottom of the ridge from the origin
 * @param Height	height of the power source (should differ between channels)
 *
 * This will set up a power source based on the antenna polarization (v or h).
 * It will also make the waveform type. This second part may not need to be 
 * 	redone for every individual.
 * There are many things commented out that may seem redundant. They are there 
 * 	because they allow us to use both sources at once, which may be desirable.
 */
function CreateAntennaSource(h_or_v, x, Height)
{
	// a CircuitComponent that will attach those to our current geometry.
	var waveformList = App.getActiveProject().getWaveformList();
	waveformList.clear();
	// Make the waveform; for whatever reason, Gaussian derivative seems standard
	var waveform = new Waveform();
	var GDer = new GaussianDerivativeWaveformShape ();
	GDer.pulseWidth = 2e-9;
	waveform.setWaveformShape( GDer );
	waveform.name ="Gaussian Derivative";
	var waveformInList = waveformList.addWaveform( waveform );

	// Now to create the circuit component definition:
	var componentDefinitionList = App.getActiveProject().getCircuitComponentDefinitionList();
	// clear the list
	componentDefinitionList.clear();

	// Create our Feed
	var feed1 = new Feed();
	var feed2 = new Feed();

	feed1.feedType = Feed.Voltage; // Set its type enumeration to be Voltage.
	//feed2.feedType = Feed.Voltage; // Set its type enumeration to be Voltage.

	// Define a 50-ohm resistance for this feed
	var rlc = new RLCSpecification();
	rlc.setResistance( "50 ohm" );
	rlc.setCapacitance( "0" );
	rlc.setInductance( "0" );
	feed1.setImpedanceSpecification( rlc );
	feed1.setWaveform( waveformInList );	// Make sure to use the reference that was returned by the list, or query the list directly
	feed1.name = "50-Ohm Voltage Source";
	var feedInList = componentDefinitionList.addCircuitComponentDefinition( feed1 );

	feed2.setImpedanceSpecification( rlc );
	feed2.setWaveform( waveformInList );	// Make sure to use the reference that was returned by the list, or query the list directly
	feed2.name = "50-Ohm Voltage Source 2";
	var feedInList = componentDefinitionList.addCircuitComponentDefinition( feed2 );

	// Now create a circuit component that will be the feed point for our simulation
	var componentList = App.getActiveProject().getCircuitComponentList();
	componentList.clear();

	var component1 = new CircuitComponent();
	//var component2 = new CircuitComponent();

	component1.name = "Source";
	//component2.name = "Source";

	component1.setAsPort( true );
	//component2.setAsPort( true );
	// Define the endpoints of this feed - these are defined in world position, but you can also attach them to edges, faces, etc.
	if(h_or_v == 0) // 0 for h, 1 for v
	{
		var coordinate1 = new CoordinateSystemPosition( -x, 0, Height);
		var coordinate2 = new CoordinateSystemPosition( x, 0, Height);
	}
	else
	{
		var coordinate1 = new CoordinateSystemPosition( 0, -x, Height);
		var coordinate2 = new CoordinateSystemPosition( 0, x, Height);
	}
	//var coordinate3 = new CoordinateSystemPosition( 0, -x2, height);
	//var coordinate4 = new CoordinateSystemPosition( 0, x2, height);
	component1.setCircuitComponentDefinition( feed1 );
	component1.setCircuitComponentDefinition( feed1 );
	component1.setEndpoint1( coordinate1 );
	component1.setEndpoint2( coordinate2 );
/*
		component2.setCircuitComponentDefinition( feed2 );
		component2.setCircuitComponentDefinition( feed2 );
		component2.setEndpoint1( coordinate3 );
		component2.setEndpoint2( coordinate4 );
*/
	componentList.addCircuitComponent( component1 );
	//componentList.addCircuitComponent( component2 );

}
