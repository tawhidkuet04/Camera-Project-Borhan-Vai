//
//  PlayerDisplayVCViewController.m
//  CameraProject
//
//  Created by Tawhid Joarder on 4/15/19.
//  Copyright © 2019 BrainCraft LTD. All rights reserved.
//

#import "PlayerDisplayVCViewController.h"
#import "ViewController.h"
@interface PlayerDisplayVCViewController (){
    AVPlayer *player;
    IBOutlet UIButton *playPause;
    IBOutlet UISlider *slider;
    AVPlayerItem *playerItem ;
    AVAsset *asset;
    id observer;
}

@end

@implementation PlayerDisplayVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    asset = [AVAsset assetWithURL:_videoURL];
    playerItem = [AVPlayerItem playerItemWithAsset:asset];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    slider.maximumValue = CMTimeGetSeconds(playerItem.asset.duration);
    slider.hidden =  NO;
    [slider setValue:0];
   // __weak NSObject *weakSelf = self;
   

   // _playerView.player = player;
    [self.playerView setPlayer:player];

}
- (void)viewWillAppear:(BOOL)animated{
    playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    slider.maximumValue = CMTimeGetSeconds(playerItem.asset.duration);
    slider.hidden =  NO;
    [slider setValue:0];
    // _playerView.player = player;
    [self.playerView setPlayer:player];
}
#pragma  mark -play/pause
- (IBAction)playPauseAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    [self PlayerSetPlayPause:btn withPlayingStatus:player.rate];
}

- (void) PlayerSetPlayPause : (UIButton*)btn withPlayingStatus:(float)rate{
    if (rate) {
        [player pause];
        [btn setTitle:@"Play" forState:UIControlStateNormal];
        if (observer) {
            [player removeTimeObserver:observer];
            observer = nil;
        }
        
        // [self.timer invalidate];
    }else{
        
        [btn setTitle:@"Pause" forState:UIControlStateNormal];
        
        observer = [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1/ 10000.0, NSEC_PER_SEC)
                                                        queue:NULL
                                                   usingBlock:^(CMTime time){
                                                       [self updateSlider];
                                                   }];
        [player play];
        //  self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
    }
}

- (void)itemDidFinishPlaying:(NSNotification *)notification {
    [player seekToTime:kCMTimeZero];
    player.rate = 0 ;
    [playPause setTitle:@"Play" forState:UIControlStateNormal];
    [slider setValue:0];
}
#pragma mark -slider

- (IBAction)slidingBegin:(UISlider *)sender {
    [self PlayerSetPlayPause:playPause withPlayingStatus:1];
}
- (IBAction)slideValueChange:(UISlider *)sender {
    [player seekToTime:CMTimeMakeWithSeconds(sender.value, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
- (IBAction)slidingDone:(UISlider *)sender {
    [self PlayerSetPlayPause:playPause withPlayingStatus:0];
}

- (void)updateSlider {
    
    double time = CMTimeGetSeconds([player currentTime]);
//     NSLog(@"min %f max %f time %f dur %f",minValue,maxValue,time,duration);
    [slider setValue:time];
    
}
#pragma  mark -back
- (IBAction)backButtonPressed:(id)sender {
    player = nil;
    playerItem = nil;
    [slider setValue:0];
   // [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
   // [self presentViewController:cameraWindow  animated:YES completion:nil];
}



@end
