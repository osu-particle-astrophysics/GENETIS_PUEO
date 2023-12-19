// New extensions but with trapezoid shapes
// We define L as the half length of the minor side of the trapezoid
// We want the trapezoid to be at 45 degrees from the major base, so we 
//	say the height is y0 - L
function extend_ridges_trapezoid(S, x_0, y_0, D, L, th) // D for "depdth", L for "Length"
{


	// Below works for example antenna at l = (x0-y0)/4
	// Make the edges to define the square
	var edge1 = Line( new Cartesian3D(-S  , y_0, 0), new Cartesian3D(-x_0, y_0, 0)); // good
	var diag1 = Line( new Cartesian3D(-x_0, y_0, 0), new Cartesian3D(-x_0 + th, L, 0)); // good
	var edge5 = Line( new Cartesian3D(-x_0 + th, L, 0), new Cartesian3D(-x_0 + th, -L, 0));	// good
	var diag2 = Line( new Cartesian3D(-x_0 + th, -L, 0), new Cartesian3D(-x_0, -y_0, 0)); // good
	var edge3 = Line( new Cartesian3D(-x_0,-y_0, 0), new Cartesian3D(-S, -y_0, 0)); // good
	var edge4 = Line( new Cartesian3D(-S  ,-y_0, 0), new Cartesian3D(-S, y_0, 0)); // good


// For original (45 degree opening) trapezoid\
/*
	// Below works for example antenna at l = (x0-y0)/4
	// Make the edges to define the square
	var edge1 = Line( new Cartesian3D(-S  , y_0, 0), new Cartesian3D(-x_0, y_0, 0)); // good
	var diag1 = Line( new Cartesian3D(-x_0, y_0, 0), new Cartesian3D(-x_0 - L + y_0, L, 0)); // good
	var edge5 = Line( new Cartesian3D(-x_0 - L + y_0, L, 0), new Cartesian3D(-x_0 - L + y_0, -L, 0));	// good
	var diag2 = Line( new Cartesian3D(-x_0 - L + y_0, -L, 0), new Cartesian3D(-x_0, -y_0, 0)); // good
	var edge3 = Line( new Cartesian3D(-x_0,-y_0, 0), new Cartesian3D(-S, -y_0, 0)); // good
	var edge4 = Line( new Cartesian3D(-S  ,-y_0, 0), new Cartesian3D(-S, y_0, 0)); // good
*/
	// NOT S COME ONNNNNNNNNNNNNNNN
/*	var edge1 = Line( new Cartesian3D(-S,-S, 0), new Cartesian3D(-S, S, 0));
	var edge2 = Line( new Cartesian3D(-S, S, 0), new Cartesian3D(S/2, S, 0));
	var diag1 = Line( new Cartesian3D(S/2, S, 0), new Cartesian3D(S, S/2, 0));	
	var edge3 = Line( new Cartesian3D(S,S/2, 0), new Cartesian3D(S, -S/2, 0));
	var diag2 = Line( new Cartesian3D(S, -S/2, 0), new Cartesian3D(S/2, -S, 0));	
	var edge4 = Line( new Cartesian3D(S/2,-S, 0), new Cartesian3D(-S, -S, 0));
*/
/*
	// NOT S COME ONNNNNNNNNNNNNNNN
	var edge1 = Line( new Cartesian3D(-S, y_0, 0), new Cartesian3D(-S+9*S/10, y_0, 0));
	var diag1 = Line( new Cartesian3D(-S+9*S/10, y_0, 0), new Cartesian3D(-x_0, y_0/2, 0));
	var edge2 = Line( new Cartesian3D(-x_0, y_0/2, 0), new Cartesian3D(-x_0, -y_0/2, 0));	
	var diag2 = Line( new Cartesian3D(-x_0,-y_0/2, 0), new Cartesian3D(-S+9*S/10, -y_0, 0));
	var edge3 = Line( new Cartesian3D(-S+9*S/10, -y_0, 0), new Cartesian3D(-S, -y_0, 0));	
	var edge4 = Line( new Cartesian3D(-S,-y_0, 0), new Cartesian3D(-S, y_0, 0));
*/

/*
	// NOT S COME ONNNNNNNNNNNNNNNN
	var edge1 = Line( new Cartesian3D(-S, y_0, 0), new Cartesian3D(-x_0-y_0/2, y_0, 0));
	var diag1 = Line( new Cartesian3D(-x_0-y_0/2, y_0, 0), new Cartesian3D(-x_0, y_0/2, 0));
	var edge2 = Line( new Cartesian3D(-x_0, y_0/2, 0), new Cartesian3D(-x_0, -y_0/2, 0));	
	var diag2 = Line( new Cartesian3D(-x_0,-y_0/2, 0), new Cartesian3D(-x_0-y_0/2, -y_0, 0));
	var edge3 = Line( new Cartesian3D(-x_0-y_0/2, -y_0, 0), new Cartesian3D(-S, -y_0, 0));	
	var edge4 = Line( new Cartesian3D(-S,-y_0, 0), new Cartesian3D(-S, y_0, 0));
*/


	// Declare sketches to be made from the edges
	var wallSegment = new Sketch();
	var bottomSegment = new Sketch();
	wallSegment.addEdge(edge1);
//	wallSegment.addEdge(edge2);
	wallSegment.addEdge(edge3);
	wallSegment.addEdge(edge4);
	wallSegment.addEdge(diag1);
	wallSegment.addEdge(diag2);
	wallSegment.addEdge(edge5);


	bottomSegment.addEdge(edge1);
//	bottomSegment.addEdge(edge2);
	bottomSegment.addEdge(edge3);
	bottomSegment.addEdge(edge4);
	bottomSegment.addEdge(diag1);
	bottomSegment.addEdge(diag2);
	bottomSegment.addEdge(edge5);

	// Let's start by making the bottom
	var bottomCover = new Cover(bottomSegment);
	var bottomRecipe = new Recipe();
	bottomRecipe.append( bottomCover );
	var bottomModel = new Model();
	bottomModel.setRecipe( bottomRecipe );
	// Add the surface
	//var bottom = App.getActiveProject().getGeometryAssembly().append(bottomModel);
	//bottom.name = "Bottom square";

	// Now we need to extrude the edges to get height
	var walls = new Extrude( wallSegment, D);				// Makes an Extrude
	var wallOptions = walls.getOptions();						// Gives the possible options for 
	// We will use the draft law option to extrude linearly
	wallOptions.draftOption = SweepOptions.DraftLaw;			// allows for draftlaw
	wallOptions.draftLaw = "(-1)";							// Set the expression for the extrude
	wallOptions.draftOption = 4;								// 4 indicates we use draftlaw
    //Walter - Change the gap type to Extended to get the desired shape
	wallOptions.gapType = SweepOptions.Extended; 				// I actually don't like this when we have x^2, but it doesn't do much for just x
    //Walter - Create a shell instead of a solid part
	wallOptions.createSolid = true;							// This way the shape isn't filled in
	walls.setOptions ( wallOptions );							// Sets the settings we assigned above

	// Make elliptical pattern for extensions
	var ePattern = new EllipticalPattern();
	ePattern.setCenter(new CoordinateSystemPosition(0,0,0));
	ePattern.setNormal(new CoordinateSystemDirection(0,0,1));
	ePattern.setInstances(num_ridges);
	ePattern.setRotated(true);

	// Make a recipe for a model
	var wallRecipe = new Recipe();
	wallRecipe.append(walls);
	wallRecipe.append(ePattern);
	var wallModel = new Model();
	wallModel.setRecipe(wallRecipe);
	wallModel.name = "Outer Walls";
	wallModel.getCoordinateSystem().translate(new Cartesian3D(0,0,0));	// Makes the model start at the origin

	// Set the material for these parts
	var wallProject = App.getActiveProject().getGeometryAssembly().append(wallModel);	// Adds the model to the project
	var pecMaterial = App.getActiveProject().getMaterialList().getMaterial( "PEC" );	// Makes the material available
	App.getActiveProject().setMaterial( wallProject, pecMaterial );						// Sets the material
	//App.getActiveProject().setMaterial( bottom, pecMaterial );						// Sets the material

}

