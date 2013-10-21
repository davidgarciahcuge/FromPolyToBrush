//
//  FPTBWindowController.h
//  FromPolyToBrush
//
//  Created by David García Juan on 26/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.


#import <Cocoa/Cocoa.h>
#import <OsiriXAPI/DCMView.h>

@class ViewerController;

@interface FPTBWindowController : NSWindowController {
    
    ViewerController *_viewerController;
    DCMView *_imageView;
    NSString *labeledImagePath;
    
    IBOutlet NSButton *buttonBrowse;
    IBOutlet NSButton *buttonImport;
    IBOutlet NSTextField *labelPath;
    
    //Path
    NSMutableString *FPTBhomeFilePath;
}

@property (weak) ViewerController *_viewerController; 

//Init window.
-(id)initWithViewerController :(ViewerController*)viewerController;

//Get labeled image path;
-(IBAction)browseLabeledImages:(id)sender;

//Update label with labeled image path
-(void)updateLabel;

//Import labeled images to Brush ROIs
-(IBAction)importLabeledImages:(id)sender;


@end
