//
//  FPTBROIVolumeView.m
//  FromPolyToBrush
//
//  Created by David García Juan on 21/01/14.
//
// Cambio chorra para forzar a que master acepte el merge

#import "FPTBROIVolumeView.h"

#import <OsiriXAPI/N2Debug.h>

#define id Id
//#import "vtkVersion.h"
//#import "vtkSmartPointer.h"
//#import "vtkCellArray.h"
//#import "vtkCellData.h"
//#import "vtkDoubleArray.h"
//#import "vtkPoints.h"
//#import "vtkPolyLine.h"
//#import "vtkPolyData.h"
//#import "vtkPolyDataMapper.h"
//#import "vtkActor.h"
//#import "vtkRenderWindow.h"
//#import "vtkRenderWindowInteractor.h"
//#import "vtkPolyDataNormals.h"
//#import "vtkDataSet.h"
//#import "vtkSphereSource.h"
//#import "vtkContourFilter.h"
//#import "vtkSurfaceReconstructionFilter.h"
//#import "vtkXMLPolyDataWriter.h"
//#import "vtkDataSet.h"
//#import "vtkDelaunay3D.h"
//#import "vtkSphereSource.h"
//#import "vtkGlyph3D.h"
//#import "vtkAnnotatedCubeActor.h"
//#import "vtkRenderer.h"
//#import "vtkActor.h"

#import <OsirixAPI/vtkSmartPointer.h>
#import <OsiriXAPI/vtkActor.h>
#import <OsiriXAPI/vtkPowerCrustSurfaceReconstruction.h>
#undef id


//vtkSmartPointer<vtkActor> pointsActor;
//vtkSmartPointer<vtkActor> surfaceActor;

@implementation FPTBROIVolumeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        //aRenderer = [self renderer];
        NSLog(@"FPTBROIVolumeView inicializado correctamente");
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

-(void)dealloc
{
    NSLog(@"FPTBROIVolumeView: dealloc: start");
    
    //[_points3D release];
    
    [super dealloc];
}

#pragma mark Functionality Methods

-(short)setPixSource:(NSMutableArray*)pts
{
	GLint swap = 1;  // LIMIT SPEED TO VBL if swap == 1
	[self getVTKRenderWindow]->MakeCurrent();
	[[NSOpenGLContext currentContext] setValues:&swap forParameter:NSOpenGLCPSwapInterval];
    
	[_points3D release];
	_points3D = [pts copy];
    
    return 1;
    
    //return [super renderVolume];
    
}

//-(void)reseCamera
//{
//    
//    aCamera = aRenderer->GetActiveCamera();
//	float distance = aCamera->GetDistance();
//	float pp = aCamera->GetParallelScale();
//    
//	aCamera->SetFocalPoint (0, 0, 0);
//	aCamera->SetPosition (0, -1, 0);
//	aCamera->ComputeViewPlaneNormal();
//	aCamera->SetViewUp(0, 0, 1);
//	aCamera->OrthogonalizeViewUp();
//	aRenderer->ResetCamera();
//    
//	// Apply the same zoom
//	
//	double vn[ 3], center[ 3];
//	aCamera->GetFocalPoint(center);
//	aCamera->GetViewPlaneNormal(vn);
//	aCamera->SetPosition(center[0]+distance*vn[0], center[1]+distance*vn[1], center[2]+distance*vn[2]);
//	aCamera->SetParallelScale( pp);
//	aRenderer->ResetCameraClippingRange();
//	
//	[self setNeedsDisplay:YES];
//    
//}


-(void)renderVolumeWitDelaunay: (BOOL)delaunay withPowerCrust: (BOOL)powerCrust showPoints: (BOOL)points showSurface: (BOOL)surface
{
//    BOOL useDelaunay = delaunay;
//    BOOL usePowerCrust = powerCrust;
//    BOOL showPoints = points;
//    BOOL showSurface = surface;
    
    BOOL useDelaunay = TRUE;
    BOOL usePowerCrust = FALSE;
    BOOL showPoints = FALSE;
    BOOL showSurface = TRUE;
    
    WaitRendering *splash = [[WaitRendering alloc] init: NSLocalizedString( @"Rendering 3D Object...", nil)];
	[splash showWindow:self];
	
    @try /*DAVID*//*Copiar esta cadena de trys cuando trabajo con código para VTK*/
    {
        try
        {
            //**DAVID**//
            //aRenderer = [self renderer];
            
            if (surfaceActor)
            {
                _renderer->RemoveActor(surfaceActor);
            }
            
            if (ballsActor)
            {
                _renderer->RemoveActor(ballsActor);
            }
            
            vtkSmartPointer<vtkPoints> points = vtkSmartPointer<vtkPoints>::New();
            
            NSArray *pts = _points3D;
            
            for(int i = 0; i < [pts count]; i++)
            {
                NSArray	*pt3D = [pts objectAtIndex: i];
            	points->InsertPoint( i, [[pt3D objectAtIndex: 0] floatValue], [[pt3D objectAtIndex: 1] floatValue], [[pt3D objectAtIndex: 2] floatValue]);
                            }
            
            vtkSmartPointer<vtkPolyData> profile = vtkSmartPointer<vtkPolyData>::New();
            profile -> SetPoints(points);
            //profile -> Update();
            
            //**DAVID**//
            //Ejemplo de como se crea una línea uniendo puntos, útil para la interpolación.
//            vtkSmartPointer<vtkPolyLine> polyLine =
//            vtkSmartPointer<vtkPolyLine>::New();
//            polyLine->GetPointIds()->SetNumberOfIds(points->GetNumberOfPoints());
//            
////            for(unsigned int i = 0; i < 5; i++)
////            {
////                polyLine->GetPointIds()->SetId(i,i);
////            }
//            
//            //**DAVID**//
//            for(unsigned int i = 0; i < points->GetNumberOfPoints(); i++)
//            {
//                polyLine->GetPointIds()->SetId(i,i);
//            }
//            //**DAVID**//
//            
//            // Create a cell array to store the lines in and add the lines to it
//            vtkSmartPointer<vtkCellArray> cells =
//            vtkSmartPointer<vtkCellArray>::New();
//            cells->InsertNextCell(polyLine);
//            
  
            //**DAVID**//
            
            vtkSmartPointer<vtkDataSet> output = NULL;
            
            //Creamos surface con PowerCrustSurfaceReconstruction
            if (usePowerCrust == TRUE)
            {
                vtkSmartPointer<vtkPowerCrustSurfaceReconstruction> power = vtkSmartPointer<vtkPowerCrustSurfaceReconstruction>::New();
            
#if VTK_MAJOR_VERSION <= 5
            power->SetInput(profile);
#else
            power->SetInputData(profile);
#endif
            
                vtkSmartPointer<vtkPolyDataNormals> polyDataNormals = vtkSmartPointer<vtkPolyDataNormals>::New();
                polyDataNormals->ConsistencyOn();
                polyDataNormals->AutoOrientNormalsOn();
                polyDataNormals->SetInput(power->GetOutput());
                //polyDataNormals->Update();
            
                output = (vtkDataSet*) polyDataNormals -> GetOutput();
            }else if (useDelaunay == true)
            {
            
            //Creamos surface con Delaunay
                vtkSmartPointer<vtkDelaunay3D> delaunayTriangulator = vtkSmartPointer<vtkDelaunay3D>::New();
                delaunayTriangulator->SetInput( profile);
            
                delaunayTriangulator->SetTolerance( 0.001);
                delaunayTriangulator->SetAlpha( 20);
                delaunayTriangulator->BoundingTriangulationOff();
            
                output = (vtkDataSet*) delaunayTriangulator -> GetOutput();
            }
            //****//
            
            //**DAVID**//
            
            vtkSmartPointer<vtkTextureMapToSphere> tmapper = vtkSmartPointer<vtkTextureMapToSphere>::New(); //Spheric coordinates??
            tmapper -> SetInput( output);
            tmapper -> PreventSeamOn();
            
            vtkSmartPointer<vtkTransformTextureCoords> xform = vtkSmartPointer<vtkTransformTextureCoords>::New(); //Why to scale??
            xform->SetInput(tmapper->GetOutput());
            xform->SetScale(4,4,4);
            
            vtkSmartPointer<vtkDataSetMapper> map = vtkSmartPointer<vtkDataSetMapper>::New();
			map->SetInput( tmapper->GetOutput());
            //map->ScalarVisibilityOff();
            map->Update();
            
//            // The balls
			
			vtkSmartPointer<vtkSphereSource> ball = vtkSmartPointer<vtkSphereSource>::New();
            ball->SetRadius(0.3);
            ball->SetThetaResolution( 12);
            ball->SetPhiResolution( 12);
			
			vtkSmartPointer<vtkGlyph3D> balls = vtkSmartPointer<vtkGlyph3D>::New();
            balls->SetInput( profile);
            balls->SetSource( ball->GetOutput());
			//ball->Delete();
			
			vtkSmartPointer<vtkPolyDataMapper> mapBalls = vtkPolyDataMapper::New();
            mapBalls->SetInput( balls->GetOutput());
            
//            vtkSmartPointer<vtkActor> myballActor;
//			
//			if(!myballActor) {
//				myballActor = vtkSmartPointer<vtkActor>::New();
//				myballActor->GetProperty()->SetSpecular( 0.5);
//				myballActor->GetProperty()->SetSpecularPower( 20);
//				myballActor->GetProperty()->SetAmbient( 0.2);
//				myballActor->GetProperty()->SetDiffuse( 0.8);
//				myballActor->GetProperty()->SetOpacity( 0.8);
//			}
//            
//			myballActor->SetMapper(mapBalls);
            
            if (!ballsActor) {
                ballsActor = vtkSmartPointer<vtkActor>::New();
                ballsActor->GetProperty()->SetSpecular( 0.5);
                ballsActor->GetProperty()->SetSpecularPower( 20);
                ballsActor->GetProperty()->SetAmbient( 0.2);
                ballsActor->GetProperty()->SetDiffuse( 0.8);
                ballsActor->GetProperty()->SetOpacity( 0.8);
            }
//
////			mapBalls->Delete();
////			
////			profile->Delete();
////			xform->Delete();
            
            ballsActor->SetMapper(mapBalls);
//
            if (showPoints)
            {
                _renderer->AddActor(ballsActor);
            }
            //vtkSmartPointer<vtkActor> actor = vtkSmartPointer<vtkActor>::New();
            //if (!surfaceActor) {
                surfaceActor = vtkSmartPointer<vtkActor>::New();
                surfaceActor->SetMapper(map);
            //}
            
            //actor -> SetMapper(map);
            //**DAVID**//
            
          
            //**DAVID**//
            //Uso mi ventana a ver si funciona
            //surfaceActor->GetProperty()->FrontfaceCullingOn();
            //surfaceActor->GetProperty()->BackfaceCullingOn();
            
            if (showSurface)
            {
                _renderer->AddActor(surfaceActor);
            }
                
            vtkSmartPointer<vtkAnnotatedCubeActor> cube = vtkSmartPointer<vtkAnnotatedCubeActor>::New();
            
            cube->SetXPlusFaceText ( [NSLocalizedString( @"L", @"L: Left") UTF8String] );
            cube->SetXMinusFaceText( [NSLocalizedString( @"R", @"R: Right") UTF8String] );
            cube->SetYPlusFaceText ( [NSLocalizedString( @"P", @"P: Posterior") UTF8String] );
            cube->SetYMinusFaceText( [NSLocalizedString( @"A", @"A: Anterior") UTF8String] );
            cube->SetZPlusFaceText ( [NSLocalizedString( @"S", @"S: Superior") UTF8String] );
            cube->SetZMinusFaceText( [NSLocalizedString( @"I", @"I: Inferior") UTF8String] );
            cube->SetFaceTextScale( 0.67 );
            
            vtkSmartPointer<vtkProperty> property = cube->GetXPlusFaceProperty();
            property->SetColor(0, 0, 1);
            property = cube->GetXMinusFaceProperty();
            property->SetColor(0, 0, 1);
            property = cube->GetYPlusFaceProperty();
            property->SetColor(0, 1, 0);
            property = cube->GetYMinusFaceProperty();
            property->SetColor(0, 1, 0);
            property = cube->GetZPlusFaceProperty();
            property->SetColor(1, 0, 0);
            property = cube->GetZMinusFaceProperty();
            property->SetColor(1, 0, 0);
            
            cube->SetTextEdgesVisibility( 1);
            cube->SetCubeVisibility( 1);
            cube->SetFaceTextVisibility( 1);
            
            if (!orientationWidget) {
                orientationWidget = vtkOrientationMarkerWidget::New();
                orientationWidget->SetInteractor( [self getInteractor] );
                orientationWidget->SetViewport( 0.90, 0.90, 1, 1);
            }
            orientationWidget->SetOrientationMarker( cube );
            orientationWidget->SetEnabled( 1 );
            orientationWidget->InteractiveOff();
            //cube->Delete();
            
            orientationWidget->On();
            
//            aCamera = aRenderer->GetActiveCamera();
//			aCamera->Zoom(1.5);
//			aCamera->SetFocalPoint (0, 0, 0);
//			aCamera->SetPosition (0, 0, -1);
//			aCamera->ComputeViewPlaneNormal();
//			aCamera->SetViewUp(0, -1, 0);
//			aCamera->OrthogonalizeViewUp();
//			aCamera->SetParallelProjection( false);
//			aCamera->SetViewAngle( 60);
//			aRenderer->ResetCamera();
            
            //[self reseCamera];
            //[self setNeedsDisplay:TRUE];
            [self showPoints:showPoints showSurface:showSurface];
            //[self coView:self];
            //**DAVID**//
            
            //////////////**********************//////////////////////////
		}
        catch(...)
        {
            printf( "***** C++ exception in %s\r", __PRETTY_FUNCTION__);
            
//            if( [[NSUserDefaults standardUserDefaults] boolForKey:@"UseDelaunayFor3DRoi"] == NO)
//            {
//                [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"UseDelaunayFor3DRoi"];
//                [self renderVolume];
//                [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"UseDelaunayFor3DRoi"];
//            }
        }
    }
    @catch (NSException * e)
    {
        N2LogExceptionWithStackTrace(e);
        
//        if( [[NSUserDefaults standardUserDefaults] boolForKey:@"UseDelaunayFor3DRoi"] == NO)
//        {
//            [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"UseDelaunayFor3DRoi"];
//            [self renderVolume];
//            [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"UseDelaunayFor3DRoi"];
//        }
    }
    
	[splash close];
	[splash autorelease];
    
	//return error;
    
}

-(void)showPoints: (BOOL)points showSurface: (BOOL)surface
{
    //vtkRenderer *aRenderer = [self renderer];
    //_renderer -> GetActiveCamera();
    
    if( ballActor && roiVolumeActor)
	{
        //Doy por echo que los dos actores están añadidos al Renderer
		if( points == NO)
        {
            _renderer->RemoveActor( ballActor);
        }
		else
        {
            _renderer->AddActor( ballActor);
        }
		
		if( surface == NO)
        {
           _renderer->RemoveActor( roiVolumeActor);
        }
		else
        {
           _renderer->AddActor( roiVolumeActor);
        }
		
    }
	
	//[self setNeedsDisplay: YES];
    [self coView:self];
    
}

-(void) coView:(id) sender
{
//	aCamera = aRenderer->GetActiveCamera();
//	float distance = aCamera->GetDistance();
//	float pp = aCamera->GetParallelScale();
//    
//	aCamera->SetFocalPoint (0, 0, 0);
//	aCamera->SetPosition (0, -1, 0);
//	aCamera->ComputeViewPlaneNormal();
//	aCamera->SetViewUp(0, 0, 1);
//	aCamera->OrthogonalizeViewUp();
//	aRenderer->ResetCamera();
//    
//	// Apply the same zoom
//	
//	double vn[ 3], center[ 3];
//	aCamera->GetFocalPoint(center);
//	aCamera->GetViewPlaneNormal(vn);
//	aCamera->SetPosition(center[0]+distance*vn[0], center[1]+distance*vn[1], center[2]+distance*vn[2]);
//	aCamera->SetParallelScale( pp);
//	aRenderer->ResetCameraClippingRange();
    
    
    
    //aCamera = aRenderer->GetActiveCamera();
    
    //aCamera->Zoom(1.5);
    //aCamera->SetFocalPoint (0, 0, 0);
    //aCamera->SetPosition (0, 0, -1);
    //aCamera->ComputeViewPlaneNormal();
    //aCamera->SetViewUp(0, -1, 0);
    //aCamera->OrthogonalizeViewUp();
    //aCamera->SetParallelProjection( false);
    //aCamera->SetViewAngle( 60);
    _renderer->ResetCamera();
    //_interactor->Start();
    
    _renderer->Render();
    
    [self setNeedsDisplay:YES];
	
    
	
}

@end
