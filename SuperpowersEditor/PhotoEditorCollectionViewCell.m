//
//  PhotoEditorCollectionViewCell.m
//  Superpowers
//
//  Created by Zakk Hoyt on 6/28/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "PhotoEditorCollectionViewCell.h"

@interface PhotoEditorCollectionViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation PhotoEditorCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = _image;
}

-(void)setTitle:(NSString *)title{
    _title = title;
    self.titleLabel.text = _title;
}
@end
