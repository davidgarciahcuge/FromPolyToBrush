//
//  FPTBWindowController.h
//  FromPolyToBrush
//
//  Created by David García Juan on 26/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.


#import <Cocoa/Cocoa.h>

#import "OsiriXAPI/DCMView.h"
#import "OsiriXAPI/DCMPix.h"
#import "OsiriXAPI/Window3DController.h"

#import "FPTBROIVolumeView.h"


@class ViewerController;

@interface FPTBWindowController : Window3DController <NSWindowDelegate> {
    
    ViewerController *_viewerController;
    
    DCMView *_imageView;
    NSString *labeledImagePath;
    NSMutableArray *_fptbPixList, *_fptbRoiList;
    //short _fptbCurMovieIndex;
    
    DCMPix *_fptbcurPix;
    
    IBOutlet NSButton *buttonBrowse;
    IBOutlet NSButton *buttonImport;
    IBOutlet NSButton *buttonDisplay;
    IBOutlet NSTextField *labelPath;
    
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


@end
