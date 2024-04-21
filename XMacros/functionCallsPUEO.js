/********************************************* Function Calls **************************************************/


var file = new File(path);
file.open(1);
var generationDNA = file.readAll();

// Lists to hold the genes
var S=[];	// Side length of bottom of antenna
//var m=[];
var H=[];	// Height of antenna
var X0=[];	// distance from center of ridges at bottom // previously 0.04
var Y0=[];	// (half) width of ridges at bottom // previously 0.04
var Z0=[];	// initial height of ridges (0 always for now)
var Xf=[];	// final distance from center of curve of ridges at max height
var Yf=[];	// final width of ridges at max height
var Zf=[];	// max height of ridges
var Beta=[];	// curvature of ridges
var L=[];	// (half) width of minor length of trapezoid extrude
var h=[];	// "height" of trapezoid extrude (in x-y plane; must be < x0)


var lines = generationDNA.split('\n');


//for(var counter = indiv;counter<=NPOP;counter++)
//{
	
//	j = 1;
//	Output.println(counter);

	
	// Loop over reading in the gene values
	for(var i = 0;i < lines.length - 1;i++)
	{
		//Output.println(i);
		if(i==headerLines)
		{
			var frequencies = lines[i].split(",");
		}
    	if(i>=antennaLines)
      {
      var params = lines[i].split(",");
			Output.println("Individual "+ i - headerLines);
			Output.println("Side length 1: "+params[0]);
			Output.println("Height 1: "+params[1]);
			Output.println("x0 1: "+params[2]);
			Output.println("y0 1: "+params[3]);
			Output.println("yf 1: "+params[4]);
			Output.println("zf 1: "+params[5]);
			Output.println("Beta 1: "+params[6]);
			Output.println("Trapezoid height 1: "+params[7]/100);
			Output.println("Trapezoid length 1: "+params[8]/100+"\n");

			S[i-antennaLines]=params[0]/100;
			H[i-antennaLines]=params[1]/100;
			//m[i-antennaLines]=params[0];
			X0[i-antennaLines]=params[2]/100; // previously 0.04
			Y0[i-antennaLines]=params[3]/100; // previously 0.04
			Z0[i-antennaLines]=0;
			//xf[i-antennaLines]=params[0];
			Yf[i-antennaLines]=params[4]/100; // Preferably swap this order in the GA!!
			Zf[i-antennaLines]=params[5]/100;
			Beta[i-antennaLines]=params[6];
			h[i-antennaLines]=params[7]/100;
			L[i-antennaLines]=params[8]/100;
/*
			Output.println("Side length: ", S[i-antennaLines]);
			Output.println("Height: ", H[i-antennaLines]);
			Output.println("x0: ", X0[i-antennaLines]);
			Output.println("y0: ", Y0[i-antennaLines]);
			Output.println("yf: ", Yf[i-antennaLines]);
			Output.println("zf: ", Zf[i-antennaLines]);
			Output.println("beta: ", Beta[i-antennaLines]);
			Output.println("Trapezoid length: ", L[i-antennaLines]);
			Output.println("Trapezoid height: ", h[i-antennaLines]);
*/
		}
	}
//}

for(var i = indiv - 1; i < NPOP; i++)
{
	
		var s = S[i];
		var ah = H[i];
		var x0 = X0[i];
		var y0 = Y0[i];
		var z0 = 0;
		var xf = s; // By constraint
		var yf = Yf[i];
		var zf = Zf[i];
		var beta = Beta[i];
		var l = L[i];
		var th = h[i];
		var m = 1;
		var d = 0.03;


		//T = Tau/(Math.exp(zf/beta)-1)*(Math.exp(height/beta)-1);
		//X = 1*x0 + (zf-x0)/Tau * T; // Multiply x0 by 1 because otherwise it doesn't know it's a number lol
		//Output.println(T);
		//Output.println(X);

		Output.println("x0: "+ x0);
		Output.println("y0: "+ y0);
		Output.println("z0: "+ z0);
		Output.println("xf: "+ xf);
		Output.println("yf: "+ yf);
		Output.println("zf: "+ zf);
		Output.println("beta: "+ beta);
		Output.println("Side length: "+ s);
		Output.println("Height: "+ ah);
		Output.println("Trapezoid height: "+ th);
		Output.println("Trapezoid length: "+ l);

		// Function calls
		// We do it twice, first for horizontal source then for vertical
		for(var k = 0; k <= sym_count; k++)
		{

			if(k == 0)
			{
				height = -height1;
			}
			else
			{
				height = -height2;
			}
			T = Tau/(Math.exp(zf/beta)-1)*(Math.exp(height/beta)-1);
			X = 1*x0 + (zf-x0)/Tau * T; // Multiply x0 by 1 because otherwise it doesn't know it's a number lol

			//l = (x0-y0)/4; //arbitrary
			//Output.println(l);
			//Output.println(x0);
			//Output.println(y0);
			App.getActiveProject().getGeometryAssembly().clear();
			CreatePEC();
			build_waveguide(1*s, 1*x0,1*y0,-1*d);
			//extend_ridges(1*s, 1*x0,1*y0,-1*d);
			extend_ridges_trapezoid(1*s, 1*x0,1*y0,-1*d, 1*l, 1*th);
			build_walls(s,m,ah);
			//build_walls(s,-m,-ah);
			build_ridges(1*x0, 1*y0, 1*z0, 1*xf, 1*yf, 1*zf, 1*Tau, beta, 1*s/100, 1*m); 
			//build_ridges(1*x0, 1*y0, 1*z0, 1*xf, 1*yf, -1*zf, 1*Tau, -beta, 1*s/100, 1*m); // trying to make a second one pointing at the first
			CreateAntennaSource(k, 1*x0, 1*y0, height, 1*l); 
			CreateGrid(1*x0, 1*y0, 1*d);
			CreateSensors();
			CreateAntennaSimulationData();
			QueueSimulation();
			Output.println(ResultQuery().simulationId);
			MakeImage(i);
		}
	
}

file.close();
App.quit();
