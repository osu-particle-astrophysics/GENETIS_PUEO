// Make the grid
function CreateGrid(x, y, d)
{
    // Set up the grid spacing for the antenna
    var grid = App.getActiveProject().getGrid();
    var cellSizes = grid.getCellSizesSpecification();

    cellSizes.setTargetSizes( Cartesian3D( 3, 3, 3 ));
    // And we need to set the Minimum Sizes - these are the minimum deltas that we will allow in this project.
    // We'll use the scalar ratio of 20% here.
    cellSizes.setMinimumSizes( Cartesian3D( "3", "3", "3" ) );
    cellSizes.setMinimumIsRatioX( true );
    cellSizes.setMinimumIsRatioY( true );
    cellSizes.setMinimumIsRatioZ( true );

    grid.specifyPaddingExtent( Cartesian3D( "20", "20", "20" ), Cartesian3D( "20", "20", "20" ), true, true );


	a = Math.sqrt(2*(x-y));
	var boundingBox = new BoundingBox3D( new Cartesian3D( "-"+x+"", "-"+x+"", "-"+d+"" ), new Cartesian3D( ""+x+" ", ""+x+" ", "0.05 " ) );
	var cellSizeSpec = new CellSizesSpecification;
	cellSizeSpec.setTargetSizes( new Cartesian3D( "0.9 mm", "0.9 mm", "0.9 mm" ) );
	cellSizeSpec.setMinimumSizes( new Cartesian3D( "0.3 mm", "0.3 mm", "0.3 mm" ) );
//	cellSizeSpec.setTargetSizes( new Cartesian3D(  "3*"+a+" m", "3*"+a+" m", "3*"+a+" m" ) );
//	cellSizeSpec.setMinimumSizes( new Cartesian3D( ""+a+" m", ""+a+" m", ""+a+" m" ) );
//	grid.addManualGridRegion( Grid.X | Grid.Y | Grid.Z, boundingBox, cellSizeSpec );


}

