//
//  HGCollectionFooterView.m
//  modelbase
//
//  Created by HamGuy on 6/7/14.
//  Copyright (c) 2014 HamGuy. All rights reserved.
//

#import "HGExtendImageView.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface HGExtendImageView ()
{id tmpData;
}

@end

@implementation HGExtendImageView


-(id)imageData{
    return tmpData;
}

-(void)setImageData:(id)imageData{
    tmpData = imageData;
    __weak typeof(self) mySelf = self;
    if ([imageData isKindOfClass:[ALAsset class]]) {
        UIImage *thumImage = [UIImage imageWithCGImage:[imageData thumbnail]];
        mySelf.image = thumImage;
    }

    
    if ([imageData isKindOfClass:[NSURL class]]) {
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
        [lib assetForURL:imageData resultBlock:^(ALAsset *asset) {
            UIImage *thumImage = [UIImage imageWithCGImage:[asset thumbnail]];
            mySelf.image = thumImage;
        } failureBlock:^(NSError *error) {
            
        }];
    }
}
@end
