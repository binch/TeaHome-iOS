//
//  ProductsCommentsViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-14.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "ProductsCommentsViewController.h"
#import "ProductCommentDetailViewController.h"
#import "SimpleUserinfoViewController.h"

#define get_item_comments_cmd @"get_item_comments"

@interface ProductsCommentsViewController ()

@end

@implementation ProductsCommentsViewController

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

    self.title = @"评价列表";
    
    self.comments = [NSMutableArray array];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&item=%d",CMD_URL,get_item_comments_cmd,self.pid];
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
               self.comments = [NSArray arrayWithArray:jsonObj];
               [self.tableView reloadData];
           }else{
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
           }
       }
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.comments count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //商品评价
    NSDictionary *comment = [self.comments objectAtIndex:indexPath.row];
    NSString *nickname = [comment objectForKey:@"nickname"];
    int naipao = [[comment objectForKey:@"naipao"] intValue];
    int xiangqi = [[comment objectForKey:@"xiangqi"] intValue];
    int ziwei = [[comment objectForKey:@"ziwei"] intValue];
    int yexing = [[comment objectForKey:@"yexing"] intValue];
    NSString *title = [comment objectForKey:@"title"];
    NSString *itemTitle = [comment objectForKey:@"item_title"];
    NSString *thumb = [comment objectForKey:@"thumb"];
    NSString *createTime = [comment objectForKey:@"create_time"];
    CGFloat x = 20, y = 20;
    
    //用户头像
    UIImage *image = [UIImage imageNamed:@"user_icon"];
    UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 30, 30)];
    if ([thumb isEqualToString:@""] || thumb == nil) {
        [userIconView setImage:image];
    }else{
        [userIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.thumb.jpg",upload_image_root_url,thumb]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
    }
    
    userIconView.userInteractionEnabled = YES;
    userIconView.tag = indexPath.row;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconAction:)];
    [userIconView addGestureRecognizer:tap];
    
    [cell addSubview:userIconView];
    
    //用户名
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+40, y, 100, 15)];
    usernameLabel.textColor = [UIColor blackColor];
    usernameLabel.font = [UIFont systemFontOfSize:13];
    usernameLabel.text = [NSString stringWithFormat:@"%@",nickname];
    [cell addSubview:usernameLabel];
    
    //回复时间
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+40, y+20, 100, 10)];
    timeLabel.textColor = [UIColor lightGrayColor];
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.text = [createTime substringWithRange:NSMakeRange(5, 14)];
    [cell addSubview:timeLabel];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 140, 15)];
    titleLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    titleLabel.textAlignment = NSTextAlignmentRight;
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.text = [NSString stringWithFormat:@"%@(%@)",title,itemTitle];
    [cell addSubview:titleLabel];
    
    //评分
    UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y+20, 70, 10)];
    pointLabel.textColor = [UIColor lightGrayColor];
    pointLabel.textAlignment = NSTextAlignmentRight;
    pointLabel.font = [UIFont systemFontOfSize:10];
    pointLabel.text = @"综合评分";
    [cell addSubview:pointLabel];
    
    x = 230;
    y += 20;
    //评分图
    int currentPoint =  naipao + xiangqi + ziwei + yexing;
    UIImage *like = [UIImage imageNamed:@"like_yes"];
    UIImage *unlike = [UIImage imageNamed:@"like_no"];
    
    for (int i=1; i<6; i++) {
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 10, 10)];
        if (currentPoint >= i*4) {
            iv.image = like;
        }else{
            iv.image = unlike;
        }
        [cell addSubview:iv];
        
        x += 10;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProductCommentDetailViewController *pcdvc = [[ProductCommentDetailViewController alloc] init];
    pcdvc.comment = [self.comments objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:pcdvc animated:YES];
}

#pragma mark -- 点击头像查看个人详情
-(void)userIconAction:(UITapGestureRecognizer *)tap
{
    int tag = tap.view.tag;
    NSString *username = nil;
    //答复区
    NSDictionary *dic = [self.comments objectAtIndex:tag];
    username = [dic objectForKey:@"username"];

    SimpleUserinfoViewController *suvc = [[SimpleUserinfoViewController alloc] init];
    suvc.username = username;
    [self.navigationController pushViewController:suvc animated:YES];
}

@end
