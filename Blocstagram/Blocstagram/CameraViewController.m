//
//  CameraViewController.m
//  Blocstagram
//
//  Created by Alexis Schreier on 06/13/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "CameraViewController.h"
#import "CameraToolbar.h"
#import "UIImage+ImageUtilities.h"


@interface CameraViewController () <CameraToolbarDelegate>

@property (nonatomic, strong) UIView *imagePreview;//will show the user the image from the camera

@property (nonatomic, strong) AVCaptureSession *session;// an AVCaptureSession, which coordinates data from inputs (cameras and microphones) to the outputs (movie files and still images)
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//special type of CALayer (AVCaptureVideoPreviewLayer) that displays video from a camera
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;//captures still images from the capture session's input (camera)

@property (nonatomic, strong) NSArray *horizontalLines;
@property (nonatomic, strong) NSArray *verticalLines;
@property (nonatomic, strong) UIToolbar *topView;
@property (nonatomic, strong) UIToolbar *bottomView;

@property (nonatomic, strong) CameraToolbar *cameraToolbar;

@end



@implementation CameraViewController

#pragma mark - Build View Hierarchy
#pragma mark

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [self createViews];
    [self addViewsToViewHierarchy];
    [self setupImageCapture];
    [self createCancelButton];
}

- (void) createViews {
    
    self.imagePreview = [UIView new];
    self.topView = [UIToolbar new];
    self.bottomView = [UIToolbar new];
    
    self.cameraToolbar = [[CameraToolbar alloc] initWithImageNames:@[@"rotate", @"road"]];
    self.cameraToolbar.delegate = self;
    
    UIColor *whiteBG = [UIColor colorWithWhite:1.0 alpha:.15];
    self.topView.barTintColor = whiteBG;
    self.bottomView.barTintColor = whiteBG;
    self.topView.alpha = 0.5;
    self.bottomView.alpha = 0.5;
}

- (void) addViewsToViewHierarchy {
    
    NSMutableArray *views = [@[self.imagePreview, self.topView, self.bottomView] mutableCopy];
    
    [views addObjectsFromArray:self.horizontalLines];
    [views addObjectsFromArray:self.verticalLines];
    [views addObject:self.cameraToolbar];
    
    for (UIView *view in views) {
        
        [self.view addSubview:view];
    }
}

- (void) createCancelButton {
    UIImage *cancelImage = [UIImage imageNamed:@"x"];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancelImage style:UIBarButtonItemStyleDone target:self action:@selector(cancelPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}


#pragma mark - Layout subviews
#pragma mark

//The top and bottom views cover the areas of the photo that won't be saved.
//The horizontal and vertical lines are distributed evenly over the photo area to create a 3x3 grid of squares.
//self.imagePreview and self.captureVideoPreviewLayer fill the view controller's primary view.
//Finally, place the camera toolbar at the bottom.

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.view.bounds);
    self.topView.frame = CGRectMake(0, self.topLayoutGuide.length, width, 44);
    
    CGFloat yOriginOfBottomView = CGRectGetMaxY(self.topView.frame) + width;
    CGFloat heightOfBottomView = CGRectGetHeight(self.view.frame) - yOriginOfBottomView;
    self.bottomView.frame = CGRectMake(0, yOriginOfBottomView, width, heightOfBottomView);
    
    CGFloat thirdOfWidth = width / 3;
    
    for (int i = 0; i < 4; i++) {
        UIView *horizontalLine = self.horizontalLines[i];
        UIView *verticalLine = self.verticalLines[i];
        
        horizontalLine.frame = CGRectMake(0, (i * thirdOfWidth) + CGRectGetMaxY(self.topView.frame), width, 0.5);
        
        CGRect verticalFrame = CGRectMake(i * thirdOfWidth, CGRectGetMaxY(self.topView.frame), 0.5, width);
        
        if (i == 3) {
            verticalFrame.origin.x -= 0.5;
        }
        
        verticalLine.frame = verticalFrame;
    }
    
    self.imagePreview.frame = self.view.bounds;
    self.captureVideoPreviewLayer.frame = self.imagePreview.bounds;
    
    CGFloat cameraToolbarHeight = 100;
    self.cameraToolbar.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - cameraToolbarHeight, width, cameraToolbarHeight);
}


#pragma mark - Create white grid
#pragma mark

- (NSArray *) horizontalLines {
    if (!_horizontalLines) {
        _horizontalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _horizontalLines;
}

- (NSArray *) verticalLines {
    if (!_verticalLines) {
        _verticalLines = [self newArrayOfFourWhiteViews];
    }
    
    return _verticalLines;
}

- (NSArray *) newArrayOfFourWhiteViews {
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i < 4; i++) {
        UIView *view = [UIView new];
        view.backgroundColor = [UIColor whiteColor];
        [array addObject:view];
    }
    
    return array;
}


#pragma mark - imageCapture setup
#pragma mark

- (void) setupImageCapture {
    //create a capture session, which mediates between the camera and output layer
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
    //create self.captureVideoPreviewLayer to display the camera content. We set videoGravity to AVLayerVideoGravityResizeAspectFill, which is like setting a UIImageView's contentMode property to UIViewContentModeScaleAspectFill. addSublayer: is analogous to calling addSubview: on a UIView
    self.captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.captureVideoPreviewLayer.masksToBounds = YES;
    [self.imagePreview.layer addSublayer:self.captureVideoPreviewLayer];
    
    //request permission from the user to access the camera. Because the user might not reply immediately, the response is handled asynchronously in a completion block
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //indicates whether the user has accepted our request
            if (granted) {
                //create a device which represents the camera. It provides its data to the AVCaptureSession through an AVCaptureDeviceInput object
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                
                //create the AVCaptureDeviceInput object
                NSError *error = nil;
                AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                if (!input) {
                    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
                    [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        [self.delegate cameraViewController:self didCompleteWithImage:nil];
                    }]];
                    
                    [self presentViewController:alertVC animated:YES completion:nil];
                } else {//add the input to our capture session, create a still image output that saves JPEG files, and start running the session
                    
                    [self.session addInput:input];
                    
                    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
                    self.stillImageOutput.outputSettings = @{AVVideoCodecKey: AVVideoCodecJPEG};
                    
                    [self.session addOutput:self.stillImageOutput];
                    
                    [self.session startRunning];
                }
            } else {
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Camera Permission Denied", @"camera permission denied title")
                                                                                 message:NSLocalizedString(@"This app doesn't have permission to use the camera; please update your privacy settings.", @"camera permission denied recovery suggestion")
                                                                          preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [self.delegate cameraViewController:self didCompleteWithImage:nil];
                }]];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            }
        });
    }];
}


#pragma mark - Event Handling
#pragma mark

- (void) cancelPressed:(UIBarButtonItem *)sender {
    [self.delegate cameraViewController:self didCompleteWithImage:nil];
}


#pragma mark - CameraToolbarDelegate
#pragma mark

//The left button flips between the front and rear cameras
- (void) leftButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    //get the current input and an array of all possible video devices. This is typically 2 (front camera and rear camera)
    AVCaptureDeviceInput *currentCameraInput = self.session.inputs.firstObject;
    
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    //If there's more than one possible device, we'll try to create an input for it
    if (devices.count > 1) {
        NSUInteger currentIndex = [devices indexOfObject:currentCameraInput.device];
        NSUInteger newIndex = 0;
        
        if (currentIndex < devices.count - 1) {
            newIndex = currentIndex + 1;
        }
        
        AVCaptureDevice *newCamera = devices[newIndex];
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:nil];
        
        //If that succeeds, we make a nice dissolve effect
        if (newVideoInput) {
            UIView *fakeView = [self.imagePreview snapshotViewAfterScreenUpdates:YES];
            fakeView.frame = self.imagePreview.frame;
            [self.view insertSubview:fakeView aboveSubview:self.imagePreview];
            
            [self.session beginConfiguration];
            [self.session removeInput:currentCameraInput];
            [self.session addInput:newVideoInput];
            [self.session commitConfiguration];
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                fakeView.alpha = 0;
            } completion:^(BOOL finished) {
                [fakeView removeFromSuperview];
            }];
        }
    }
}

//right camera toolbar button will open a different view to allow the user to select a photo from their library
- (void) rightButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    NSLog(@"Photo library button pressed.");
}

- (void) cameraButtonPressedOnToolbar:(CameraToolbar *)toolbar {
    AVCaptureConnection *videoConnection;
    
    // #8 we find the correct AVCaptureConnection, which represents the input - session - output connection. This connection is passed to the output object
    // Find the right connection object
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in connection.inputPorts) {
            if ([port.mediaType isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    // #9 returns the image in a completion block. The image is a CMSampleBufferRef, but we know it's a JPEG still image, so we can easily convert it to an NSData and then to a UIImage
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        if (imageSampleBuffer) {
            // #10 convert it to an NSData and then to a UIImage
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
            
            CGSize captureVideoPreviewLayerSize = self.captureVideoPreviewLayer.bounds.size;
            
            UIView *leftLine = self.verticalLines.firstObject;
            UIView *rightLine = self.verticalLines.lastObject;
            UIView *topLine = self.horizontalLines.firstObject;
            UIView *bottomLine = self.horizontalLines.lastObject;
            
            CGRect gridRect = CGRectMake(CGRectGetMinX(leftLine.frame),
                                         CGRectGetMinY(topLine.frame),
                                         CGRectGetMaxX(rightLine.frame) - CGRectGetMinX(leftLine.frame),
                                         CGRectGetMinY(bottomLine.frame) - CGRectGetMinY(topLine.frame));

            
            image = [image imageByScalingToSize:captureVideoPreviewLayerSize andCroppingWithRect:gridRect];

            // #13 Once it's cropped, we call the delegate method with the image. The camera button should now capture the correct image
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate cameraViewController:self didCompleteWithImage:image];
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:error.localizedDescription message:error.localizedRecoverySuggestion preferredStyle:UIAlertControllerStyleAlert];
                [alertVC addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"OK button") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [self.delegate cameraViewController:self didCompleteWithImage:nil];
                }]];
                
                [self presentViewController:alertVC animated:YES completion:nil];
            });
            
        }
    }];
}


#pragma mark - Misc
#pragma mark

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
