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
@property (weak) IBOutlet UILabel *label;
@end


@implementation VWWAssetCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
}

-(void)setTitle:(NSString*)title{
    _title = title;
    self.label.text = title;
}


@end
