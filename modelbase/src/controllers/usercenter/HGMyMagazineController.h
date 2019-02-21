//
//  HGMyMagazineController.h
//  modelbase
//
//  Created by HamGuy on 5/19/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MyMagazineType) {
    MyMagazineTypeDownladed,
    MyMagazineTypeMine
};


@interface HGMyMagazineController : UICollectionViewController

-(id)initWithCovers:(NSArray *)covers;

-(id)initWithUserName:(NSString *)userName;

@end
