//
//  ThreadReplysViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "ThreadReplysViewController.h"
#import "PostThreadViewController.h"
#import "SimpleUserinfoViewController.h"
#import <ShareSDK/ShareSDK.h>

#define share_thread_url @"thread/html/"

static CGFloat ImageViewHeight = 60;

@interface ThreadReplysViewController ()

@property(nonatomic,strong) SNPopupView *popview;
@property(nonatomic,strong) NSString *mycopytext;

@end

@implementation ThreadReplysViewController

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

    self.tableView.backgroundColor = [UIColor whiteColor];
    self.title = self.name;
    self.hidesBottomBarWhenPushed = YES;
    
    if (self.thread) {
        self.tid = [[self.thread objectForKey:@"id"] intValue];

    }
    
    UIBarButtonItem *reply = [[UIBarButtonItem alloc] initWithTitle:@"发表回复"
                                                            style:UIBarButtonItemStyleBordered
                                                             target:self
                                                             action:@selector(replyAction:)];
    //    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithTitle:@"分享"
    //                                                              style:UIBarButtonItemStyleBordered
    //                                                             target:self
    //                                                             action:@selector(shareAction:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:reply, nil];

    
}

//-(void)shareAction:(UIBarButtonItem *)item
//{
//    NSString *url = [NSString stringWithFormat:@"%@%@%d",share_root_url,share_thread_url,[[self.thread objectForKey:@"id"] intValue]];
//    
// 
//}

-(void)replyAction:(id)sender
{
    NSString *nickname = [self.thread objectForKey:@"nickname"];
    
    PostThreadViewController *ptvc = [[PostThreadViewController alloc] init];
    ptvc.style = kPostStyleReply;
    ptvc.postId = [[self.thread objectForKey:@"id"] intValue];
    ptvc.nickname = nickname;
    [self.navigationController pushViewController:ptvc animated:YES];
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
    
    self.get_data = false;

    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&thread=%d&username=%@",CMD_URL,update_comment_cmd,self.tid,TeaHomeAppDelegate.username];
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
               self.get_data = true;
               self.thread = (NSDictionary *)jsonObj;
               self.likeCount = [[self.thread objectForKey:@"like_count"] intValue];
               self.favorCount = [[self.thread objectForKey:@"favor_count"] intValue];
               self.comments = [self.thread objectForKey:@"comments"];
               [self.likeView removeFromSuperview];
               [self.favView removeFromSuperview];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.get_data == false) {
        return 0;
    }
    if (section == 0) {
        return 1;
    }
    return [self.comments count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
//        NSString *title = [NSString stringWithFormat:@"%@",[self.thread objectForKey:@"title"]];
//        CGFloat titleHeight = [Utils heightForString:title withWidth:235 withFont:17];
        NSString *content = [NSString stringWithFormat:@"%@",[self.thread objectForKey:@"content"]];
        CGFloat contentHeight = [Utils heightForString:content withWidth:280 withFont:14];
        NSString *images = [self.thread objectForKey:@"images"];
        if (![images isEqualToString:@""] && images != nil) {
            return 50 + contentHeight + 30 + ImageViewHeight + 30;
        }
        return 50 + contentHeight + 5 + 30;
    }
    NSDictionary *dic = [self.comments objectAtIndex:indexPath.row];
    CGFloat height = [Utils heightForString:[dic objectForKey:@"content"] withWidth:280 withFont:15];
    NSString *images = [dic objectForKey:@"images"];
    if (![images isEqualToString:@""] && images != nil) {
        return 60 + height + 20 + ImageViewHeight;
    }
    return 65 + height;
    //return 60 + height + 10 + ImageViewHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, 280, 30)];
        
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        headerLabel.font = [UIFont boldSystemFontOfSize:14];
        headerLabel.frame = CGRectMake(20, 0.0, 280, 30);
        //headerLabel.text = @"评论";
        
        [customView addSubview:headerLabel];
        
        return customView;
    }
    return nil;
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
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=thread&id=%d",CMD_URL,@"unfavor",TeaHomeAppDelegate.username
                         ,TeaHomeAppDelegate.password,self.tid];
    } else {
        favImage = [UIImage imageNamed:@"like_yes"];
        self.fav_state = true;
        self.favorCount = self.favorCount + 1;
        self.favorLabel.text = [NSString stringWithFormat:@"%d收藏",self.favorCount];
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=thread&id=%d",CMD_URL,@"favor",TeaHomeAppDelegate.username
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
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=thread&id=%d",CMD_URL,@"unlike",TeaHomeAppDelegate.username
               ,TeaHomeAppDelegate.password,self.tid];
    } else {
        likeImage = [UIImage imageNamed:@"like_up"];
        self.like_state = true;
        self.likeCount = self.likeCount + 1;
        self.likeLabel.text = [NSString stringWithFormat:@"%d赞",self.likeCount];

        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=thread&id=%d",CMD_URL,@"like",TeaHomeAppDelegate.username
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
    
    CGFloat x=20,y=10;
    
    if (indexPath.section == 0) {
        //问题cell
        
        //用户头像
        NSString *thumb = [self.thread objectForKey:@"thumb"];
        UIImage *image = [UIImage imageNamed:@"user_icon"];
        UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
        if ([thumb isEqualToString:@""] || thumb == nil) {
            [userIconView setImage:image];
        }else{
            [userIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,thumb]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
        }
        
        userIconView.userInteractionEnabled = YES;
        userIconView.tag = 0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconAction:)];
        [userIconView addGestureRecognizer:tap];
        
        [cell addSubview:userIconView];
        
        NSString *content = [self.thread objectForKey:@"content"];
        NSString *images = [self.thread objectForKey:@"images"];
       
        //发帖人
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+45, y, 200, 20)];
        usernameLabel.backgroundColor = [UIColor clearColor];
        usernameLabel.font = [UIFont systemFontOfSize:13];
        usernameLabel.textColor = [UIColor blackColor];
        usernameLabel.text = [self.thread objectForKey:@"nickname"];
        [cell addSubview:usernameLabel];
        
        //等级
        UILabel *gradeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+205, y, 200, 20)];
        gradeLabel.backgroundColor = [UIColor clearColor];
        gradeLabel.font = [UIFont systemFontOfSize:12];
        gradeLabel.textColor = [UIColor grayColor];
        gradeLabel.text = [self.thread objectForKey:@"grade"];
        [cell addSubview:gradeLabel];
        
        //发帖时间
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+45, y+25, 100, 15)];
        timeLabel.backgroundColor = [UIColor clearColor];
        NSString *dd = [self.thread objectForKey:@"create_time"];
        NSString *time = [[NSString stringWithFormat:@"%@",[self.thread objectForKey:@"create_time"]] substringWithRange:NSMakeRange(0, 19)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateFromString = [dateFormatter dateFromString:time];
        NSString *delta = [self timeAgo:dateFromString];
        timeLabel.text = delta;
        [timeLabel setFont:[UIFont systemFontOfSize:10]];
        timeLabel.textColor = [UIColor lightGrayColor];
        [cell addSubview:timeLabel];
        
        UILabel *button = [[UILabel alloc] initWithFrame:CGRectMake(x+145, y+25, 100, 15)];
        button.text = @"删除";
        [button  setFont:[UIFont systemFontOfSize:10]];
        button.textColor = [UIColor blueColor];
        button.userInteractionEnabled = YES;
        NSString *username = [self.thread objectForKey:@"username"];
        if ([username isEqualToString:TeaHomeAppDelegate.username]) {
            [cell addSubview:button];
            UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDelTapAction:)];
            [button addGestureRecognizer:tap2];
        }

        y += 40;
        
        //发帖标题
//        NSString *title = [NSString stringWithFormat:@"%@",[self.thread objectForKey:@"title"]];
//        CGFloat titleHeight = [Utils heightForString:title withWidth:280-35 withFont:17];
//        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+45, y, 280, titleHeight)];
//        titleLabel.backgroundColor = [UIColor clearColor];
//        titleLabel.font = [UIFont boldSystemFontOfSize:15];
//        titleLabel.text = title;
//        titleLabel.textColor = [UIColor blackColor];
//        [cell addSubview:titleLabel];
//        
//        y += titleHeight;
        
        //帖子正文
        CGFloat contentHeight = [Utils heightForString:content withWidth:280 withFont:13];
        UILabel *contenLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y+10, 280, contentHeight)];
        contenLabel.backgroundColor = [UIColor clearColor];
        contenLabel.numberOfLines = 0;
        contenLabel.text = content;
        [contenLabel setFont:[UIFont systemFontOfSize:13]];
        contenLabel.userInteractionEnabled = YES;
        
        self.mycopytext = content;
        
        UILongPressGestureRecognizer *contentPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleContentTapAction:)];
//        contentPress.minimumPressDuration = 1;
        [contenLabel addGestureRecognizer:contentPress];
        
        [cell addSubview:contenLabel];
        
        y += contentHeight + 5;
        
        if (![images isEqualToString:@""] && images != nil) {
            
            UIScrollView *imagesView = [[UIScrollView alloc] initWithFrame:CGRectMake(x,y+10,280, ImageViewHeight)];
            imagesView.backgroundColor = [UIColor clearColor];
            imagesView.tag = 0;
            imagesView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
            [imagesView addGestureRecognizer:tap];
            
            [cell addSubview:imagesView];
            
            CGFloat imagesViewx = 0;
            for (NSString *name in [images componentsSeparatedByString:@","]) {
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@.thumb.jpg",upload_image_root_url,name];
                UIImageView *iv = [[UIImageView alloc] init];
                [iv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_loading"]];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                [iv setFrame:CGRectMake(imagesViewx, 0, ImageViewHeight, ImageViewHeight)];
                [imagesView addSubview:iv];
                imagesViewx += 100;
            }
            imagesView.contentSize = CGSizeMake(imagesViewx, ImageViewHeight);
            y += 80;
        }
        
        y += 10;
        
        int icon_size = 20;
        
        UIImage *likeImage = [UIImage imageNamed:@"like_down"];
        self.likeView = [[UIImageView alloc] initWithFrame:CGRectMake(10, y, icon_size, icon_size)];
        self.likeView.backgroundColor = [UIColor clearColor];
        self.likeView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeTapAction:)];
        [self.likeView addGestureRecognizer:gesture];
        self.like = [[self.thread objectForKey:@"like"] boolValue];
        
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
        //[self.likeView setImage:likeImage];
        [self.view addSubview:self.likeView];
        
        //评论数
        self.likeLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, y+3, 40, 15)];
        self.likeLabel.backgroundColor = [UIColor clearColor];
        self.likeLabel.font = [UIFont systemFontOfSize:13];
        self.likeLabel.textColor = [UIColor lightGrayColor];
        self.likeLabel.userInteractionEnabled = YES;
        self.likeLabel.textAlignment = NSTextAlignmentRight;
        self.likeLabel.text = [NSString stringWithFormat:@"%d赞",[[self.thread objectForKey:@"like_count"] intValue]];//
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeTapAction:)];
        [self.likeLabel addGestureRecognizer:gesture];
        [cell addSubview:self.likeLabel];
        
        UIImage *favImage = [UIImage imageNamed:@"like_no"];
        self.favView = [[UIImageView alloc] initWithFrame:CGRectMake(80, y, icon_size, icon_size)];
        self.favView.backgroundColor = [UIColor clearColor];
        self.favView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFavTapAction:)];
        [self.favView addGestureRecognizer:gesture2];
        [self.favView setImage:favImage];
        self.favor = [[self.thread objectForKey:@"favor"] boolValue];
        
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
        [self.view addSubview:self.favView];
        
        //评论数
        self.favorLabel = [[UILabel alloc] initWithFrame:CGRectMake(103, y+3, 40, 15)];
        self.favorLabel.backgroundColor = [UIColor clearColor];
        self.favorLabel.font = [UIFont systemFontOfSize:13];
        self.favorLabel.textColor = [UIColor lightGrayColor];
        self.favorLabel.userInteractionEnabled = YES;
        //self.favorLabel.textAlignment = NSTextAlignmentRight;
        self.favorLabel.text = [NSString stringWithFormat:@"%d收藏",[[self.thread objectForKey:@"favor_count"] intValue]];//
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFavTapAction:)];
        [self.favorLabel addGestureRecognizer:gesture];
        [cell addSubview:self.favorLabel];
        
        UIImage *shareImage = [UIImage imageNamed:@"user_wallet"];
        self.shareView = [[UIImageView alloc] initWithFrame:CGRectMake(160, y, icon_size, icon_size)];
        self.shareView.backgroundColor = [UIColor clearColor];
        self.shareView.userInteractionEnabled = YES;
        UITapGestureRecognizer *gesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleShareTapAction:)];
        [self.shareView addGestureRecognizer:gesture3];
        [self.shareView setImage:shareImage];
        [self.view addSubview:self.shareView];
        
        UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(183, y+3, 30, 15)];
        shareLabel.numberOfLines = 0;
        //shareLabel.textAlignment = NSTextAlignmentRight;
        shareLabel.textColor = [UIColor grayColor];
        shareLabel.font = [UIFont systemFontOfSize:14];
        shareLabel.text = @"分享";
        shareLabel.userInteractionEnabled = YES;
        gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleShareTapAction:)];
        [shareLabel addGestureRecognizer:gesture];
        [self.view addSubview:shareLabel];
        
        
        
        //评论数
        UILabel *replyLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, y, 60, 15)];
        replyLabel.backgroundColor = [UIColor clearColor];
        replyLabel.font = [UIFont systemFontOfSize:13];
        replyLabel.textColor = [UIColor lightGrayColor];
        replyLabel.textAlignment = NSTextAlignmentRight;
        replyLabel.text = [NSString stringWithFormat:@"评论:%d",[self.comments count]];//
        [cell addSubview:replyLabel];
        
        y += 35;
        //分割线
        UIImage *line = [UIImage imageNamed:@"grey_space_line"];
        UIImageView *lineView = [[UIImageView alloc] initWithImage:line];
        lineView.frame = CGRectMake(x, y, cell.bounds.size.width, line.size.height);
        [cell addSubview:lineView];
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    y = 5;
    NSDictionary *dic = [self.comments objectAtIndex:indexPath.row];
    //用户头像
    NSString *thumb = [dic objectForKey:@"thumb"];
    UIImage *image = [UIImage imageNamed:@"user_icon"];
    UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 40, 40)];
    if ([thumb isEqualToString:@""] || thumb == nil) {
        [userIconView setImage:image];
    }else{
        [userIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,thumb]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
    }
    
    userIconView.userInteractionEnabled = YES;
    userIconView.tag = 100 + indexPath.row;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconAction:)];
    [userIconView addGestureRecognizer:tap];
    
    [cell addSubview:userIconView];
    
    //用户名
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+45, y, 100, 20)];
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.font = [UIFont systemFontOfSize:13];
    usernameLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"nickname"]];
    [cell addSubview:usernameLabel];
    
    //等级
    UILabel *gradeLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(x+145, y, 200, 20)];
    gradeLabel1.backgroundColor = [UIColor clearColor];
    gradeLabel1.font = [UIFont systemFontOfSize:12];
    gradeLabel1.textColor = [UIColor grayColor];
    gradeLabel1.text = [dic objectForKey:@"grade"];
    //[cell addSubview:gradeLabel1];
    
    //用第几层
    UILabel *floorLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+245, y, 60, 20)];
    floorLabel.backgroundColor = [UIColor clearColor];
    floorLabel.font = [UIFont systemFontOfSize:11];
    floorLabel.text = [NSString stringWithFormat:@"第 %d 楼", indexPath.row];
    floorLabel.userInteractionEnabled = YES;
    floorLabel.textColor = [UIColor grayColor];
    floorLabel.tag = indexPath.row;
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReplyZoneLayer:)];
    [floorLabel addGestureRecognizer:tap];
    
    [cell addSubview:floorLabel];
    
    //回复本层
    UILabel *replyLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+245, y+25, 60, 15)];
    replyLabel.backgroundColor = [UIColor clearColor];
    replyLabel.font = [UIFont systemFontOfSize:11];
    replyLabel.text = [NSString stringWithFormat:@"回复本楼"];
    replyLabel.userInteractionEnabled = YES;
    replyLabel.textColor = [UIColor grayColor];
    replyLabel.tag = indexPath.row;
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReplyZoneLayer:)];
    [replyLabel addGestureRecognizer:tap];
    

//    replyLabel.tag = 1000 + indexPath.row;
//    UITapGestureRecognizer *tapreply = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyAction:)];
//    [userIconView addGestureRecognizer:tapreply];
    
    [cell addSubview:replyLabel];
    
    //回复时间
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+45, y+25, 220, 15)];
    timeLabel.backgroundColor = [UIColor clearColor];
    NSString *time = [[NSString stringWithFormat:@"%@",[dic objectForKey:@"create_time"]] substringWithRange:NSMakeRange(0, 19)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *dateFromString = [dateFormatter dateFromString:time];
    NSString *delta = [self timeAgo:dateFromString];
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.text = delta;
    timeLabel.textColor = [UIColor grayColor];
    [cell addSubview:timeLabel];
    
    y += 55;
    
    //回复正文
    CGFloat height = [Utils heightForString:[dic objectForKey:@"content"] withWidth:280 withFont:15];
    UILabel *contenLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, y, 250, height)];
    contenLabel.backgroundColor = [UIColor clearColor];
    contenLabel.numberOfLines = 0;
    contenLabel.font = [UIFont systemFontOfSize:13];
    contenLabel.text = [dic objectForKey:@"content"];
    [cell addSubview:contenLabel];
    
    y += height + 5;
    NSString *images = [dic objectForKey:@"images"];
    if (![images isEqualToString:@""] && images != nil) {
        UIScrollView *imagesView = [[UIScrollView alloc] initWithFrame:CGRectMake(x,y,280, ImageViewHeight)];
        imagesView.backgroundColor = [UIColor clearColor];
        imagesView.tag = 100+indexPath.row;
        imagesView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
        [imagesView addGestureRecognizer:tap];
        
        [cell addSubview:imagesView];
        
        CGFloat imagesViewx = 0;
        for (NSString *name in [images componentsSeparatedByString:@","]) {
            NSString *imageUrl = [NSString stringWithFormat:@"%@%@.thumb.jpg",upload_image_root_url,name];
            UIImageView *iv = [[UIImageView alloc] init];
            [iv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_loading"]];
            iv.contentMode = UIViewContentModeScaleAspectFit;
            [iv setFrame:CGRectMake(imagesViewx, 0, ImageViewHeight, ImageViewHeight)];
            [imagesView addSubview:iv];
            imagesViewx += 100;
        }
        imagesView.contentSize = CGSizeMake(imagesViewx, ImageViewHeight);
        y += 80;
        
    }
    
    y += 5;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)handleTapAction:(UITapGestureRecognizer *)tap
{
    UIView *v = tap.view;
    if (v.tag == 0) {
        //点击的内容
        NSString *images = [self.thread objectForKey:@"images"];
        if (![images isEqualToString:@""] && images != nil) {
            NSMutableArray *photos = [NSMutableArray array];
            for (NSString *name in [images componentsSeparatedByString:@","]) {
                IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,name]]];
                [photos addObject:photo];
            }
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
            browser.displayActionButton = YES;
            browser.displayArrowButton = YES;
            browser.displayCounterLabel = YES;
            [self presentViewController:browser animated:YES completion:nil];
        }
    }else{
        NSDictionary *dic = [self.comments objectAtIndex:(v.tag -100)];
        NSString *images = [dic objectForKey:@"images"];
        if (![images isEqualToString:@""] && images != nil) {
            NSMutableArray *photos = [NSMutableArray array];
            for (NSString *name in [images componentsSeparatedByString:@","]) {
                IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,name]]];
                [photos addObject:photo];
            }
            IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
            browser.displayActionButton = YES;
            browser.displayArrowButton = YES;
            browser.displayCounterLabel = YES;
            [self presentViewController:browser animated:YES completion:nil];
        }

    }
}

#pragma mark -- 点击头像查看个人详情
-(void)userIconAction:(UITapGestureRecognizer *)tap
{
    int tag = tap.view.tag;
    NSString *username = nil;
    if (tag == 0) {
        //问题区
        username = [self.thread objectForKey:@"username"];
    }else{
        //答复区
        NSDictionary *dic = [self.comments objectAtIndex:tag-100];
        username = [dic objectForKey:@"username"];
    }
    
    SimpleUserinfoViewController *suvc = [[SimpleUserinfoViewController alloc] init];
    suvc.username = username;
    [self.navigationController pushViewController:suvc animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&id=%d",CMD_URL,@"del_thread",TeaHomeAppDelegate.username
                         ,TeaHomeAppDelegate.password,self.tid];
    
        id jsonObj = [Utils getJsonDataFromWeb:str];
        [[NSNotificationCenter defaultCenter] postNotificationName:kPostThreadSuccessNotification object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)handleDelTapAction:(UITapGestureRecognizer *)tap
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认删除贴子"
                                                    message:@"是否确认？"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定删除",@"取消", nil];
    [alert show];
}

#pragma mark -- 点击第几楼的时候进入回复
-(void)tapReplyZoneLayer:(UITapGestureRecognizer *)tap
{
    int index = tap.view.tag;
    NSDictionary *reply = [self.comments objectAtIndex:index];
    NSString *nickname = [reply objectForKey:@"nickname"];
    
    PostThreadViewController *ptvc = [[PostThreadViewController alloc] init];
    ptvc.style = kPostStyleReply;
    ptvc.postId = [[self.thread objectForKey:@"id"] intValue];
    ptvc.nickname = nickname;
    [self.navigationController pushViewController:ptvc animated:YES];
}

#pragma mark -- 点击帖子正文部分复制文本
-(void)handleContentTapAction:(UILongPressGestureRecognizer *)tap
{
    switch (tap.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint point = [tap locationInView:self.view];
            self.popview = [[SNPopupView alloc] initWithString:@"复制全文" withFontOfSize:12];
            [self.popview addTarget:self action:@selector(copyAction)];
            [self.popview presentModalAtPoint:point inView:self.view];
        }
            break;
            
        default:
            break;
    }
    
}

-(void)copyAction
{
    [self.popview dismiss:YES];
    
    [[UIPasteboard generalPasteboard] setPersistent:YES];
    [[UIPasteboard generalPasteboard] setValue:self.mycopytext forPasteboardType:[UIPasteboardTypeListString objectAtIndex:0]];
}

-(void)handleShareTapAction:(UITapGestureRecognizer *)gesture
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
    NSString *url = [NSString stringWithFormat:@"%@%d",THREAD_URL,self.tid];
    NSString *content = [NSString stringWithFormat:@"%@",[self.thread objectForKey:@"content"]];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"默认分享内容，没内容时显示"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:content
                                                  url:url
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
    
}


@end
