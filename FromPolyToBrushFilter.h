//
//  FromPolyToBrushFilter.h
//  FromPolyToBrush
//
//  Copyright (c) 2013 David. All rights reserved.
//  23/10/2013

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>

#import "FPTBWindowController.h"

@interface FromPolyToBrushFilter : PluginFilter {
    
    FPTBWindowController *fptbWindowController;

}

- (long) filterImage:(NSString*) menuName;

@end
