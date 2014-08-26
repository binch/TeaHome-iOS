//
//  FavorTableViewController.m
//  TeaHome
//
//  Created by Bin Chen on 14-8-19.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "FavorTableViewController.h"
#import "ThreadsViewController.h"
#import "FavorShopViewController.h"
#import "FavorItemTableViewController.h"

@interface FavorTableViewController ()

@end

@implementation FavorTableViewController

typedef NS_ENUM(int, kLabelTag) {
    kThreadLabelTag = 1,
    kShopLabelTag,
    kItemLabelTag,
};

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
    }else if (indexPath.row == 1) {
        [self handleTapGesture:kThreadLabelTag];
    }else if (indexPath.row == 2) {
        [self handleTapGesture:kShopLabelTag];
    }else if (indexPath.row == 3) {
        [self handleTapGesture:kItemLabelTag];
    } else if (indexPath.row == 4) {
        ThreadsViewController *tvc = [[ThreadsViewController alloc] init];
        tvc.his_username = TeaHomeAppDelegate.username;
        tvc.type = 2;
        tvc.name = @"我的贴子";
        [self.navigationController pushViewController:tvc animated:YES];
    }

}

-(void)handleTapGesture:(int )tag
{
    switch (tag) {
        case kThreadLabelTag:
        {
            ThreadsViewController *tvc = [[ThreadsViewController alloc] init];
            tvc.type = 1;
            tvc.name = @"收藏的贴子";
            [self.navigationController pushViewController:tvc animated:YES];
        }
            break;
        case kShopLabelTag:
        {
            FavorShopViewController *tvc = [[FavorShopViewController alloc] init];
            [self.navigationController pushViewController:tvc animated:YES];
        }
            break;
        case kItemLabelTag:
        {
            FavorItemTableViewController *ncvc = [[FavorItemTableViewController alloc] init];
            [self.navigationController pushViewController:ncvc animated:YES];
        }
            break;
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"我的收藏", @"我的收藏");
    }else if (indexPath.row == 1) {
        //staticContentCell.cellStyle = UITableViewCellStyleValue1;
        cell.textLabel.text = NSLocalizedString(@"贴子", @"贴子");
        cell.imageView.image = [UIImage imageNamed:@"user_chart"];
    }else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"店铺", @"店铺");
        cell.imageView.image = [UIImage imageNamed:@"user_bill"];
    }else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"商品", @"商品");
        cell.imageView.image = [UIImage imageNamed:@"user_bill"];
    } else if (indexPath.row == 4) {
        cell.textLabel.text = NSLocalizedString(@"我的贴子", @"我的贴子");
        cell.imageView.image = [UIImage imageNamed:@"user_chart"];
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
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
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

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
