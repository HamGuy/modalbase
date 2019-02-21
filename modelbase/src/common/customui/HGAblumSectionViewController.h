//
//  HGAlblumSectionViewController.h
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AblumSectionType) {
    AblumSectionTypeNew,
    AblumSectionTypeRec,
    AblumSectionTypeVip,
    AblumSectionTypeCop,
    AblumSectionTypeMine,
    AblumSectionTypeDownloaded
};

@class HGAblumSectionViewController;

@protocol  HGAblumSectionViewControllerDelegate<NSObject>

-(void)didClickedItemAtIndex:(int)index ablumType:(AblumSectionType)type;
-(void)didCleckedButtonWithAblumType:(AblumSectionType)type;

@end

@interface HGAblumSectionViewController : UIViewController

@property(weak,nonatomic) id<HGAblumSectionViewControllerDelegate> delegate;

-(id) initWithAblumSectionType:(AblumSectionType)sectionType;
-(void) LoadData:(NSArray *)data;
-(void) hideNavButton:(BOOL)hide;
@end
