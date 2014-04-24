//
//  FPTBXmlController.h
//  FromPolyToBrush
//
//  Created by David García Juan on 10/04/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "OsiriXAPI/DCMObjectDBImport.h"
//#import "OsiriXAPI/ViewerController.h"

@interface FPTBXmlController : NSObject
{
    //NSManagedObject *imObj;
    //Paths of all the images in the serie in the viewer
    NSMutableArray *dicomFilePaths;
    
    //Path to the current image in the viewer
    NSString *imagePath;
    
    NSXMLDocument *xml;
    DCMObjectDBImport *dcm;
    
    //ViewerController *_viewer;
}
- (id) initWithImages:(NSArray*) images withIndex: (short) index;

- (void)modifyDicom;

@end
