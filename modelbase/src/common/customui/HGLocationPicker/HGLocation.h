//
//  HGLocation.h
//  modelbase
//
//  Created by HamGuy on 5/30/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGLocation : NSObject

@property (copy, nonatomic) NSString *country;
@property (copy, nonatomic) NSString *state;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *district;
@property (copy, nonatomic) NSString *street;
@property (nonatomic) CGFloat latitude;
@property (nonatomic) CGFloat longitude;


@end
