//
//  HGAblumViewerViewController.m
//  modelbase
//
//  Created by HamGuy on 5/21/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAblumViewerViewController.h"
#import "HGAblumViewCell.h"

@interface HGAblumViewerViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *pictureDatas;
@property (nonatomic, weak) IBOutlet UIView *headerView;
@property (nonatomic, weak) IBOutlet UIView *footerView;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (assign, nonatomic) BOOL isHeaderViewHidden;
@property (nonatomic,assign) NSInteger currentIndex;

@end

@implementation HGAblumViewerViewController

-(id)initWithPictures:(NSArray *)pictiures{
    self = [super initWithNibName:@"HGAblumViewerViewController" bundle:nil];
    if(self){
        self.pictureDatas = pictiures;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.collectionView registerClass:[HGAblumViewCell class] forCellWithReuseIdentifier:@"viewCell"];
    [self.collectionView registerNib:[HGAblumViewCell nib] forCellWithReuseIdentifier:@"viewCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView DataSource & Delegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.pictureDatas.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    HGAblumViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"viewCell" forIndexPath:indexPath];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - UIScrollview Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.currentIndex = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
//    self.countLabel.text = [NSString stringWithFormat:@"%d/%lu",（int)(self.currentIndex+1),(unsigned long)self.pictureDatas.count];
}



#pragma mark - Actions
-(IBAction)goBack:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)showSnsView:(id)sender{
    
}

-(IBAction)previous:(id)sender{
    NSIndexPath *indexPath = [self currentIndexPath];
    if(indexPath.row != 0){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
}

-(IBAction)next:(id)sender{
    NSIndexPath *indexPath = [self currentIndexPath];
    if(indexPath.row <= self.pictureDatas.count-1){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    }
 
}

-(IBAction)likeThisPic:(id)sender{
    
}

#pragma mark - Private
-(void)setUpCountLabel{
    
}

-(NSIndexPath *)currentIndexPath{
    return [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
}

@end
