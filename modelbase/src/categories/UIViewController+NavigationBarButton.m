//
//  UIViewController+NavigationBarButton.m
//  modelbase
//
//  Created by HamGuy on 5/16/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "UIViewController+NavigationBarButton.h"
#import "UIImage+Alpha.h"

#define kFontSize 17.0f

@implementation UIViewController (NavigationBarButton)

-(void)addbackButtonWithAction:(SEL)action{
    if(action==nil){
        action = @selector(goBack);
    }
    [self addLeftButtonWithImage:[UIImage imageNamed:@"IconBack"] highlight:[UIImage imageNamed:@"IconBackSel"] action:action];
}

-(void)addMoreButton{
    [self addLeftButtonWithImage:[UIImage imageNamed:@"IconMore"] highlight:[UIImage imageNamed:@"IconMoreSel"] action:@selector(more)];
}

-(void)addLeftButtonWithImage:(UIImage *)image highlight:(UIImage*)highlightImage action:(SEL)action{
    self.navigationItem.leftBarButtonItem = [self barItemWithImage:image highlight:highlightImage target:self action:action direction:0];
}

-(void) addRightButtonWithImage:(UIImage *)image highlight:(UIImage*)highlightImage action:(SEL)action{
    self.navigationItem.rightBarButtonItem = [self barItemWithImage:image highlight:highlightImage target:self action:action direction:1];
}

-(void)addRightBarButtonWithName:(NSString *)name withAction:(SEL)action{
    self.navigationItem.rightBarButtonItem = [self barButtonItemWithName:name action:action];
}


-(void)addLeftBarButtonWithName:(NSString *)name withAction:(SEL)action{
    self.navigationItem.leftBarButtonItem = [self barButtonItemWithName:name action:action];
}


- (UIBarButtonItem *)barButtonItemWithName:(NSString *)name action:(SEL)action {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 4, 44.0f, 36.0f);
    [btn setTitle:name forState:UIControlStateNormal];
    [btn setTitle:name forState:UIControlStateHighlighted];
    btn.backgroundColor = [UIColor clearColor];
    btn.titleLabel.backgroundColor = [UIColor clearColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:kFontSize];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
//    if (!IS_IOS6()) {
//        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -16);
//    }
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

-(UIBarButtonItem *)barItemWithImage:(UIImage *)image highlight:(UIImage*)highlightImage target:(id)target action:(SEL)action direction:(int) direction{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted = NO;
    button.frame = CGRectMake(0, 0, 30, 30);
    button.backgroundColor = [UIColor clearColor];
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:highlightImage?:[image imageByApplyingAlpha:0.2] forState:UIControlStateHighlighted];
    
//    if(!IS_IOS6()){
//        button.contentEdgeInsets = direction == 0 ? UIEdgeInsetsMake(0, -20.f, 0, 0) : UIEdgeInsetsMake(0, 0, 0, -20.f);
//    }
    
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:button];
    return item;
}

-(void)goBack{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)more{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}
@end
