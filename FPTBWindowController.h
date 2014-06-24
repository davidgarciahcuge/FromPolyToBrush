//
//  FPTBWindowController.h
//  FromPolyToBrush
//
//  Created by David García Juan on 26/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.


#import <Cocoa/Cocoa.h>

#import <OsiriXAPI/DCMView.h>
#import <OsiriXAPI/DCMPix.h>
#import <OsiriXAPI/Window3DController.h>


#import "FPTBROIVolumeView.h"

#define id ID
#import <OsiriXAPI/vtkSmartPointer.h>
#import <OsiriXAPI/vtkImageData.h>
#import <OsiriXAPI/vtkPolyData.h>

//#import "vtkPolyData.h"
//#import "vtkImageData.h"
//#import "vtkSmartPointer.h"
#undef id


@class ViewerController;
@class FPTBXmlController;


@interface FPTBWindowController : Window3DController <NSWindowDelegate> {
    
    ViewerController *_viewerController;
    NSArray *_fptbFileList;
    
    DCMView *_imageView;
    NSString *meshPath;
    NSMutableArray *_fptbPixList, *_fptbRoiList;
    //short _fptbCurMovieIndex;
    
    DCMPix *_fptbcurPix;
    
    //vtkSmartPointer<vtkImageData> imageStencil;
    vtkSmartPointer<vtkPolyData> polydata;
    
    FPTBXmlController *_fptbXmlController;
    
    IBOutlet NSButton *buttonBrowse;
    IBOutlet NSButton *buttonImport;
    IBOutlet NSButton *buttonDisplay;
    IBOutlet NSTextField *labelPath;
    IBOutlet NSButton   *pointsCheckbox;
    IBOutlet NSButton   *surfaceCheckbox;
    IBOutlet NSButtonCell *delaunayReconstruction;
    IBOutlet NSButtonCell *powerCrustReconstruction;
    IBOutlet NSMatrix *matrixRadioButtons;
    IBOutlet NSButton *buttonPatientPosition;
    
    //Path
    NSMutableString *FPTBhomeFilePath;
    
    //My view class for performing the visualization
    IBOutlet FPTBROIVolumeView *_theView;
    
}

//Init window.
-(id)initWithViewerController :(ViewerController*)viewerController;

//Get labeled image path;
-(IBAction)browseLabeledImages:(id)sender;

//Update label with labeled image path
-(void)updateLabel;

//Import labeled images to Brush ROIs
-(IBAction)importLabeledImages:(id)sender;

//Display a 3D model of the imported labeled image
-(IBAction)displayLabeledImages:(id)sender;

//Update the view displaying only points, only the surface or both
-(IBAction)updateView:(id)sender;

//Recompute the surface reconstruction
-(IBAction)changeReconstruction:(id)sender;

//Update Patient Position tag
-(IBAction)changePatientPosition:(id)sender;

-(IBAction)multiFrameToSingleFrame:(id)sender;


@end
