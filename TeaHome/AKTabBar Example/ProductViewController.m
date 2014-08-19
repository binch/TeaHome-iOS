//
//  ProductViewController.m
//  TeaHome
//
//  Created by andylee on 14-6-27.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "ProductViewController.h"
#import "CartItem.h"
#import "CartDetailViewController.h"
#import "ProductsCommentsViewController.h"
#import "PostProductEvaluateViewController.h"

#define share_product_url @"item/html/"

@interface ProductViewController ()

@end

@implementation ProductViewController

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
    
    self.tid = [[self.product objectForKey:@"id"] intValue];
    
    self.favor = [[self.product objectForKey:@"favor"] boolValue];
    self.likeCount = [[self.product objectForKey:@"like_count"] intValue];
    self.favorCount = [[self.product objectForKey:@"favor_count"] intValue];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hidesBottomBarWhenPushed = YES;
    
    UIScrollView *holderView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 51 - 64)];
    [self.view addSubview:holderView];

    NSString *title = [self.product objectForKey:@"title"];
    float price = [[self.product objectForKey:@"price"] floatValue];
    int productId = [[self.product objectForKey:@"id"] intValue];
    int sold = [[self.product objectForKey:@"sold"] intValue];
    NSString *content = [self.product objectForKey:@"content"];
    NSString *images = [self.product objectForKey:@"images"];
    self.title = title;
    
    CGFloat x=180,y = 0;
    
    y += 20;
    NSString *product_image_url = [NSString stringWithFormat:@"%@%d.jpg",product_image_root_url,productId];
    NSURL *url = [NSURL URLWithString:product_image_url];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, y, 140, 140)];
    imageView.backgroundColor = [UIColor clearColor];
    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
    [holderView addSubview:imageView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 50)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor blueColor];
    titleLabel.text = title;
    [holderView addSubview:titleLabel];
    y += 30;
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 15)];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.numberOfLines = 0;
    categoryLabel.font = [UIFont systemFontOfSize:12];
    categoryLabel.textColor = [UIColor lightGrayColor];
    categoryLabel.text = @"[品种] : 乌龙茶";//TODO:
    //[holderView addSubview:categoryLabel];
    y += 15+5;
    
    UILabel *produceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 15)];
    produceLabel.backgroundColor = [UIColor clearColor];
    produceLabel.numberOfLines = 0;
    produceLabel.font = [UIFont systemFontOfSize:12];
    produceLabel.textColor = [UIColor lightGrayColor];
    produceLabel.text = @"[产地] : 台湾";//TODO:
    //[holderView addSubview:produceLabel];
    y += 15+10;

    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 15)];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.numberOfLines = 0;
    priceLabel.textColor = [UIColor blackColor];
    priceLabel.font = [UIFont systemFontOfSize:12];
    priceLabel.text = [NSString stringWithFormat:@"价格: %.1f元",price];
    [holderView addSubview:priceLabel];
    y+= 20;
    
    UILabel *soldLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 15)];
    soldLabel.backgroundColor = [UIColor clearColor];
    soldLabel.numberOfLines = 0;
    soldLabel.textColor = [UIColor redColor];
    soldLabel.font = [UIFont systemFontOfSize:12];
    soldLabel.text = [NSString stringWithFormat:@"折后: %d",sold];;
    if (sold > 0) {
        [holderView addSubview:soldLabel];
    }
    y += 25;
    
    UIImage *productCommentsImage = [UIImage imageNamed:@"product_comments"];
    UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    commentBtn.frame = CGRectMake(x, y, productCommentsImage.size.width, productCommentsImage.size.height);
    [commentBtn setBackgroundImage:productCommentsImage forState:UIControlStateNormal];
    [commentBtn addTarget:self action:@selector(productCommentAction:) forControlEvents:UIControlEventTouchUpInside];
    [holderView addSubview:commentBtn];
    
    UIImage *addToCartImage = [UIImage imageNamed:@"product_addinchart_button"];
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(x + productCommentsImage.size.width + 5, y, addToCartImage.size.width, addToCartImage.size.height);
    [addBtn setBackgroundImage:addToCartImage forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addToCartAction:) forControlEvents:UIControlEventTouchUpInside];
    [holderView addSubview:addBtn];
    
    y += 30;
    
    UILabel *ctLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 280, 15)];
    ctLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    ctLabel.text = @"商品介绍:";
    [holderView addSubview:ctLabel];
    
    y += 15;
    
    NSString *contentStr = [NSString stringWithFormat:@"%@",content];
    CGFloat height = [Utils heightForString:contentStr withWidth:280 withFont:17];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, y, 280, height)];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = [UIColor lightGrayColor];
    contentLabel.text = contentStr;
    [holderView addSubview:contentLabel];
    
    y += height + 10;
    
//    NSRange range = [images rangeOfString:@","];
    if (![images isEqualToString:@""] && images != nil) {
        for (NSString *imageUrl in [images componentsSeparatedByString:@","]) {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(20, y, 280, 100)];
            [iv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_loading"]];
            [holderView addSubview:iv];
            y += 110;
        }
    }
    
    UIImage *checkCommentsImage = [UIImage imageNamed:@"product_check_comments"];
    UIButton *checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    checkBtn.frame = CGRectMake(160 - checkCommentsImage.size.width/2, y, checkCommentsImage.size.width, checkCommentsImage.size.height);
    [checkBtn setBackgroundImage:checkCommentsImage forState:UIControlStateNormal];
    [checkBtn addTarget:self action:@selector(checkCommentsAction:) forControlEvents:UIControlEventTouchUpInside];
    [holderView addSubview:checkBtn];
    
    y += checkCommentsImage.size.height;
    
    holderView.contentSize = CGSizeMake(holderView.bounds.size.width, y);
//    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithTitle:@"加入购物车" style:UIBarButtonItemStyleBordered target:self action:@selector(addToCartAction:)];
//    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithTitle:@"分享"
//                                                              style:UIBarButtonItemStyleBordered
//                                                             target:self
//                                                             action:@selector(shareAction:)];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:share, nil];
    UIImage *likeImage = [UIImage imageNamed:@"like_down"];
    self.likeView = [[UIImageView alloc] initWithFrame:CGRectMake(50, self.view.bounds.size.height - 100, 30, 30)];
    self.likeView.backgroundColor = [UIColor clearColor];
    self.likeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeTapAction:)];
    [self.likeView addGestureRecognizer:gesture];
    [self.likeView setImage:likeImage];
    [self.view addSubview:self.likeView];
    
    self.likeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, self.view.bounds.size.height - 100, 40, 30)];
    self.likeLabel.numberOfLines = 0;
    self.likeLabel.textAlignment = NSTextAlignmentRight;
    self.likeLabel.textColor = [UIColor grayColor];
    self.likeLabel.font = [UIFont systemFontOfSize:14];
    self.likeLabel.text = [NSString stringWithFormat:@"%d赞",[[self.product objectForKey:@"like_count"] intValue]];
    [self.view addSubview:self.likeLabel];
    
    UIImage *favImage = [UIImage imageNamed:@"like_no"];
    self.favView = [[UIImageView alloc] initWithFrame:CGRectMake(140, self.view.bounds.size.height - 100, 30, 30)];
    self.favView.backgroundColor = [UIColor clearColor];
    self.favView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFavTapAction:)];
    [self.favView addGestureRecognizer:gesture2];
    [self.favView setImage:favImage];
    [self.view addSubview:self.favView];
    
    self.favorLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, self.view.bounds.size.height - 100, 70, 30)];
    self.favorLabel.numberOfLines = 0;
    self.favorLabel.textAlignment = NSTextAlignmentRight;
    self.favorLabel.textColor = [UIColor grayColor];
    self.favorLabel.font = [UIFont systemFontOfSize:14];
    self.favorLabel.text = [NSString stringWithFormat:@"%d收藏",[[self.product objectForKey:@"favor_count"] intValue]];
    [self.view addSubview:self.favorLabel];
    
    self.favor = [[self.product objectForKey:@"favor"] boolValue];
    if (self.favor) {
        self.fav_state = true;
        UIImage *likeImage;
        likeImage = [UIImage imageNamed:@"like_yes"];
        [self.favView setImage:likeImage];
    } else {
        self.fav_state = false;
        UIImage *likeImage;
        likeImage = [UIImage imageNamed:@"like_no"];
        [self.favView setImage:likeImage];
    }
    
    self.like = [[self.product objectForKey:@"like"] boolValue];
    
    if (self.like) {
        self.like_state = true;
        UIImage *likeImage;
        likeImage = [UIImage imageNamed:@"like_up"];
        [self.likeView setImage:likeImage];
    } else {
        self.like_state = false;
        UIImage *likeImage;
        likeImage = [UIImage imageNamed:@"like_down"];
        [self.likeView setImage:likeImage];
    }


}

-(void)handleFavTapAction:(UITapGestureRecognizer *)gesture
{
    NSString *str;
    UIImage *favImage;
    if (self.fav_state == true) {
        favImage = [UIImage imageNamed:@"like_no"];
        self.fav_state = false;
        self.favorCount = self.favorCount - 1;
        self.favorLabel.text = [NSString stringWithFormat:@"%d收藏",self.favorCount];
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=item&id=%d",CMD_URL,@"unfavor",TeaHomeAppDelegate.username
               ,TeaHomeAppDelegate.password,self.tid];
    } else {
        favImage = [UIImage imageNamed:@"like_yes"];
        self.fav_state = true;
        self.favorCount = self.favorCount + 1;
        self.favorLabel.text = [NSString stringWithFormat:@"%d收藏",self.favorCount];
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=item&id=%d",CMD_URL,@"favor",TeaHomeAppDelegate.username
               ,TeaHomeAppDelegate.password,self.tid];
    }
    
    [self.favView setImage:favImage];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    //[self.postHUD show:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if ([[MBProgressHUD allHUDsForView:self.view] count] == 0) {
                                   return ;
                               }
                               //[self.postHUD hide:YES];
                               if (data != nil) {
                               }
                           }];
}

-(void)handleLikeTapAction:(UITapGestureRecognizer *)gesture
{
    NSString *str;
    UIImage *likeImage;
    if (self.like_state == true) {
        likeImage = [UIImage imageNamed:@"like_down"];
        self.like_state = false;
        self.likeCount = self.likeCount - 1;
        self.likeLabel.text = [NSString stringWithFormat:@"%d赞",self.likeCount];
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=item&id=%d",CMD_URL,@"unlike",TeaHomeAppDelegate.username
               ,TeaHomeAppDelegate.password,self.tid];
    } else {
        likeImage = [UIImage imageNamed:@"like_up"];
        self.like_state = true;
        self.likeCount = self.likeCount + 1;
        self.likeLabel.text = [NSString stringWithFormat:@"%d赞",self.likeCount];
        
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=item&id=%d",CMD_URL,@"like",TeaHomeAppDelegate.username
               ,TeaHomeAppDelegate.password,self.tid];
    }
    [self.likeView setImage:likeImage];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    //[self.postHUD show:YES];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if ([[MBProgressHUD allHUDsForView:self.view] count] == 0) {
                                   return ;
                               }
                               //[self.postHUD hide:YES];
                               if (data != nil) {
                               }
                           }];
    
}


-(void)checkCommentsAction:(UIButton *)btn
{
    ProductsCommentsViewController *pcvc = [[ProductsCommentsViewController alloc] init];
    pcvc.pid = [[self.product objectForKey:@"id"] intValue];
    [self.navigationController pushViewController:pcvc animated:YES];
}

-(void)shareAction:(UIBarButtonItem *)item
{
    NSString *url = [NSString stringWithFormat:@"%@%@%d",share_root_url,share_product_url,[[self.product objectForKey:@"id"] intValue]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addToCartAction:(UIButton *)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithFrame:self.view.bounds];
    [alert setTitle:@"选择购买数量"];
    [alert setDelegate: self];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    UITextField *tf = [alert textFieldAtIndex:0];
    tf.keyboardType = UIKeyboardTypeNumberPad;
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    [alert show];
}

-(void)productCommentAction:(UIButton *)sender
{
    PostProductEvaluateViewController *ppevc = [[PostProductEvaluateViewController alloc] init];
    ppevc.pid = [[self.product objectForKey:@"id"] intValue];
    [self.navigationController pushViewController:ppevc animated:YES];
}

#pragma mark - alert view delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UITextField *tf = [alertView textFieldAtIndex:0];
        int mount = [[tf text] intValue] > 0 ? [[tf text] intValue] : 1;
        CartItem *ci = [[CartItem alloc] init];
        ci.product = self.product;
        ci.mount = mount;
        int productId = [[self.product objectForKey:@"id"] intValue];
        
        NSData *oldCiData = [TeaHomeAppDelegate.cartsDic objectForKey:[NSString stringWithFormat:@"%d",productId]];
        if (oldCiData != nil) {
            CartItem *oldCI = [NSKeyedUnarchiver unarchiveObjectWithData:oldCiData];
            if (oldCI != nil) {
                ci.mount += oldCI.mount;
            }
        }
        
        
        NSData *ciData = [NSKeyedArchiver archivedDataWithRootObject:ci];
        [TeaHomeAppDelegate.cartsDic setObject:ciData forKey:[NSString stringWithFormat:@"%d",productId]];
       [Utils saveDataToUserDefaults:CartItems withValue:TeaHomeAppDelegate.cartsDic];
        
        [Utils showAlertViewWithMessage:@"加入成功."];
        
        CartDetailViewController *cvc = [[CartDetailViewController alloc] init];
        [self.navigationController pushViewController:cvc animated:YES];
    }
}
@end
