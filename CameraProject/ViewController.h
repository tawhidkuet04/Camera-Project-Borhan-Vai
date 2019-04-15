//
//  ViewController.h
//  CameraProject
//
//  Created by Sk Borhan Uddin on 9/4/19.
//  Copyright © 2019 BrainCraft LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#define CAPTURE_FRAMES_PER_SECOND        20
@interface ViewController : UIViewController{
    UIImageOrientation imageOrientation;
    AVPlayer *player;
    int  cameraOrVideoSelection;
    IBOutlet UILabel *lbl;
    NSTimer *stopTimer;
    NSDate *startDate;
    BOOL running;
    
}
-(void)updateTimer;
- (UIImageOrientation)currentImageOrientation;
@end



