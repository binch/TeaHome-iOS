//
//  BoardsViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-10.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "BoardsViewController.h"
#import "ThreadsViewController.h"

#define get_boards_cmd @"get_boards"

@interface BoardsViewController ()

@end

@implementation BoardsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"社区";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"coumunity_icon";
}

- (NSString *)tabTitle
{
	return self.title;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    [self.tableView headerBeginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self getBoardsFormWeb];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)headerRereshing
{
    [self getBoardsFormWeb];
}

-(void)getBoardsFormWeb
{
//    if (TeaHomeAppDelegate.networkIsReachable == NO) {
//        [self.tableView headerEndRefreshing];
//        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
//        return;
//    }
    //获取论坛板块
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
     NSString *urlStr = [NSString stringWithFormat:@"%@%@&username=%@",CMD_URL,get_boards_cmd,TeaHomeAppDelegate.username];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
                               if (data != nil) {
                                   NSError *error;
                                   id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   if (json != nil) {
                                       self.boards = [NSMutableArray arrayWithArray:json];
                                   }else{
                                       [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
                                   }
                                   [self.tableView reloadData];
                                   [self.tableView headerEndRefreshing];
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
    return [self.boards count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 106;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *board = [self.boards objectAtIndex:indexPath.row];
    NSString *name = [board objectForKey:@"name"];
//    int bid = [[board objectForKey:@"id"] intValue];
    NSString *desc = [board objectForKey:@"desc"];
    int total = [[board objectForKey:@"nr_thread"] intValue];
    int notread = [[board objectForKey:@"nr_unread_thread"] intValue];
    
    UIImage *titleImage = [UIImage imageNamed:@"forum_title"];
    UIImage *contentImage = [UIImage imageNamed:@"forum_content"];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, titleImage.size.width, titleImage.size.height)];
    titleLabel.backgroundColor = [UIColor colorWithPatternImage:titleImage];
    titleLabel.text = [NSString stringWithFormat:@"  %@",name];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    titleLabel.textColor = [UIColor whiteColor];
    [cell addSubview:titleLabel];

    UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y + titleLabel.frame.size.height, contentImage.size.width, 50)];
    holderView.backgroundColor = [UIColor colorWithPatternImage:contentImage];
    [cell addSubview:holderView];
    
    CGFloat descHeight = [Utils heightForString:desc withWidth:(holderView.frame.size.width - 30) withFont:14];
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, holderView.frame.size.width - 30, descHeight)];
    descLabel.numberOfLines = 0;
    descLabel.textColor = [UIColor lightGrayColor];
    descLabel.font = [UIFont systemFontOfSize:14];
    descLabel.text = desc;    
    [holderView addSubview:descLabel];
    
    NSMutableAttributedString *asString = [[NSMutableAttributedString alloc] initWithString:@""];
    NSAttributedString *totalString = [[NSAttributedString alloc] initWithString:
                                       [NSString stringWithFormat:@"共有%d条帖子",total] attributes:
                                       [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor lightGrayColor],NSForegroundColorAttributeName,nil]];
    [asString appendAttributedString:totalString];
    
    if (notread > 0) {
        NSAttributedString *unreadString = [[NSAttributedString alloc] initWithString:
                                        [NSString stringWithFormat:@"(%d条新帖子",notread] attributes:
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         [Utils hexStringToColor:navigation_bar_color],NSForegroundColorAttributeName,nil]];
        [asString appendAttributedString:unreadString];
    
        [asString appendAttributedString:[[NSAttributedString alloc] initWithString:@")" attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor lightGrayColor],NSForegroundColorAttributeName, nil]]];
    }
    
    UILabel *unreadLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, holderView.bounds.size.height - 20, holderView.frame.size.width - 30, 20)];
    unreadLabel.numberOfLines = 0;
    unreadLabel.textAlignment = NSTextAlignmentRight;
    unreadLabel.font = [UIFont systemFontOfSize:12];
    unreadLabel.attributedText = asString;
    
    [holderView addSubview:unreadLabel];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *board = [self.boards objectAtIndex:indexPath.row];
    NSString *name = [board objectForKey:@"name"];
    int bid = [[board objectForKey:@"id"] intValue];
    ThreadsViewController *tvc = [[ThreadsViewController alloc] init];
    tvc.type = 0; // board
    tvc.bid = bid;
    tvc.name = name;
    [self.navigationController pushViewController:tvc animated:YES];
}

@end
