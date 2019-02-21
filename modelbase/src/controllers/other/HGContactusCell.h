//
//  HGContactusCell.h
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGBaseCell.h"

@interface HGContactusCell : HGBaseCell
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *contentLabel;
@property (nonatomic, strong) UIView *seperatorView;
@end
