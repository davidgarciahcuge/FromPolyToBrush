//
//  FPTBWindowController.m
//  FromPolyToBrush
//
//  Created by David García Juan on 26/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//



#import "FPTBWindowController.h"

#import <OsiriXAPI/ViewerController.h>
#import <OsirixAPI/Notifications.h>
#import <OsirixAPI/Roi.h>
#import <OsiriXAPI/DCMPix.h>

#import "vtkStructuredPointsReader.h"
#import "vtkStructuredPoints.h"


@interface FPTBWindowController ()

@end

@implementation FPTBWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

-(id)initWithViewerController:(ViewerController*)viewerController {
    
    _viewerController = viewerController;
    [_viewerController retain];

    _imageView = [[_viewerController imageView] retain];
    
    // Load the window
	self = [self initWithWindowNibName:@"FPTBWindow"];
	
	FPTBhomeFilePath = [[NSMutableString alloc] initWithString: NSHomeDirectory()];//home path
    [FPTBhomeFilePath appendString:@"/Documents/RadioAnatomy_Data/FPTBROIs_generated"]; //folder of masks and meshes
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name: NSWindowWillCloseNotification object: nil];    
    
    return self;
}

- (void)awakeFromNib 
{
    [super windowDidLoad];
    
 
    // place at viewer window upper right corner
	NSRect frame = [[self window] frame];
	NSRect screen = [[[_viewerController window] screen] frame];
	frame.origin.x = screen.origin.x+screen.size.width-frame.size.width;
	frame.origin.y = screen.origin.y+screen.size.height-frame.size.height;
	[[self window] setFrame:frame display:YES]; 
    
    // Show
    [[self window] setLevel:NSFloatingWindowLevel];
    
}

- (void)dealloc
{
    [FPTBhomeFilePath release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_viewerController release];
    [_imageView release];
    
    [super dealloc];
    
}

- (void)viewerWillClose:(NSNotification*)notification {
    
    NSLog(@"viewerWillClose");
    
    if( [notification object] == _viewerController )
	{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self close];
        [self autorelease];
	}
    
    //NSLog(@"MainWindowController:viewerWillClose:End");
}

- (void)windowWillClose:(NSNotification*)notification {
    
    NSLog(@"windowWillClose");
    
    if( [notification object] == [self window] )
	{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [self close];
        [self autorelease];
	}
}

-(IBAction)browseLabeledImages:(id)sender
{
    
    NSLog(@"Select labeled image.");    
    
    NSOpenPanel* nsopanel = [NSOpenPanel openPanel];
    [nsopanel setCanChooseFiles:TRUE];
    [nsopanel setCanCreateDirectories:FALSE];
    [nsopanel setCanChooseDirectories:FALSE];
    [nsopanel setAllowsMultipleSelection:FALSE];
    [nsopanel setTitle:@"Select the labeled image file"];
    NSInteger returnvalue = [nsopanel runModal];
    
    if( returnvalue == NSOKButton )
    {        
        NSArray* filenames = [nsopanel URLs];          
        //[_imageField setStringValue:[[filenames objectAtIndex:0] path]];
        labeledImagePath = [[filenames objectAtIndex:0] path];
        
        if (labeledImagePath != @"")
        {
            [buttonImport setEnabled:true];
        }else {
            [buttonImport setEnabled:false];
        }
        
        [self updateLabel];
        
    }
    
}

-(void)updateLabel{
    
    NSLog(@"Update label."); 
    [labelPath setStringValue:labeledImagePath];
 
}

-(IBAction)importLabeledImages:(id)sender
{
    NSLog(@"Importing labeled images");
    
    //NSString *imageFile = [la];
    
    // Read image
    vtkStructuredPointsReader* reader = vtkStructuredPointsReader::New();
    reader->SetFileName( [labeledImagePath UTF8String] );
    reader->Update(); 
    
    vtkStructuredPoints* img = vtkStructuredPoints::New();
    img = reader->GetOutput();
    
    // Get image information
    double *spac1 = img->GetSpacing();
    double sx = spac1[0];
    double sy = spac1[1];
    double sz = spac1[2];
    double *org1 = img->GetOrigin();  
    NSPoint roiOrigin;
    roiOrigin.x = org1[0];
    roiOrigin.y = org1[1];  
    int *dim = img->GetDimensions();
    
    // Get data pointer
    unsigned short *buffOriginal = (unsigned short*)img->GetScalarPointer(); //Pointer to the first byte of the DICOM image
    int buffWidth  = dim[0];
    int buffHeight = dim[1];
    int buffDepth  = dim[2];
    
    // Create the movie ROIs array
    NSMutableArray* roisPerMovies = [NSMutableArray array];
    
    // Create the series ROIs array
    NSMutableArray* roisPerSeries = [NSMutableArray array];
    
    //We assume we are in RAI coordinates, feet first.
    int start = 0;
    int end = buffDepth-1;
    int step = 1; 
    
    //We assume we are not in RAI coordinates, head first.
    //int start = buffDepth-1;
    //int end = 0;
    //int step = -1;  
    
    //short FPTBmaxMovieIndex = [_viewerController maxMovieIndex];
    
    //We get the list of images
    NSMutableArray *fptbPixList = [_viewerController pixList];
    //[[_viewerController pixList] retain];
    
    //We get the ROIs
    NSMutableArray *fptbRoiList = [_viewerController roiList];
    NSLog(@"Dirección de fptbRoiList = %p", &fptbRoiList);
    NSLog(@"fptbRoiList apunta a:  %p", fptbRoiList);
    //NSMutableArray *fptbRoiList = [[NSMutableArray alloc] initWithArray:[_viewerController roiList]];
    //[_viewerController roiList retain];
    
    // For each slice
    for( int i = start; i != end; i+=step)         
    {               
        unsigned short *buff = buffOriginal+i*buffWidth*buffHeight; //Apunta al primer pixel de la imagen
        
        DCMPix *curDCM = [/*[*/fptbPixList /*objectAtIndex:y]*/ objectAtIndex: i];
        
        // Create the images ROIs array
        NSMutableArray* roisPerImages = [NSMutableArray array];
        
        // Add loaded ROIs if merging mode
        /*if (hasLoadedROIsToMerge) {
            mi++;
            if (mi < [loadedRoisSeries count]) {
                if ([[loadedRoisSeries objectAtIndex:mi] count] > 0) { 
                    [roisPerImages addObjectsFromArray:[loadedRoisSeries objectAtIndex:mi]];
                }
            }
        }*/
        
        // For each label
        //int cntLabel = 0;
        //for (NSDictionary* label in labels) {
            //cntLabel++;
            
            // Create the ROI buff
            //I am creating only one label, I don't need to go trough the dictionary.
            unsigned char *roiBuff = (unsigned char*) malloc( buffHeight*buffWidth*sizeof(unsigned char) );
            
            int minW = buffWidth; int maxW = 0;
            int minH = buffHeight; int maxH = 0;
            
            bool hasLabelValue = false;
            
            // Get label information
            /*int labelValue = [[label valueForKey:@"IDX"] intValue];
            NSString* labelName = [label valueForKey:@"LABEL"];  
            RGBColor labelColor;          
            labelColor.red = (short) [[label valueForKey:@"R"]floatValue] /255.0*65535.;
            labelColor.green = (short) [[label valueForKey:@"G"]floatValue] /255.0*65535.;
            labelColor.blue = (short) [[label valueForKey:@"B"]floatValue] /255.0*65535.; */
            
            // Skip label 0
            //if (labelValue == 0) continue;
            
            for (int h=0; h<buffHeight; h++) {                    
                for (int w=0; w<buffWidth; w++) {
                    int k = h*buffWidth + w;
                    
                    //if (buff[k] == labelValue) {
                    if (buff[k] == 1){
                        roiBuff[k] = 255;
                        hasLabelValue = true;
                        //hasLabelInCompleteImage = true;
                        if (w < minW) minW = w;
                        if (w > maxW) maxW = w;
                        if (h < minH) minH = h;
                        if (h > maxH) maxH = h;
                    } else {
                        roiBuff[k] = 0;
                    }
                    
                }
            }
            
            // If the slice does not contain the current label skip it
            if (!hasLabelValue) {
                free(roiBuff);
                
                // Add the empty ROIs to the series ROIs. Para mantener la sincronización con las imágenes.
                [roisPerSeries addObject:roisPerImages];
                
                continue;
            }
            
            // Resize buffer for memory optimisation
            int optBuffWidth = maxW - minW+1;
            int optBuffHeight = maxH - minH+1;        
            unsigned char *optRoiBuff = (unsigned char*) malloc( optBuffHeight*optBuffWidth*sizeof(unsigned char) );
            for (int h=0; h<optBuffHeight; h++) {    
                for (int w=0; w<optBuffWidth; w++) {
                    
                    int k = (minH+h)*buffWidth + w + minW;
                    int optK = h*optBuffWidth + w;
                    
                    optRoiBuff[optK] = roiBuff[k];
                    
                }
            }
            free(roiBuff);
            
            // Create the new ROI
            ROI *theNewROI = [[ROI alloc] initWithTexture:optRoiBuff
                                                textWidth:optBuffWidth
                                               textHeight:optBuffHeight
                                                 textName:@"ROI_Prueba"
                                                positionX:minW
                                                positionY:minH
                                                 spacingX:sx
                                                 spacingY:sy
                                              imageOrigin:roiOrigin];                
            free(optRoiBuff);
            
        // Add RGB color to the new ROI               
        [theNewROI setNSColor:[NSColor greenColor]];
            
        // Set ROI thickness
        [theNewROI setSliceThickness:sz];

        //Set ROI opacity
        [theNewROI setOpacity:0.5];
        
        //Set the ROI to its images
        [theNewROI setPix:curDCM];
        
        //Unlock the ROI
        [theNewROI setLocked:false];
        
        
        //[fptbRoiList addObject:theNewROI];
        [[fptbRoiList objectAtIndex: i] addObject: theNewROI];
        //[fptbRoiList removeObjectAtIndex:i];
        //[fptbRoiList insertObject:theNewROI atIndex:i];
        
        //[[_viewerController roiList[0] objectAtIndex: i] addObject: theNewROI];
        
        [_imageView roiSet: theNewROI];
        
        [theNewROI release];
        // Add the new ROI to the slice array
            //[roisPerImages addObject: theNewROI];
            
        //} // End labels
        
        // Add the images ROIs to the series ROI
        [roisPerSeries addObject:roisPerImages];
        
    } // End slices
    
    [roisPerMovies addObject:roisPerSeries];
    
    
    [_imageView setIndex: [_imageView curImage]];
    
    //[_imageView stopROIEditingForce: YES];

    
    //We try to avoid the step of saving in a file
    //_viewerController = [ViewerController frontMostDisplayed2DViewer];
    //[_viewerController retain];
    
    //short FPTBmaxMovieIndex = [_viewerController maxMovieIndex];
    
    //NSMutableArray *FPTBpixList = [[NSMutableArray alloc] initWithArray:[_viewerController pixList]];
    
    //NSArray *fptbPixList;
    
    //fptbPixList = [_viewerController pixList];
    //[[_viewerController pixList] retain];
    
    //[[_viewerController pixList] retain];
    //FPTBpixList = [_viewerController pixList];
    
    //FPTBpixList = [[_viewerController pixList] copy];
    //[FPTBpixList retain];
    
    /*NSMutableArray *fptbRoiList = [_viewerController roiList];
    [fptbRoiList retain];
    
    for( int y = 0; y < FPTBmaxMovieIndex; y++)
	{
		if( [roisPerMovies count] > y)
		{
			NSArray *roisSeries = [roisPerMovies objectAtIndex: y];
			
			for( int x = 0; x < [fptbPixList count]; x++)
			{
				DCMPix *curDCM = [fptbPixList objectAtIndex: x];
				
				if( [roisSeries count] > x)
				{
					NSArray *roisImages = [roisSeries objectAtIndex: x];
					
					for( ROI *r in roisImages)
					{
                        //Correct the origin only if the orientation is the same
                        r.pix = curDCM;
                        
						[r setOriginAndSpacing: curDCM.pixelSpacingX :curDCM.pixelSpacingY :[DCMPix originCorrectedAccordingToOrientation: curDCM]];
						
						[[[fptbRoiList objectAtIndex:y] objectAtIndex: x] addObject: r];
						[_imageView roiSet: r];
					}
				}
			}
		}
	}
	
	[_imageView setIndex: [_imageView curImage]];*/
    
    //[FPTBpixList release];
    //[FPTBroiList release];
    
    // Save the ROIs in the output file
    //if (hasLabelInCompleteImage) {
    /*NSMutableString *FPTBroisFile = [[NSMutableString alloc] initWithString:FPTBhomeFilePath];
    [FPTBroisFile appendString:@"/RadioAnatomyROIs.rois_series"];
    
    // Save the ROIs to the file
    //[NSArchiver archiveRootObject: roisPerMovies toFile :@"/Users/David/Development/ROIs_generated/RadioAnatomyROIs.rois_series"];
    [NSArchiver archiveRootObject: roisPerMovies toFile :FPTBroisFile];  
    
    
    NSMutableString *FPTBroisZip = [[NSMutableString alloc] initWithString:FPTBroisFile];
    [FPTBroisZip appendString:@".zip"];
       
    // Zip the file
    //NSString *outputZip = [NSString stringWithFormat:@"%@.zip", outputFile];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    
    if (!([fileManager fileExistsAtPath:FPTBhomeFilePath isDirectory:&isDir] && isDir)) {
    
        [fileManager createDirectoryAtPath:FPTBhomeFilePath withIntermediateDirectories:false attributes:nil error:nil];
        
    }
    
    if ([fileManager fileExistsAtPath:FPTBroisZip]) {
            [fileManager removeItemAtPath:FPTBroisZip error:NULL];
        }
    
    NSString *path = @"/usr/bin/zip";
    NSArray *args = [NSArray arrayWithObjects:@"-m", @"-j", FPTBroisZip, FPTBroisFile, nil];
    [[NSTask launchedTaskWithLaunchPath:path arguments:args] waitUntilExit];
    
    [FPTBroisFile release];
    [FPTBroisZip release];*/
        
    //}
}


@end
