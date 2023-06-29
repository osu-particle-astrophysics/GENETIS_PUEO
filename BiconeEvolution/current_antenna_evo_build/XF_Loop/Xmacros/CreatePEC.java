/**
 * Makes the material for the antenna (Perfect Electrical Conductor).
 *
 * In the future, it may be wise to add in more materials, like copper.
 */
function CreatePEC() //borrowed from XF demo
{
	var pec = new Material();
	pec.name = "PEC";
	var pecProperties = new PEC();		// This is the electric properties that defines PEC
	var pecMagneticFreespace = new MagneticFreespace();		 // We could make a material that acts as PEC and PMC, but in this case we just care about electrical components.
	var pecPhysicalMaterial = new PhysicalMaterial();
	pecPhysicalMaterial.setElectricProperties( pecProperties );
	pecPhysicalMaterial.setMagneticProperties( pecMagneticFreespace );
	pec.setDetails( pecPhysicalMaterial );
	// PEC is historically a "white" material, so we can easily change its appearance:
	var pecBodyAppearance = pec.getAppearance();
	var pecFaceAppearance = pecBodyAppearance.getFaceAppearance();	// The "face" appearance is the color/style associated with the surface of geometry objects
	pecFaceAppearance.setColor( new Color( 255, 255, 255, 255 ) );	// Set the surface color to white. (255 is the maximum intensity, these are in order R,G,B,A).
	// Check for an existing material
	if( null != App.getActiveProject().getMaterialList().getMaterial( pec.name ) )
	{
		App.getActiveProject().getMaterialList().removeMaterial( pec.name );
	}
	App.getActiveProject().getMaterialList().addMaterial( pec );
}
