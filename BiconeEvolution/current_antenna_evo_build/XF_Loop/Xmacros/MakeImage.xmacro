/**
 * Saves a picture of the antenna to a .png file in the antenna_images/ directory.
 *
 */
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
	View.saveImageToFile('antenna_images/' + i+'_'+'detector.png', -1, -1);
}
