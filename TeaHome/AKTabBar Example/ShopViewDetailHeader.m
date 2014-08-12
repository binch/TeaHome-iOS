//
//  ShopViewDetailHeader.m
//  TeaHome
//
//  Created by andylee on 14-7-24.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "ShopViewDetailHeader.h"

@implementation ShopViewDetailHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.catLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 20)];
        self.catLabel.backgroundColor = [UIColor clearColor];
       self.catLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
//        catLabel.text = [NSString stringWithFormat:@"商品种类:%@",[cat objectForKey:@"name"]];
        
        [self addSubview:self.catLabel];
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
