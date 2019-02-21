//
//  NSString+LineSpace.m
//  modelbase
//
//  Created by HamGuy on 5/19/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "NSString+LineSpace.h"

@implementation NSString (LineSpace)

-(NSAttributedString *)attributedStringWithLineSpace:(CGFloat)lineSpace{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self length])];
    return attributedString;
}

@end
