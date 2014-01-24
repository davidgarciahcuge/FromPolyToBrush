//
//  FPTBWindowController.m
//  FromPolyToBrush
//
//  Created by David García Juan on 26/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
// PRUEBA 19:29



#import "FPTBWindowController.h"

#import <OsiriXAPI/ViewerController.h>
#import <OsirixAPI/Notifications.h>
#import <OsirixAPI/Roi.h>
#import <OsiriXAPI/DCMPix.h>
#import "OsiriXAPI/RoiVolumeController.h"

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
    
    //We get the viewer and sen retain.
    _viewerController = viewerController;
    [viewerController retain];
      
    // Load the window
	self = [super initWithWindowNibName:@"FPTBWindow"];
    
    [[self window] setDelegate:self];
	
	//FPTBhomeFilePath = [[NSMutableString alloc] initWithString: NSHomeDirectory()];//home path
    //[FPTBhomeFilePath appendString:@"/Documents/RadioAnatomy_Data/FPTBROIs_generated"]; //folder of masks and meshes
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name: NSWindowWillCloseNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name: OsirixCloseViewerNotification object: nil];
    
    return self;
}

- (void)awakeFromNib 
{
    [super windowDidLoad];
    
 
    // place at viewer window upper right corner
//	NSRect frame = [[self window] frame];
//	NSRect screen = [[[_viewerController window] screen] frame];
//	frame.origin.x = screen.origin.x+screen.size.width-frame.size.width;
//	frame.origin.y = screen.origin.y+screen.size.height-frame.size.height;
//	[[self window] setFrame:frame display:YES]; 
    
    // Show
    [[self window] center];
    [[self window] setLevel:NSFloatingWindowLevel];
    
}

- (void)dealloc
{
    //[FPTBhomeFilePath release];
    NSLog(@"FPTBWindowController: dealloc: start");
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_viewerController release];
    [_fptbPixList release];
    [_fptbRoiList release];

    
    [super dealloc];
    
    NSLog(@"FPTBWindowController: dealloc: end");
    
}

- (void)viewerWillClose:(NSNotification*)notification {
    
    NSLog(@"viewerWillClose");
    
    if( [notification object] == _viewerController )
	{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[self window] close];
        //[self autorelease]; //We don't need id because we subclass from NSWindow, and he will take care of deallocating everything.
	}
    
    //NSLog(@"MainWindowController:viewerWillClose:End");
}

- (void)windowWillClose:(NSNotification*)notification {
    
    NSLog(@"windowWillClose");
    
    if( [notification object] == [self window] )
	{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[self window] close];
        //[self autorelease];/We don't need id because we subclass from NSWindow, and he will take care of deallocating everything.

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

        labeledImagePath = [[filenames objectAtIndex:0] path];
        
        if (![labeledImagePath  isEqual: @""])
        {
            [buttonImport setEnabled:true];
            [buttonDisplay setEnabled:true];
            
            [self updateLabel];
            
        }
        
        
    }
    
}

-(void)updateLabel {
    
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
    //reader->Update();
    
   
    
    //vtkStructuredPoints* img = vtkStructuredPoints::New();
    vtkStructuredPoints *img = reader -> GetOutput();
    img -> Update();
    
    //For allowing the img block memory to stay in memory without been linked to the filter.
    //img -> Register(NULL);
    //img -> SetSource(NULL);
    
    //reader -> Delete();
    
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
    
    //We assume we are in RAI coordinates, feet first.
    int start = 0;
    int end = buffDepth-1;
    int step = 1; 
    
    //We get the list of images
    _fptbPixList = [_viewerController pixList];
    [_fptbPixList retain];
    //[[_viewerController pixList] retain];
    
    //We get the ROIs
    _fptbRoiList = [_viewerController roiList];
    [_fptbRoiList retain];
    
    NSLog(@"Dirección de _fptbRoiList = %p", &_fptbRoiList);
    NSLog(@"_fptbRoiList apunta a:  %p", _fptbRoiList);
    //NSMutableArray *_fptbRoiList = [[NSMutableArray alloc] initWithArray:[_viewerController roiList]];
    //[_viewerController roiList retain];
    
    //img -> Update();
    //reader -> Update();
    
    // For each slice
    for( int i = start; i != end; i+=step)         
    {               
        unsigned short *buff = buffOriginal+i*buffWidth*buffHeight; //Apunta al primer pixel de la imagen
        
        DCMPix *curDCM = [_fptbPixList objectAtIndex: i];
        
        // Create the images ROIs array
        //NSMutableArray* roisPerImages = [NSMutableArray array];
        
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
                //[roisPerSeries addObject:roisPerImages];
                
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
        
        //We add the ROI to roiList in OSIRIX
        [[_fptbRoiList objectAtIndex: i] addObject: theNewROI];
        
        //Since the arrasy sent a retain to theNewROI, we can send a release. We won't loose it.
        [theNewROI release];
        
        //[[_viewerController roiList[0] objectAtIndex: i] addObject: theNewROI];
        
        [_imageView roiSet: theNewROI];
        
        
    } // End slices
    
  
    [_imageView setIndex: [_imageView curImage]];
    
    //reader -> Delete();
    
}

-(IBAction)displayLabeledImages:(id)sender
{
    //Por ahora trabajamos presuponiendo que sólo tendremos una ROI en la imagen
    
    ROI *roi = nil;
    float volume = 0, preLocation = 0, interval = 0;
    NSMutableArray *fptbpts;
    
    NSLog(@"3D Display button pulsado");
    
    [_viewerController computeInterval];
    
    [_viewerController displayAWarningIfNonTrueVolumicData];
    
    for( int i = 0; i < [_viewerController maxMovieIndex]; i++)
    {
		[_viewerController saveROI: i];
    }
    
    roi = [_viewerController selectedROI];
    
    if( roi == nil)
	{
		NSRunCriticalAlertPanel(NSLocalizedString(@"ROIs Volume Error", nil), NSLocalizedString(@"Select a ROI to compute volume of all ROIs with the same name.", nil) , NSLocalizedString(@"OK", nil), nil, nil);
		return;
	}
    
    // Check that sliceLocation is available and identical for all images
	preLocation = 0;
	interval = 0;
    
    //We obtain the curMovieIndex from the ViewController
    //_fptbCurMovieIndex = [_viewerController curMovieIndex];
	
	for( int x = 0; x < [_fptbPixList count]; x++)
	{
		DCMPix *curPix = [_fptbPixList objectAtIndex: x];
		
		if( preLocation != 0)
		{
			if( interval)
			{
				if( fabs( [curPix sliceLocation] - preLocation - interval) > 1.0)
				{
					NSRunCriticalAlertPanel(NSLocalizedString(@"ROIs Volume Error", nil), NSLocalizedString(@"Slice Interval is not constant!", nil) , NSLocalizedString(@"OK", nil), nil, nil);
					return;
				}
			}
			interval = [curPix sliceLocation] - preLocation;
		}
		preLocation = [curPix sliceLocation];
	}
    
    if( interval == 0)
    {
        NSRunCriticalAlertPanel(NSLocalizedString(@"ROIs Volume Error", nil), NSLocalizedString(@"Slice Locations not available to compute a volume.", nil) , NSLocalizedString(@"OK", nil), nil, nil);
        return;
    }
    
    //We assume that we won't have missing ROIs for now, so we don't take the code for generating the missing rois.
    NSString	*error;
    NSMutableDictionary	*data = [NSMutableDictionary dictionary];
        
    volume = [_viewerController computeVolume: roi points:&fptbpts generateMissingROIs: NO generatedROIs: nil computeData:data error: &error];
    
    NSLog(@"Volume = %f", volume);
    
    //Usando el ROIVolumeController de Osirix
    //ROIVolumeController *volumeControlloer = [[ROIVolumeController alloc] initWithPoints:fptbpts :volume :_viewerController roi:roi];
    
    //[volumeControlloer showWindow:self];
    
    
    [_theView setPixSource:fptbpts];
    
    //Set the data for rendering
    //[_theView setPointsSource:fptbpts];
    
    //Render the volume
    //[_theView renderVolume];
    
    
    
    
    
        
    
    
    
    
}


@end
