/* ******************************** Function Calls **************************** */


for(var j = indiv;j<=NPOP;j++)
{
	var file = new File(path);
	file.open(1);
	var generationDNA = file.readAll();

	// Lists to hold the genes
	var S=[];
	//var m=[];		// Comment for now because we keep to 1
	var H=[];
	var X0=[]; // previously 0.04
	var Y0=[]; // previously 0.04
	var Z0=[];
	var Xf=[];
	var Yf=[];
	var Zf=[];
	var Beta=[];

	var lines = generationDNA.split('\n');
	// Loop over reading in the gene values
	for(var i = 0;i < lines.length;i++)
	{
		//Output.println(i);
		if(i==headerLines)
		{
			var frequencies = lines[i].split(",");
		}
			if(i>=antennaLines)
				{
					var params = lines[i].split(",");

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

			//Output.println(S[i-antennaLines]);
			//Output.println(H[i-antennaLines]);
			//Output.println(X0[i-antennaLines]);
			//Output.println(Y0[i-antennaLines]);
			//Output.println(Yf[i-antennaLines]);
			//Output.println(Zf[i-antennaLines]);
			//Output.println(Beta[i-antennaLines]);
		}
	}
	for(var i = 0;i < NPOP;i++)
	{
		if(i==j-1)
		{
			var s = S[i];
			var h = H[i];
			var x0 = X0[i];
			var y0 = Y0[i];
			var z0 = 0;
			var xf = s; // By constraint
			var yf = Yf[i];
			var zf = Zf[i];
			var beta = Beta[i];
			var m = 1;

			//T = Tau/(Math.exp(zf/beta)-1)*(Math.exp(height/beta)-1);
			//X = 1*x0 + (zf-x0)/Tau * T; // Multiply x0 by 1 because otherwise it doesn't know it's a number lol
			//Output.println(T);
			//Output.println(X);

			Output.println(x0);
			Output.println(y0);
			Output.println(z0);
			Output.println(xf);
			Output.println(yf);
			Output.println(zf);
			Output.println(beta);
			Output.println(s);
			Output.println(h);


			// Function calls
			// We do it twice, first for horizontal source then for vertical
			for(var k = 0; k <= SYMMETRY; k++)
			{

				if(k == 0)
				{
					height = height1;
				}
				else
				{
					height = height2;
				}

				T = Tau/(Math.exp(zf/beta)-1)*(Math.exp(height/beta)-1);
				X = 1*x0 + (zf-x0)/Tau * T; // Multiply x0 by 1 because otherwise it doesn't know it's a number lol

				App.getActiveProject().getGeometryAssembly().clear();
				CreatePEC();
				buildWalls(s,m,h);
				buildRidges(1*x0, 1*y0, 1*z0, 1*xf, 1*yf, 1*zf, 1*Tau, beta, 1*s/100, 1*m); 
				CreateAntennaSource(k, X, height); 
				CreateGrid();
				CreateSensors();
				CreateAntennaSimulationData();
				QueueSimulation();
			}
		}
	}
	MakeImage(j);
} // uncomment?
file.close();
