//
//  SimpleUserinfoViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-15.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "SimpleUserinfoViewController.h"

#define get_userinfo_cmd @"get_userinfo"

@interface SimpleUserinfoViewController ()

@end

@implementation SimpleUserinfoViewController

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
    self.hidesBottomBarWhenPushed = YES;
    
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&username=%@",CMD_URL,get_userinfo_cmd,self.username];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       //   [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       if (data != nil) {
           NSError *error;
           id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (jsonObj != nil) {
               self.userInfo = jsonObj;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 140;
    }
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    NSString *nickName = [self.userInfo objectForKey:@"nickname"];
    NSString *username = self.username;
    NSString *thumb = [self.userInfo objectForKey:@"thumb"];
    NSString *desc = [self.userInfo objectForKey:@"desc"];
    int point = [[self.userInfo objectForKey:@"point"] intValue];
    NSString *grade = [self.userInfo objectForKey:@"grade"];
    
     CGFloat descHeight = [Utils heightForString:[NSString stringWithFormat:@"个人简介:%@",desc] withWidth:160 withFont:12];
    
    CGFloat x = 30 ;
    
    if (indexPath.row == 0) {
        
        CGFloat y = 30;
        
        UIImage *home_icon = [UIImage imageNamed:@"user_icon"];
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.frame = CGRectMake(30, (120+descHeight-home_icon.size.height)/2, home_icon.size.width, home_icon.size.height);
        if ([thumb isEqualToString:@""] || thumb == nil) {
            [iconView setImage:home_icon];
        }else{
            [iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,thumb]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
        }
        [cell addSubview:iconView];
        
        UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, y, 160, 30)];
        nickLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        nickLabel.text = nickName;
        nickLabel.font = [UIFont systemFontOfSize:15];
        [cell addSubview:nickLabel];
        
        y += 40;
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, y, 160, descHeight)];
        descLabel.font = [UIFont systemFontOfSize:12];
        descLabel.textColor = [UIColor lightGrayColor];
        descLabel.numberOfLines = 0;
        descLabel.text = [NSString stringWithFormat:@"个人简介:%@",desc];
        [cell addSubview:descLabel];
    
    }else if (indexPath.row == 1) {
        
        CGFloat y = 10;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 130, 20)];
        titleLabel.text = @"用户名";
        titleLabel.textColor = [UIColor blackColor];
        [cell addSubview:titleLabel];
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 130, 20)];
        usernameLabel.text = username;
        usernameLabel.textAlignment = NSTextAlignmentRight;
        usernameLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        [cell addSubview:usernameLabel];
    }else if (indexPath.row == 2) {
        
        CGFloat y = 10;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 130, 20)];
        titleLabel.text = @"积分";
        titleLabel.textColor = [UIColor blackColor];
        [cell addSubview:titleLabel];
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 130, 20)];
        usernameLabel.text = [NSString stringWithFormat:@"%d",point];
        usernameLabel.textAlignment = NSTextAlignmentRight;
        usernameLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        [cell addSubview:usernameLabel];
    }else if (indexPath.row == 3) {
        
        CGFloat y = 10;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 130, 20)];
        titleLabel.text = @"等级";
        titleLabel.textColor = [UIColor blackColor];
        [cell addSubview:titleLabel];
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 130, 20)];
        usernameLabel.text = grade;
        usernameLabel.textAlignment = NSTextAlignmentRight;
        usernameLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        [cell addSubview:usernameLabel];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
