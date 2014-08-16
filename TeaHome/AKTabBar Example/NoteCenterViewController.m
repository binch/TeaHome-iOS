//
//  NoteCenterViewController.m
//  TeaHome
//
//  Created by andylee on 14-6-28.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "NoteCenterViewController.h"
#import "ThreadReplysViewController.h"
#import "AnswersViewController.h"

#define mark_read_atmessage_cmd @"mark_read_atmessage"

@interface NoteCenterViewController ()

@end

@implementation NoteCenterViewController

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
    
    self.seg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"未读",@"已读", nil]];
    self.seg.frame = CGRectMake(0, 0, 160, 30);
    [self.seg addTarget:self action:@selector(handleSegmentControlEvent:) forControlEvents:UIControlEventValueChanged];
    [self.seg setSelectedSegmentIndex:0];
//    [self handleSegmentControlEvent:nil];
    self.navigationItem.titleView = self.seg;
   
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    [self.tableView headerBeginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSegmentControlEvent:) name:kRefreshNoteCenterViewNotification object:nil];
}

-(void)handleSegmentControlEvent:(id)sender
{
    [self.tableView headerBeginRefreshing];
}

-(void)headerRereshing
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        return;
    }
    if (![TeaHomeAppDelegate.username isEqualToString:@""]) {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@&username=%@",CMD_URL,get_user_atmessages_cmd,TeaHomeAppDelegate.username];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
        [NSURLConnection sendAsynchronousRequest:request
                   queue:[NSOperationQueue mainQueue]
       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
           if (data != nil) {
               NSError *error;
               id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
               if (json != nil) {
                   NSArray *messages = [json objectForKey:@"atmessages"];
                   TeaHomeAppDelegate.atMessages = [NSArray arrayWithArray:messages];
                   if ([TeaHomeAppDelegate.atMessages count] > 0) {
                       TeaHomeAppDelegate.unreadMessages = [NSMutableArray array];
                       TeaHomeAppDelegate.readMessages = [NSMutableArray array];
                       for (NSDictionary *message in TeaHomeAppDelegate.atMessages) {
                           NSString *readStatus = [message objectForKey:@"read"];
                           if ([readStatus isEqualToString:message_status_unread]) {
                               [TeaHomeAppDelegate.unreadMessages addObject:message];
                           }else{
                               [TeaHomeAppDelegate.readMessages addObject:message];
                           }
                       }
                       [self.tableView reloadData];
                       [self.tableView headerEndRefreshing];
                       [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[TeaHomeAppDelegate.unreadMessages count]];
                       [TeaHomeAppDelegate setItemBageNumberView];
                   }
               }
           }
       }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark -- table view delegate methods
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"My-cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *message = nil;
    if (self.seg.selectedSegmentIndex == 0) {
        message = TeaHomeAppDelegate.unreadMessages[indexPath.row];
    }else{
        message = TeaHomeAppDelegate.readMessages[indexPath.row];
        
    }
    
    NSString *text = [message objectForKey:@"text"];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.text = text;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *message = nil;
    if (self.seg.selectedSegmentIndex == 0) {
        message = TeaHomeAppDelegate.unreadMessages[indexPath.row];
    }else{
        message = TeaHomeAppDelegate.readMessages[indexPath.row];
    }
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:[TeaHomeAppDelegate.unreadMessages count]];
    NSString *type = [message objectForKey:@"type"];
    int messageId = [[message objectForKey:@"id"] intValue];
    int from_id = [[message objectForKey:@"from_id"] intValue];
    
    if ([type isEqualToString:@"forum"]) {
        ThreadReplysViewController *tcvc = [[ThreadReplysViewController alloc] init];
        tcvc.tid = from_id;
        [self.navigationController pushViewController:tcvc animated:YES];
    }else if([type isEqualToString:@"qa"]){
        AnswersViewController *avc = [[AnswersViewController alloc] init];
        avc.qid = from_id;
        [self.navigationController pushViewController:avc animated:YES];
    }
    
    
    if (self.seg.selectedSegmentIndex == 0) {
        NSString *urlStr = [NSString stringWithFormat:@"%@%@&atmessage=%d&username=%@",CMD_URL,mark_read_atmessage_cmd,messageId,TeaHomeAppDelegate.username];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
        [NSURLConnection sendAsynchronousRequest:request
                       queue:[NSOperationQueue mainQueue]
           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
               if (data != nil) {
                   NSError *error;
                   id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                   if (json != nil) {
                       if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
                           [[NSNotificationCenter defaultCenter] postNotificationName:kReadAtmessageNotification object:message];
                       }
                   }else{
                       [Utils showAlertViewWithMessage:@"网络连接出错,请稍后再试."];
                   }
               }
           }];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.seg.selectedSegmentIndex == 0) {
        return [TeaHomeAppDelegate.unreadMessages count];
    }
    return [TeaHomeAppDelegate.readMessages count];
}
@end
