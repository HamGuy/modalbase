//
//  HGAblumCell.m
//  modelbase
//
//  Created by HamGuy on 5/18/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAblumCell.h"

@interface HGAblumCell ()

@end

@implementation HGAblumCell

+(UINib *)nib{
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    return [UINib nibWithNibName:@"HGAblumCell" bundle:classBundle];
}

-(void)changeToEditMode:(BOOL)isEdit{
    
    [self.layer removeAllAnimations];
    if(isEdit){
        CGFloat rotation = 0.03;
        
        CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform"];
        shake.duration = 0.13;
        shake.autoreverses = YES;
        shake.repeatCount  = MAXFLOAT;
        shake.removedOnCompletion = NO;
        shake.fromValue = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform,-rotation, 0.0 ,0.0 ,1.0)];
        shake.toValue   = [NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, rotation, 0.0 ,0.0 ,1.0)];
        
        [self.layer addAnimation:shake forKey:@"shake"];
    }
}

-(IBAction)delBttonClicked:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(delButtonCickedOnCell:)]) {
        [self.delegate delButtonCickedOnCell:self];
    }
}

@end
