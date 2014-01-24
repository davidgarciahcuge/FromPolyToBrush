//
//  FPTBROIVolumeView.m
//  FromPolyToBrush
//
//  Created by David García Juan on 21/01/14.
//
//

#import "FPTBROIVolumeView.h"
#import "OsiriXAPI/N2Debug.h"

#define id Id
#include "vtkCleanPolyData.h"
#include "vtkActorCollection.h"
#include "vtkPolyDataMapper.h"
#undef id

@implementation FPTBROIVolumeView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
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

-(void)setPointsSource:(NSMutableArray*)pts
{
    GLint swap = 1;  // LIMIT SPEED TO VBL if swap == 1
	[self getVTKRenderWindow]->MakeCurrent();
	[[NSOpenGLContext currentContext] setValues:&swap forParameter:NSOpenGLCPSwapInterval];
    
    [_points release];
    _points = [pts copy];
    
//    [_points3D release];
//    _points3D = [pts copy];
    
    //_points3D = pts;
    //[_points3D retain];
    
    //[self renderVolume];
    
}


//-(void) renderVolume
//{
//    
//    //WaitRendering *splash = [[WaitRendering alloc] init: NSLocalizedString( @"Rendering 3D Object...", nil)];
//	//[splash showWindow:self];
//    
//    @try /*DAVID*//*Copiar esta cadena de trys cuando trabajo con código para VTK*/
//    {
//        try
//        {
////			//long	i;
////			aRenderer = [self renderer];
////			
////			vtkPoints *vtkPoints = vtkPoints::New();
////			
////            
////            //NSArray *pts = _points3D;
////            
////            //Pasamos al formato correcto para vtkPoints
////			for(int i = 0; i < [/*pts*/ _points count]; i++)
////			{
////				NSArray	*pt3D = [/*pts*/ _points objectAtIndex: i];
////				vtkPoints->InsertPoint( i, [[pt3D objectAtIndex: 0] floatValue], [[pt3D objectAtIndex: 1] floatValue], [[pt3D objectAtIndex: 2] floatValue]);
////			}
////            
////            NSLog(@"Número de points 3D: %lli", vtkPoints->GetNumberOfPoints());
////			
////			vtkPolyData *profile = vtkPolyData::New();
////			profile->SetPoints(vtkPoints);
////			vtkPoints->Delete();
////            
////            //NSLog(@"Número de triángulos: %lli", profile->GetNumberOfLines());
////            
////			vtkDelaunay3D *delaunayTriangulator = nil;
////			vtkPolyDataNormals *polyDataNormals = nil;
////			vtkDecimatePro *isoDeci = nil;
////			vtkSmoothPolyDataFilter * pSmooth = nil;
////			vtkDataSet*	output = nil;
////            vtkCleanPolyData *cleaner = nil;
////			
////			if( [[NSUserDefaults standardUserDefaults] boolForKey:@"UseDelaunayFor3DRoi"])
////			{
////                //                cleaner = vtkCleanPolyData::New();
////                //                cleaner->SetInput( profile);
////                
////				delaunayTriangulator = vtkDelaunay3D::New();
////				delaunayTriangulator->SetInput( profile);
////				
////				delaunayTriangulator->SetTolerance( 0.001);
////				delaunayTriangulator->SetAlpha( 20);
////				delaunayTriangulator->BoundingTriangulationOff();
////				
////				output = (vtkDataSet*) delaunayTriangulator -> GetOutput();
////			}
////			else{
////			
////                //Genera la surface a partir de los puntos que le pasamos
////				vtkPowerCrustSurfaceReconstruction *power = vtkPowerCrustSurfaceReconstruction::New();
////				power->SetInput( profile);
////                //power->Update();
////                
////                //Para suavizar el renderizado (Probar con y sin a ver si vemos diferencias)
////				polyDataNormals = vtkPolyDataNormals::New();
////				polyDataNormals->ConsistencyOn();
////				polyDataNormals->AutoOrientNormalsOn();
////                polyDataNormals->SetInput(power->GetOutput());
////				
////				power->Delete();
////				
////				output = (vtkDataSet*) polyDataNormals -> GetOutput();
////                //output -> Update();
////			}
////			
////			// ****************** Mapper
////			vtkTextureMapToSphere *tmapper = vtkTextureMapToSphere::New(); //Spheric coordinates??
////            tmapper -> SetInput( output);
////            tmapper -> PreventSeamOn();
////			
////			if( polyDataNormals) polyDataNormals->Delete();
////			if( delaunayTriangulator) delaunayTriangulator->Delete();
////			if( isoDeci) isoDeci->Delete();
////			if( pSmooth) pSmooth->Delete();
////            if( cleaner) cleaner->Delete();
////            
////			vtkTransformTextureCoords *xform = vtkTransformTextureCoords::New(); //Why to scale??
////            xform->SetInput(tmapper->GetOutput());
////            xform->SetScale(4,4,4);
////			tmapper->Delete();
////            
////			vtkDataSetMapper *map = vtkDataSetMapper::New();
////			map->SetInput( tmapper->GetOutput());
////			map->ScalarVisibilityOff(); //Desactivamos los valores escalares de los puntos porque vamos a aplicar una textura desde una imagen .tiff.
////			//map->ScalarVisibilityOn();
////            
////			map->Update();
////            
////            //vtkPolyDataMapper *map = vtkPolyDataMapper::New();
////            //map->SetInput(output);
////            
////			if (!roiVolumeActor) {
////				roiVolumeActor = vtkActor::New();
////				roiVolumeActor->GetProperty()->FrontfaceCullingOn();
////				roiVolumeActor->GetProperty()->BackfaceCullingOn();
////			}
////            
////			roiVolumeActor->SetMapper(map);
////            
////            
////			map->Delete();
////			
////			// *****************Texture
////			NSString *location = [[NSUserDefaults standardUserDefaults] stringForKey:@"textureLocation"];
////			
////			if( location == nil || [location isEqualToString:@""])
////				location = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"texture.tif"];
////			
////			vtkTIFFReader *bmpread = vtkTIFFReader::New();
////			
////			bmpread->SetFileName( [location UTF8String]);
////            
////			if ( !texture)
////			{
////				texture = vtkTexture::New();
////				texture->InterpolateOn();
////			}
////			texture->SetInput( bmpread->GetOutput());
////            
////			bmpread->Delete();
////            
////			roiVolumeActor->SetTexture( texture); //Aplicas la textura al volumen generado
////            
////            // The balls
////			
////			vtkSphereSource *ball = vtkSphereSource::New();
////            ball->SetRadius(0.3);
////            ball->SetThetaResolution( 12);
////            ball->SetPhiResolution( 12);
////			
////			vtkGlyph3D *balls = vtkGlyph3D::New();
////            balls->SetInput( profile);
////            balls->SetSource( ball->GetOutput());
////			ball->Delete();
////			
////			vtkPolyDataMapper *mapBalls = vtkPolyDataMapper::New();
////            mapBalls->SetInput( balls->GetOutput());
////			balls->Delete();
////			
////			if(!ballActor) {
////				ballActor = vtkActor::New();
////				ballActor->GetProperty()->SetSpecular( 0.5);
////				ballActor->GetProperty()->SetSpecularPower( 20);
////				ballActor->GetProperty()->SetAmbient( 0.2);
////				ballActor->GetProperty()->SetDiffuse( 0.8);
////				ballActor->GetProperty()->SetOpacity( 0.8);
////			}
////            
////			ballActor->SetMapper( mapBalls);
////            
////			mapBalls->Delete();
////			
////			profile->Delete();
////			xform->Delete();
////			
////			aRenderer->AddActor( ballActor);
////			
////			roiVolumeActor->GetProperty()->FrontfaceCullingOn();
////			roiVolumeActor->GetProperty()->BackfaceCullingOn();
////			
////			aRenderer->AddActor( roiVolumeActor);
////            
////            //**DAVID**//
////            //vtkActorCollection *collection = aRenderer->GetActors();
////			//**//
////			// *********************** Orientation Cube
////			
////            //	if( [[NSUserDefaults standardUserDefaults] boolForKey: @"dontShow3DCubeOrientation"] == NO)
////			
////				vtkAnnotatedCubeActor* cube = vtkAnnotatedCubeActor::New();
////				cube->SetXPlusFaceText ( [NSLocalizedString( @"L", @"L: Left") UTF8String] );		
////				cube->SetXMinusFaceText( [NSLocalizedString( @"R", @"R: Right") UTF8String] );
////				cube->SetYPlusFaceText ( [NSLocalizedString( @"P", @"P: Posterior") UTF8String] );
////				cube->SetYMinusFaceText( [NSLocalizedString( @"A", @"A: Anterior") UTF8String] );
////				cube->SetZPlusFaceText ( [NSLocalizedString( @"S", @"S: Superior") UTF8String] );
////				cube->SetZMinusFaceText( [NSLocalizedString( @"I", @"I: Inferior") UTF8String] );
////				cube->SetFaceTextScale( 0.67 );
////                
////				vtkProperty* property = cube->GetXPlusFaceProperty();
////				property->SetColor(0, 0, 1);
////				property = cube->GetXMinusFaceProperty();
////				property->SetColor(0, 0, 1);
////				property = cube->GetYPlusFaceProperty();
////				property->SetColor(0, 1, 0);
////				property = cube->GetYMinusFaceProperty();
////				property->SetColor(0, 1, 0);
////				property = cube->GetZPlusFaceProperty();
////				property->SetColor(1, 0, 0);
////				property = cube->GetZMinusFaceProperty();
////				property->SetColor(1, 0, 0);
////                
////				cube->SetTextEdgesVisibility( 1);
////				cube->SetCubeVisibility( 1);
////				cube->SetFaceTextVisibility( 1);
////                
////				if (!orientationWidget) {
////					orientationWidget = vtkOrientationMarkerWidget::New();	
////					orientationWidget->SetInteractor( [self getInteractor] );
////					orientationWidget->SetViewport( 0.90, 0.90, 1, 1);
////				}
////				orientationWidget->SetOrientationMarker( cube );
////				orientationWidget->SetEnabled( 1 );
////				orientationWidget->InteractiveOff();
////				cube->Delete();
////				
////				orientationWidget->On();
////			
////			
////			// *********************** Camera
////			
////			aCamera = aRenderer->GetActiveCamera();
////			aCamera->Zoom(1.5);
////			aCamera->SetFocalPoint (0, 0, 0);
////			aCamera->SetPosition (0, 0, -1);
////			aCamera->ComputeViewPlaneNormal();
////			aCamera->SetViewUp(0, -1, 0);
////			aCamera->OrthogonalizeViewUp();
////			aCamera->SetParallelProjection( false);
////			aCamera->SetViewAngle( 60);
////			aRenderer->ResetCamera();		
////            
////			
////			//[self coView: self];
////            aCamera = aRenderer->GetActiveCamera();
////            float distance = aCamera->GetDistance();
////            float pp = aCamera->GetParallelScale();
////            
////            aCamera->SetFocalPoint (0, 0, 0);
////            aCamera->SetPosition (0, -1, 0);
////            aCamera->ComputeViewPlaneNormal();
////            aCamera->SetViewUp(0, 0, 1);
////            aCamera->OrthogonalizeViewUp();
////            aRenderer->ResetCamera();
////            
////            // Apply the same zoom
////            
////            double vn[ 3], center[ 3];
////            aCamera->GetFocalPoint(center);
////            aCamera->GetViewPlaneNormal(vn);
////            aCamera->SetPosition(center[0]+distance*vn[0], center[1]+distance*vn[1], center[2]+distance*vn[2]);
////            aCamera->SetParallelScale( pp);
////            aRenderer->ResetCameraClippingRange();
////            
////            [self setNeedsDisplay: YES];
//            
//            //**DAVID**//
//            //More simple for creating poly data and showing them
//            
//            aRenderer = [self renderer];
//            
//            vtkPoints *vtkPoints = vtkPoints::New();
//            
//            for(int i = 0; i < [/*pts*/ _points count]; i++)
//            {
//            	NSArray	*pt3D = [/*pts*/ _points objectAtIndex: i];
//            	vtkPoints->InsertPoint( i, [[pt3D objectAtIndex: 0] floatValue], [[pt3D objectAtIndex: 1] floatValue], [[pt3D objectAtIndex: 2] floatValue]);
//            }
//            
//            vtkPolyData *polydata = vtkPolyData::New();
//            polydata->SetPoints(vtkPoints);
//            
//            vtkPolyDataMapper *mapper = vtkPolyDataMapper::New();
//            mapper->SetInput(polydata);
//            
//            vtkActor *actor = vtkActor::New();
//            actor->SetMapper(mapper);
//            
//            aRenderer->AddActor(actor);
//            
//            [self setNeedsDisplay:TRUE];
//            
//            //_cocoaRenderWindow = [self cocoaWindow];
//            
//            //_cocoaRenderWindow->Render();
//            
//            //vtkCocoaRenderWindowInteractor *interactor = _cocoaRenderWindow->GetInteractor();
//            
//		}
//        catch(...)
//        {
//            printf( "***** C++ exception in %s\r", __PRETTY_FUNCTION__);
//            
//            if( [[NSUserDefaults standardUserDefaults] boolForKey:@"UseDelaunayFor3DRoi"] == NO)
//            {
//                [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"UseDelaunayFor3DRoi"];
//                [self renderVolume];
//                [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"UseDelaunayFor3DRoi"];
//            }
//        }
//    }
//    @catch (NSException * e)
//    {
//        N2LogExceptionWithStackTrace(e);
//        
//        if( [[NSUserDefaults standardUserDefaults] boolForKey:@"UseDelaunayFor3DRoi"] == NO)
//        {
//            [[NSUserDefaults standardUserDefaults] setBool: YES forKey:@"UseDelaunayFor3DRoi"];
//            [self renderVolume];
//            [[NSUserDefaults standardUserDefaults] setBool: NO forKey:@"UseDelaunayFor3DRoi"];
//        }
//    }
//    
//	//[splash close];
//	//[splash autorelease];
//    
//}
@end
