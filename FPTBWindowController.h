//
//  FPTBWindowController.h
//  FromPolyToBrush
//
//  Created by David García Juan on 26/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//  PRUEBA DE BRANCH

#import <Cocoa/Cocoa.h>

@class ViewerController;

@interface FPTBWindowController : NSWindowController {
    
    ViewerController *_viewerController;
    NSString *labeledImagePath;
    
    IBOutlet NSButton *buttonBrowse;
    IBOutlet NSButton *buttonImport;
    IBOutlet NSTextField *labelPath;
    
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


@end
