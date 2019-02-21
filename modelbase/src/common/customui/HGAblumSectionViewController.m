//
//  HGAlblumSectionViewController.m
//  modelbase
//
//  Created by HamGuy on 5/17/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAblumSectionViewController.h"
#import "HGAblumCell.h"
#import "HGOnePixelHeightView.h"
#import "Cover.h"
#import "UIImageView+Loading.h"
#import "HGLocalAblumsManager.h"
#import "HGFlowLayOut.h"

@interface HGAblumSectionViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UILabel *titileLabel;
@property (nonatomic, weak) IBOutlet UIButton *navButton;
@property (nonatomic, weak) IBOutlet UIImageView *indicatorImgView;
@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@property (nonatomic, weak) IBOutlet UIView *collectionContainerView;
@property (nonatomic, weak) IBOutlet HGOnePixelHeightView *topSepratorView;
@property (nonatomic, weak) IBOutlet HGOnePixelHeightView *bottomSepratorView;

@property (nonatomic, assign) AblumSectionType currentType;
@property (nonatomic, strong) NSMutableArray *covers;

@property (nonatomic, strong) UIImage *normaBgIndex;
@property (nonatomic, strong) UIImage *hilightedBgIndex;

//@property (nonatomic, strong) UIImage *normalBgUser;
@property (nonatomic, strong) IBOutlet HGFlowLayOut *flowLayout;


@end

@implementation HGAblumSectionViewController

-(id)initWithAblumSectionType:(AblumSectionType)sectionType{
    self = [super initWithNibName:NSStringFromClass([HGAblumSectionViewController class])      bundle:nil];
    if (self) {
        // Custom initialization
        self.currentType = sectionType;
        self.view.hidden = YES;
    }
    return self;
    
}

-(void)LoadData:(NSArray *)data{
    if (data && data.count>0) {
        self.view.hidden = NO;
        self.covers = [data mutableCopy];
    }else{
        if (self.covers) {
            [self.covers removeAllObjects];
        }
    }
    [self.collectionView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setUptitleAndButton];
    
    [self.collectionView registerClass:[HGAblumCell class] forCellWithReuseIdentifier:@"ablumCell"];
    [self.collectionView registerNib:[HGAblumCell nib] forCellWithReuseIdentifier:@"ablumCell"];
//    self.view.clipsToBounds = YES;
}

- (void)hideNavButton:(BOOL)hide{
    self.navButton.hidden = hide;
}
#pragma mark - FlowLayoutDelegate
//-(CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake(100, 100);
//}

#pragma mark - CollectionView Datasource
-(NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _covers.count;
}

-(NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.currentType == AblumSectionTypeDownloaded) {
        __block HGAblumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ablumCell" forIndexPath:indexPath];
        
        NSString *ablumId = [self.covers objectAtIndex:indexPath.row];
        Cover *cover = [Cover coverForAblum:ablumId];
        
        NSString *imgPath = [[HGLocalAblumsManager sharedInstance] coverImagePathForAblum:ablumId];
        ablumId = nil;
        
        __block UIImage *img = nil;
        cell.imageView.image = [UIImage imageNamed:@"BgPlaceHoderSmall"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            img = [UIImage imageWithContentsOfFile:imgPath];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = img;
            });
        });
        
//        [cell.imageView setImageShowingActivityIndicatorWithURL:[NSURL URLWithString:imgPath] placeholderImage:[UIImage imageNamed:@"BgPlaceHoderSmall"] failed:^{
//            dispatch_async(dispatch_get_main_queue(), ^(void) {
//                cell.imageView.image = [UIImage imageNamed:@"BgImageFiledSmall"];
//            });
//        }];
        cell.titleLabel.text = cover.title;
        
        return cell;
    }else{
        Cover *cover = [self.covers objectAtIndex:indexPath.row];
        __block HGAblumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ablumCell" forIndexPath:indexPath];
        cell.titleLabel.text =cover.title;
        NSString *tmp = [cover.path pathExtension];
        NSString *strpath = [tmp isEqualToString:@"jpg"] ? cover.path : [NSString stringWithFormat:@"%@.jpg",cover.path];
        NSString *urlString = [NSString stringWithFormat:@"%@%@",kCoverUrl,strpath];
//        urlString = @"http://tp1.sinaimg.cn/1839434204/180/5697005509/1";
        
        [cell.imageView setImageShowingActivityIndicatorWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"BgPlaceHoderSmall"] failed:^{
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                cell.imageView.image = [UIImage imageNamed:@"BgImageFiledSmall"];
            });
        }];
        if(self.currentType == AblumSectionTypeMine || self.currentType == AblumSectionTypeDownloaded){
            cell.imageView.top = 3;
            cell.titleLabel.top = 123;
        }else{
            cell.titleLabel.textColor = [UIColor whiteColor];
        }
        return cell;
    }
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 45;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedItemAtIndex:ablumType:)]) {
        [self.delegate didClickedItemAtIndex:indexPath.row ablumType:self.currentType];
    }
}


-(void)setUptitleAndButton{
    switch (self.currentType) {
        case AblumSectionTypeNew:
            [self setUpHeaderViewWithTitle:@"新片速递"];
            break;
        case AblumSectionTypeRec:
            [self setUpHeaderViewWithTitle:@"推荐大师"];
            break;
        case AblumSectionTypeVip:
            [self setUpHeaderViewWithTitle:@"实力会员"];
            break;
        case AblumSectionTypeCop:
            [self setUpHeaderViewWithTitle:@"合作专区"];
            break;
        case AblumSectionTypeMine:
            self.view.backgroundColor = [UIColor whiteColor];
            self.titileLabel.text = @"我的专辑";
            self.indicatorImgView.hidden = YES;
            self.titileLabel.left = 8.f;
            self.collectionView.top += 4.f;
            self.collectionView.backgroundColor = [UIColor whiteColor];
            break;
        case AblumSectionTypeDownloaded:
            self.view.backgroundColor = [UIColor whiteColor];
            self.collectionView.backgroundColor = [UIColor whiteColor];
            self.collectionView.top += 0.f;
            self.titileLabel.text = @"已经下载";
            self.indicatorImgView.hidden = YES;
            self.titileLabel.left = 8.f;
            break;
            
        default:
            break;
    }
}

-(UIImage *)normaBgIndex{
    if(_normaBgIndex == nil){
        _normaBgIndex = [UIImage imageNamed:@"RightArrow"];
    }
    return _normaBgIndex;
}

-(UIImage *)hilightedBgIndex{
    if(_hilightedBgIndex == nil){
        _hilightedBgIndex = [UIImage imageNamed:@"RightArrowPress"];
    }
    return _hilightedBgIndex;
}

-(void)setUpHeaderViewWithTitle:(NSString *)title{
    self.collectionContainerView.backgroundColor = [UIColor clearColor];
    self.topSepratorView.hidden = YES;
    self.bottomSepratorView.hidden = YES;
    self.titileLabel.text = title;
    self.view.backgroundColor = [UIColor clearColor];
    self.titileLabel.textColor = [UIColor whiteColor];
    [self.navButton setTitleColor:RGBCOLOR(96, 96, 96) forState:UIControlStateNormal];
    [self.navButton setTitleColor:RGBCOLOR(96, 96, 96) forState:UIControlStateHighlighted];
    self.navButton.imageEdgeInsets = UIEdgeInsetsMake(2, 72, 0, 0);
    self.navButton.titleEdgeInsets = UIEdgeInsetsMake(2, -15, 0, 0);
    [self.navButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.navButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.navButton setImage:self.normaBgIndex forState:UIControlStateNormal];
    [self.navButton setImage:self.hilightedBgIndex forState:UIControlStateHighlighted];
    self.navButton.left += 4.f;
    self.navButton.top -= 3.f;
    [self.navButton setTitle: @"显示全部" forState:UIControlStateNormal];
    [self.navButton setTitle: @"显示全部" forState:UIControlStateHighlighted];
}

-(IBAction)clickedBtn:(id)sender{
    if(self.delegate && [self.delegate respondsToSelector:@selector(didCleckedButtonWithAblumType:)]){
        [self.delegate didCleckedButtonWithAblumType:self.currentType];
    }
}
@end
