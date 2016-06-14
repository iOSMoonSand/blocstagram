//
//  CameraViewController.h
//  Blocstagram
//
//  Created by Alexis Schreier on 06/13/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraViewController;

@protocol CameraViewControllerDelegate <NSObject>//will inform the presenting view controller when the camera view controller is done

- (void) cameraViewController:(CameraViewController *)cameraViewController didCompleteWithImage:(UIImage *)image;

@end



@interface CameraViewController : UIViewController

@property (nonatomic, weak) NSObject <CameraViewControllerDelegate> *delegate;

@end
