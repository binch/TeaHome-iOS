//
//  ShopViewDetailCell.m
//  TeaHome
//
//  Created by andylee on 14-7-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "ShopViewDetailCell.h"

@implementation ShopViewDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 80, 80)];
        self.imageView.backgroundColor = [UIColor clearColor];
//        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
        [self.contentView addSubview:self.imageView];
        
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, self.bounds.size.width, 20)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.textColor = [UIColor blackColor];
//        self.titleLabel.text = title;
        [self.contentView addSubview:self.titleLabel];
        
        self.soldLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, self.bounds.size.width, 20)];
        self.soldLabel.backgroundColor = [UIColor clearColor];
        self.soldLabel.numberOfLines = 0;
        self.soldLabel.font = [UIFont systemFontOfSize:12];
        self.soldLabel.textColor = [UIColor blackColor];
//        self.soldLabel.text = [NSString stringWithFormat:@"销量:%d",sold];
        [self.contentView addSubview:self.soldLabel];
        
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 130, self.bounds.size.width, 20)];
        self.priceLabel.backgroundColor = [UIColor clearColor];
        self.priceLabel.numberOfLines = 0;
        self.priceLabel.font = [UIFont systemFontOfSize:12];
        self.priceLabel.textColor = [UIColor blackColor];
//        priceLabel.text = [NSString stringWithFormat:@"价格:%.1f元",price];
        [self.contentView addSubview:self.priceLabel];
        

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
