//
//  ProductCommentDetailViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-14.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "ProductCommentDetailViewController.h"

@interface ProductCommentDetailViewController ()
{
    UIScrollView *holderView;
}
@end

@implementation ProductCommentDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    self.hidesBottomBarWhenPushed = YES;

    NSString *nickname = [self.comment objectForKey:@"nickname"];
    int naipao = [[self.comment objectForKey:@"naipao"] intValue];
    int xiangqi = [[self.comment objectForKey:@"xiangqi"] intValue];
    int ziwei = [[self.comment objectForKey:@"ziwei"] intValue];
    int yexing = [[self.comment objectForKey:@"yexing"] intValue];
    NSString *title = [self.comment objectForKey:@"title"];
//    NSString *itemTitle = [self.comment objectForKey:@"item_title"];
    NSString *thumb = [self.comment objectForKey:@"thumb"];
    NSString *createTime = [self.comment objectForKey:@"create_time"];
    NSString *content = [self.comment objectForKey:@"content"];
    NSString *images = [self.comment objectForKey:@"images"];
    
    holderView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    holderView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:holderView];
    
    CGFloat x = 20, y = 20;
    
    //用户头像
    UIImage *image = [UIImage imageNamed:@"user_icon"];
    UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 30, 30)];
    if ([thumb isEqualToString:@""] || thumb == nil) {
        [userIconView setImage:image];
    }else{
        [userIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,thumb]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
    }
    [holderView addSubview:userIconView];
    
    //用户名
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+40, y, 100, 15)];
    usernameLabel.textColor = [UIColor blackColor];
    usernameLabel.font = [UIFont systemFontOfSize:13];
    usernameLabel.text = [NSString stringWithFormat:@"%@",nickname];
    [holderView addSubview:usernameLabel];
    
    //回复时间
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+40, y+20, 100, 10)];
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.text = [createTime substringWithRange:NSMakeRange(5, 14)];
    [holderView addSubview:timeLabel];
    
    y += 40;
    
    y += 2;
    //分割线
    UIImage *lineImage1 = [UIImage imageNamed:@"grey_space_line"];
    UIImageView *lineIV1 = [[UIImageView alloc] initWithImage:lineImage1];
    lineIV1.frame = CGRectMake(x, y, holderView.frame.size.width - 2*x, lineImage1.size.height);
    [holderView addSubview:lineIV1];
    y += 2;
    
    //标题
    CGFloat titleHeight = [Utils heightForString:title withWidth:(holderView.frame.size.width - 2*x) withFont:17];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,(holderView.frame.size.width - 2*x) , titleHeight)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.text = title;
    [holderView addSubview:titleLabel];
    
    y += titleHeight;
    
    //内容
    CGFloat contentHeight = [Utils heightForString:content withWidth:(holderView.frame.size.width - 2*x) withFont:16];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,(holderView.frame.size.width - 2*x) , contentHeight)];
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.font = [UIFont systemFontOfSize:16];
    contentLabel.text = content;
    [holderView addSubview:contentLabel];
    
    y += contentHeight;
    
    CGFloat ImageViewHeight = 80;
    //图片区域
    if (![images isEqualToString:@""] && images != nil) {
        UIScrollView *imagesView = [[UIScrollView alloc] initWithFrame:CGRectMake(20,y,280, ImageViewHeight)];
        imagesView.backgroundColor = [UIColor clearColor];
        imagesView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        [imagesView addGestureRecognizer:tap];
        
        [holderView addSubview:imagesView];
        
        CGFloat imagesViewx = 0;
        for (NSString *name in [images componentsSeparatedByString:@","]) {
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@.thumb.jpg",upload_image_root_url,name];
            UIImageView *iv = [[UIImageView alloc] init];
            [iv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_loading"]];
            iv.contentMode = UIViewContentModeScaleAspectFit;
            [iv setFrame:CGRectMake(imagesViewx, 0, ImageViewHeight, ImageViewHeight)];
            [imagesView addSubview:iv];
            imagesViewx += 100;
        }
        imagesView.contentSize = CGSizeMake(imagesViewx, ImageViewHeight);
        y += 80;
    }
    
    y += 10;
    
    UIImage *like = [UIImage imageNamed:@"like_yes"];
    UIImage *unlike = [UIImage imageNamed:@"like_no"];
    
    //香气
    UILabel *xiangqiLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 50, 20)];
    xiangqiLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    xiangqiLabel.font = [UIFont systemFontOfSize:15];
    xiangqiLabel.text = @"香气";
    [holderView addSubview:xiangqiLabel];
    
    //评分图
    
    CGFloat pointx = xiangqiLabel.frame.origin.x + xiangqiLabel.frame.size.width;
    for (int i=1; i<6; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(pointx, y, 20, 20)];
        if (xiangqi >= i) {
            iv.image = like;
        }else{
            iv.image = unlike;
        }
        [holderView addSubview:iv];
        
        pointx += 20;
    }
    
    y += 20;
    
    //滋味
    UILabel *ziweiLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 50, 20)];
    ziweiLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    ziweiLabel.font = [UIFont systemFontOfSize:15];
    ziweiLabel.text = @"滋味";
    [holderView addSubview:ziweiLabel];
    
    //评分图
    
    pointx = ziweiLabel.frame.origin.x + ziweiLabel.frame.size.width;
    for (int i=1; i<6; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(pointx, y, 20, 20)];
        if (ziwei >= i) {
            iv.image = like;
        }else{
            iv.image = unlike;
        }
        [holderView addSubview:iv];
        
        pointx += 20;
    }
    
    y += 20;
    
    //耐泡度
    UILabel *naipaoLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 50, 20)];
    naipaoLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    naipaoLabel.font = [UIFont systemFontOfSize:15];
    naipaoLabel.text = @"耐泡度";
    [holderView addSubview:naipaoLabel];
    
    //评分图
    
    pointx = naipaoLabel.frame.origin.x + naipaoLabel.frame.size.width;
    for (int i=1; i<6; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(pointx, y, 20, 20)];
        if (naipao >= i) {
            iv.image = like;
        }else{
            iv.image = unlike;
        }
        [holderView addSubview:iv];
        
        pointx += 20;
    }
    
    y += 20;
    
    //叶形
    UILabel *yexingLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 50, 20)];
    yexingLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    yexingLabel.font = [UIFont systemFontOfSize:15];
    yexingLabel.text = @"叶形";
    [holderView addSubview:yexingLabel];
    
    //评分图
    
    pointx = yexingLabel.frame.origin.x + yexingLabel.frame.size.width;
    for (int i=1; i<6; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(pointx, y, 20, 20)];
        if (yexing >= i) {
            iv.image = like;
        }else{
            iv.image = unlike;
        }
        [holderView addSubview:iv];
        
        pointx += 20;
    }
    
    y += 20;
    
    y += 2;
    //分割线
     UIImage *lineImage2 = [UIImage imageNamed:@"grey_space_line"];
    UIImageView *lineIV2 = [[UIImageView alloc] initWithImage:lineImage2];
    lineIV2.frame = CGRectMake(x, y, holderView.frame.size.width - 2*x, lineImage2.size.height);
    [holderView addSubview:lineIV2];
    y += 2;
    
    holderView.contentSize = CGSizeMake(holderView.frame.size.width, y);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleTapAction:(UITapGestureRecognizer *)tap
{
    NSString *images = [self.comment objectForKey:@"images"];
    if (![images isEqualToString:@""] && images != nil) {
        NSMutableArray *photos = [NSMutableArray array];
        for (NSString *name in [images componentsSeparatedByString:@","]) {
            IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,name]]];
            [photos addObject:photo];
        }
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
        browser.displayActionButton = YES;
        browser.displayArrowButton = YES;
        browser.displayCounterLabel = YES;
        [self presentViewController:browser animated:YES completion:nil];
    }
}
@end
