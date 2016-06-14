//
//  CameraToolbar.h
//  Blocstagram
//
//  Created by Alexis Schreier on 06/13/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CameraToolbar;

//the CameraToolbarView will know nothing about it's buttons' funcionality since it will be delegated out to the camera view controller
@protocol CameraToolbarDelegate <NSObject>

- (void) leftButtonPressedOnToolbar: (CameraToolbar *)toolbar;
- (void) rightButtonPressedOnToolbar: (CameraToolbar *)toolbar;
- (void) cameraButtonPressedOnToolbar: (CameraToolbar *)toolbar;

@end



@interface CameraToolbar : UIView

//**use instancetype on method that is returning an instance of that class
//image names for the icons of the side buttons will be passed to this method
- (instancetype) initWithImageNames: (NSArray *)imageNames;

@property (nonatomic, weak) NSObject <CameraToolbarDelegate> *delegate;

@end
