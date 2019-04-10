//
//  imageShowViewController.h
//  NayemVaiCameraUi
//
//  Created by Tawhid Joarder on 4/9/19.
//  Copyright © 2019 Tawhid Joarder. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface imageShowViewController : UIViewController{

}
@property (nonatomic, strong) UIImage *imageToSend;
@property (strong, nonatomic) IBOutlet UIImageView *imageThatCaptured;
@end

NS_ASSUME_NONNULL_END
