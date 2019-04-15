//
//  PlayerBC.m
//  CameraProject
//
//  Created by Tawhid Joarder on 4/15/19.
//  Copyright © 2019 BrainCraft LTD. All rights reserved.
//

#import "PlayerBC.h"

@implementation PlayerBC

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (IBAction)playPause:(id)sender {
}

- (IBAction)asas:(UIButton *)sender {
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    ((AVPlayerLayer *)[self layer]).videoGravity = AVLayerVideoGravityResizeAspectFill;
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
