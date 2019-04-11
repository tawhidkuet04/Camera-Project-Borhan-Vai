//
//  ViewController.m
//  CameraProject
//
//  Created by Sk Borhan Uddin on 9/4/19.
//  Copyright © 2019 BrainCraft LTD. All rights reserved.
//

#import "ViewController.h"
#import "imageShowViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
@interface ViewController ()<AVCapturePhotoCaptureDelegate,AVCaptureFileOutputRecordingDelegate>{
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput* videoDeviceInput;
    AVCaptureVideoDataOutput* videoDataOutput;
    AVCapturePhotoOutput *Output ;
    AVCaptureMovieFileOutput *MovieFileOutput;
    BOOL isRecording;
}
@property (weak, nonatomic) IBOutlet UIView *cameraView;
@property (weak, nonatomic) IBOutlet UIButton *swipeCamera;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (nonatomic) AVCaptureDeviceDiscoverySession* videoDeviceDiscoverySession;
@end

@implementation ViewController

/*!
 This method is use to control ViewController based device rotation.
@return:
 NO determines rotation'll not happened for this ViewController.
 */


- (void)viewDidLoad {
    [super viewDidLoad];
    // initially camera selected which value is 2
    
    cameraOrVideoSelection = 2 ;
    // you can't put it in the front using:
    //    [delegate.window insertSubview:nonRotatingView aboveSubview:self.view];
    // It will show up the same as before
    
    // you should declare nonRotatingView as a property so you can easily access it for removal, etc.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    captureSession = [AVCaptureSession new];
    NSArray<AVCaptureDeviceType>* deviceTypes = @[AVCaptureDeviceTypeBuiltInWideAngleCamera, AVCaptureDeviceTypeBuiltInDualCamera];
    self.videoDeviceDiscoverySession = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:deviceTypes mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionUnspecified];
    
    AVCaptureDevice* videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInDualCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    if (!videoDevice) {
        // If a rear dual camera is not available, default to the rear wide angle camera.
        videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        
        // In the event that the rear wide angle camera isn't available, default to the front wide angle camera.
        if (!videoDevice) {
            videoDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
        }
    }
    
    AVCaptureDeviceInput *cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:videoDevice error:nil];
    videoDeviceInput = cameraDeviceInput;
    AVCaptureDeviceInput *micDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    Output = [[AVCapturePhotoOutput alloc] init];
  
    
    if ([captureSession canAddInput:cameraDeviceInput]) {
        [captureSession addInput:cameraDeviceInput];
    }
    if ([captureSession canAddInput:micDeviceInput]) {
        [captureSession addInput:micDeviceInput];
    }
    if ([captureSession canAddOutput:Output]) {
        [captureSession addOutput:Output];
    }
    if ([captureSession canAddOutput:MovieFileOutput]) {
       // [captureSession addOutput:MovieFileOutput];
    }

    [captureSession startRunning];
    
    _videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    [_videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    [_videoPreviewLayer setFrame:[UIScreen mainScreen].bounds];
    [_cameraView.layer insertSublayer:_videoPreviewLayer atIndex:0];

}

- (void)viewWillAppear:(BOOL)animated{
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
}

/*!
 Method used to find current device orientation.
 Basically a NSNotification fired while any device rotation happend.
 */

// Notify if the screen orientation is changed
#pragma  mark - Orientation Functions

-(void)orientationChanged:(NSNotification *)notif {
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    // Calculate rotation angle
    CGFloat angle;
    switch (deviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:
            angle = M_PI;
            break;
        case UIDeviceOrientationLandscapeLeft:
            angle = M_PI_2;
            break;
        case UIDeviceOrientationLandscapeRight:
            angle = - M_PI_2;
            break;
        default:
            angle = 0;
            break;
    }
    
    [UIView animateWithDuration:.2 animations:^{
        self.swipeCamera.transform = CGAffineTransformMakeRotation(angle);
    } completion:^(BOOL finished) {
        
    }];
}

// Give the current orientation of the screen

- (UIImageOrientation)currentImageOrientation
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    UIImageOrientation imageOrientation;
    
    AVCaptureDeviceInput *input = captureSession.inputs.firstObject;
    if (input.device.position == AVCaptureDevicePositionBack) {
        switch (deviceOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationUp;
                break;
                
            case UIDeviceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationDown;
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationLeft;
                break;
                
            default:
                imageOrientation = UIImageOrientationRight;
                break;
        }
    } else {
        switch (deviceOrientation) {
            case UIDeviceOrientationLandscapeLeft:
                imageOrientation = UIImageOrientationDownMirrored;
                break;
                
            case UIDeviceOrientationLandscapeRight:
                imageOrientation = UIImageOrientationUpMirrored;
                break;
                
            case UIDeviceOrientationPortraitUpsideDown:
                imageOrientation = UIImageOrientationRightMirrored;
                break;
                
            default:
                imageOrientation = UIImageOrientationLeftMirrored;
                break;
        }
    }
    
    return imageOrientation;
}
#pragma mark - Camera Action Methods
- (IBAction)cameraButtonPressed:(id)sender {
    NSLog(@"------ %d",cameraOrVideoSelection);
    if(cameraOrVideoSelection == 2 ){
        NSLog(@"CAMERA SELECTED");
        AVCapturePhotoSettings *settings = [[AVCapturePhotoSettings alloc]init];
        // settings.flashMode =  AVCaptureFlashModeAuto ;
        [Output capturePhotoWithSettings:settings delegate:self];
        
        NSLog(@"Pressed");
    }else {
        if(!isRecording){
            isRecording = YES ;
            NSLog(@"hhh");
            NSString *outputPath= [[NSString alloc] initWithFormat:@"%@%@",NSTemporaryDirectory(),@"output.mov"];
            NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSLog(@"sssss");
            if([fileManager fileExistsAtPath:outputPath]){
                NSError *error ;
                NSLog(@"aise");
                if([fileManager removeItemAtPath:outputPath error:&error] == NO ){
                    NSLog(@"error");
                }
            }
            //[outputPath release];
            [MovieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
            NSLog(@"aise nai");
        }else{
            isRecording = NO;
            [MovieFileOutput stopRecording];
        }
        

      
    }
}
- (IBAction)selectVideoOrCamera:(id)sender {
        UISegmentedControl *s = (UISegmentedControl *)sender;
        
        if (s.selectedSegmentIndex == 1)
        {   // video
            // Add movie file output
            MovieFileOutput= [[AVCaptureMovieFileOutput alloc]init];
            Float64 TotalSeconds = 60 ;
            int32_t preferredTimeScale = 30 ;
            CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);    ///<SET MAX DURATION
            
            MovieFileOutput.maxRecordedDuration = maxDuration ;
            MovieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
            cameraOrVideoSelection = 1 ;
            NSLog(@"Video Selected");
           [captureSession removeOutput:Output];
            if ([captureSession canAddOutput:MovieFileOutput]) {
                [captureSession addOutput:MovieFileOutput];
            }
            
        }
        else
        {
            //camera
            cameraOrVideoSelection = 2 ;
            NSLog(@"Camera Selected");
            [captureSession removeOutput:MovieFileOutput];
            if ([captureSession canAddOutput:Output]) {
                [captureSession addOutput:Output];
            }

            
        }
    }

- (IBAction)swipeCamera:(id)sender {
    AVCaptureDevice* currentVideoDevice = [videoDeviceInput device];
    AVCaptureDevicePosition currentPosition = currentVideoDevice.position;
    
    AVCaptureDevicePosition preferredPosition;
    AVCaptureDeviceType preferredDeviceType;
    
    switch (currentPosition)
    {
        case AVCaptureDevicePositionUnspecified:
        case AVCaptureDevicePositionFront:
            preferredPosition = AVCaptureDevicePositionBack;
            preferredDeviceType = AVCaptureDeviceTypeBuiltInDualCamera;
            break;
        case AVCaptureDevicePositionBack:
            preferredPosition = AVCaptureDevicePositionFront;
            preferredDeviceType = AVCaptureDeviceTypeBuiltInTrueDepthCamera;
            break;
    }
    NSArray<AVCaptureDevice* >* devices = self.videoDeviceDiscoverySession.devices;
    AVCaptureDevice* newVideoDevice = nil;
    
    // First, look for a device with both the preferred position and device type.
    for (AVCaptureDevice* device in devices) {
        if (device.position == preferredPosition && [device.deviceType isEqualToString:preferredDeviceType]) {
            newVideoDevice = device;
            break;
        }
    }
    
    // Otherwise, look for a device with only the preferred position.
    if (!newVideoDevice) {
        for (AVCaptureDevice* device in devices) {
            if (device.position == preferredPosition) {
                newVideoDevice = device;
                break;
            }
        }
    }
    
    if (newVideoDevice) {
        [captureSession removeInput:videoDeviceInput];
        videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:newVideoDevice error:NULL];
        [captureSession addInput:videoDeviceInput];
        
        
    }
}

#pragma mark - Delegate for camera

-(void)captureOutput:(AVCapturePhotoOutput *)captureOutput didFinishProcessingPhotoSampleBuffer:(CMSampleBufferRef)photoSampleBuffer previewPhotoSampleBuffer:(CMSampleBufferRef)previewPhotoSampleBuffer resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings bracketSettings:(AVCaptureBracketedStillImageSettings *)bracketSettings error:(NSError *)error
{
    // NSLog(@"%@",photoSampleBuffer);
    if (error) {
        NSLog(@"error : %@", error.localizedDescription);
    }
    
    if (photoSampleBuffer) {
        NSData *data = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer previewPhotoSampleBuffer:previewPhotoSampleBuffer];
        //NSLog(@"%@",data);
        
        
        // [self handleImage:image];
        
        UIImage *image = [UIImage imageWithCGImage:[[[UIImage alloc] initWithData:data] CGImage]
                                             scale:1.0f
                                       orientation:[self currentImageOrientation]];
        
        imageShowViewController *imageController = [[ imageShowViewController alloc]init];
        imageController.imageToSend = image;
        [self.navigationController pushViewController:imageController animated:YES];
        
    }
}

#pragma mark - Delegate for Video
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error
{
    
    NSLog(@"didFinishRecordingToOutputFileAtURL - enter");
    
    BOOL RecordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value)
        {
            RecordedSuccessfully = [value boolValue];
        }
    }
    if (RecordedSuccessfully)
    {
        //----- RECORDED SUCESSFULLY -----
        NSLog(@"didFinishRecordingToOutputFileAtURL - success");
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
        {
            [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                        completionBlock:^(NSURL *assetURL, NSError *error)
             {
                 if (error)
                 {
                     
                 }
             }];
        }
        
       // [library release];
        
    }
}

@end

@implementation UINavigationController (CustomCon)



@end

