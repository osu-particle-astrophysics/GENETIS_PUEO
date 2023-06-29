/* ************************** Set Global Variables ******************************** */
var units = " cm";
var num_ridges = 4; // either 2 or 4
var path = "fileDirectory/generationDNA.csv"; 
var Tau=0.26; // Normalized parametric time--no good reason to be 0.26, but it's fine

var height1=0.02; // Where we place the second power source; needs to not intersect the first one!
var height2=0.04; // Where we place the second power source; needs to not intersect the first one!

/* ****************************** Read in Data ****************************** */
var freqCoefficients = 131 // This stores how many frequencies we're working with.
var headerLines = 6 // This is how many lines come before the frequency data in the file
var antennaLines = 9 // This is how many lines come before the antenna data
var file = new File(path);
//Output.println("Before open file");
file.open(1);
//Output.println("After open file");
var generationDNA = file.readAll();
//Output.println("After assigned generationDNA");

