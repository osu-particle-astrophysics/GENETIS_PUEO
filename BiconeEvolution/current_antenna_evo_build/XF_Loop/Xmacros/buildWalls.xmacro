/**
 * Makes the outer walls of the horn antenna.
 *
 *
 * @param S half the sidelength of the bottom of the antenna
 * @param m the slope of the walls (keep to 1 for now)
 * @param H the height of the walls
 *
 */
function buildWalls(S,m,H) 
{
	// Make the edges to define the square
	var edge1 = Line( new Cartesian3D(-S,-S, 0), new Cartesian3D(-S, S, 0));
	var edge2 = Line( new Cartesian3D(-S, S, 0), new Cartesian3D(S, S, 0));
	var edge3 = Line( new Cartesian3D(S,S, 0), new Cartesian3D(S, -S, 0));
	var edge4 = Line( new Cartesian3D(S,-S, 0), new Cartesian3D(-S, -S, 0));
	
	// Declare sketches to be made from the edges
	var wallSegment = new Sketch();
	var bottomSegment = new Sketch();
	wallSegment.addEdge(edge1);
	wallSegment.addEdge(edge2);
	wallSegment.addEdge(edge3);
	wallSegment.addEdge(edge4);
	bottomSegment.addEdge(edge1);
	bottomSegment.addEdge(edge2);
	bottomSegment.addEdge(edge3);
	bottomSegment.addEdge(edge4);

	// Let's start by making the bottom
	// For now, we are setting this up but not putting it into the actual model
	var bottomCover = new Cover(bottomSegment);
	var bottomRecipe = new Recipe();
	bottomRecipe.append( bottomCover );
	var bottomModel = new Model();
	bottomModel.setRecipe( bottomRecipe );
	// Add the surface
	//var bottom = App.getActiveProject().getGeometryAssembly().append(bottomModel);
	//bottom.name = "Bottom square";

	// Now we need to extrude the edges to get height
	var walls = new Extrude( wallSegment, H);				// Makes an Extrude
	var wallOptions = walls.getOptions();						// Gives the possible options for 
	// We will use the draft law option to extrude linearly
	wallOptions.draftOption = SweepOptions.DraftLaw;			// allows for draftlaw
	wallOptions.draftLaw = "("+m+"*x)";							// Set the expression for the extrude
	wallOptions.draftOption = 4;								// 4 indicates we use draftlaw
	//Walter - Change the gap type to Extended to get the desired shape
	wallOptions.gapType = SweepOptions.Extended; 				// I actually don't like this when we have x^2, but it doesn't do much for just x
	//Walter - Create a shell instead of a solid part
	wallOptions.createSolid = false;							// This way the shape isn't filled in
	walls.setOptions ( wallOptions );							// Sets the settings we assigned above

	// Make a recipe for a model
	var wallRecipe = new Recipe();
	wallRecipe.append(walls);
	var wallModel = new Model();
	wallModel.setRecipe(wallRecipe);
	wallModel.name = "Outer Walls";
	wallModel.getCoordinateSystem().translate(new Cartesian3D(0,0,0));	
	// Set the material for these parts
	var wallProject = App.getActiveProject().getGeometryAssembly().append(wallModel);	
	var pecMaterial = App.getActiveProject().getMaterialList().getMaterial( "PEC" );	
	App.getActiveProject().setMaterial( wallProject, pecMaterial );
	//App.getActiveProject().setMaterial( bottom, pecMaterial );	// Turn on for a bottom plate

}
