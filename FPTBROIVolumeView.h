//
//  FPTBROIVolumeView.h
//  FromPolyToBrush
//
//  Created by David García Juan on 21/01/14.
//
//

#import <Cocoa/Cocoa.h>

#import "OsiriXAPI/ROIVolumeView.h"
//#import "OsiriXAPI/VTKView.h"

//#define id Id
//#include "vtkRenderer.h"
//#include "vtkCamera.h"
//#include "vtkActor.h"
//#undef id

@interface FPTBROIVolumeView : ROIVolumeView
{
    NSArray *_points;
    
    //vtkRenderer *theRenderer;
    //vtkCamera *theCamera;
    //vtkActor *theVolumeActor;
}

// Stablishes the source where the data we want to show resides
-(void)setPointsSource:(NSMutableArray*) points;

// Render the data
//-(void) renderVolume;

@end
