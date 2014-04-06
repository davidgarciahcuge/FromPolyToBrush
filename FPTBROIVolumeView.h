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
//#import <OsirixAPI/vtkRenderer.h"
#import <OsiriXAPI/vtkActor.h>
#import <OsiriXAPI/vtkSmartPointer.h>
#undef id

@interface FPTBROIVolumeView : ROIVolumeView
{
    //vtkRenderer *theRenderer;
    vtkSmartPointer<vtkActor> ballsActor;
    vtkSmartPointer<vtkActor> surfaceActor;
}

// Stablishes the source where the data we want to show resides
//-(void)setPointsSource:(NSMutableArray*) points;

// Render the data with thr reconstruction algorithm selected
-(void)renderVolumeWitDelaunay: (BOOL)delaunay withPowerCrust: (BOOL)powerCrust showPoints: (BOOL)points showSurface: (BOOL)surface;

// Update rendering actors
-(void)showPoints: (BOOL)points showSurface: (BOOL)surface;

-(short)setPixSource:(NSMutableArray*)pts;

@end
