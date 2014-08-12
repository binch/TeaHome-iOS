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
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
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
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.textColor = [UIColor greenColor];
    titleLabel.text = title;
    [holderView addSubview:titleLabel];
    y += 30;
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 15)];
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.numberOfLines = 0;
    categoryLabel.font = [UIFont systemFontOfSize:12];
    categoryLabel.textColor = [UIColor lightGrayColor];
    categoryLabel.text = @"[品种] : 乌龙茶";//TODO:
    [holderView addSubview:categoryLabel];
    y += 15+5;
    
    UILabel *produceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 15)];
    produceLabel.backgroundColor = [UIColor clearColor];
    produceLabel.numberOfLines = 0;
    produceLabel.font = [UIFont systemFontOfSize:12];
    produceLabel.textColor = [UIColor lightGrayColor];
    produceLabel.text = @"[产地] : 台湾";//TODO:
    [holderView addSubview:produceLabel];
    y += 15+10;
    
    UILabel *soldLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 15)];
    soldLabel.backgroundColor = [UIColor clearColor];
    soldLabel.numberOfLines = 0;
    soldLabel.textColor = [UIColor blackColor];
    soldLabel.font = [UIFont systemFontOfSize:12];
    soldLabel.text = [NSString stringWithFormat:@"销量: %d",sold];;
    [holderView addSubview:soldLabel];
    y += 20;
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 300-x, 15)];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.numberOfLines = 0;
    priceLabel.textColor = [UIColor blackColor];
    priceLabel.font = [UIFont systemFontOfSize:12];
    priceLabel.text = [NSString stringWithFormat:@"价格: %.1f元",price];
    [holderView addSubview:priceLabel];
    y+= 25;
    
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
