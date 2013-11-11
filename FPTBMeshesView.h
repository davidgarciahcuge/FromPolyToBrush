//
//  FPTBMeshesView.h
//  FromPolyToBrush
//
//  Created by David García Juan on 29/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "OsiriXAPI/VTKView.h"

//VTK imports
#import "vtkPolyData.h"
#import "vtkRenderer.h"
#import "vtkCocoaRenderWindow.h"
#import "vtkCocoaRenderWindowInteractor.h"

@interface FPTBMeshesView : VTKView
{

    vtkPolyData *_mesh;
    vtkRenderer *_fptbRenderer;
    vtkCocoaRenderWindow *_fptbRenderCocoaRenderWindow;
    vtkCocoaRenderWindowInteractor *_fptbCocoaRenderWindowInteractor;
    
}

- (void)showMesh:(vtkPolyData*) mesh;

@end
