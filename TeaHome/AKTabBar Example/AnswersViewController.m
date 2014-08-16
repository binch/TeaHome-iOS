//
//  AnswersViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "AnswersViewController.h"
#import "PostThreadViewController.h"
#import "SimpleUserinfoViewController.h"

#define share_answer_url @"question/html/"

static CGFloat ImageViewHeight = 80;

@interface AnswersViewController ()

@end

@implementation AnswersViewController

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
    self.title = [NSString stringWithFormat:@"%@",[self.question objectForKey:@"title"]];
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
//    NSString *url = [NSString stringWithFormat:@"%@%@%d",share_root_url,share_answer_url,[[self.question objectForKey:@"id"] intValue]];
//}

-(void)replyAction:(id)sender
{
    PostThreadViewController *ptvc = [[PostThreadViewController alloc] init];
    ptvc.style = kPostStyleAnswer;
    ptvc.postId = [[self.question objectForKey:@"id"] intValue];
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
    if (self.question) {
        self.qid = [[self.question objectForKey:@"id"] intValue];
    }
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
   NSString *urlStr = [NSString stringWithFormat:@"%@%@&question=%d",CMD_URL,update_answer_cmd,self.qid];
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
               self.question = (NSDictionary *)jsonObj;
               self.answers = [self.question objectForKey:@"answers"];
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
    return [self.answers count];
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
        NSString *content = [self.question objectForKey:@"content"];
        CGFloat h = [Utils heightForString:content withWidth:280 withFont:15];
        NSString *images = [self.question objectForKey:@"images"];
        if (![images isEqualToString:@""] && images != nil) {
            return 45+h+5+ImageViewHeight + 30;
        }
        return 45+h+5 + 30;
    }
    NSDictionary *dic = [self.answers objectAtIndex:indexPath.row];
    CGFloat height = [Utils heightForString:[dic objectForKey:@"content"] withWidth:280 withFont:15];
    NSString *images = [dic objectForKey:@"images"];
    if (![images isEqualToString:@""] && images != nil) {
        return 10+30+5+height+5+ImageViewHeight + 5;
    }
    return 10+30+5+height+5;
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
        
        //提问图标
        UIImage *askImage = [UIImage imageNamed:@"ask_buttom"];
        UIImageView *askImgView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y+2, askImage.size.width,askImage.size.height)];
        askImgView.image = askImage;
        [cell addSubview:askImgView];
        
        NSString *thumb = [self.question objectForKey:@"thumb"];
        //用户头像
        UIImage *image = [UIImage imageNamed:@"user_icon"];
        UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(x + askImage.size.width + 10, y, 30, 30)];
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
        
        NSString *content = [self.question objectForKey:@"content"];
        NSString *images = [self.question objectForKey:@"images"];
        
        //发帖人
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(userIconView.frame.origin.x + userIconView.frame.size.width + 10, y, 100, 20)];
        usernameLabel.backgroundColor = [UIColor clearColor];
        usernameLabel.font = [UIFont systemFontOfSize:12];
        usernameLabel.textColor = [UIColor blackColor];
        usernameLabel.text = [self.question objectForKey:@"nickname"];
        [cell addSubview:usernameLabel];
        
        //发帖时间
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(usernameLabel.frame.origin.x, y+20, 200, 10)];
        timeLabel.backgroundColor = [UIColor clearColor];
        NSString *time = [self.question objectForKey:@"create_time"];
        timeLabel.text = [time substringWithRange:NSMakeRange(0, 19)];
        [timeLabel setFont:[UIFont systemFontOfSize:10]];
        timeLabel.textColor = [UIColor lightGrayColor];
        [cell addSubview:timeLabel];
        
        y += 30;
        
        y += 2;
        //分割线
        UIImage *line = [UIImage imageNamed:@"grey_space_line"];
        UIImageView *lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, cell.bounds.size.width - 2*x,line.size.height)];
        lineImageView.image = line;
        [cell addSubview:lineImageView];
        y += 2;
        
        y += 5;
        //问题正文
        CGFloat contentHeight = [Utils heightForString:content withWidth:280 withFont:15];
        UILabel *contenLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, cell.bounds.size.width - 2*x, contentHeight)];
        contenLabel.numberOfLines = 0;
        contenLabel.text = content;
        [contenLabel setFont:[UIFont systemFontOfSize:15]];
        [cell addSubview:contenLabel];
        
        y += contentHeight+5;
        
        if (![images isEqualToString:@""] && images != nil) {
            UIScrollView *imagesView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, y, 280, ImageViewHeight)];
            imagesView.backgroundColor = [UIColor clearColor];
            imagesView.tag = 0;
            imagesView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
            [imagesView addGestureRecognizer:tap];
            
            CGFloat imagex = 0;
            CGFloat imagey = 0;
            for (NSString *name in [images componentsSeparatedByString:@","]) {
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@.thumb.jpg",upload_image_root_url,name];
                UIImageView *iv = [[UIImageView alloc] init];
                [iv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_loading"]];
                iv.contentMode = UIViewContentModeScaleAspectFit;
                [iv setFrame:CGRectMake(imagex,imagey, ImageViewHeight, ImageViewHeight)];
                iv.backgroundColor = [UIColor clearColor];
                [imagesView addSubview:iv];
                imagex += ImageViewHeight;
            }
            imagesView.contentSize = CGSizeMake(imagex, ImageViewHeight);
            [cell addSubview:imagesView];
            
            y += ImageViewHeight;
        }
        y += 5;
        
        //是否已回答
        BOOL ended = [[self.question objectForKey:@"ended"] boolValue];
        UIImage *yesImage = nil;
        if (ended) {
            yesImage = [UIImage imageNamed:@"answered_buttom"];
        }else{
            yesImage = [UIImage imageNamed:@"not_answered_buttom"];
        }
        UIImageView *yesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x,y, yesImage.size.width, yesImage.size.height)];
        yesImageView.image = yesImage;
        [cell addSubview:yesImageView];
        
        //阅读数量
        UILabel *readLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, y, 100, 18)];
        readLabel.numberOfLines = 0;
        readLabel.textColor = [UIColor blackColor];
        readLabel.text = [NSString stringWithFormat:@"回复数 : %d",[self.answers count]];
        readLabel.font = [UIFont systemFontOfSize:12];
        readLabel.backgroundColor = [UIColor clearColor];
        [cell addSubview:readLabel];
        
        y += 20;
        //分割线
        UIImage *line2 = [UIImage imageNamed:@"grey_space_line"];
        UIImageView *line2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, cell.bounds.size.width - 2*x,line2.size.height)];
        line2ImageView.image = line2;
        [cell addSubview:line2ImageView];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    NSDictionary *dic = [self.answers objectAtIndex:indexPath.row];
    NSString *images = [dic objectForKey:@"images"];
    
    
    //用户头像
    NSString *thumb = [dic objectForKey:@"thumb"];
    UIImage *image = [UIImage imageNamed:@"user_icon"];
    UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 30, 30)];
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
    UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+ 40, y, 220, 15)];
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.font = [UIFont systemFontOfSize:13];
    usernameLabel.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"nickname"]];
    [cell addSubview:usernameLabel];
    
    //回答时间
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + 40, y+20, 220, 10)];
    timeLabel.backgroundColor = [UIColor clearColor];
    NSString *time = [NSString stringWithFormat:@"%@",[dic objectForKey:@"create_time"]];
    timeLabel.font = [UIFont systemFontOfSize:10];
    timeLabel.text = [time substringWithRange:NSMakeRange(0, 19)];
    [cell addSubview:timeLabel];
    
    y += 30+5;
    
    //回答内容
    CGFloat height = [Utils heightForString:[dic objectForKey:@"content"] withWidth:320 withFont:17];
    UILabel *contenLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + 40, 40, cell.frame.size.width - 2*x - 40, height)];
    contenLabel.backgroundColor = [UIColor clearColor];
    contenLabel.numberOfLines = 0;
    contenLabel.text = [dic objectForKey:@"content"];
    [contenLabel setFont:[UIFont systemFontOfSize:16]];
    [cell addSubview:contenLabel];
    
    y += height + 5;
    
    if (![images isEqualToString:@""] && images != nil) {
        if (![images isEqualToString:@""] && images != nil) {
            UIScrollView *imagesView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 40+height+5, 280, ImageViewHeight)];
            imagesView.backgroundColor = [UIColor clearColor];
            imagesView.tag = 100+indexPath.row;
            imagesView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
            [imagesView addGestureRecognizer:tap];
            
            
            CGFloat imagex = 0;
            CGFloat imagey = 0;
            for (NSString *name in [images componentsSeparatedByString:@","]) {
                NSString *imageUrl = [NSString stringWithFormat:@"%@%@.thumb.jpg",upload_image_root_url,name];
                UIImageView *iv = [[UIImageView alloc] init];
                [iv sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"image_loading"]];
                iv.contentMode = UIViewContentModeScaleAspectFit;
                [iv setFrame:CGRectMake(imagex,imagey, ImageViewHeight, ImageViewHeight)];
                iv.backgroundColor = [UIColor clearColor];
                [imagesView addSubview:iv];
                imagex += ImageViewHeight;
            }
            imagesView.contentSize = CGSizeMake(imagex, ImageViewHeight);
            [cell addSubview:imagesView];
            
            y += ImageViewHeight;
        }

    }
    
    y += 5;
    
    NSString *postQuestionUsername = [self.question objectForKey:@"username"];
    if ([postQuestionUsername isEqualToString:TeaHomeAppDelegate.username] &&
        [[self.question objectForKey:@"ended"] boolValue] == 0) {
        UIButton *acceptedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        acceptedBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        acceptedBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [acceptedBtn setFrame:CGRectMake(200, 0, 120,44)];
        BOOL accepted = [[dic objectForKey:@"accepted"] boolValue];
        if (accepted) {
            [acceptedBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [acceptedBtn setTitle:@"已接受" forState:UIControlStateNormal];
            [acceptedBtn setEnabled:NO];
        }else{
            [acceptedBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [acceptedBtn setTitle:@"接受" forState:UIControlStateNormal];
        }
        acceptedBtn.tag = [[dic objectForKey:@"id"] intValue];
        [acceptedBtn addTarget:self action:@selector(acceptedAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = acceptedBtn;
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)acceptedAction:(id)sender
{
    UIButton *b = (UIButton *)sender;
    if ([b.titleLabel.text isEqualToString:@"接受"]) {
        NSString *str = [NSString stringWithFormat:@"%@%@&question=%d&answer=%d&username=%@",CMD_URL,accepted_answer_cmd,[[self.question objectForKey:@"id"] intValue],b.tag,TeaHomeAppDelegate.username];
        id json = [Utils getJsonDataFromWeb:str];
        if (json != nil) {
            if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
                [b setTitle:@"已接受" forState:UIControlStateNormal];
                [b setEnabled:NO];
                [b setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            }
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"网络链接出错，请稍后再试."
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)handleTapAction:(UITapGestureRecognizer *)tap
{
    UIView *v = tap.view;
    if (v.tag == 0) {
        //点击的内容
        NSString *images = [self.question objectForKey:@"images"];
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
        NSDictionary *dic = [self.answers objectAtIndex:(v.tag -100)];
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
        username = [self.question objectForKey:@"username"];
    }else{
        //答复区
        NSDictionary *dic = [self.answers objectAtIndex:tag-100];
        username = [dic objectForKey:@"username"];
    }
    
    SimpleUserinfoViewController *suvc = [[SimpleUserinfoViewController alloc] init];
    suvc.username = username;
    [self.navigationController pushViewController:suvc animated:YES];
}

@end
