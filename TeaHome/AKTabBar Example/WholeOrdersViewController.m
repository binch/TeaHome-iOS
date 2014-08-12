//
//  WholeOrdersViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "WholeOrdersViewController.h"
#import "OrderDetailViewController.h"


#define get_user_orders_cmd @"get_user_orders"
@interface WholeOrdersViewController ()

@end

@implementation WholeOrdersViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [Utils hexStringToColor:view_back_color];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.orders = [NSArray array];
    
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&username=%@",CMD_URL,get_user_orders_cmd,TeaHomeAppDelegate.username];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       if (data != nil) {
           NSError *error;
           id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (jsonObj != nil) {
               NSArray *orders = [jsonObj objectForKey:@"orders"];
               self.orders = [NSArray arrayWithArray:orders];
               [self.tableView reloadData];
           }else{
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
           }
       }
   }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.orders count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *order = [self.orders objectAtIndex:indexPath.row];
    NSArray *products = [order objectForKey:@"items"];
    if ([products count]<=0) {
        return 60+24+15+20+15;
    }
    return 60+24+15*[products count]+20+15;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"my_cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *order = [self.orders objectAtIndex:indexPath.row];
    NSString *orderno = @"123123123123";//TODO
    NSString *status = nil;
    if ([[order objectForKey:@"status"] isEqualToString:order_status_new]) {
        status = @"新建";
    }else if ([[order objectForKey:@"status"] isEqualToString:order_status_paid]) {
        status = @"已付款";
    }else if ([[order objectForKey:@"status"] isEqualToString:order_status_shipped]) {
        status = @"已发货";
    }else if ([[order objectForKey:@"status"] isEqualToString:order_status_completed]) {
        status = @"已完成";
    }else if ([[order objectForKey:@"status"] isEqualToString:order_status_cancelled]) {
        status = @"已取消";
    }
    NSString *create_time = [order objectForKey:@"create_time"];
    float total = [[order objectForKey:@"total"] floatValue];
    NSArray *products = [order objectForKey:@"items"];
    
    CGFloat x=10,y = 10;
    CGFloat holderWidth = 280,labelHeight = 15;
    CGFloat leftTitleLabelWidth = 60;
    
    UIView *holderView = [[UIView alloc] init];
    if ([products count] <= 0) {
        holderView.frame = CGRectMake(20, 10, holderWidth, 60+24+15+15);
    }else{
        holderView.frame = CGRectMake(20, 10, holderWidth, 60+24+15*[products count]+15);
    }
    
    holderView.backgroundColor = [UIColor whiteColor];
    holderView.layer.borderWidth = 0.5;
    holderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    holderView.layer.cornerRadius = 5;
    [cell addSubview:holderView];
    
    
    //订单编号
    UILabel *onLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    onLabel.font = [UIFont systemFontOfSize:12];
    onLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    onLabel.text = @"订单编号:";
    [holderView addSubview:onLabel];
    
    UILabel *orderNoLabel = [[UILabel alloc] initWithFrame:CGRectMake( x*2 +leftTitleLabelWidth,y, holderWidth - 3*x - leftTitleLabelWidth, labelHeight)];
    orderNoLabel.font = [UIFont systemFontOfSize:12];
    orderNoLabel.textColor = [UIColor lightGrayColor];
    orderNoLabel.text = [NSString stringWithFormat:@"%@",orderno];
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
    
    //订购商品
    UILabel *ptLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    ptLabel.font = [UIFont systemFontOfSize:12];
    ptLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    ptLabel.text = @"订购商品:";
    [holderView addSubview:ptLabel];
    
    if ([products count] <= 0) {
        y += labelHeight;
    }else{
        for (NSDictionary *product in products) {
            int count = [[product objectForKey:@"count"] intValue];
            NSString *title = [product objectForKey:@"title"];
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x*2 +leftTitleLabelWidth, y, holderWidth - 3*x - leftTitleLabelWidth-40, labelHeight)];
            titleLabel.font = [UIFont systemFontOfSize:12];
            titleLabel.textColor = [UIColor lightGrayColor];
            titleLabel.text = title;
            [holderView addSubview:titleLabel];
            
            UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(holderWidth - 50, y, holderWidth - 3*x - leftTitleLabelWidth-40, labelHeight)];
            countLabel.font = [UIFont systemFontOfSize:12];
            countLabel.textColor = [UIColor lightGrayColor];
            countLabel.text = [NSString stringWithFormat:@"%d份",count];
            [holderView addSubview:countLabel];
            
            y += labelHeight;
        }

    }
    
    UIImage *addImage = [UIImage imageNamed:@"product_check_bill"];
    UIImageView *addIv = [[UIImageView alloc] initWithImage:addImage];
    addIv.frame = CGRectMake(x, y, addImage.size.width, addImage.size.height);
    [holderView addSubview:addIv];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *order = [self.orders objectAtIndex:indexPath.row];
    
    OrderDetailViewController *ovc = [[OrderDetailViewController alloc] init];
    ovc.order = order;
    [self.navigationController pushViewController:ovc animated:YES];
    
}@end
