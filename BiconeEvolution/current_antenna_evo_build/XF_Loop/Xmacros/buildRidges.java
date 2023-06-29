/**
 * This makes the inner ridges of the antenna.
 *
 * @param x_0		x position of the bottom of the ridge
 * @param y_0		y position of the bottom of the ridge
 * @param z_0		z position of the bottom of the ridge (always set to 0)
 * @param x_f		x position of the top of the ridge
 * @param y_f		y position of the top of the ridge
 * @param z_f		z position of the top of the ridge
 * @param tau		parametric time limit (arbitrary)
 * @param beta	curvature parameter of the ridges
 * @param S			half the side length of the bottom of the outer walls
 * @param m			slope of the walls (keep to 1 for now)
 *
 * This is a very complicated script. It may be possible and worthwhile to break it
 * 	down into smaller functions. 
 * Making the geometry is very delicate and will throw errors if you make a shape that 
 * 	doesn't "close" on itself.
 *
 */
function buildRidges(x_0, y_0, z_0, x_f, y_f, z_f, tau, beta, S, m)
{

	// Curves (Z is logarithmic in t)
	var Log1 = new LawEdge( ""+x_0+" + ("+z_f+"-"+x_0+")/"+tau+"*u", // x coord 
													""+y_0+" + ("+y_f+"-"+y_0+")/"+tau+"*u", // y
													""+beta+"*ln((exp("+z_f+"/"+beta+")-1.0)/"+tau+"*u+1.0)", // z
													0, 
													tau); 
	var Log2 = new LawEdge( ""+x_0+" + ("+z_f+"-"+x_0+")/"+tau+"*u", 
													"-"+y_0+" - ("+y_f+"-"+y_0+")/"+tau+"*u", 
													""+beta+"*ln((exp("+z_f+"/"+beta+")-1.0)/"+tau+"*u+1.0)", 
													0, 
													tau);

	// Inner straight slopes 
	var IS1 = new LawEdge(""+x_0+" + ("+z_f+"-"+x_0+")/"+tau+"*u",
												""+y_0+" + ("+y_f+"-"+y_0+")/"+tau+"*u", 
												"("+z_f+"-"+z_0+")/"+tau+"*u", 
												0, 
												tau); 
	var IS2 = new LawEdge(""+x_0+" + ("+z_f+"-"+x_0+")/"+tau+"*u", 
												"-"+y_0+" - ("+y_f+"-"+y_0+")/"+tau+"*u", 
												"("+z_f+"-"+z_0+")/"+tau+"*u", 
												0, 
												tau);

	// Bottom line
	var BL1 = new LawEdge(""+x_0+" + ("+x_f+"-"+x_0+")/"+tau+"*u", 
												""+y_0+"", 
												""+z_0+"", 
												0, 
												tau);
	var BL2 = new LawEdge(""+x_0+" + ("+x_f+"-"+x_0+")/"+tau+"*u", 
												"-"+y_0+"", 
												""+z_0+"", 
												0, 
												tau);

	// Top line
	var TL1 = new LawEdge(""+z_f+" + "+x_f+"/"+tau+"*u", 
												""+y_f+"", 
												""+z_f+"", 
												0, 
												tau);
	var TL2 = new LawEdge(""+z_f+" + "+x_f+"/"+tau+"*u", 
												"-"+y_f+"", 
												""+z_f+"", 
												0, 
												tau);

	// Outer Straight slopes
	var OS1 = new LawEdge(""+x_f+" + "+z_f+"/"+tau+"*u", 
												""+y_0+" + ("+y_f+" - "+y_0+")/"+tau+"*u", 
												""+z_f+"/"+tau+"*u", 
												0, 
												tau);
	var OS2 = new LawEdge(""+x_f+" + "+z_f+"/"+tau+"*u", 
												"-"+y_0+" - ("+y_f+" - "+y_0+")/"+tau+"*u", 
												""+z_f+"/"+tau+"*u", 
												0, 
												tau);

	// Inner top line
	var ITL = new LawEdge(""+z_f+"", 
												"-"+y_f+" + 2*"+y_f+"/"+tau+"*u", 
												""+z_f+"", 
												0, 
												tau);

	// Outer top line
	var OTL = new LawEdge(""+x_f+" + "+z_f+"", 
												"-"+y_f+" + 2*"+y_f+"/"+tau+"*u", 
												""+z_f+"", 
												0, 
												tau);

	// Inner bottom line
	var IBL = new LawEdge(""+x_0+"", 
												"-"+y_0+" + 2*"+y_0+"/"+tau+"*u", 
												""+z_0+"", 
												0, 
												tau);

	// Outer bottom line
	var OBL = new LawEdge(""+x_f+"", 
												"-"+y_0+" + 2*"+y_0+"/"+tau+"*u", 
												""+z_0+"", 
												0, 
												tau);

	// Make the sketches
	var straightEdge1 = new Sketch();		// All straight edges (IS1, BL1, TL1, OS1)
	var straightEdge2 = new Sketch(); 	// All straight edges (IS2, BL2, TL2, OS2)	
	var curvedLog1 = new Sketch(); 			// Logarithmic edge (IS1 and Log1)
	var curvedLog2 = new Sketch(); 			// Logarithmic edge (IS2 and Log2)
	var topRectangle = new Sketch(); 		// Top rectangle
	var bottomRectangle = new Sketch(); // Bottom rectangle

	// Add the edges to the sketches
	straightEdge1.addEdges( [IS1, BL1, TL1, OS1] );			// Inner straight slope
	curvedLog1.addEdges( [IS1, Log1] );									// Right logarithm part
	straightEdge2.addEdges( [IS2, BL2, TL2, OS2] ); 		// Inner straight slope
	curvedLog2.addEdges( [IS2, Log2] );			 						// Left logarithm part
	topRectangle.addEdges( [ITL, OTL, TL1, TL2] );			// Top rectangle
	bottomRectangle.addEdges( [IBL, OBL, BL1, BL2] );		// Bottom Rectangle

	//WALTER - The Elliptical pattern is added as a recipe to the parts
	var ePattern = new EllipticalPattern();
	ePattern.setCenter(new CoordinateSystemPosition(0,0,0));
	ePattern.setNormal(new CoordinateSystemDirection(0,0,1));
	ePattern.setInstances(num_ridges);
	ePattern.setRotated(true);

	// Create an array of covers (used for making the ridges solid/closed)
	var cov = new Array();
	cov.push(new Cover(straightEdge1));
	cov.push(new Cover(straightEdge2));
	cov.push(new Cover(curvedLog1));
	cov.push(new Cover(curvedLog2));
	cov.push(new Cover(topRectangle));
	cov.push(new Cover(bottomRectangle));

	var pecMaterial = App.getActiveProject().getMaterialList().getMaterial( "PEC" );

	//WALTER - We can loop over all our parts and add them to the project as follows.  You can use similar concepts above.
	models = new Assembly();
	for(var w = 0; w < cov.length; w++)
	{
		var r = new Recipe();
		r.append(cov[w]);
		r.append(ePattern);
		var m = new Model();
		m.setRecipe(r);
		m.name = "Test Surface " + (w+1);
		//WALTER - Seperate array for the models, though we could just get them from the GemoetryAssembly again
		models.append(m);
		App.getActiveProject().setMaterial( m, pecMaterial );

	}

	// Work on the loft
	var vertex_position1 = curvedLog1.getPosition(curvedLog1.getVertexIds()[0]);	
	var vertex_position2 = curvedLog2.getPosition(curvedLog2.getVertexIds()[0]);

	var loft = new Loft(models.at(2).pickFace(new Cartesian3D (0, 0, 0), vertex_position1, 0.5), "0.0", models.at(3).pickFace(new Cartesian3D(0,0,0), vertex_position2, 0.5), "0.0");
	loft.setPart1(models.at(2));
	loft.setPart2(models.at(3));
		
	var r12 = new Recipe();
	r12.append( loft );
	r12.append(ePattern);
	var m12 = new Model();
	m12.setRecipe( r12 );
	m12.name = "Loft 1";
	models.append(m12);

	//WALTER - append the assembly to the project, then loop over it to assign the material
	var assembly = App.getActiveProject().getGeometryAssembly().append(models);
	for(x = 0; x < assembly.size(); x++)
	{
		Output.println(assembly.at(x));
		App.getActiveProject().setMaterial( assembly.at(x), pecMaterial );
	}

}
