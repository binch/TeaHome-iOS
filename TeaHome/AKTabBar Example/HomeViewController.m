//个人中心

#import "HomeViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "CartDetailViewController.h"
#import "WholeOrdersViewController.h"
#import "LoginViewController.h"
#import "NoteCenterViewController.h"
#import "UserInfoDetailViewController.h"

typedef NS_ENUM(int, kLabelTag) {
    kCartLabelTag = 1,
    kOrderLabelTag,
    kNotifyLabelTag,
    kNameLabelTag ,
    kAddrLabelTag,
    kPhoneLabelTag,
    kPayMethodLabelTag,
};

@interface HomeViewController ()

@property(nonatomic,strong) NSDictionary *userInfo;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"我";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"user_icon";
}

- (NSString *)tabTitle
{
	return self.title;
}


- (id) init {
    //分组列表样式
    self = [super initWithStyle:UITableViewStyleGrouped];
    //默认样式
    //self = [super init];
    
    if (!self) return nil;

	self.title = NSLocalizedString(@"关于我", @"个人中心");

	return self;
}

#pragma mark - View lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"退出登录" style:UIBarButtonItemStyleBordered target:self action:@selector(logoutAction:)];
//    self.navigationItem.rightBarButtonItem = item;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    [TeaHomeAppDelegate setItemBageNumberView];
    if ([TeaHomeAppDelegate.username isEqualToString:@""]) {
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:lvc animated:YES];
        return;
    }
    
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    
    //    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&username=%@&password=%@",CMD_URL,get_userinfo_cmd,TeaHomeAppDelegate.username,TeaHomeAppDelegate.password];
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
                   self.userInfo = jsonObj;
                   [self.tableView reloadData];
               }else{
                   [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
               }
           }
       }];
}

#pragma mark - tableview delegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        NSString *desc = [self.userInfo objectForKey:@"desc"];
        CGFloat descHeight = [Utils heightForString:[NSString stringWithFormat:@"个人简介:%@",desc] withWidth:140 withFont:10];
        return 120 + descHeight;
    }
    return 40;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *nickName = [self.userInfo objectForKey:@"nickname"];
    NSString *username = TeaHomeAppDelegate.username;
    NSString *thumb = [self.userInfo objectForKey:@"thumb"];
    NSString *desc = [self.userInfo objectForKey:@"desc"];
    CGFloat descHeight = [Utils heightForString:[NSString stringWithFormat:@"个人简介:%@",desc] withWidth:140 withFont:10];
    if (indexPath.row == 0) {
        UIImage *home_icon = [UIImage imageNamed:@"home_user_icon_preset"];
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.frame = CGRectMake(30, (120+descHeight-home_icon.size.height)/2, home_icon.size.width, home_icon.size.height);
        if ([thumb isEqualToString:@""] || thumb == nil) {
            [iconView setImage:home_icon];
        }else{
            [iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,thumb]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
        }
        [cell addSubview:iconView];
        
        UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 20, 140, 30)];
        nickLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        nickLabel.text = nickName;
        nickLabel.font = [UIFont systemFontOfSize:20];
        [cell addSubview:nickLabel];
        
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 50, 140, 10)];
        usernameLabel.font = [UIFont systemFontOfSize:10];
        usernameLabel.textColor = [UIColor lightGrayColor];
        usernameLabel.text = [NSString stringWithFormat:@"id:%@",username];
        [cell addSubview:usernameLabel];
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 65, 140, descHeight)];
        descLabel.font = [UIFont systemFontOfSize:10];
        descLabel.textColor = [UIColor lightGrayColor];
        descLabel.numberOfLines = 0;
        descLabel.text = [NSString stringWithFormat:@"个人简介:%@",desc];
        [cell addSubview:descLabel];
        
        UIImage *edit_icon = [UIImage imageNamed:@"user_edit_info"];
        UIButton *editView = [UIButton buttonWithType:UIButtonTypeCustom];
        editView.frame = CGRectMake(170, 70 + descHeight, edit_icon.size.width, edit_icon.size.height);
        [editView setBackgroundImage:edit_icon forState:UIControlStateNormal];
        [editView addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:editView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [Utils hexStringToColor:view_back_color];
    }else if (indexPath.row == 1) {
            //staticContentCell.cellStyle = UITableViewCellStyleValue1;
			cell.textLabel.text = NSLocalizedString(@"我的购物车", @"购物车");
			cell.imageView.image = [UIImage imageNamed:@"user_chart"];
    }else if (indexPath.row == 2) {
			cell.textLabel.text = NSLocalizedString(@"我的订单", @"订单");
			cell.imageView.image = [UIImage imageNamed:@"user_bill"];
    }else if (indexPath.row == 3) {
        if ([TeaHomeAppDelegate.unreadMessages count] > 0) {
            UIImage *redSpotImage = [UIImage imageNamed:@"red_spot"];
            UIButton *numberBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            numberBtn.frame = CGRectMake(cell.bounds.size.width - 50, 5, 30, 30);
            [numberBtn setBackgroundImage:redSpotImage forState:UIControlStateNormal];
            [numberBtn setTitle:[NSString stringWithFormat:@"%d",[TeaHomeAppDelegate.unreadMessages count]] forState:UIControlStateNormal];
            [numberBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            numberBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            [cell addSubview:numberBtn];
        }
        cell.textLabel.text = NSLocalizedString(@"通知中心", @"通知中心");
        cell.imageView.image = [UIImage imageNamed:@"user_info"];
    }else if (indexPath.row == 4) {
        cell.userInteractionEnabled = NO;
    }else if (indexPath.row == 5) {
        cell.textLabel.text = NSLocalizedString(@"退出登录", @"退出登录");
        [cell.textLabel setContentMode:UIViewContentModeCenter];
        //cell.imageView.image = [UIImage imageNamed:@"login"];
        cell.backgroundColor = [UIColor redColor];
    }
    
    return cell;
}
                           
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
       [self editAction:nil];
    }else if (indexPath.row == 1) {
       [self handleTapGesture:kCartLabelTag];
    }else if (indexPath.row == 2) {
       [self handleTapGesture:kOrderLabelTag];
    }else if (indexPath.row == 3) {
       [self handleTapGesture:kNotifyLabelTag];
    }else if (indexPath.row == 5) {
        [self logoutAction];
    }
}
                           
-(void)editAction:(UIButton *)b
{
    UserInfoDetailViewController *uidvc = [[UserInfoDetailViewController alloc] init];
    uidvc.userInfo = self.userInfo;
    [self.navigationController pushViewController:uidvc animated:YES];
}

//注销登录
-(void)logoutAction
{
    TeaHomeAppDelegate.username = @"";
    TeaHomeAppDelegate.password = @"";
    TeaHomeAppDelegate.unreadMessages = [NSMutableArray array];
    TeaHomeAppDelegate.readMessages = [NSMutableArray array];
    TeaHomeAppDelegate.atMessages = [NSMutableArray array];
    [[NSUserDefaults standardUserDefaults]  setObject:UnDefined forKey:Username];
    [[NSUserDefaults standardUserDefaults] setObject:UnDefined forKey:Password];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //通知中心取消
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    [self.navigationController pushViewController:lvc animated:YES];
}


-(void)handleTapGesture:(int )tag
{
    switch (tag) {
        case kCartLabelTag:
        {
            CartDetailViewController *cvc = [[CartDetailViewController alloc] init];
            [self.navigationController pushViewController:cvc animated:YES];
        }
            break;
        case kOrderLabelTag:
        {
            WholeOrdersViewController *ovc = [[WholeOrdersViewController alloc] init];
            [self.navigationController pushViewController:ovc animated:YES];
        }
            break;
        case kNotifyLabelTag:
        {
            NoteCenterViewController *ncvc = [[NoteCenterViewController alloc] init];
            [self.navigationController pushViewController:ncvc animated:YES];
        }
            break;
        case kNameLabelTag:
        {
            [self showAlertViewWith:@"修改默认接收人:" withTag:kNameLabelTag];
        }
            break;
        case kAddrLabelTag:
        {
            [self showAlertViewWith:@"修改默认接收地址:" withTag:kAddrLabelTag];
        }
            break;
        case kPhoneLabelTag:
        {
            [self showAlertViewWith:@"修改默认电话:" withTag:kPhoneLabelTag];
        }
            break;
        case kPayMethodLabelTag:
        {
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改默认支付方式:"
            //                                                            message:nil
            //                                                           delegate:self
            //                                                  cancelButtonTitle:nil
            //                                                  otherButtonTitles:@"支付宝",@"货到付款",@"取消", nil];
            //            alert.tag = kPayMethodLabelTag;
            //            [alert show];
            [Utils showAlertViewWithMessage:@"暂时只支持货到付款."];
        }
            break;
            
        default:
            break;
    }
    
   // [self performSelector:@selector(refreshLabelLayerBorderColor:) withObject:label afterDelay:1];
}

-(void)refreshLabelLayerBorderColor:(UILabel *)label
{
    label.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

//修改付款方式
-(void)showAlertViewWith:(NSString *)title withTag:(NSInteger)tag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithFrame:CGRectZero];
    [alert setTitle:title];
    [alert setDelegate: self];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = tag;
    if (tag == kPhoneLabelTag) {
        UITextField *tf = [alert textFieldAtIndex:0];
        tf.keyboardType = UIKeyboardTypeNumberPad;
    }
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    [alert show];
}

#pragma mark -- alert view delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kPayMethodLabelTag) {
        switch (buttonIndex) {
            case 0:
            {
                [Utils saveDataToUserDefaults:PayMethodSetting withValue:[NSString stringWithFormat:@"%d",kPayMethodAlipay]];
            }
                break;
            case 1:
            {
                [Utils saveDataToUserDefaults:PayMethodSetting withValue:[NSString stringWithFormat:@"%d",kPayMethodCOD]];
            }
                break;
                
            default:
                break;
        }
       // [self refreshView];
        
        return;
    }
    
    //将用户提交数据保存
    UITextField *tf = [alertView textFieldAtIndex:0];
    NSString *text = [tf text];
    if (buttonIndex == 0) {
        switch (alertView.tag) {
            case kNameLabelTag:
            {
                if ([text isEqualToString:@""]) {
                    [Utils saveDataToUserDefaults:NameSetting withValue:UnDefined];
                }else{
                    [Utils saveDataToUserDefaults:NameSetting withValue:text];
                }
                
            }
                break;
            case kAddrLabelTag:
            {
                if ([text isEqualToString:@""]) {
                    [Utils saveDataToUserDefaults:AddrSetting withValue:UnDefined];
                }else{
                    [Utils saveDataToUserDefaults:AddrSetting withValue:text];
                }
            }
                break;
            case kPhoneLabelTag:
            {
                if ([text isEqualToString:@""]) {
                    [Utils saveDataToUserDefaults:PhoneSetting withValue:UnDefined];
                }else{
                    [Utils saveDataToUserDefaults:PhoneSetting withValue:text];
                }
            }
                break;
                
            default:
                break;
        }
    }
    //[self refreshView];
}


@end