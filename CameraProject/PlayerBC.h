//
//  PlayerBC.h
//  CameraProject
//
//  Created by Tawhid Joarder on 4/15/19.
//  Copyright © 2019 BrainCraft LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PlayerBC : UIView{
    
}
@property (nonatomic, strong) AVPlayer *player;
- (void)setOk:(CGRect )framee ;
@end

NS_ASSUME_NONNULL_END
