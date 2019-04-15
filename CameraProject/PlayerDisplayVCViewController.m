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
        [self.timer invalidate];
    }else{
        [player play];
        [btn setTitle:@"Pause" forState:UIControlStateNormal];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateSlider) userInfo:nil repeats:YES];
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
    CGFloat val = slider.value + 0.1f;
    [slider setValue:val];
}/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
