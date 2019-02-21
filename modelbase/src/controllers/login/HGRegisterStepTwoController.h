//
//  HGRegisterStepTwoController.h
//  modelbase
//
//  Created by HamGuy on 5/22/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, RegisterType) {
    RegisterTypeModel,
    RegisterTypeEditor,
    RegisterTypeVIP
};

@interface HGRegisterStepTwoController : UIViewController

-(id)initWithRegisterType:(RegisterType)type;

@end
