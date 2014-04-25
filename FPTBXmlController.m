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
#import "OsiriX/DCMAttribute.h"

NSMutableArray *positions;

@implementation FPTBXmlController

- (id) initWithImages:(NSArray*) images withIndex: (short) index;
{
    self = [super init];
    
    if (self) {
        
        //Complete list of paths to the file that corresponds to the images in the viewer.
        dicomFilePaths = [NSMutableArray arrayWithArray: [images valueForKey:@"completePath"]];
        imagePath = [dicomFilePaths objectAtIndex:index];
        
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
        DCMObjectDBImport *dcm = [[DCMObject objectWithContentsOfFile:path decodingPixelData:NO] retain];
        
        //Attributes list from the dicom object
        NSMutableDictionary *attributes = [dcm attributes];
        
        //Get the attribute that we want
        DCMAttribute *attribute = [attributes objectForKey:@"0020,0032"];
        
        //Get the values from the attribute
        NSMutableArray *values = [attribute values];
        
        //Add the (x,y,z) slice position to the global array that stores all the positions.
        [positions addObject:values];
        
        //Get z position
        double z = [[values objectAtIndex:2] doubleValue];
       
        NSLog(@"Position %f", z);
        
        //Add to the array
        [zPositions addObject:[NSNumber numberWithDouble:z]];
        
        [dcm release];
    }
    
    return zPositions;
    
}

- (void)modifyDicomsWithNewPositions: (NSMutableArray*) zPositions
{
    //Params to modify the dicom files
    //NSMutableArray	*params = [NSMutableArray arrayWithObjects:@"dcmodify", @"--verbose", @"--ignore-errors", @"-i", @"(0020,0032)=0.000000\0.000000\53.000000",nil];
    
    NSMutableArray	*params = [NSMutableArray arrayWithObjects:@"dcmodify", @"--verbose", @"--ignore-errors", nil];
    
    [params addObjectsFromArray: [NSArray arrayWithObjects: @"-i", [NSString stringWithFormat: @"(0020,0032)=0.000000\\0.000000\\53.000000"], nil]];
    
    //Array with the parameters and the list of file paths
    [params addObjectsFromArray:dicomFilePaths];
    
    @try
    {
        //Get the encoding of the file
        NSStringEncoding encoding = [NSString encodingForDICOMCharacterSet: [[DicomFile getEncodingArrayForFile: imagePath] objectAtIndex: 0]];
        
        //Telling the controller to modify all the dicoms with the parameters indicated.
        [XMLController modifyDicom: params encoding: encoding];
        
        for( id loopItem in dicomFilePaths)
            [[NSFileManager defaultManager] removeFileAtPath:[loopItem stringByAppendingString:@".bak"] handler:nil];
//
//        [self updateDB: files objects: objects];
    }
    @catch (NSException * e)
    {
        NSLog(@"xml setObject: %@", e);
    }
    
    //[paramsAndPaths release];
    [params release];
        
}

@end
