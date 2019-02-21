//
//  HGAddAblumCellTableViewCell.m
//  modelbase
//
//  Created by HamGuy on 6/7/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGAddAblumCellTableViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HGAddAblumCellTableViewCell (){
     id tmpData;
}

@property (nonatomic, strong) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UIView *coverIndicator;
@property (nonatomic, weak) IBOutlet UILabel *label;
@end

@implementation HGAddAblumCellTableViewCell

-(void)awakeFromNib{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tap];
}

+(UINib *)nib{
    NSBundle *classBundle = [NSBundle bundleForClass:[self class]];
    return [UINib nibWithNibName:@"HGAddAblumCellTableViewCell" bundle:classBundle];
}

-(void)tapped:(UITapGestureRecognizer *)gesture{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClikedCell:atIndexPath:)]) {
        [self.delegate didClikedCell:self atIndexPath:self.indexPath];
    }
}


-(NSURL *)imageData{
    return tmpData;
}

-(void)setImageData:(id)imageData{
    tmpData  = imageData;
    if ([imageData isKindOfClass:[ALAsset class]]) {
        UIImage *thumImage = [UIImage imageWithCGImage:[imageData thumbnail]];
        self.imgView.image = thumImage;
    }
    
    if ([imageData isKindOfClass:[NSURL class]]) {
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:imageData resultBlock:^(ALAsset *asset) {
            UIImage *thumImage = [UIImage imageWithCGImage:[asset thumbnail]];
            self.imgView.image = thumImage;
        } failureBlock:^(NSError *error) {
            
        }];
    }
}

-(void)setCover:(BOOL)cover{
    self.coverIndicator.hidden = !cover;
    self.label.hidden = !cover;
}

@end
