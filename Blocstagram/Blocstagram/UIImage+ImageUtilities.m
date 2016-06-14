//
//  UIImage+ImageUtilities.m
//  Blocstagram
//
//  Created by Alexis Schreier on 06/13/16.
//  Copyright © 2016 Alexis Schreier. All rights reserved.
//

#import "UIImage+ImageUtilities.h"

@implementation UIImage (ImageUtilities)

//inspects the image's imageOrientation property and uses this information to flip or rotate the image as necessary
- (UIImage *) imageWithFixedOrientation {
    // Do nothing if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return [self copy];
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    
    //transform holds an "affine transformation matrix" a grid of numbers (like a spreadsheet) that describes how to rotate, flip, and scale a 2D image. We update it to reflect how we want to rotate/flip/scale the image
    //set transform
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform calculated above.
    CGFloat scaleFactor = self.scale;
    
    //Create a CGContextRef(a "bitmap graphics context", like a blank sheet of paper you can draw on)
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             self.size.width * scaleFactor,
                                             self.size.height * scaleFactor,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    
    //Scale the image (to support Retina displays)
    CGContextScaleCTM(ctx, scaleFactor, scaleFactor);
    
    //Apply transform to the drawing context with CGContextConcatCTM
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            //Draw the transformed image from the graphics context using CGContextDrawImage
            CGContextDrawImage(ctx, CGRectMake(0,0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0, self.size.width, self.size.height), self.CGImage);
            break;
    }
    
    // Create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg scale:scaleFactor orientation:UIImageOrientationUp];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//resize an image to the aspect ratio of the screen in order to make the cropping rectangle accurate
- (UIImage *) imageResizedToMatchAspectRatioOfSize:(CGSize)size {
    
    //calculate the aspect ratio
    CGFloat horizontalRatio = size.width / self.size.width;
    CGFloat verticalRatio = size.height / self.size.height;
    CGFloat ratio = MAX(horizontalRatio, verticalRatio);
    //use that to calculate the size of the resized image (newSize)
    CGSize newSize = CGSizeMake(self.size.width * ratio * self.scale, self.size.height * ratio * self.scale);
    
    //create a new drawing context in the appropriate size and draw the image on it
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = self.CGImage;
    
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             newRect.size.width,
                                             newRect.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    
    // Draw into the context; this scales the image
    CGContextDrawImage(ctx, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    //get a CGImageRef and convert that to a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(ctx);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef scale:self.scale orientation:UIImageOrientationUp];
    
    // Clean up
    CGContextRelease(ctx);
    CGImageRelease(newImageRef);
    
    return newImage;
}

//one more action we'll need to perform: cropping
- (UIImage *) imageCroppedToRect:(CGRect)cropRect {
    cropRect.size.width *= self.scale;
    cropRect.size.height *= self.scale;
    cropRect.origin.x *= self.scale;
    cropRect.origin.y *= self.scale;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return image;
}

@end
