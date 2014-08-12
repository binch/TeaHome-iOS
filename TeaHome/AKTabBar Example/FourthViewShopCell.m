//
//  FourthViewShopCell.m
//  TeaHome
//
//  Created by andylee on 14-7-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "FourthViewShopCell.h"

@implementation FourthViewShopCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
//        self.titleLabel.text = title;
        [self.contentView addSubview:self.titleLabel];
        
//        NSString *shop_image_url = [NSString stringWithFormat:@"%@%d.jpg",shop_image_root_url,shopId];
//        NSURL *url = [NSURL URLWithString:shop_image_url];
        
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,25, self.bounds.size.width, 60)];
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.backgroundColor = [UIColor clearColor];
//        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
        [self.contentView addSubview:self.imageView];
        
        self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 90, self.bounds.size.width, 40)];
        self.descLabel.backgroundColor = [UIColor clearColor];
        self.descLabel.numberOfLines = 0;
        self.descLabel.font = [UIFont systemFontOfSize:12];
        self.descLabel.textColor = [UIColor blackColor];
//        self.descLabel.text = desc;
        [self.contentView addSubview:self.descLabel];
        
        UIImage *goImage = [UIImage imageNamed:@"product_takealook"];
        UIImageView *goIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 135, 56, 13)];
        goIV.image = goImage;
        [self.contentView addSubview:goIV];
        
        self.recommendLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 135, self.bounds.size.width - 60, 15)];
        self.recommendLabel.backgroundColor = [UIColor clearColor];
        self.recommendLabel.numberOfLines = 0;
        self.recommendLabel.font = [UIFont systemFontOfSize:10];
        self.recommendLabel.textColor = [UIColor lightGrayColor];
//        self.recommendLabel.text = [NSString stringWithFormat:@"%d 人推荐该店",recommend];
        [self.contentView addSubview:self.recommendLabel];

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
