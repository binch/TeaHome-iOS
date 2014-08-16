//
//  QuestionsViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "QuestionsViewController.h"
#import "LoginViewController.h"
#import "AnswersViewController.h"
#import "PostThreadViewController.h"

#define get_questions_cmd @"get_questions"

static int page = 1;


@interface QuestionsViewController ()
{
    BOOL hasNewData ;
    BOOL pullDownRefresh;
    BOOL dataErr;
}
@end

@implementation QuestionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"问答";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"question_icon";
}

- (NSString *)tabTitle
{
	return self.title;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    hasNewData = YES;
    pullDownRefresh = YES;
    dataErr = NO;
    
    UIBarButtonItem *postThreadItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"submit_question"] style:UIBarButtonItemStyleBordered target:self action:@selector(postQuestionAction:)];
    self.navigationItem.rightBarButtonItem = postThreadItem;
    
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeGesture];
    
    swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
    
    self.dataSource = [NSMutableArray array];
    
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:kPostQuestionSuccessNotification object:nil];
    
    [self.tableView headerBeginRefreshing];
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([TeaHomeAppDelegate.username isEqualToString:@""]) {
        [self.tableView headerEndRefreshing];
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:lvc animated:YES];
        return;
    }
    
   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)handleNotification:(NSNotification *)note
{
    [self.tableView headerBeginRefreshing];
}


#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    pullDownRefresh = YES;
    page = 1;
    [self fetchQuestionsWithPage:page];
}

- (void)footerRereshing
{
    page += 1;
    pullDownRefresh = NO;
    [self fetchQuestionsWithPage:page];
}

/**
 * 跳转到提问页面
 **/
-(void)postQuestionAction:(id)sender
{
    PostThreadViewController *ptvc = [[PostThreadViewController alloc] init];
    ptvc.style = kPostStyleQuestion;    
    [self.navigationController pushViewController:ptvc animated:YES];
}


-(void)fetchQuestionsWithPage:(int)pageNumber
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [self.tableView headerEndRefreshing];
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&page=%d",CMD_URL,get_questions_cmd,pageNumber];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//     [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
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
                   if (pullDownRefresh == YES && [self.dataSource count] == 0) {
                       hasNewData = YES;
                       [self.dataSource addObjectsFromArray:jsonObj];
                       [self.tableView reloadData];
                       [self.tableView headerEndRefreshing];
                       return;
                   }
                   hasNewData = YES;
                   if ([self.dataSource count] > 0) {
                       for (NSDictionary *d in jsonObj) {
                           int continueValue = 0;
                           for (NSDictionary *od in self.dataSource) {
                               if ([[od objectForKey:@"id"]
                                    isEqual:
                                    [d objectForKey:@"id"]]) {
                                   continueValue = 1;
                               }
                           }
                           if (continueValue == 0) {
                               if (pullDownRefresh == 1) {
                                   [self.dataSource insertObject:d  atIndex:0];
                               }else{
                                   [self.dataSource addObject:d];
                               }
                               continueValue = 0;
                           }
                       }
                   }else{
                       [self.dataSource addObjectsFromArray:jsonObj];
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
//        NSString *str = [NSString stringWithFormat:@"%@%@&page=%d",CMD_URL,get_questions_cmd,pageNumber];
//        id jsonObj = [Utils getJsonDataFromWeb:str];
//        if (jsonObj != nil) {
//            dataErr = NO;
//            if ([jsonObj isKindOfClass:[NSArray class]]) {
//                if (pullDownRefresh == NO && [jsonObj count] == 0) {
//                    page -- ;
//                    hasNewData = NO;
//                    [self.tableView footerEndRefreshing];
//                    return ;
//                }
//                jsonObj = (NSArray *)jsonObj;
//                if (pullDownRefresh == YES) {
////                    if ([self.dataSource count] > 0) {
////                        if ([[[self.dataSource objectAtIndex:0] objectForKey:@"id"]
////                             isEqual:
////                             [[jsonObj objectAtIndex:0] objectForKey:@"id"]]) {
////                            hasNewData = NO;
////                            [self.tableView headerEndRefreshing];
////                            return;
////                        }
////                    }else{
////                        hasNewData = YES;
////                        [self.dataSource addObjectsFromArray:jsonObj];
////                        return;
////                    }
//                    hasNewData = YES;
//                    [self.dataSource addObjectsFromArray:jsonObj];
//                    return;
//                }
//                hasNewData = YES;
//                if ([self.dataSource count] > 0) {
//                    for (NSDictionary *d in jsonObj) {
//                        int continueValue = 0;
//                        for (NSDictionary *od in self.dataSource) {
//                            if ([[od objectForKey:@"id"]
//                                 isEqual:
//                                 [d objectForKey:@"id"]]) {
//                                continueValue = 1;
//                            }
//                        }
//                        if (continueValue == 0) {
//                            if (pullDownRefresh == 1) {
//                                [self.dataSource insertObject:d  atIndex:0];
//                            }else{
//                                [self.dataSource addObject:d];
//                            }
//                            continueValue = 0;
//                        }
//                    }
//                }else{
//                    [self.dataSource addObjectsFromArray:jsonObj];
//                }
//            }else{
//                //dictionary
//                if ([self.dataSource count] > 0) {
//                    int exist = 0;
//                    if ([[[self.dataSource objectAtIndex:0] objectForKey:@"id"]
//                         isEqual:
//                         [[jsonObj objectAtIndex:0] objectForKey:@"id"]]) {
//                        exist = 1;
//                    }
//                    if (exist == 0) {
//                        if (pullDownRefresh == 1) {
//                            [self.dataSource insertObject:jsonObj  atIndex:0];
//                        }else{
//                            [self.dataSource addObject:jsonObj];
//                        }
//                        exist = 0;
//                    }
//                }else{
//                    [self.dataSource addObject:jsonObj];
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
//        
//    }];
}


#pragma mark -- tableview delegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"My_cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.row];
    NSString *title = [dic objectForKey:@"title"];
    NSString *cat = [dic objectForKey:@"cat"];
    NSArray *answers = [dic objectForKey:@"answers"];
    BOOL ended = [[dic objectForKey:@"ended"] boolValue];
    UIImage *answeredImage = nil;
    if (ended) {
        answeredImage = [UIImage imageNamed:@"ask_buttom"];
    }else{
        answeredImage = [UIImage imageNamed:@"ask_buttom_grey"];
    }
    
    UIImageView *anseredImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, answeredImage.size.width, answeredImage.size.height)];
    anseredImageView.image = answeredImage;
    [cell addSubview:anseredImageView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 13, 240, 20)];
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.backgroundColor = [UIColor clearColor];
    [cell addSubview:titleLabel];
    
    UIImage *yesImage = nil;
    if (ended) {
        yesImage = [UIImage imageNamed:@"answered_buttom"];
    }else{
        yesImage = [UIImage imageNamed:@"not_answered_buttom"];
    }
    UIImageView *yesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(120, 40, yesImage.size.width, yesImage.size.height)];
    yesImageView.image = yesImage;
    [cell addSubview:yesImageView];
    
    UILabel *readLabel = [[UILabel alloc] initWithFrame:CGRectMake(190, 40, 60, 18)];
    readLabel.numberOfLines = 0;
    readLabel.textColor = [UIColor blackColor];
    readLabel.text = [NSString stringWithFormat:@"回复 : %d",[answers count]];
    readLabel.font = [UIFont systemFontOfSize:12];
    readLabel.backgroundColor = [UIColor clearColor];
    [cell addSubview:readLabel];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 40, 60, 18)];
    categoryLabel.numberOfLines = 0;
    categoryLabel.textColor = [UIColor blackColor];
    categoryLabel.text = [NSString stringWithFormat:@"分类 : %@",cat];
    categoryLabel.font = [UIFont systemFontOfSize:12];
    categoryLabel.backgroundColor = [UIColor clearColor];
    [cell addSubview:categoryLabel];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/**
 * 跳转到选中的问题页面
 **/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AnswersViewController *tcvc = [[AnswersViewController alloc] init];
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.row];
    tcvc.question = dic;
    [self.navigationController pushViewController:tcvc animated:YES];
}

@end
