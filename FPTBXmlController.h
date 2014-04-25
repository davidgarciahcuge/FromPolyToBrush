//
//  FPTBXmlController.h
//  FromPolyToBrush
//
//  Created by David García Juan on 10/04/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//#import "OsiriXAPI/ViewerController.h"

@interface FPTBXmlController : NSObject
{
    //NSManagedObject *imObj;
    //Paths of all the images in the serie in the viewer
    NSMutableArray *dicomFilePaths;
    
    //Path to the current image in the viewer
    NSString *imagePath;
    
    //NSXMLDocument *xml;
    //DCMObjectDBImport *dcm;
    
    //ViewerController *_viewer;
}
- (id) initWithImages:(NSArray*) images withIndex: (short) index;

//Extract the z patient position of each slice
- (NSMutableArray*)extractZPatientPosition;

//We update the Dicom Files with the new z patient positions computed
- (void)modifyDicomsWithNewPositions: (NSMutableArray*) zPositions;

@end
