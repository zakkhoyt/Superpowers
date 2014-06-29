//
//  VWWAssetCollectionViewCell.m
//  Superpowers
//
//  Created by Zakk Hoyt on 6/26/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//
//  https://github.com/foundry/UIImageMetadata
//  http://asciiwwdc.com/2014/sessions/511?q=Swift

#import "VWWAssetCollectionViewCell.h"
@import ImageIO;
@interface VWWAssetCollectionViewCell ()
@property (strong) IBOutlet UIImageView *imageView;
@property (strong) IBOutlet UIImageView *grayImageView;
@property (weak) IBOutlet UILabel *label;
@end


@implementation VWWAssetCollectionViewCell


- (id)initWithCoder:(NSCoder*)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        longPressGesture.minimumPressDuration = 1.0;
        [self addGestureRecognizer:longPressGesture];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGesture];
    }
    return self;
}


#pragma mark UIView
//
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.delegate assetCollectionViewCellTouchBegan:self];
//}
//
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.delegate assetCollectionViewCellTouchEnded:self];
//}
//
//-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//    [self.delegate assetCollectionViewCellTouchEnded:self];
//}

#pragma mark Public methods

- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
    self.layer.cornerRadius = self.frame.size.height / 4.0;
}

-(void)setTitle:(NSString*)title{
    _title = title;
    self.label.text = title;
}

-(void)setWithinLayout:(BOOL)offscreen{
    
    if(offscreen == _withinLayout) return;
    
    _withinLayout = offscreen;
    [self updateOffscreen];
}

#pragma mark Private methods
-(void)updateOffscreen{
    if(_withinLayout){
        [UIView animateWithDuration:0.3 animations:^{
            //            self.bubbleImageView.alpha = 1.0;
            //            self.countLabel.alpha = 1.0;
            self.grayImageView.alpha = 0.0;
        } completion:^(BOOL finished) {
            //            self.grayImageView.hidden = YES;
        }];
        
    } else {
        //        self.grayImageView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            //            self.bubbleImageView.alpha = 0.0;
            //            self.countLabel.alpha = 0.0;
            self.grayImageView.alpha = 0.5;
        }];
    }
}


-(void)doubleTap:(UITapGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateEnded){
        [self.delegate assetCollectionViewCellDoubleTap:self];
    }
}



-(void)longPress:(UILongPressGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        [self.delegate assetCollectionViewCellLongPress:self];
    }
}


//-(UIImage *)addMetaData:(UIImage *)image {
//    
//    NSData *jpeg = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
//    
//    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
//    
//    NSDictionary *metadata = [[asset_ defaultRepresentation] metadata];
//    
//    NSMutableDictionary *metadataAsMutable = [metadata mutableCopy];
//    
//    NSMutableDictionary *EXIFDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyExifDictionary];
//    NSMutableDictionary *GPSDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
//    NSMutableDictionary *TIFFDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
//    NSMutableDictionary *RAWDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyRawDictionary];
//    NSMutableDictionary *JPEGDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyJFIFDictionary];
//    NSMutableDictionary *GIFDictionary = [metadataAsMutable objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
//    
//    if(!EXIFDictionary) {
//        EXIFDictionary = [NSMutableDictionary dictionary];
//    }
//    
//    if(!GPSDictionary) {
//        GPSDictionary = [NSMutableDictionary dictionary];
//    }
//    
//    if (!TIFFDictionary) {
//        TIFFDictionary = [NSMutableDictionary dictionary];
//    }
//    
//    if (!RAWDictionary) {
//        RAWDictionary = [NSMutableDictionary dictionary];
//    }
//    
//    if (!JPEGDictionary) {
//        JPEGDictionary = [NSMutableDictionary dictionary];
//    }
//    
//    if (!GIFDictionary) {
//        GIFDictionary = [NSMutableDictionary dictionary];
//    }
//    
//    [metadataAsMutable setObject:EXIFDictionary forKey:(NSString *)kCGImagePropertyExifDictionary];
//    [metadataAsMutable setObject:GPSDictionary forKey:(NSString *)kCGImagePropertyGPSDictionary];
//    [metadataAsMutable setObject:TIFFDictionary forKey:(NSString *)kCGImagePropertyTIFFDictionary];
//    [metadataAsMutable setObject:RAWDictionary forKey:(NSString *)kCGImagePropertyRawDictionary];
//    [metadataAsMutable setObject:JPEGDictionary forKey:(NSString *)kCGImagePropertyJFIFDictionary];
//    [metadataAsMutable setObject:GIFDictionary forKey:(NSString *)kCGImagePropertyGIFDictionary];
//    
//    CFStringRef UTI = CGImageSourceGetType(source);
//    
//    NSMutableData *dest_data = [NSMutableData data];
//    
//    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)dest_data,UTI,1,NULL);
//    
//    //CGImageDestinationRef hello;
//    
//    CGImageDestinationAddImageFromSource(destination,source,0, (__bridge CFDictionaryRef) metadataAsMutable);
//    
//    BOOL success = NO;
//    success = CGImageDestinationFinalize(destination);
//    
//    if(!success) {
//    }
//    
//    dataToUpload_ = dest_data;
//    
//    CFRelease(destination);
//    CFRelease(source);
//    
//    return image;
//}


@end
