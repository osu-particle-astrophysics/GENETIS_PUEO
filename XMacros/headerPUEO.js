/**************************************** Set Global Variables **************************************************/
var units = " cm";
var num_ridges = 4; // either 2 or 4
var path = workingdir + "/Run_Outputs/" + RunName + "/Generation_Data/" + gen + "_generationDNA.csv"


// Order of genes:
// S, H, x0, y0, xf, yf, zf, beta
var Tau=0.26; // Normalized parametric time--no good reason to be 0.26, but it's fine

var height1=0.01; // Where we place the second power source; needs to not intersect the first one!
var height2=0.06; // Where we place the second power source; needs to not intersect the first one!

// create the frequency array
var freq = [];
for (var i = 0; i < freqCoefficients; i++) {
    freq.push(freq_start + i * freq_step);
}

/******************************************** Read in Data *****************************************************/
var antennaLines = 0 // This is how many lines come before the antenna data
var file = new File(path);
file.open(1);
var generationDNA = file.readAll();
