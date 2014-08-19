//
//  FirstViewController.m
//  AKTabBar Example
//
//  Created by Ali KARAGOZ on 04/05/12.
//  Copyright (c) 2012 Ali Karagoz. All rights reserved.
//
//首页资讯

#import "FirstViewController.h"
#import "ArticleContentViewController.h"
#import "LoginViewController.h"

#define news_cmd @"get_articles"
#define get_bigpictures_cmd @"get_bigpictures"

static int page = 1;

@interface FirstViewController ()<UIScrollViewDelegate>
{
    UIScrollView *picScrollView;
    UIPageControl *pageControl;
    NSArray *scrollPics;
    
    BOOL hasNewData ;
    BOOL pullDownRefresh;
    BOOL dataErr;
}

@end

@implementation FirstViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"资讯";
        self.dataSource = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    hasNewData = YES;
    pullDownRefresh = YES;
    dataErr = NO;
    
    scrollPics = [NSArray array];
    self.dataSource = [NSMutableArray array];

    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    
    [self getPicsFromWeb];
    
    [self getArticlesFromWebWithPage:1];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    pullDownRefresh = YES;
    page = 1;
    
    [self getPicsFromWeb];
   
    [self getArticlesFromWebWithPage:page];
    
}

- (void)footerRereshing
{
    pullDownRefresh = NO;
    
    page += 1;
    
    [self getArticlesFromWebWithPage:page];
    
   

}

//获取顶部滚动的图片
-(void)getPicsFromWeb
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        return;
    }
    NSString *urlStr  = [NSString stringWithFormat:@"%@%@",CMD_URL,get_bigpictures_cmd];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (data != nil) {
                                   NSError *error;
                                   id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                                   if (json != nil) {
                                       scrollPics = [NSArray arrayWithArray:(NSArray *)json];
                                       [self.tableView reloadData];
                                   }
                               }
                           }];

}

//获取首页信息列表
-(void)getArticlesFromWebWithPage:(int)aPage
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [self.tableView headerEndRefreshing];
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&page=%d",CMD_URL,news_cmd,aPage];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       if (data != nil) {
           NSError *error;
           id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (jsonObj != nil) {
               dataErr = NO;
               if (pullDownRefresh == NO && [jsonObj count] == 0) {
                   page -- ;
                   hasNewData = NO;
                   [self.tableView footerEndRefreshing];
                   return ;
               }
               if (pullDownRefresh == YES && [self.dataSource count] == 0) {
                   hasNewData = YES;
                   self.dataSource = [NSMutableArray arrayWithArray:jsonObj];
                   [self.tableView reloadData];
                   [self.tableView headerEndRefreshing];
                   return;
               }
               hasNewData = YES;
               for (NSDictionary *d in jsonObj) {
                   int continueValue = 0;
                   for (NSDictionary *od in self.dataSource) {
                       if ([[od objectForKey:@"id"] isEqual:[d objectForKey:@"id"]]) {
                           continueValue = 1;
                       }
                   }
                   if (continueValue == 0) {
                       if (pullDownRefresh == YES) {
                           [self.dataSource insertObject:d  atIndex:0];
                       }else{
                           [self.dataSource addObject:d];
                       }
                       continueValue = 0;
                   }
               }
           }else{
               [self.tableView headerEndRefreshing];
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
           //有新数据的时候重新加载数据
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
                   [Utils showAlertViewWithMessage:@"没有更新的文章."];
               }else{
                   [Utils showAlertViewWithMessage:@"没有更多的文章."];
                   
               }
           }
       }
   }];

//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    [hud showAnimated:YES whileExecutingBlock:^{
//        NSString *str = [NSString stringWithFormat:@"%@%@&page=%d",CMD_URL,news_cmd,aPage];
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
//                    hasNewData = YES;
//                    self.dataSource = [NSMutableArray arrayWithArray:jsonObj];
//                    return;
//                }
//                hasNewData = YES;
//                for (NSDictionary *d in jsonObj) {
//                    int continueValue = 0;
//                    for (NSDictionary *od in self.dataSource) {
//                        if ([[od objectForKey:@"id"] isEqual:[d objectForKey:@"id"]]) {
//                            continueValue = 1;
//                        }
//                    }
//                    if (continueValue == 0) {
//                        if (pullDownRefresh == YES) {
//                            [self.dataSource insertObject:d  atIndex:0];
//                        }else{
//                            [self.dataSource addObject:d];
//                        }
//                        continueValue = 0;
//                    }
//                }
//            }else{
//                //dictionary
//                if ([self.dataSource count] > 0) {
//                    int exist = 0;
//                    
//                    for (NSDictionary *od in self.dataSource) {
//                        if ([[od objectForKey:@"id"] isEqual:[((NSDictionary *)jsonObj) objectForKey:@"id"]]) {
//                            exist = 1;
//                        }
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
//        //有新数据的时候重新加载数据
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
//                [Utils showAlertViewWithMessage:@"没有更新的文章."];
//            }else{
//                [Utils showAlertViewWithMessage:@"没有更多的文章."];
//                
//            }
//        }
//    }];
}

- (NSString *)tabImageName
{
	return @"info_icon";
}

- (NSString *)tabTitle
{
	return self.title;
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
    return [self.dataSource count] + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 180;
    }
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    //表格的第一行是滚动图片视图
    if (indexPath.row == 0) {

        picScrollView = nil;
        pageControl = nil;
        
        picScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
        [picScrollView setContentSize:CGSizeMake([scrollPics count] * 320, 180)];
        [picScrollView setPagingEnabled:YES];
        [picScrollView setShowsHorizontalScrollIndicator:NO];
        [picScrollView setBounces:NO];
        picScrollView.delegate = self;
        
        for (int i=0;i<[scrollPics count];i++) {
            NSDictionary *picDic = scrollPics[i];
            NSString *picUrl = [picDic objectForKey:@"pic_url"];
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(320*i, 0, 320, 180)];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.userInteractionEnabled = YES;
            [imageView sd_setImageWithURL:[NSURL URLWithString:picUrl] placeholderImage:[UIImage imageNamed:@"image_loading"]];
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePicImageTapAction:)];
            [imageView addGestureRecognizer:gesture];
            
            [picScrollView addSubview:imageView];
            
        }
        [cell addSubview:picScrollView];
        
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 150, 320, 30)];
        pageControl.numberOfPages = [scrollPics count];
        pageControl.currentPage = 0;
        [pageControl addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:pageControl];
    
        return cell;
    }
    
    NSDictionary *d = [self.dataSource objectAtIndex:indexPath.row - 1];
    NSString *title = [d objectForKey:@"name"];
    NSString *summary = [d objectForKey:@"summary"];
    NSString *imageUrl = [d objectForKey:@"pic_url"];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 120, 90)];
    imageView.backgroundColor = [UIColor clearColor];
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_loading"]];
    [cell addSubview:imageView];
    
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 10, 170, 20)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    titleLabel.text = [NSString stringWithFormat:@"%@",title];
    titleLabel.textColor = [UIColor blackColor];
    [cell addSubview:titleLabel];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 35, 170, 55)];
    descLabel.backgroundColor = [UIColor clearColor];
    descLabel.numberOfLines = 0;
    descLabel.text = [NSString stringWithFormat:@"%@",summary];
    descLabel.font = [UIFont systemFontOfSize:10];
    descLabel.textColor = [UIColor lightGrayColor];
    [cell addSubview:descLabel];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0) {
//        //TODO
//    }
    NSDictionary *d = [self.dataSource objectAtIndex:indexPath.row - 1];
    NSString *text = [d objectForKey:@"text"];
    NSString *title = [d objectForKey:@"name"];
    ArticleContentViewController *acvc = [[ArticleContentViewController alloc] init];
    acvc.text = text;
    //acvc.articleTitle = title;
    acvc.articleId = [[d objectForKey:@"id"] intValue];
    [self.navigationController pushViewController:acvc animated:YES];
}

#pragma mark -- scrollview delegate method
//pagecontrol的点跟着页数改变
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1{
    if (scrollView1 != picScrollView) {
        return;
    }
    CGPoint offset=scrollView1.contentOffset;
    CGRect bounds=scrollView1.frame;
    [pageControl setCurrentPage:offset.x/bounds.size.width];
}
//点击pagecontrol的点 跳到那一页的实现
- (void)pageTurn:(UIPageControl *)sender {
    CGSize viewsize = picScrollView.frame.size;
    CGRect rect=CGRectMake(sender.currentPage*viewsize.width, 0, viewsize.width, viewsize.height);
    [picScrollView scrollRectToVisible:rect animated:YES];
}

-(void)handlePicImageTapAction:(UITapGestureRecognizer *)gesture
{
    NSDictionary *d = [scrollPics objectAtIndex:pageControl.currentPage];
    NSString *title = @"";
    NSString *text = [d objectForKey:@"link"];
    ArticleContentViewController *acvc = [[ArticleContentViewController alloc] init];
    acvc.text = text;
    acvc.articleTitle = title;
    acvc.articleId = [[d objectForKey:@"id"] intValue];
    [self.navigationController pushViewController:acvc animated:YES];
}
@end
