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


@implementation FPTBXmlController

- (id) initWithImages:(NSArray*) images withIndex: (short) index;
{
    self = [super init];
    
    if (self) {
        
        //Complete list of paths to the file that corresponds to the images in the viewer.
        dicomFilePaths = [NSMutableArray arrayWithArray: [images valueForKey:@"completePath"]];
        imagePath = [dicomFilePaths objectAtIndex:index];
        
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
    //[imagePath release];
    
    //[dcm release];
    //[xml release];
    
    //[_viewer release];
    
    [super dealloc];
}

#pragma mark Core

- (void)modifyDicom
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
