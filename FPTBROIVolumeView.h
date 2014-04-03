//
//  FPTBROIVolumeView.h
//  FromPolyToBrush
//
//  Created by David García Juan on 21/01/14.
//
//

#import <Cocoa/Cocoa.h>

#import <OsiriXAPI/ROIVolumeView.h>
//#import <OsiriXAPI/VTKView.h>

#define id Id
//#import "vtkRenderer.h"
//#import "vtkActor.h"
//#import "vtkSmartPointer.h"
#undef id

@interface FPTBROIVolumeView : ROIVolumeView
{
    //vtkRenderer *theRenderer;
    //vtkActor *ballActor;
    //vtkActor *roiVolumeActor;
}      

// Stablishes the source where the data we want to show resides
//-(void)setPointsSource:(NSMutableArray*) points;

// Render the data with thr reconstruction algorithm selected
-(void)renderVolumeWitDelaunay: (BOOL)delaunay withPowerCrust: (BOOL)powerCrust showPoints: (BOOL)points showSurface: (BOOL)surface;

// Update rendering actors
-(void)showPoints: (BOOL)points showSurface: (BOOL)surface;

-(short)setPixSource:(NSMutableArray*)pts;

@end
