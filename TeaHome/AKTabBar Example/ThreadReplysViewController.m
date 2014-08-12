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

#define share_thread_url @"thread/html/"

static CGFloat ImageViewHeight = 80;

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
    if (self.thread) {
        self.tid = [[self.thread objectForKey:@"id"] intValue];
    }
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&thread=%d&username=%@",CMD_URL,update_comment_cmd,self.tid,TeaHomeAppDelegate.username];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       //                               [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       if (data != nil) {
           NSError *error;
           id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (jsonObj != nil) {
               self.thread = (NSDictionary *)jsonObj;
               self.comments = [self.thread objectForKey:@"comments"];
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
    return 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
//        NSString *title = [NSString stringWithFormat:@"%@",[self.thread objectForKey:@"title"]];
//        CGFloat titleHeight = [Utils heightForString:title withWidth:235 withFont:17];
        NSString *content = [NSString stringWithFormat:@"%@",[self.thread objectForKey:@"content"]];
        CGFloat contentHeight = [Utils heightForString:content withWidth:280 withFont:15];
        NSString *images = [NSString stringWithFormat:@"images"];
        if (![images isEqualToString:@""] && images != nil) {
            return 50 + contentHeight + 10 + ImageViewHeight + 20;
        }
        return 50 + contentHeight + 5 + 20;
    }
    NSDictionary *dic = [self.comments objectAtIndex:indexPath.row];
    CGFloat height = [Utils heightForString:[dic objectForKey:@"content"] withWidth:280 withFont:15];
    NSString *images = [dic objectForKey:@"images"];
    if (![images isEqualToString:@""] && images != nil) {
        return 60 + height + 10 + ImageViewHeight;
    }
    //return 65 + height;
    return 60 + height + 10 + ImageViewHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0.0, 280, 30)];
        
        UILabel * headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        headerLabel.frame = CGRectMake(20, 0.0, 280, 30);
        headerLabel.text = @"评论";
        
        [customView addSubview:headerLabel];
        
        return customView;
    }
    return nil;
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
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+45, y+25, 200, 15)];
        timeLabel.backgroundColor = [UIColor clearColor];
        NSString *time = [self.thread objectForKey:@"create_time"];
        timeLabel.text = [time substringWithRange:NSMakeRange(0, 19)];
        [timeLabel setFont:[UIFont systemFontOfSize:10]];
        timeLabel.textColor = [UIColor lightGrayColor];
        [cell addSubview:timeLabel];
        
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
                iv.contentMode = UIViewContentModeScaleAspectFit;
                [iv setFrame:CGRectMake(imagesViewx, 0, ImageViewHeight, ImageViewHeight)];
                [imagesView addSubview:iv];
                imagesViewx += 100;
            }
            imagesView.contentSize = CGSizeMake(imagesViewx, ImageViewHeight);
            y += 80;
        }
        
        y += 5;
        
        //评论数
        UILabel *replyLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, y, 60, 15)];
        replyLabel.backgroundColor = [UIColor clearColor];
        replyLabel.font = [UIFont systemFontOfSize:13];
        replyLabel.textColor = [UIColor lightGrayColor];
        replyLabel.textAlignment = NSTextAlignmentRight;
        replyLabel.text = [NSString stringWithFormat:@"评论:%d",[self.comments count]];//
        [cell addSubview:replyLabel];
        
        y += 17;
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
    [cell addSubview:gradeLabel1];
    
    //用第几层
    UILabel *floorLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+245, y, 60, 20)];
    floorLabel.backgroundColor = [UIColor clearColor];
    floorLabel.font = [UIFont systemFontOfSize:11];
    floorLabel.text = [NSString stringWithFormat:@"第 %d 楼", indexPath.row];
    floorLabel.userInteractionEnabled = YES;
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
    NSString *time = [NSString stringWithFormat:@"%@",[dic objectForKey:@"create_time"]];
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.text = [time substringWithRange:NSMakeRange(0, 19)];
    [cell addSubview:timeLabel];
    
    y += 55;
    
    //回复正文
    CGFloat height = [Utils heightForString:[dic objectForKey:@"content"] withWidth:280 withFont:13];
    UILabel *contenLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 280, height)];
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
            browser.displayActionButton = NO;
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
            browser.displayActionButton = NO;
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

@end
