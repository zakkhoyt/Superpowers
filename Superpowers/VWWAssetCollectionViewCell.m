//
//  VWWAssetCollectionViewCell.m
//  Superpowers
//
//  Created by Zakk Hoyt on 6/26/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWAssetCollectionViewCell.h"

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
    }
    return self;
}


#pragma mark UIView

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate assetCollectionViewCellTouchBegan:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate assetCollectionViewCellTouchEnded:self];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.delegate assetCollectionViewCellTouchEnded:self];
}

#pragma mark Public methods

- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
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




-(void)longPress:(UILongPressGestureRecognizer*)sender{
    if(sender.state == UIGestureRecognizerStateBegan){
        [self.delegate assetCollectionViewCellLongPress:self];
    }
}


@end
