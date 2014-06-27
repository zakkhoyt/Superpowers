//
//  RDCollectionView.m
//  CollectionViewLayouts
//
//  Created by Zakk Hoyt on 6/16/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "RDCollectionView.h"

@implementation RDCollectionView

-(UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    if(self.mapMode){
        NSArray *indexPaths = [self indexPathsForVisibleItems];
        for(NSIndexPath *indexPath in indexPaths.reverseObjectEnumerator){
            UICollectionViewCell *cell = [self cellForItemAtIndexPath:indexPath];
            if(CGRectContainsPoint(cell.frame, point)){
                return cell;
            }
        }
        return nil;
    } else {
        return [super hitTest:point withEvent:event];
    }
}


- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return !self.mapMode;
}
@end
