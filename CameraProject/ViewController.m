//
//  ViewController.m
//  CameraProject
//
//  Created by Sk Borhan Uddin on 9/4/19.
//  Copyright © 2019 BrainCraft LTD. All rights reserved.
//

#import "ViewController.h"
#import "imageShowViewController.h"

@interface ViewController ()<AVCapturePhotoCaptureDelegate>{
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput* videoDeviceInput;
    AVCaptureVideoDataOutput* videoDataOutput;
    AVCapturePhotoOutput *Output ;
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

-(BOOL)shouldAutorotate{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
- (IBAction)cameraButtonPressed:(id)sender {
    
    AVCapturePhotoSettings *settings = [[AVCapturePhotoSettings alloc]init];
    settings.flashMode =  AVCaptureFlashModeAuto ;
    [Output capturePhotoWithSettings:settings delegate:self];
    
    NSLog(@"Pressed");
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
                                       orientation:UIImageOrientationRight];
        
        imageShowViewController *imageController = [[ imageShowViewController alloc]init];
        imageController.imageToSend = image;
        [self.navigationController pushViewController:imageController animated:YES];
        
    }
}

@end

@implementation UINavigationController (CustomCon)

- (BOOL)shouldAutorotate{
    return NO;
}

@end

