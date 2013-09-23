//
//  FromPolyToBrushFilter.m
//  FromPolyToBrush
//
//  Copyright (c) 2013 David. All rights reserved.
//

#import "FromPolyToBrushFilter.h"
#import <OsiriXAPI/OSIFloatVolumeData.h>
#import <OsiriXAPI/OSIROIMask.h>

@implementation FromPolyToBrushFilter

- (void) initPlugin
{
}

- (long) filterImage:(NSString*) menuName
{
	/*ViewerController	*new2DViewer;
	
	// In this plugin, we will simply duplicate the current 2D window!
	
	new2DViewer = [self duplicateCurrent2DViewerWindow];
    
    NSData *data = [new2DViewer volumeData];
    NSArray *pixelData = [new2DViewer pixList];
        
	OSIFloatVolumeData *osiFloatVolumeData = [[OSIFloatVolumeData alloc] initWithWithPixList:pixelData volume:data];

    OSIROIMask *osiRoiMask = [OSIROIMask ROIMaskFromVolumeData:osiFloatVolumeData];
    
    NSArray *maskRuns = [osiRoiMask maskRuns];
    //NSUInteger length = [osiRoiMask maskRunCount];
    
    NSUInteger *maskRunsLength = [maskRuns count];
    OSIROIMaskRun *maskRun = [maskRuns objectAtIndex:0];
    OSIROIMaskRun *maskRun2 = [maskRuns lastObject];*/

    fptbWindowController = [[FPTBWindowController alloc] initWithViewerController:viewerController];
    [fptbWindowController showWindow:self];
    
	if( fptbWindowController)  // No Errors
    {
        //[osiFloatVolumeData release];
        NSLog(@"All OK!!");
        return 0;
    }
	else return -1;
}

@end
