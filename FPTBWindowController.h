//
//  FPTBWindowController.h
//  FromPolyToBrush
//
//  Created by David García Juan on 26/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.


#import <Cocoa/Cocoa.h>
#import <OsiriXAPI/DCMView.h>

#import "FPTBMeshesView.h"

@class ViewerController;

@interface FPTBWindowController : NSWindowController {
    
    ViewerController *_viewerController;
    DCMView *_imageView;
    NSString *labeledImagePath;
    
    IBOutlet NSButton *buttonBrowse;
    IBOutlet NSButton *buttonBrushROI;
    IBOutlet NSButton *buttonLoadMeshes;
    IBOutlet NSButton *buttonMesh;
    IBOutlet NSTextField *labelPath;
    IBOutlet FPTBMeshesView *meshesView;
    
    //Path
    NSMutableString *FPTBhomeFilePath;
}

//Init window.
-(id)initWithViewerController :(ViewerController*)viewerController;

//Get labeled image path;
-(IBAction)browseLabeledImages:(id)sender;

//Update label with labeled image path
-(void)updateLabel;

//Import labeled images to Brush ROIs
-(IBAction)importLabeledImages:(id)sender;

//Import and show vtk mesh.
-(IBAction)loadMeshFromFile:(id)sender;

//Import labeled image and create mesh
-(IBAction)meshFromLabeledImage:(id)sender;



@end
