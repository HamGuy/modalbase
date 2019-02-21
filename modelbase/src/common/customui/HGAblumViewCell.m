//
//  HGAblumViewCell.m
//  modelbase
//
//  Created by HamGuy on 5/21/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAblumViewCell.h"

@implementation HGAblumViewCell

+(UINib *)nib{
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    return [UINib nibWithNibName:@"HGAblumViewCell" bundle:classBundle];
}


@end
