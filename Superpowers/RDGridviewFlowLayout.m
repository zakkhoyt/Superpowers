//
//  RDGridviewFlowLayout.m
//  CollectionViewLayouts
//
//  Created by Zakk Hoyt on 6/17/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "RDGridviewFlowLayout.h"

@implementation RDGridviewFlowLayout


-(id)init{
    if ((self = [super init])) {
        [self setupClass];
    }
    return self;
}


- (id)initWithSize:(CGSize)size {
    if ((self = [self init])) {
        [self setupClass];
        self.itemSize = size;
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setupClass];
    }
    return self;
}

-(void)setupClass{
    self.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.minimumLineSpacing = 8.0f;
    self.minimumInteritemSpacing = 8.0f;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return self.itemSize;
}

@end
