function MakeImage(i)
{
  // This function orients the generated detector and saves it as a .png
  // Creates a new Camera and initializes its position
  if (i==0)
  {
    newCam = Camera();
    newCam.setPosition(Cartesian3D('0','0','10'))
    // Adjusts project camera to the above coordinates
    View.setCamera(newCam);
  }
  // Zooms out to include the entire detector, then saves as a .png
  View.zoomToExtents();
  View.saveImageToFile(workingdir+"/Run_Outputs/"+RunName+"/Antenna_Images/"+gen+"/"+i+"_"+"detector.png", -1, -1);
}
