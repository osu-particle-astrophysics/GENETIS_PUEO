/**
 * Makes the grid for the geometry.
 *
 * Do we need to do this for each individual?
 */
function CreateGrid()
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
}
