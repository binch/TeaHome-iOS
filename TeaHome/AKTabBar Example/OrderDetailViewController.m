//
//  OrderDetailViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "PostProductEvaluateViewController.h"

#define get_order_cmd @"get_order"

@interface OrderDetailViewController ()

@end

@implementation OrderDetailViewController

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

    self.view.backgroundColor = [Utils hexStringToColor:view_back_color];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"订单详情";
    
    if (self.order == nil) {
        if (TeaHomeAppDelegate.networkIsReachable == NO) {
            [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
            return;
        }
        //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        NSString *urlStr = [NSString stringWithFormat:@"%@%@&order=%d",CMD_URL,get_order_cmd,self.orderId];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
        [NSURLConnection sendAsynchronousRequest:request
                   queue:[NSOperationQueue mainQueue]
       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
           //                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
           if (data != nil) {
               NSError *error;
               id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
               if (jsonObj != nil) {
                   self.order = (NSDictionary *)jsonObj;
                   [self initOrderDetailView];
               }else{
                   [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
               }
           }
       }];
    }else{
        [self initOrderDetailView];
    }
    
//    if (self.order == nil) {
//        NSString *url = [NSString stringWithFormat:@"%@%@&order=%d",CMD_URL,get_order_cmd,self.orderId];
//        id json = [Utils getJsonDataFromWeb:url];
//        if (json != nil) {
//            self.order = (NSDictionary *)json;
//        }else{
//            [Utils showAlertViewWithMessage:@"网络连接出错,请稍后再试."];
//            return;
//        }
//    }
    
 
}

-(void)initOrderDetailView
{
    if ([[self.order objectForKey:@"pay"] isEqualToString:@"alipay"] &&
        [[self.order objectForKey:@"status"] isEqualToString:order_status_new]) {
        //支付宝新建订单
        UIBarButtonItem *payItem = [[UIBarButtonItem alloc] initWithTitle:@"支付" style:UIBarButtonItemStyleBordered target:self action:@selector(payAction:)];
        self.navigationItem.rightBarButtonItem = payItem;
    }
    
    NSString *orderno = [self.order objectForKey:@"id"];;
    NSString *status = nil;
    if ([[self.order objectForKey:@"status"] isEqualToString:order_status_new]) {
        status = @"新建";
    }else if ([[self.order objectForKey:@"status"] isEqualToString:order_status_paid]) {
        status = @"已付款";
    }else if ([[self.order objectForKey:@"status"] isEqualToString:order_status_shipped]) {
        status = @"已发货";
    }else if ([[self.order objectForKey:@"status"] isEqualToString:order_status_completed]) {
        status = @"已完成";
    }else if ([[self.order objectForKey:@"status"] isEqualToString:order_status_cancelled]) {
        status = @"已取消";
    }
    NSString *create_time = [self.order objectForKey:@"create_time"];
    float total = [[self.order objectForKey:@"total"] floatValue];
    NSArray *products = [self.order objectForKey:@"items"];
    NSString *payMethod = [self.order objectForKey:@"pay"];
    NSString *contact = [self.order objectForKey:@"contact"];
    NSString *addr = [self.order objectForKey:@"addr"];
    NSString *phone = [self.order objectForKey:@"phone"];
    
    CGFloat x=10,y = 10;
    CGFloat holderWidth = 280,labelHeight = 15;
    CGFloat leftTitleLabelWidth = 60;
    
    UIScrollView *holderView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 10, holderWidth, self.view.bounds.size.height - 135)];
    holderView.backgroundColor = [UIColor whiteColor];
    holderView.layer.borderWidth = 0.5;
    holderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    holderView.layer.cornerRadius = 5;
    
    //订单编号
    UILabel *onLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    onLabel.font = [UIFont systemFontOfSize:12];
    onLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    onLabel.text = @"订单编号:";
    [holderView addSubview:onLabel];
    
    UILabel *orderNoLabel = [[UILabel alloc] initWithFrame:CGRectMake( x*2 +leftTitleLabelWidth,y, holderWidth - 3*x - leftTitleLabelWidth, labelHeight)];
    orderNoLabel.font = [UIFont systemFontOfSize:12];
    orderNoLabel.textColor = [UIColor lightGrayColor];
    orderNoLabel.text = [NSString stringWithFormat:@"5917368 %@",orderno];
    [holderView addSubview:orderNoLabel];
    
    y += labelHeight;
    
    //订单状态
    UILabel *stLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    stLabel.font = [UIFont systemFontOfSize:12];
    stLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    stLabel.text = @"订单状态:";
    [holderView addSubview:stLabel];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake( x*2 +leftTitleLabelWidth, y,holderWidth - 3*x - leftTitleLabelWidth, labelHeight)];
    statusLabel.font = [UIFont systemFontOfSize:12];
    statusLabel.textColor = [UIColor lightGrayColor];
    statusLabel.text = status;
    [holderView addSubview:statusLabel];
    
    y += labelHeight;
    
    //订单总额
    UILabel *ttLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    ttLabel.font = [UIFont systemFontOfSize:12];
    ttLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    ttLabel.text = @"订单总额:";
    [holderView addSubview:ttLabel];
    
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake( x*2 +leftTitleLabelWidth, y,holderWidth - 3*x - leftTitleLabelWidth, labelHeight)];
    totalLabel.font = [UIFont systemFontOfSize:12];
    totalLabel.textColor = [UIColor lightGrayColor];
    totalLabel.text = [NSString stringWithFormat:@"%.1f元",total];
    [holderView addSubview:totalLabel];
    
    y += labelHeight;
    
    //订单时间
    UILabel *cttLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    cttLabel.font = [UIFont systemFontOfSize:12];
    cttLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    cttLabel.text = @"下单时间:";
    [holderView addSubview:cttLabel];
    
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake( x*2 +leftTitleLabelWidth, y,holderWidth - 3*x - leftTitleLabelWidth, labelHeight)];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.text = [create_time substringWithRange:NSMakeRange(0, 19)];
    [holderView addSubview:timeLabel];
    
    y += labelHeight;
    
    y += 2;
    //分割线
    UIImage *line1 = [UIImage imageNamed:@"grey_space_line"];
    UIImageView *line1View = [[UIImageView alloc] initWithImage:line1];
    line1View.frame = CGRectMake(x, y, holderWidth-2*x, line1.size.height);
    [holderView addSubview:line1View];
    y += 2;
    
    //支付方式
    UILabel *pmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    pmtLabel.font = [UIFont systemFontOfSize:12];
    pmtLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    pmtLabel.text = @"支付方式:";
    [holderView addSubview:pmtLabel];
    
    UILabel *payMethodLabel = [[UILabel alloc] initWithFrame:CGRectMake( x*2 +leftTitleLabelWidth, y,holderWidth - 3*x - leftTitleLabelWidth, labelHeight)];
    payMethodLabel.font = [UIFont systemFontOfSize:12];
    payMethodLabel.textColor = [UIColor lightGrayColor];
    payMethodLabel.text = payMethod ;
    [holderView addSubview:payMethodLabel];
    
    y += labelHeight;
    
    y += 2;
    //分割线
    UIImage *line2 = [UIImage imageNamed:@"grey_space_line"];
    UIImageView *line2View = [[UIImageView alloc] initWithImage:line2];
    line2View.frame = CGRectMake(x, y, holderWidth-2*x, line2.size.height);
    [holderView addSubview:line2View];
    y += 2;
    
    //收件人
    UILabel *ctLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    ctLabel.font = [UIFont systemFontOfSize:12];
    ctLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    ctLabel.text = @"收 件 人:";
    [holderView addSubview:ctLabel];
    
    UILabel *contactLabel = [[UILabel alloc] initWithFrame:CGRectMake( x*2 +leftTitleLabelWidth, y,holderWidth - 3*x - leftTitleLabelWidth, labelHeight)];
    contactLabel.font = [UIFont systemFontOfSize:12];
    contactLabel.textColor = [UIColor lightGrayColor];
    contactLabel.text = contact ;
    [holderView addSubview:contactLabel];
    
    y += labelHeight;
    
    //地址
    UILabel *atLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    atLabel.font = [UIFont systemFontOfSize:12];
    atLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    atLabel.text = @"收件地址:";
    [holderView addSubview:atLabel];
    
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:12]};
    CGSize strSize = [addr boundingRectWithSize:
                      CGSizeMake(holderWidth - 3*x - leftTitleLabelWidth, 0)
                                        options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                     attributes:dic
                                        context:nil].size;
    CGFloat addrLabelHeight = strSize.height;
    if (addrLabelHeight > labelHeight) {
        addrLabelHeight = 2*labelHeight;
    }else{
        addrLabelHeight = labelHeight;
    }
    UILabel *addrLabel = [[UILabel alloc] initWithFrame:CGRectMake( x*2 +leftTitleLabelWidth, y,holderWidth - 3*x - leftTitleLabelWidth, addrLabelHeight)];
    addrLabel.font = [UIFont systemFontOfSize:12];
    addrLabel.textColor = [UIColor lightGrayColor];
    addrLabel.text = addr ;
    [holderView addSubview:addrLabel];
    
    y += addrLabelHeight;
    
    //电话
    UILabel *phonetLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    phonetLabel.font = [UIFont systemFontOfSize:12];
    phonetLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    phonetLabel.text = @"联系电话:";
    [holderView addSubview:phonetLabel];
    
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake( x*2 +leftTitleLabelWidth, y,holderWidth - 3*x - leftTitleLabelWidth, labelHeight)];
    phoneLabel.font = [UIFont systemFontOfSize:12];
    phoneLabel.textColor = [UIColor lightGrayColor];
    phoneLabel.text = phone ;
    [holderView addSubview:phoneLabel];
    
    y += labelHeight;
    
    y += 2;
    //分割线
    UIImage *line3 = [UIImage imageNamed:@"grey_space_line"];
    UIImageView *line3View = [[UIImageView alloc] initWithImage:line3];
    line3View.frame = CGRectMake(x, y, holderWidth-2*x, line2.size.height);
    [holderView addSubview:line3View];
    y += 2;
    
    //订购商品
    UILabel *ptLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    ptLabel.font = [UIFont systemFontOfSize:12];
    ptLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    ptLabel.text = @"订购商品:";
    [holderView addSubview:ptLabel];
    
    y += labelHeight + 5;
    
    for (NSDictionary *product in products) {
        
        int count = [[product objectForKey:@"count"] intValue];
        NSString *title = [product objectForKey:@"title"];
        int pid = [[product objectForKey:@"id"] intValue];
        float price = [[product objectForKey:@"price"] floatValue];
        
        //        UIView *itemView = [[UIView alloc] initWithFrame:CGRectMake(x, y, holderWidth - 2*x, leftTitleLabelWidth)];
        //        itemView.backgroundColor = [UIColor clearColor];
        //        itemView.tag = pid;
        //
        //        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        //        [itemView addGestureRecognizer:tap];
        //
        //        [holderView addSubview:itemView];
        //
        
        UIImageView *pIV = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, leftTitleLabelWidth, leftTitleLabelWidth)];
        NSString *product_image_url = [NSString stringWithFormat:@"%@%d.jpg",product_image_root_url,pid];
        NSURL *url = [NSURL URLWithString:product_image_url];
        [pIV sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
        [holderView addSubview:pIV];
        
        UIImage *productCommentsImage = [UIImage imageNamed:@"product_comments"];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x*2 +leftTitleLabelWidth, y + 5, holderWidth - 3*x - leftTitleLabelWidth -  productCommentsImage.size.width, 20)];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.textColor = [UIColor lightGrayColor];
        titleLabel.text = title;
        [holderView addSubview:titleLabel];
        
        
        UIButton *commentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        commentBtn.tag = pid;
        commentBtn.frame = CGRectMake(holderWidth - x - productCommentsImage.size.width, y + 5, productCommentsImage.size.width, productCommentsImage.size.height);
        [commentBtn setBackgroundImage:productCommentsImage forState:UIControlStateNormal];
        [commentBtn addTarget:self action:@selector(productCommentAction:) forControlEvents:UIControlEventTouchUpInside];
        [holderView addSubview:commentBtn];
        
        UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(x*2 +leftTitleLabelWidth, y+30,(holderWidth - 3*x - leftTitleLabelWidth) / 2, 20)];
        countLabel.font = [UIFont systemFontOfSize:12];
        countLabel.textColor = [UIColor lightGrayColor];
        countLabel.text = [NSString stringWithFormat:@"数量: %d份",count];
        [holderView addSubview:countLabel];
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(countLabel.frame.origin.x + countLabel.frame.size.width, y+30, (holderWidth - 3*x - leftTitleLabelWidth) / 2, 20)];
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.textAlignment = NSTextAlignmentRight;
        priceLabel.textColor = [UIColor lightGrayColor];
        priceLabel.text = [NSString stringWithFormat:@"金额: %.1f元",price*count];
        [holderView addSubview:priceLabel];
        
        y += leftTitleLabelWidth + 5;
    }
    
    CGRect r = holderView.frame;
    if (y < r.size.height) {
        r.size.height = y;
        holderView.frame = r;
    }
    holderView.contentSize = CGSizeMake(holderWidth, y);
    
    [self.view addSubview:holderView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)productCommentAction:(UIButton *)sender
{
    PostProductEvaluateViewController *ppevc = [[PostProductEvaluateViewController alloc] init];
    ppevc.pid = sender.tag;
    [self.navigationController pushViewController:ppevc animated:YES];
}

@end
