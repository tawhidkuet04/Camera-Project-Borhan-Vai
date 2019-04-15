//
//  PlayerDisplayVCViewController.h
//  CameraProject
//
//  Created by Tawhid Joarder on 4/15/19.
//  Copyright © 2019 BrainCraft LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerBC.h"

NS_ASSUME_NONNULL_BEGIN

@interface PlayerDisplayVCViewController : UIViewController
@property (strong, nonatomic) IBOutlet PlayerBC *playerView;
@property (nonatomic, strong) NSURL *videoURL;
 @property (strong, nonatomic) NSTimer *timer;
@end

NS_ASSUME_NONNULL_END
