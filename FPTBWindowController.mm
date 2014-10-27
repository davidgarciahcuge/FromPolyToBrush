//
//  FPTBWindowController.m
//  FromPolyToBrush
//
//  Created by David García Juan on 26/08/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
// PRUEBA 19:29



#import "FPTBWindowController.h"

//#import <OsiriXAPI/ViewerController.h>
#import "OsirixAPI/Notifications.h"
#import "OsirixAPI/ROI.h"
//#import <OsiriXAPI/DCMPix.h>
#import "OsiriXAPI/RoiVolumeController.h"
//#import <OsiriXAPI/XMLController.h>
#import "FPTBXmlController.h"


#define id Id
#import <OsiriXAPI/vtkStructuredPointsReader.h>
#import <OsiriXAPI/vtkStructuredPoints.h>
#import <OsiriXAPI/vtkPolyDataReader.h>
#import <OsiriXAPI/vtkPolyDataToImageStencil.h>
#import <OsiriXAPI/vtkImageStencil.h>
#import <OsiriXAPI/vtkMetaImageWriter.h>
#import <OsiriXAPI/vtkImageData.h>
#import <OsiriXAPI/vtkPointData.h>

//#import "vtkStructuredPointsReader.h"
//#import "vtkStructuredPoints.h"
//#import "vtkPolyDataReader.h"
//#import "vtkPolyDataToImageStencil.h"
//#import "vtkImageStencil.h"
//#import "vtkMetaImageWriter.h"
//#import "vtkImageData.h"
//#import "vtkPointData.h"
#undef id

double spacing[3];
NSString *meshPath;

@implementation FPTBWindowController

@synthesize _viewerController;
@synthesize _fptbFileList;
@synthesize _imageView;
@synthesize _fptbPixList, _fptbRoiList;
@synthesize _fptbcurPix;

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
    
    self = [super initWithWindowNibName:@"FPTBWindow"];
    
    if (self) {
        
        [[self window] setDelegate:self];

        //We get the viewer and sen retain.
//        [_viewerController release];
//        _viewerController = viewerController;
//        [viewerController retain];
        
        
        //NSLog(@"Reference count viewer controller: %d", [viewerController ])
        self._viewerController = viewerController; //Esto es equivalente a lo de arriba, estamos utilizando el setter definido en properties, que es la forma correcta de hacerlo.
        
        self._imageView = [_viewerController imageView];
        
        self._fptbFileList = [_viewerController fileList];
        
        _fptbXmlController = [[FPTBXmlController alloc] initWithImages:_fptbFileList withViewer:_viewerController] ;
        
       
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name: NSWindowWillCloseNotification object: nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewerWillClose:) name: OsirixCloseViewerNotification object: nil];
    }
    
    
    
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
    _viewerController = nil;
    
//    [_fptbPixList release];
//    _fptbPixList = nil;
//    
//    [_fptbRoiList release];
//    _fptbRoiList = nil;
    
    [_fptbXmlController release];
    _fptbXmlController = nil;
    
//    [_fptbFileList release];
//    _fptbFileList = nil;
//    
//    [_imageView release];
//    _imageView = nil;

    
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

#pragma mark Functionality

-(IBAction)browseLabeledImages:(id)sender
{
    
    NSLog(@"Mesh selection.");
    
    NSOpenPanel* nsopanel = [NSOpenPanel openPanel];
    [nsopanel setCanChooseFiles:TRUE];
    [nsopanel setCanCreateDirectories:FALSE];
    [nsopanel setCanChooseDirectories:FALSE];
    [nsopanel setAllowsMultipleSelection:FALSE];
    [nsopanel setTitle:@"Select the 3D mesh file"];
    
    NSInteger returnvalue = [nsopanel runModal];
    
    if( returnvalue == NSOKButton )
    {        
        NSArray* filenames = [nsopanel URLs];          

        meshPath = [[filenames objectAtIndex:0] path];
        
        if (![meshPath  isEqual: @""])
        {
            [buttonImport setEnabled:true];
            //[buttonDisplay setEnabled:true];
            
            [self updateLabel];
            
        }
        
        
    }
    
}

-(void)updateLabel {
    
    NSLog(@"Update label."); 
    [labelPath setStringValue:meshPath];
 
}

-(IBAction)importLabeledImages:(id)sender
{
    NSLog(@"Importing labeled images");
    
    vtkSmartPointer<vtkImageData> stencil = [self labeledImagesFromPolydata:meshPath];
    
    // Read image
//    vtkStructuredPointsReader* reader = vtkStructuredPointsReader::New();
//    reader->SetFileName( [meshPath UTF8String] );
//   
//    vtkStructuredPoints *img = reader -> GetOutput();
//    img -> Update();
    
    //For allowing the img block memory to stay in memory without been linked to the filter.
    //img -> Register(NULL);
    //img -> SetSource(NULL);
    
    //reader -> Delete();
    
    // Get image information
    //double *spac1 = img->GetSpacing();
    double *spac1 = stencil -> GetSpacing();
    
    double sx = spac1[0];
    double sy = spac1[1];
    double sz = spac1[2];
    
    //double *org1=img->GetOrigin();
    double *org1 = stencil->GetOrigin();
    
    NSPoint roiOrigin;
    roiOrigin.x = org1[0];
    roiOrigin.y = org1[1];
    
    //int *dim = img->GetDimensions();
    int *dim = stencil->GetDimensions();
    
    // Get data pointer
    //unsigned short *buffOriginal = (unsigned short*)img->GetScalarPointer(); //Pointer to the first byte of the DICOM image
    unsigned char *buffOriginal = (unsigned char*)stencil->GetScalarPointer(); //Pointer to the first byte of the DICOM image
    
    int buffWidth  = dim[0];
    int buffHeight = dim[1];
    int buffDepth  = dim[2];
    
    //We assume we are in RAI coordinates, feet first.
    bool RAI = TRUE;
    
    int start = 0;
    int end = buffDepth-1;
    int step = 1;
    
    if (!RAI)
    {
        start = buffDepth-1;
        end = 0;
        step = -1;
    }
    
    //We get the list of images
    _fptbPixList = [_viewerController pixList];
    //[_fptbPixList retain];
    //[[_viewerController pixList] retain];
    
    //We get the ROIs
    _fptbRoiList = [_viewerController roiList];
    //[_fptbRoiList retain];
    
//    _imageView = [_viewerController imageView];
//    [_imageView retain];
    
    NSLog(@"Dirección de _fptbRoiList = %p", &_fptbRoiList);
    NSLog(@"_fptbRoiList apunta a:  %p", _fptbRoiList);
    //NSMutableArray *_fptbRoiList = [[NSMutableArray alloc] initWithArray:[_viewerController roiList]];
    //[_viewerController roiList retain];
    
    //img -> Update();
    //reader -> Update();
    
    //**DAVID**//
    //Harcoding the number of images to read for testing purposes
    //end = 259;
    
    // For each slice
    for( int i = start; i != end; i+=step)         
    {               
        unsigned char *buff = (unsigned char*)buffOriginal+i*buffWidth*buffHeight; //Apunta al primer pixel de la imagen
        
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
        
        //**DAVID**//
            for (int h=0; h<buffHeight; h++) {                    
                for (int w=0; w<buffWidth; w++) {
                    int k = h*buffWidth + w;
                    
                    //if (buff[k] == labelValue) {
                    if (buff[k] == 255){
                    //if (buff[k] != 0){ //Para trabajar con labeled images
                        roiBuff[k] = 0;
                        hasLabelValue = true;
                        //hasLabelInCompleteImage = true;
                        if (w < minW) minW = w;
                        if (w > maxW) maxW = w;
                        if (h < minH) minH = h;
                        if (h > maxH) maxH = h;
                    } else {
                        roiBuff[k] = 255;
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
            
//        int optBuffWidth = maxW - minW+1;
//        int optBuffHeight = maxH - minH+1;        
//        unsigned char *optRoiBuff = (unsigned char*) malloc( optBuffHeight*optBuffWidth*sizeof(unsigned char) );
//            
//        for (int h=0; h<optBuffHeight; h++) {    
//                for (int w=0; w<optBuffWidth; w++) {
//                    
//                    int k = (minH+h)*buffWidth + w + minW;
//                    int optK = h*optBuffWidth + w;
//                    
//                    optRoiBuff[optK] = roiBuff[k];
//                    
//                }
//            }
        
            
        
        // Create the new ROI
        ROI *theNewROI = [[ROI alloc] initWithTexture:roiBuff
                                            textWidth:buffWidth
                                            textHeight:buffHeight
                                            textName:@"ROI_Prueba"
                                            positionX:minW
                                            positionY:minH
                                            spacingX:sx
                                            spacingY:sy
                                            imageOrigin:roiOrigin];
        
        free(roiBuff);

//
//        NSLog(@"BrushROI created");
        
        //Try to create a tCPolygon ROI from scratch
//        ROI *theNewROI = [[[ROI alloc] initWithType:10 :sx :roiOrigin] autorelease];
//        
//        //**DAVID**//
//        [theNewROI retain];
//        
//        [theNewROI setName:@"ROI_Prueba"];
//        
//        [theNewROI setTexture:optRoiBuff width:optBuffWidth height:optBuffHeight];
//        
//        [[_imageView curRoiList] addObject:theNewROI];
        [_imageView roiSet:theNewROI];
        
//        [theNewROI setRoiView:_imageView];
        //****//
        
//        free(optRoiBuff);
        
//        ROI *polROI = [_viewerController convertBrushROItoPolygon:theNewROI numPoints:100];
//        
//        NSLog(@"PolygonROI created");
        
        // Add RGB color to the new ROI
        [theNewROI setNSColor:[NSColor greenColor]];
            
        // Set ROI thickness
        [theNewROI setSliceThickness:1.5];

        //Set ROI opacity
        [theNewROI setOpacity:0.5];
        
        //Set the ROI to its images
        [theNewROI setPix:curDCM];
        
        //Unlock the ROI
        [theNewROI setLocked:false];
        
        
        //We add the ROI to roiList in OSIRIX
        [[_fptbRoiList objectAtIndex: i] addObject: theNewROI];
        

        
        
        //[[_viewerController roiList[0] objectAtIndex: i] addObject: theNewROI];
        
        //[_imageView roiSet: theNewROI];
        
        //NSLog(@"PolygonROI stored");
        
        //Since the arrasy sent a retain to theNewROI, we can send a release. We won't loose it.
        [theNewROI release];
        
        
    } // End slices
    
  
    [_imageView setIndex: [_imageView curImage]];
    
    [buttonDisplay setEnabled:TRUE];
    
    NSLog(@"Import de la mesh finalizado");
    
//    reader -> Delete();
    
}

-(vtkSmartPointer<vtkImageData>)labeledImagesFromPolydata: (NSString*) filePath
{
    //Sacamos la primera imagen para poder acceder al pixelSpacing y los datos que necesitamos
    //We get the list of images
    _fptbPixList = [_viewerController pixList];
    [_fptbPixList retain];
    
    DCMPix *firstPix = [_fptbPixList objectAtIndex:0];
    [firstPix retain];
    
    DCMPix *lastPix = [_fptbPixList lastObject];
    [lastPix retain];
    
    //Leemos la mesh desde archivo
    vtkSmartPointer<vtkPolyDataReader> dataReader = vtkSmartPointer<vtkPolyDataReader>::New();
    //dataReader->SetFileName("/Users/David/Documents/PHD/Data/Matthias_Segmentation_Data/2014/left-segmented-femur-subject1.vtp");
    
    dataReader->SetFileName([meshPath UTF8String]);
    
    polydata = dataReader->GetOutput();
           
    dataReader->Update();
    
    //Imagen a la que luego se aplicará el stencil
    vtkSmartPointer<vtkImageData> whiteImage = vtkSmartPointer<vtkImageData>::New();
    
    // desired volume spacing, sacamos el spacing de la serie que tenemos, que es con la que queremos que esté alineada.

    spacing[0] = [firstPix pixelSpacingX];
    spacing[1] = [firstPix pixelSpacingY];
    spacing[2] = [firstPix spacingBetweenSlices];
    
//    spacing[0] = 0.78125;
//    spacing[1] = 0.78125;
//    spacing[2] = 1.5;
    
    whiteImage->SetSpacing(spacing);
    
    // compute dimensions, dividiendo los límites entre el spacing, eso hace que squemos el número de píxels.
//    double bounds[6];
//    polydata->GetBounds(bounds);
//    
//    int dimPoly[3];
//    for (int i = 0; i < 3; i++)
//    {
//        dimPoly[i] = static_cast<int>(ceil((bounds[i * 2 + 1] - bounds[i * 2]) / spacing[i]));
//    }
//    
//    //Origen a partir de los bounds del polydata
//    double originPoly[3];
//    originPoly[0] = bounds[0] + spacing[0] / 2;
//    originPoly[1] = bounds[2] + spacing[1] / 2;
//    originPoly[2] = bounds[4] + spacing[2] / 2;
    
    
    //Mismas dimensiones que el DICOM
    int dim[3];

    dim[0] = [firstPix pwidth];
    dim[1] = [firstPix pheight];
    dim[2] = [_fptbPixList count];
    
//    dim[0]=640;
//    dim[1]=640;
//    dim[2]=260;
    
    whiteImage->SetDimensions(dim);
    whiteImage->SetExtent(0, dim[0] - 1, 0, dim[1] - 1, 0, dim[2] - 1);
    
    //NSNumber *test = [[NSNumber alloc] initWithDouble:round([firstPix originZ] * 1000)/1000];
    
    //Mismo origen que la serie DICOM
    double origin[3];
    origin[0] = [firstPix originX];
    origin[1] = [firstPix originY];
    origin[2] = round([firstPix originZ]); //Round to make the stencil work...
    
//    [firstPix origin:origin];
    
    //**Set WhiteImage Origin**//
    whiteImage->SetOrigin(origin);
    //****//
    
#if VTK_MAJOR_VERSION <= 5
    whiteImage->SetScalarTypeToUnsignedChar();
    whiteImage->AllocateScalars();
#else
    whiteImage->AllocateScalars(VTK_UNSIGNED_CHAR,1);
#endif
    
    unsigned char inval = 255;
    unsigned char outval = 0;
    
    vtkIdType count = whiteImage->GetNumberOfPoints();
    
    NSLog(@"Número de puntos en whiteImage: %lld", count);
    
    for (vtkIdType i = 0; i < count; ++i)
    {
        whiteImage->GetPointData()->GetScalars()->SetTuple1(i, inval);
    }
    
    // polygonal data --> image stencil:
    vtkSmartPointer<vtkPolyDataToImageStencil> pol2stenc = vtkSmartPointer<vtkPolyDataToImageStencil>::New();
    
#if VTK_MAJOR_VERSION <= 5
    pol2stenc->SetInput(polydata);
#else
    pol2stenc->SetInputData(polydata);
#endif
    
    pol2stenc->SetOutputOrigin(origin);
    pol2stenc->SetOutputSpacing(spacing);
    pol2stenc->SetOutputWholeExtent(whiteImage->GetExtent()); //Extent de la imagen output (será el Extent de toda la serie)
    //pol2stenc->SetOutputWholeExtent(dimPoly);
    pol2stenc->Update();
    
    // cut the corresponding white image and set the background:
    vtkSmartPointer<vtkImageStencil> imgstenc =
    vtkSmartPointer<vtkImageStencil>::New();
    
#if VTK_MAJOR_VERSION <= 5
    imgstenc->SetInput(whiteImage);
    imgstenc->SetStencil(pol2stenc->GetOutput());
#else
    imgstenc->SetInputData(whiteImage);
    imgstenc->SetStencilConnection(pol2stenc->GetOutputPort());
#endif
    
    imgstenc->ReverseStencilOn();
    imgstenc->SetBackgroundValue(outval);
    //imgstenc->Update();
    
    //vtkSmartPointer<vtkImageData> imageStencil = imgstenc -> GetOutput();
    
//    //**Writing the image created in a .mhd file**//

    //****//
    
//    //**Flipping y**//
    vtkSmartPointer<vtkImageFlip> flipyFilter = vtkSmartPointer<vtkImageFlip>::New();
    
    flipyFilter->SetFilteredAxis(1); // flip y axis
    flipyFilter->SetInput(imgstenc->GetOutput());
    
//    vtkSmartPointer<vtkImageData> imageStencil = flipyFilter -> GetOutput();
//    
//    flipyFilter -> Update();
//    

    //****//
    
    //**Flipping x**//
//
    vtkSmartPointer<vtkImageFlip> flipxFilter = vtkSmartPointer<vtkImageFlip>::New();
    
    flipxFilter->SetFilteredAxis(0); // flip x axis
    flipxFilter->SetInput(flipyFilter->GetOutput());
    
    vtkSmartPointer<vtkImageData> imageStencil = flipxFilter -> GetOutput();

    flipxFilter->Update();
    
      //****//
//
//    //Write image and flipped images in files
    
//    vtkSmartPointer<vtkMetaImageWriter> writer =
//    vtkSmartPointer<vtkMetaImageWriter>::New();
//    
//    writer->SetFileName("/Users/David/Development/Repositories/FromPolyToBrushResults/labeled_mesh.mhd");
//    writer->SetInput(imgstenc->GetOutput());
//    
//    writer->Write();
//    
//    writer -> SetInput(flipyFilter->GetOutput());
//    writer->SetFileName("/Users/David/Development/Repositories/FromPolyToBrushResults/labeled_mesh_yflipped_round.mhd");
//    
//    writer -> Write();
//    
//    writer->SetInput(flipxFilter->GetOutput());
//    writer->SetFileName("/Users/David/Development/Repositories/FromPolyToBrushResults/labeled_mesh_yxflipped_round.mhd");
//    
//    writer->Write();
//

    
    NSLog(@"Labeled Image creada");
    
    [firstPix release];
    [lastPix release];
    [_fptbPixList release];
    
    
    return imageStencil;
//    return EXIT_SUCCESS;
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
    
    //We get the z spacingBetweenSlices
    //zspacing = spacing[2];
    
    //We obtain the curMovieIndex from the ViewController
    //_fptbCurMovieIndex = [_viewerController curMovieIndex];
    
    [self setRealSliceLocation];
	
	for( int x = 0; x < [_fptbPixList count]; x++)
	{
		DCMPix *curPix = [_fptbPixList objectAtIndex: x];
        
        NSLog(@"slice location: %f", [curPix sliceLocation]);
		
		if( preLocation != 0)
		{
            //**DAVID**//
            //Check if the slice location es la misma que antes, si lo es, pon la location buena.
			if( interval)
			{
				if( fabs( [curPix sliceLocation] - preLocation - interval) > 1.0)
				{
					NSRunCriticalAlertPanel(NSLocalizedString(@"ROIs Volume Error", nil), NSLocalizedString(@"Slice Interval is not constant!", nil) , NSLocalizedString(@"OK", nil), nil, nil);
					return;
				}
			}
            //Trick for computing the interval between slices
			interval = [curPix sliceLocation]  - preLocation;
            
//            //**DAVID**//
//            //If sliceLocation is not changing in z, we have to compute the z position.
//            if (interval == 0) {
//                [curPix setSliceLocation:([curPix sliceLocation] + (x * zspacing))];
//            }
//            else
//            {
//                preLocation = [curPix sliceLocation];
//            }
//            
//            continue;
            //****//

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
    
    
    //[_theView setPixSource:fptbpts];
    
    //Set the data for rendering
    short result = [_theView setPixSource:fptbpts];
    
    //[buttonDisplay setEnabled:TRUE];
    
    //short result2 = [_theView renderVolume];
    
    [pointsCheckbox setEnabled:TRUE];
    [pointsCheckbox setState:NSOffState];
    
    [surfaceCheckbox setEnabled:TRUE];
    [surfaceCheckbox setState:NSOnState];
    
    
//    [delaunayReconstruction setEnabled:TRUE];
//    [delaunayReconstruction setState:NSOffState];
//    
//    [powerCrustReconstruction setEnabled:TRUE];
//    [powerCrustReconstruction setState:NSOnState];
    
    [matrixRadioButtons setEnabled:TRUE];
    [matrixRadioButtons selectCell:powerCrustReconstruction];

    
    [_theView renderVolumeWitDelaunay:[delaunayReconstruction state] withPowerCrust:[powerCrustReconstruction state] showPoints:[pointsCheckbox state] showSurface:[surfaceCheckbox state]];
    
    NSLog(@"Error = %hd", result);
    
    //NSLog(@"Error2 = %hd", result2);
    
    //[_theView renderVolume];
    
    //Render the volume
    //[_theView renderVolume];
}

-(IBAction)updateView:(id)sender
{
    BOOL points = false;
    BOOL surface = false;

    
    points = [pointsCheckbox state];
    surface = [surfaceCheckbox state];

    
    if (_theView)
    {
        
        [_theView showPoints:points showSurface:surface];
        
    }
    
}

-(IBAction)changeReconstruction:(id)sender
{
    
//    if ([sender selectedCell] == delaunayReconstruction)
//    {
//        //[powerCrustReconstruction setState:![delaunayReconstruction state]];
//        [_theView renderVolumeWitDelaunay:[delaunayReconstruction state] withPowerCrust:[powerCrustReconstruction state]];
//    }
//    
//    
//    if ([sender selectedCell] == powerCrustReconstruction)
//    {
//        //[delaunayReconstruction setState:![powerCrustReconstruction state]];
//        [_theView renderVolumeWitDelaunay:[delaunayReconstruction state] withPowerCrust:[powerCrustReconstruction state]];
    
//    }
    
    
    BOOL delaunay = FALSE;
    BOOL powerCrust = FALSE;
    
    BOOL points = [pointsCheckbox state];
    BOOL surface = [surfaceCheckbox state];
    
    if ([matrixRadioButtons selectedCell] == powerCrustReconstruction)
    {
        powerCrust = TRUE;
    }else
    {
        delaunay = TRUE;
    }
    
    [_theView renderVolumeWitDelaunay:delaunay withPowerCrust:powerCrust showPoints:points showSurface:surface];

    
}

#pragma mark Internal Use

-(NSMutableArray*)setRealSliceLocations:(NSMutableArray*)originalPositions
{
    //double zspacing = spacing[2];
    double zspacing = 1.5; //Hardcodeamos para testing purposes
    
    NSMutableArray *correctPositions = [NSMutableArray arrayWithCapacity:[originalPositions count]];
    
    NSLog(@"NEW Z POSITIONS");
    
//    for( int x = 0; x < [_fptbPixList count] - 1; x++)
//	{
//		DCMPix *curPix1 = [_fptbPixList objectAtIndex:x];
//        DCMPix *curPix2 = [_fptbPixList objectAtIndex:(x + 1)];
//        
//        if ([curPix1 sliceLocation] == [curPix2 sliceLocation] & x!= [_fptbPixList count] - 2) {
//            [curPix1 setSliceLocation:[curPix1 sliceLocation] + (x*zspacing)];
//            [curPix1 setSliceInterval:[curPix1 spacingBetweenSlices]];
//        }else if ([curPix1 sliceLocation] == [curPix2 sliceLocation] & x == [_fptbPixList count] - 2)
//        {
//            [curPix1 setSliceLocation:[curPix1 sliceLocation] + (x*zspacing)];
//            [curPix2 setSliceLocation:[curPix2 sliceLocation] + ((x+1)*zspacing)];
//            
//            [curPix1 setSliceInterval:[curPix1 spacingBetweenSlices]];
//            [curPix2 setSliceInterval:[curPix2 spacingBetweenSlices]];
//        }
//        
//        
//    }
    
    for (int x = 0; x < [originalPositions count]; x++)
    {
        double original = [[originalPositions objectAtIndex:x] doubleValue];
        double correct = original + (x*zspacing);
        
        [correctPositions addObject:[NSNumber numberWithDouble:correct]];
        
        NSLog(@"Position: %f", correct);
    }
    
    return correctPositions;
}

-(IBAction)changePatientPosition:(id)sender
{
    //imObj = [fileList[curMovieIndex] objectAtIndex:[imageView curImage]];

    //Apuntes
//    dcmDocument = [[DCMObject objectWithContentsOfFile:srcFile decodingPixelData:NO] retain];
//    xmlDocument = [[dcmDocument xmlDocument] retain];
    
    //_fptbFileList = [[_viewerController fileList] retain];
    
    //short curIndex = [_viewerController curMovieIndex];

    //FPTBXmlController *_fptbController = [[FPTBXmlController alloc] initWithImages:_fptbFileList withViewer:_viewerController] ;
    
    //Update ViewerController data
    //[[_viewerController previewMatrixScrollView] ];
    
    //Extract z position of each slice
    NSMutableArray *zPositions = [_fptbXmlController extractZPatientPosition];
    
    //Compute the real zPosition
    NSMutableArray *correctPositions = [self setRealSliceLocations:zPositions];

    
    [_fptbXmlController modifyDicomsWithNewPositions:correctPositions];

    
//    [_fptbController release];
//    _fptbController = nil;
    
}

-(IBAction)multiFrameToSingleFrame:(id)sender
{
    //Files list of the loaded serie in the viewer controller
    //_fptbFileList = [[_viewerController fileList] retain];
    
//    FPTBXmlController *_fptbController = [[FPTBXmlController alloc] initWithImages:_fptbFileList withViewer:_viewerController] ;
//    
//    [_fptbController release];
//    _fptbController = nil;
    
    bool multi = [_fptbXmlController checkIfMultiFrame];
    
    if (multi) {
        bool result = [_fptbXmlController fromMultiFrameToSingleFrame];
        if (result) {
            //Mostrar un popup diciendo que se ha hecho correctamente la conversión
            //¿Devolver ya la lista de archivos?
            NSRunAlertPanel(@"Multi - Single", @"Conversion from single-frame to multi-frame successful", @"OK", nil, nil);
            
//            NSRunInformationalAlertPanel(NSLocalizedString(@"OsiriX crashed", nil), NSLocalizedString(@"OsiriX crashed... You are running an outdated version of OsiriX ! This bug is probably corrected in the last version !", nil), NSLocalizedString(@"OK",nil), nil, nil);
        }else{
            //Mostrar popup diciendo que no se ha podico generar correctamente
            NSRunAlertPanel(@"Multi - Single", @"There was an error in the conversion process", @"OK", nil, nil);
        }
    }else
    {
        //Popup diciendo ya se trata de una single frame
        NSRunAlertPanel(@"Multi - Single", @"The .dcm files are already single-frame", @"OK", nil, nil);
    }

}


@end
