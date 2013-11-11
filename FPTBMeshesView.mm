//
//  FPTBMeshesView.m
//  FromPolyToBrush
//
//  Created by David García Juan on 29/10/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "FPTBMeshesView.h"

//VTK imports
#define id Id
#import "vtkPolyDataMapper.h"
#import "vtkActor.h"
#import "vtkDebugLeaks.h"
#undef id

@implementation FPTBMeshesView

-(id) initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        _fptbRenderer = [self renderer];
        _fptbRenderCocoaRenderWindow = [self getVTKRenderWindow];
        _fptbCocoaRenderWindowInteractor = [self getInteractor];
        
        _mesh = NULL;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name: NSWindowWillCloseNotification object: nil];        
    }
    
    return self;
    
}


-(void)dealloc
{
    NSLog(@"fptbMeshesView:dealloc:begin");
    
    //NSLog(@"_mesh reference count: %i", _mesh -> GetReferenceCount());

    [super dealloc];
    
    NSLog(@"fptbMeshesView:dealloc:close");

    
}

- (void)windowWillClose:(NSNotification *)notification
{
    NSLog(@"fptbMeshesView:windowWillClose:begin");
    
	if( [notification object] == [self window])
	{
        NSLog(@"It is plugin's window!!");
        
		[[self window] setAcceptsMouseMovedEvents: NO];
		
        [[NSNotificationCenter defaultCenter] removeObserver: self];
        
        [self prepareForRelease];
        
	}
    
    NSLog(@"fptbMeshesView:windowWillClose:close");

}

#pragma mark-

- (void)showMesh:(vtkPolyData*) mesh
{
    
    _mesh = mesh;
    
    vtkPolyDataMapper *fptbMapper = vtkPolyDataMapper::New();
    fptbMapper -> SetInput(_mesh);
    _mesh -> Delete();
        
    vtkActor *fptbActor = vtkActor::New();

    fptbActor -> SetMapper(fptbMapper);
    fptbMapper -> Delete();
    
    _fptbRenderer -> AddActor(fptbActor);
    _fptbRenderer -> ResetCamera();
    fptbActor -> Delete();
    
    [self setNeedsDisplay:TRUE];
    

   
}




@end
