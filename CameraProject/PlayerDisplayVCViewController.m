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
    __weak NSObject *weakSelf;
    AVPlayerItem *playerItem ;
   
}

@end

@implementation PlayerDisplayVCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    playerItem = [AVPlayerItem playerItemWithURL:_videoURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    player = [AVPlayer playerWithPlayerItem:playerItem];
    slider.maximumValue = CMTimeGetSeconds(playerItem.asset.duration);
    slider.hidden =  NO;
    [slider setValue:0];
    weakSelf = self;
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
- (IBAction)playPauseAction:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (player.rate) {
        [player pause];
        [btn setTitle:@"Play" forState:UIControlStateNormal];
       // [self.timer invalidate];
    }else{
       
        [btn setTitle:@"Pause" forState:UIControlStateNormal];
        double interval = .1f;
        
        CMTime playerDuration = [self playerItemDuration]; // return player duration.
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        double duration = CMTimeGetSeconds(playerDuration);
        if (isfinite(duration))
        {
            CGFloat width = CGRectGetWidth([slider bounds]);
            interval = 0.5f * duration / width;
        }
        [player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1/ 60.0, NSEC_PER_SEC)
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
    [self.timer invalidate];
    [slider setValue:0];
}
- (IBAction)sliderValueChanged:(UISlider *)sender {
    [player seekToTime:CMTimeMakeWithSeconds(sender.value, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
- (IBAction)backButtonPressed:(id)sender {
    player = nil;
    playerItem = nil;
    [slider setValue:0];
   // [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
   // [self presentViewController:cameraWindow  animated:YES completion:nil];
}
- (void)updateSlider {
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        slider.minimumValue = 0.0;
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration) && (duration > 0))
    {
        float minValue = [ slider minimumValue];
        float maxValue = [ slider maximumValue];
        double time = CMTimeGetSeconds([player currentTime]);
        [slider setValue:(maxValue - minValue) * time / duration + minValue];
    }
}
- (CMTime)playerItemDuration
{
    AVPlayerItem *thePlayerItem = [player currentItem];
    if (thePlayerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        
        return([playerItem duration]);
    }
    
    return(kCMTimeInvalid);
}/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
