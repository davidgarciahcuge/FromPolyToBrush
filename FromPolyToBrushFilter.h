//
//  FromPolyToBrushFilter.h
//  FromPolyToBrush
//
//  Copyright (c) 2013 David. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OsiriXAPI/PluginFilter.h>
//#import <OsiriXAPI/PluginFilter.h>

//#import "FPTBWindowController.h"

@interface FromPolyToBrushFilter : PluginFilter {
    
    //FPTBWindowController *fptbWindowController;

}

- (long) filterImage:(NSString*) menuName;

@end
