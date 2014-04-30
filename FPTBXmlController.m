//
//  FPTBXmlController.m
//  FromPolyToBrush
//
//  Created by David García Juan on 10/04/14.
//
//

#import "FPTBXmlController.h"

#import "OsiriXAPI/dicomFile.h"
#import "OsiriXAPI/XMLControllerDCMTKCategory.h"
#import "OsiriXAPI/MutableArrayCategory.h"
#import "OsiriXAPI/DICOMToNSString.h"
#import "OsiriXAPI/DicomFileDCMTKCategory.h"
#import "OsiriXAPI/DCMObjectDBImport.h"
#import "OsiriXAPI/ViewerController.h"
#import "OsiriXAPI/Wait.h"
#import "OsiriXAPI/DCMView.h"
#import "OsiriXAPI/BrowserController.h"
#import "OsiriXAPI/DicomDatabase.h"

#import "OsiriX/DCMAttribute.h"


NSMutableArray *positions;
ViewerController *_viewer;
DCMView *_dcmView;
BrowserController *_browserController;
DicomDatabase *_database;

@implementation FPTBXmlController

- (id) initWithImages:(NSArray*) images withViewer: (ViewerController*) viewer;
{
    self = [super init];
    
    if (self) {
        
        //Complete list of paths to the file that corresponds to the images in the viewer.
        dicomFilePaths = [NSMutableArray arrayWithArray: [images valueForKey:@"completePath"]];
        _viewer = [viewer retain];
        _dcmView = [[_viewer imageView] retain];
        
        NSString *firstPath = [dicomFilePaths objectAtIndex:0];
        NSString *secondPath = [dicomFilePaths objectAtIndex:1];
        
        //if two consecutive paths are the same, then the serie is multi-frame and we need to create the single-frame images
        if ([firstPath isEqualToString:secondPath]) {
            [self fromMultiFrameToSingleFrame];
        }
        
        //imagePath = [dicomFilePaths objectAtIndex:index];
        
        positions = [[NSMutableArray alloc]init];
        
//        if(dicomFilePaths)//Check if the file in the path is a Dicom file
//        {
//            //Deleting repeated paths
//            [dicomFilePaths removeDuplicatedStrings];
//            
//            dcm = [[DCMObjectDBImport objectWithContentsOfFile:dicomFilePath decodingPixelData:NO] retain];
//            xml = [[dcm xmlDocument] retain];
//            
//            
//            //isDICOM = YES;
//        }else
//        {
//            NSLog(@"El archivo no es un archivo DICOM.");
//        }
    }
    
    return  self;
}

-(void)dealloc
{
    [dicomFilePaths release];
    
    [positions release];
    [_viewer release];
    [_dcmView release];
    
    if (_browserController) {
        [_browserController release];
    }
    
    if (_database) {
        [_database release];
    }
    
    //[imagePath release];
    
    //[dcm release];
    //[xml release];
    
    //[_viewer release];
    
    [super dealloc];
}

#pragma mark Core

- (NSMutableArray*)extractZPatientPosition
{
    NSMutableArray *zPositions = [[NSMutableArray alloc] init];
    
    NSLog(@"POSICIONES ORIGINALES: ");
    
    for (NSString *path in dicomFilePaths)
    {
        //Dicom object of the image in the viewer
        NSDate *start = [NSDate date];
        DCMObjectDBImport *dcm = [[DCMObject objectWithContentsOfFile:path decodingPixelData:NO] retain];
        NSDate *end = [NSDate date];
        NSTimeInterval interval = [end timeIntervalSinceDate:start];
        NSLog(@"Time for creating the DCMObject = %f seconds", interval);
        
        int fileSize = [[[[NSFileManager defaultManager] attributesOfItemAtPath: path error: nil] valueForKey: NSFileSize] longLongValue] / 1024L;
        NSLog(@"The dicom file is : %d kbytes", fileSize);
        
        //Attributes list from the dicom object
        NSMutableDictionary *attributes = [dcm attributes];
        
        //Get the attribute that we want
        DCMAttribute *attribute = [attributes objectForKey:@"0020,0032"];
        
        if (attribute)
        {
            //Get the values from the attribute
            NSMutableArray *values = [attribute values];
            
            //Add the (x,y,z) slice position to the global array that stores all the positions.
            [positions addObject:values];
            
            //Get z position
            double z = [[values objectAtIndex:2] doubleValue];
            
            NSLog(@"Position %f", z);
            
            //Add to the array
            [zPositions addObject:[NSNumber numberWithDouble:z]];
        }else
        {
            NSLog(@"Attribure (0020,0032) no encontrado");
        }
        
        [start release];
        [end release];
        
        //[dcm release];
    }
    
    return zPositions;
    
}

- (void)modifyDicomsWithNewPositions: (NSMutableArray*) zPositions
{
    //Params to modify the dicom files
    //NSMutableArray	*params = [NSMutableArray arrayWithObjects:@"dcmodify", @"--verbose", @"--ignore-errors", @"-i", @"(0020,0032)=0.000000\0.000000\53.000000",nil];
    
    for (int x=0; x < [dicomFilePaths count]; x++)
    {
        //Path of the image dicom file
        NSString *filePath = [dicomFilePaths objectAtIndex:x];
        
        //Array with the necessary parameters for modifyDicom
        NSMutableArray	*params = [NSMutableArray arrayWithObjects:@"dcmodify", @"--verbose", @"--ignore-errors", nil];
        
        NSArray *values = [NSArray arrayWithArray:[positions objectAtIndex:x]];
        
        NSString *stringTagValues = [NSString stringWithFormat: @"(0020,0032)=%f\\%f\\%f", [[values objectAtIndex:0] doubleValue], [[values objectAtIndex:1] doubleValue], [[zPositions objectAtIndex:x] doubleValue]];
        
        //Adding the specific values for the current slice
        //[params addObjectsFromArray: [NSArray arrayWithObjects: @"-i", [NSString stringWithFormat: @"(0020,0032)=0.000000\\0.000000\\53.000000"], nil]];
        [params addObjectsFromArray: [NSArray arrayWithObjects: @"-i", stringTagValues, nil]];
        
        //Array with the parameters and the list of file paths
        [params addObjectsFromArray:[NSArray arrayWithObject:filePath]];
        
        @try
        {
            //Get the encoding of the file
            NSStringEncoding encoding = [NSString encodingForDICOMCharacterSet: [[DicomFile getEncodingArrayForFile: filePath] objectAtIndex: 0]];
            
            //Telling the controller to modify all the dicoms with the parameters indicated.
            [XMLController modifyDicom: params encoding: encoding];
            
            //for( id loopItem in dicomFilePaths)
            [[NSFileManager defaultManager] removeFileAtPath:[filePath stringByAppendingString:@".bak"] handler:nil];
        }
        @catch (NSException * e)
        {
            NSLog(@"xml setObject: %@", e);
        }
        
        //[paramsAndPaths release];
        [params release];
        [values release];
        [stringTagValues release];
    }
    
    
        
}

-(void)fromMultiFrameToSingleFrame
{
    NSLog(@"fromMultiframeToSingleFrame: start");
    
    NSLog( @"export start");
    
    NSMutableArray *producedFiles = [NSMutableArray array];
    
    
    Wait *splash = [[Wait alloc] initWithString:NSLocalizedString(@"Creating a DICOM series", nil)];
    [splash showWindow:self];
    [[splash progress] setMaxValue: [dicomFilePaths count]];
    [splash setCancel: YES];
    
    int curImage = [_dcmView curImage];
    
    //En este for es donde se crean las .dcm y se escriben en memoria
    for (int i = 0 ; i < [dicomFilePaths count]; i ++)
   {
       NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
//        
//        BOOL	export = YES;
//        
//        if( [[dcmSelection selectedCell] tag] == 2)	// Only key images
//        {
//            NSManagedObject	*image;
//            
//            if( [imageView flippedData]) image = [[self fileList] objectAtIndex: (long)[[self fileList] count] -1 -i];
//            else image = [[self fileList] objectAtIndex: i];
//            
//            export = [[image valueForKey:@"isKeyImage"] boolValue];
//        }
//        
//        if( export)
//        {
//            if( [imageView flippedData]) [imageView setIndex: (long)[pixList[ curMovieIndex] count] -1 -i];
//            else [imageView setIndex:i];
//            
//            [imageView sendSyncMessage: 0];
//            [self adjustSlider];
       [_dcmView setIndex:i];
       
       [_dcmView sendSyncMessage: 0];
       [_viewer adjustSlider];

        
       NSDictionary* s = [_viewer exportDICOMFileInt:0 withName:@"Single frames serie" allViewers: NO];
       
       NSLog(@"Produced File");
    
        if( s)
        {
            [producedFiles addObject: s];
        }
       
       [splash incrementBy:1];

        [pool release];
       
       
    }
    
        
//        [splash incrementBy: 1];
//        
//        if( [splash aborted])
//            i = to;
    
    // Go back to initial frame
    [_dcmView setIndex: curImage];
    [_dcmView sendSyncMessage:0];
    [_viewer adjustSlider];
    
    [splash close];
    [splash autorelease];
    
    NSLog( @"export end");
    
    
    
    //Storing files in the database
    if( [producedFiles count])
    {
        NSLog(@"Writing images in database");
        
        _browserController = [[BrowserController currentBrowser] retain];
        _database = [[_browserController database] retain];
        
        NSArray *objects = [_database addFilesAtPaths: [producedFiles valueForKey: @"file"]
                                                                    postNotifications: YES
                                                                            dicomOnly: YES
                                                                  rereadExistingItems: YES
                                                                    generatedByOsiriX: YES];
        
        objects = [_database objectsWithIDs: objects];
        
//        if( [[NSUserDefaults standardUserDefaults] boolForKey: @"afterExportSendToDICOMNode"])
//            [_browserController selectServer: objects];
//        
//        if( [[NSUserDefaults standardUserDefaults] boolForKey: @"afterExportMarkThemAsKeyImages"])
//        {
//            for( DicomImage *im in objects)
//                [im setValue: [NSNumber numberWithBool: YES] forKey: @"isKeyImage"];
//        }
    }
    
    NSLog(@"fromMultiframeToSingleFrame: end");
}

@end
