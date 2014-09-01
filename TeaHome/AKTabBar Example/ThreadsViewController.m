//
//  ThreadsViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-10.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "ThreadsViewController.h"
#import "LoginViewController.h"
#import "ThreadReplysViewController.h"
#import "PostThreadViewController.h"
#import "SimpleUserinfoViewController.h"

#define get_threads_cmd @"get_threads"

static int page = 1;

@interface ThreadsViewController ()
{
    BOOL pullDownRefresh;
    BOOL hasNewData ;
    BOOL dataErr;
}
@end

@implementation ThreadsViewController

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

    self.title = self.name;
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.hidesBottomBarWhenPushed = YES;
    
    pullDownRefresh = YES;
    hasNewData = YES;
    dataErr = NO;
    
    UIBarButtonItem *postThreadItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"submit_question"] style:UIBarButtonItemStyleBordered target:self action:@selector(postThreadAction:)];
    self.navigationItem.rightBarButtonItem = postThreadItem;
    
    self.threads = [NSMutableArray array];
    
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
     [self.tableView headerBeginRefreshing];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:kPostThreadSuccessNotification object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
}

-(void)handleNotification:(NSNotification *)note
{
    [self.tableView headerBeginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)postThreadAction:(id)sender
{
    if ([TeaHomeAppDelegate.username isEqualToString:@""]) {
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:lvc animated:YES];
        return;
    }
    
    PostThreadViewController *ptvc = [[PostThreadViewController alloc] init];
    ptvc.style = kPostStyleThread;
    ptvc.postId = self.bid;
    [self.navigationController pushViewController:ptvc animated:YES];
}


#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    pullDownRefresh = YES;
    page = 1;
    [self fetchThreadsWithPage:page];
   
}

- (void)footerRereshing
{
    page += 1;
    pullDownRefresh = NO;
    [self fetchThreadsWithPage:page];
    
}

-(void)fetchThreadsWithPage:(int)pageNumber
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr;
    if (self.type == 0) {
        urlStr = [NSString stringWithFormat:@"%@%@&type=board&board=%d&username=%@&page=%d",CMD_URL,get_threads_cmd,self.bid,TeaHomeAppDelegate.username,pageNumber];
    } else if (self.type == 1) {
        urlStr = [NSString stringWithFormat:@"%@%@&type=favor&username=%@&page=%d",CMD_URL,get_threads_cmd,TeaHomeAppDelegate.username,pageNumber];
    } else if (self.type == 2) {
        urlStr = [NSString stringWithFormat:@"%@%@&type=user_thread&his_username=%@&username=%@&page=%d",CMD_URL,get_threads_cmd,self.his_username,TeaHomeAppDelegate.username,pageNumber];
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       if (data != nil) {
           NSError *error;
           id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (jsonObj != nil) {
               dataErr = NO;
               if ([jsonObj isKindOfClass:[NSArray class]]) {
                   if (pullDownRefresh == NO && [jsonObj count] == 0) {
                       page -- ;
                       hasNewData = NO;
                       [self.tableView footerEndRefreshing];
                       return ;
                   }
                   if (pullDownRefresh == YES) {
                       hasNewData = YES;
                       self.threads = [NSMutableArray arrayWithArray:jsonObj];
                       [self.tableView reloadData];
                       [self.tableView headerEndRefreshing];
                       return;
                   }
                   hasNewData = YES;
                   for (NSDictionary *d in jsonObj) {
                       int continueValue = 0;
                       for (NSDictionary *od in self.threads) {
                           if ([[od objectForKey:@"id"] isEqual:[d objectForKey:@"id"]]) {
                               continueValue = 1;
                           }
                       }
                       if (continueValue == 0) {
                           if (pullDownRefresh == 1) {
                               [self.threads insertObject:d  atIndex:0];
                           }else{
                               [self.threads addObject:d];
                           }
                           continueValue = 0;
                       }
                   }
               }
           }else{
               dataErr = YES;
           }

           if (dataErr) {
               if (pullDownRefresh == NO) {
                   // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
                   [self.tableView footerEndRefreshing];
               }else{
                   [self.tableView headerEndRefreshing];
               }
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
               return ;
           }
           if (hasNewData) {
               [self.tableView reloadData];
               if (pullDownRefresh == NO) {
                   // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
                   [self.tableView footerEndRefreshing];
               }else{
                   [self.tableView headerEndRefreshing];
               }
           }else{
               if (pullDownRefresh == 1) {
                   [Utils showAlertViewWithMessage:@"没有更新的数据."];
               }else{
                   [Utils showAlertViewWithMessage:@"没有更多数据."];
               }
           }
       }
    }];
    
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    [hud showAnimated:YES whileExecutingBlock:^{
//        //获取帖子内容
//        NSString *str = [NSString stringWithFormat:@"%@%@&board=%d&username=%@&page=%d",CMD_URL,get_threads_cmd,self.bid,TeaHomeAppDelegate.username,pageNumber];
//        id jsonObj = [Utils getJsonDataFromWeb:str];
//        if (jsonObj != nil) {
//            dataErr = NO;
//            if ([jsonObj isKindOfClass:[NSArray class]]) {
//                if (pullDownRefresh == NO && [jsonObj count] == 0) {
//                    page -- ;
//                    hasNewData = NO;
//                    
//                    // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
//                    [self.tableView footerEndRefreshing];
//                    return ;
//                }
//                jsonObj = (NSArray *)jsonObj;
//                if (pullDownRefresh == YES) {
////                    if ([self.threads count] > 0) {
////                        if ([[[self.threads objectAtIndex:0] objectForKey:@"id"]
////                             isEqualToString:[[jsonObj objectAtIndex:0] objectForKey:@"id"]]) {
////                            hasNewData = NO;
////                            [self.tableView headerEndRefreshing];
////                            return;
////                        }
////                    }else{
////                        hasNewData = YES;
////                        [self.threads addObjectsFromArray:jsonObj];
////                        return;
////                    }
//                    hasNewData = YES;
//                    self.threads = [NSMutableArray arrayWithArray:jsonObj];
//                    return;
//                    
//                }
//                hasNewData = YES;
//                for (NSDictionary *d in jsonObj) {
//                    int continueValue = 0;
//                    for (NSDictionary *od in self.threads) {
//                        if ([[od objectForKey:@"id"] isEqual:[d objectForKey:@"id"]]) {
//                            continueValue = 1;
//                        }
//                    }
//                    if (continueValue == 0) {
//                        if (pullDownRefresh == 1) {
//                            [self.threads insertObject:d  atIndex:0];
//                        }else{
//                            [self.threads addObject:d];
//                        }
//                        continueValue = 0;
//                    }
//                }
//            }else{
//                //dictionary
//                if ([self.threads count] > 0) {
//                    int exist = 0;
//
//                    for (NSDictionary *od in self.threads) {
//                        if ([[od objectForKey:@"id"] isEqual:[((NSDictionary *)jsonObj) objectForKey:@"id"]]) {
//                            exist = 1;
//                        }
//                    }
//                    if (exist == 0) {
//                        if (pullDownRefresh == 1) {
//                            [self.threads insertObject:jsonObj  atIndex:0];
//                        }else{
//                            [self.threads addObject:jsonObj];
//                        }
//                        exist = 0;
//                    }
//                }else{
//                    [self.threads addObject:jsonObj];
//                }
//            }
//        }else{
//            dataErr = YES;
//        }
//
//    } completionBlock:^{
//        if (dataErr) {
//            if (pullDownRefresh == NO) {
//                // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
//                [self.tableView footerEndRefreshing];
//            }else{
//                [self.tableView headerEndRefreshing];
//            }
//            [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
//            return ;
//        }
//        if (hasNewData) {
//            [self.tableView reloadData];
//            if (pullDownRefresh == NO) {
//                // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
//                [self.tableView footerEndRefreshing];
//            }else{
//                [self.tableView headerEndRefreshing];
//            }
//        }else{
//            if (pullDownRefresh == 1) {
//                [Utils showAlertViewWithMessage:@"没有更新的数据."];
//            }else{
//                [Utils showAlertViewWithMessage:@"没有更多数据."];
//            }
//        }
//    }];
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
    return [self.threads count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.threads objectAtIndex:indexPath.row];
    NSString *content = [dic objectForKey:@"content"];
    CGFloat height = [Utils heightForString:content withWidth:300 withFont:15];
    if (height > 20) {
        height = 40;
    }else{
        height = 20;
    }
    NSString *images = [dic objectForKey:@"images"];
    if (![images isEqualToString:@""] && images != nil) {
        return 135;
    }
    //return 70 + height;
    return 90;

}

-(NSString *)timeAgo:(NSDate*) date {
    NSDate *todayDate = [NSDate date];
    
    double ti = [date timeIntervalSinceNow];
    ti = ti * -1;
    if (ti < 1) {
        return @"1秒前";
    } else if (ti < 60) {
        return @"1分钟前";
    } else if (ti < 3600) {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d分钟前", diff];
    } else if (ti < 86400) {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d小时前", diff];
    } else if (ti < 2629743) {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d天前", diff];
    } else if (ti < 31556926) {
        int diff = round(ti / 60 / 60 / 24 / 30);
        return [NSString stringWithFormat:@"%d月前", diff];
    } else {
        int diff = round(ti / 60 / 60 / 24 / 30 / 12);
        return [NSString stringWithFormat:@"%d年前", diff];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dic = [self.threads objectAtIndex:indexPath.row];
    NSString *content = [dic objectForKey:@"content"];
    NSString *grade = [dic objectForKey:@"grade"];
    NSString *username = [dic objectForKey:@"nickname"];
    NSArray *comments = [dic objectForKey:@"comments"];
    int like_count = [[dic objectForKey:@"like_count"] intValue];
    NSString *time = [[dic objectForKey:@"create_time"] substringWithRange:NSMakeRange(0, 19)];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    //[dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    NSDate *dateFromString = [dateFormatter dateFromString:time];
    NSString *delta = [self timeAgo:dateFromString];
    
    NSString *thumb = [dic objectForKey:@"thumb"];
    UIImage *image = [UIImage imageNamed:@"user_icon"];
    UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
    if ([thumb isEqualToString:@""] || thumb == nil) {
        [userIconView setImage:image];
    }else{
        [userIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,thumb]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
    }
    
    userIconView.userInteractionEnabled = YES;
    userIconView.tag = indexPath.row;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconAction:)];
    [userIconView addGestureRecognizer:tap];
    [cell addSubview:userIconView];
    
    
    CGFloat height = [Utils heightForString:content withWidth:300 withFont:15];
    height = 40;
    
    NSString *images = [dic objectForKey:@"images"];
    if (images == nil || [images isEqualToString:@""]) {
        height = 80;
    }
    
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, cell.bounds.size.width - 70, height)];
    contentLabel.text = content;
    contentLabel.numberOfLines = 2;
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.font = [UIFont fontWithName:@"TrebuchetMS-Bold" size:14];
    contentLabel.textColor = [UIColor blackColor];
    [contentLabel sizeToFit];
    [cell addSubview:contentLabel];
    
    CGFloat y = 55;
    
    CGFloat ImageViewHeight = 50;
    
    if (![images isEqualToString:@""] && images != nil) {
        UIScrollView *imagesView = [[UIScrollView alloc] initWithFrame:CGRectMake(70,y,280, ImageViewHeight)];
        imagesView.backgroundColor = [UIColor clearColor];
        imagesView.tag = indexPath.row;
        [cell addSubview:imagesView];
        
        CGFloat imagesViewx = 0;
        for (NSString *name in [images componentsSeparatedByString:@","]) {
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@.thumb.jpg",upload_image_root_url,name];
            UIImageView *iv = [[UIImageView alloc] init];
            [iv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_loading"]];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            [iv setFrame:CGRectMake(imagesViewx, 0, 60, ImageViewHeight)];
            [imagesView addSubview:iv];
            imagesViewx += 85;
        }
        CGRect rect = imagesView.frame;
        if (rect.size.width >= imagesViewx) {
            rect.size.width = imagesViewx;
            imagesView.frame = rect;
            imagesView.userInteractionEnabled = NO;
        }
        imagesView.contentSize = CGSizeMake(imagesViewx, ImageViewHeight);
        y += ImageViewHeight;
        y = 113;
    } else {
        //y += ImageViewHeight;
        y = 65;
    }
    
//    y += 5;
//    UILabel *replyLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, y, 40,15)];
//    replyLabel.text = @"";
//    replyLabel.backgroundColor = [UIColor clearColor];
//    replyLabel.font = [UIFont systemFontOfSize:10];
//    replyLabel.textColor = [UIColor lightGrayColor];
//    [cell addSubview:replyLabel];
//
    
    
    UILabel *userLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, y, 110, 15)];
    userLabel.text = username;
    userLabel.backgroundColor = [UIColor clearColor];
    userLabel.font = [UIFont systemFontOfSize:12];
    userLabel.textColor = [UIColor grayColor];
    [cell addSubview:userLabel];
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 70,15)];
    timeLabel.text = delta;
//    timeLabel.textAlignment = NSTextAlignmentRight;
    timeLabel.backgroundColor = [UIColor clearColor];
    timeLabel.font = [UIFont systemFontOfSize:12];
    timeLabel.textColor = [UIColor lightGrayColor];
    [cell addSubview:timeLabel];
    
    UILabel *commentCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 140,15)];
    commentCountLabel.text = [NSString stringWithFormat:@"%d赞 | %d回复", like_count, [comments count]];
    commentCountLabel.backgroundColor = [UIColor clearColor];
    commentCountLabel.font = [UIFont systemFontOfSize:12];
    commentCountLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    commentCountLabel.textColor = [UIColor grayColor];
    commentCountLabel.textAlignment = NSTextAlignmentRight;
    [cell addSubview:commentCountLabel];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ThreadReplysViewController *tcvc = [[ThreadReplysViewController alloc] init];
    NSDictionary *dic = [self.threads objectAtIndex:indexPath.row];
    tcvc.thread = dic;
    tcvc.name = self.name;
    [self.navigationController pushViewController:tcvc animated:YES];
    
}

-(void)handleTapAction:(UITapGestureRecognizer *)tap
{
    int index = tap.view.tag;
    NSString *images = [[self.threads objectAtIndex:index] objectForKey:@"images"];
    NSArray *uploadImages = [images componentsSeparatedByString:@","];
    NSMutableArray *photos = [NSMutableArray array];
    for (NSString *name in uploadImages) {
        IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,name]]];
        [photos addObject:photo];
    }
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
    browser.displayActionButton = YES;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark -- 点击头像查看个人详情
-(void)userIconAction:(UITapGestureRecognizer *)tap
{
    int tag = tap.view.tag;
    NSString *username = nil;
    //答复区
    NSDictionary *dic = [self.threads objectAtIndex:tag];
    username = [dic objectForKey:@"username"];
    
    SimpleUserinfoViewController *suvc = [[SimpleUserinfoViewController alloc] init];
    suvc.username = username;
    [self.navigationController pushViewController:suvc animated:YES];
}

@end
