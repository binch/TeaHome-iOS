//
//  CartDetailViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-11.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "CartDetailViewController.h"
#import "CartItem.h"
#import "OrderDetailViewController.h"

#define new_order_cmd @"new_order"
@interface CartDetailViewController ()
{
    UIScrollView *holderView;
    float total;
}
@end

@implementation CartDetailViewController

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

    self.view.backgroundColor = [Utils hexStringToColor:view_back_color];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIImage *submitImage = [UIImage imageNamed:@"bill_submit_button"];
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(0, 0, submitImage.size.width, submitImage.size.height);
    [submitBtn setImage:submitImage forState:UIControlStateNormal];
    [submitBtn addTarget:self action:@selector(payAction:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *payItem = [[UIBarButtonItem alloc] initWithCustomView:submitBtn];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:payItem, nil];
    
    CGFloat x=15,y = 10;
    CGFloat holderWidth = 280,labelHeight = 20;
    CGFloat leftTitleLabelWidth = 60;
    
    holderView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, 10, holderWidth, self.view.bounds.size.height - 135)];
    holderView.backgroundColor = [UIColor whiteColor];
    holderView.layer.borderWidth = 0.5;
    holderView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    holderView.layer.cornerRadius = 5;
    [self.view addSubview:holderView];
  
    //name
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, leftTitleLabelWidth, labelHeight)];
    nameLabel.font = [UIFont boldSystemFontOfSize:13];
    nameLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    nameLabel.text = @"收 件 人 :";
    [holderView addSubview:nameLabel];
    
    NSString *nameText = [Utils fetchDataFromUserDefaults:NameSetting];
    self.nameTF = [[UITextField alloc] initWithFrame:CGRectMake( x + 65, y, 180, 20)];
    if([nameText isEqualToString:UnDefined]){
        self.nameTF.placeholder = UnDefined;
    }else{
        self.nameTF.text = nameText;
    }
    self.nameTF.background = [UIImage imageNamed:@"bill_inputbox"];
    self.nameTF.delegate = self;
    self.nameTF.returnKeyType = UIReturnKeyNext;
    self.nameTF.font = [UIFont systemFontOfSize:13];
    [holderView addSubview:self.nameTF];
    
    y += 25;
    
    //phone
    NSString *phoneText = [Utils fetchDataFromUserDefaults:PhoneSetting];
    UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, leftTitleLabelWidth, labelHeight)];
    phoneLabel.font = [UIFont boldSystemFontOfSize:13];
    phoneLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    phoneLabel.text = @"联系电话:";
    [holderView addSubview:phoneLabel];
    
    self.phoneTF = [[UITextField alloc] initWithFrame:CGRectMake(x+65, y, 180, 20)];
    if([phoneText isEqualToString:UnDefined]){
        self.phoneTF.placeholder = UnDefined;
    }else{
        self.phoneTF.text = phoneText;
    }
    self.phoneTF.keyboardType = UIKeyboardTypeNamePhonePad;
    self.phoneTF.delegate = self;
    self.phoneTF.background = [UIImage imageNamed:@"bill_inputbox"];
    self.phoneTF.returnKeyType = UIReturnKeyNext;
    self.phoneTF.font = [UIFont systemFontOfSize:13];
    [holderView addSubview:self.phoneTF];
    y  += 25;
    
    //address
    NSString *addrText = [Utils fetchDataFromUserDefaults:AddrSetting];
    UILabel *addrLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, leftTitleLabelWidth, labelHeight)];
    addrLabel.font = [UIFont boldSystemFontOfSize:13];
    addrLabel.numberOfLines = 0;
    addrLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    addrLabel.text = @"收件地址:";
    [holderView addSubview:addrLabel];
    
    self.addrTF = [[UITextField alloc] initWithFrame:CGRectMake(x+65, y, 180, 20)];
    if([addrText isEqualToString:UnDefined]){
        self.addrTF.placeholder = UnDefined;
    }else{
        self.addrTF.text = addrText;
    }
    self.addrTF.background = [UIImage imageNamed:@"bill_inputbox"];
    self.addrTF.returnKeyType = UIReturnKeyDone;
    self.addrTF.delegate = self;
    self.addrTF.font = [UIFont systemFontOfSize:13];
    [holderView addSubview:self.addrTF];
    
    y += 25;
    
    y += 2;
    //分割线
    UIImage *line1 = [UIImage imageNamed:@"grey_space_line"];
    UIImageView *line1View = [[UIImageView alloc] initWithImage:line1];
    line1View.frame = CGRectMake(x, y, holderWidth- 2*x, line1.size.height);
    [holderView addSubview:line1View];
    y += 2;
    
    //订购商品
    UILabel *ptLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y,leftTitleLabelWidth , labelHeight)];
    ptLabel.font = [UIFont boldSystemFontOfSize:13];
    ptLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    ptLabel.text = @"订购商品:";
    [holderView addSubview:ptLabel];
    
    y += labelHeight + 5;
    
    self.cartItemsView = [[UITableView alloc] initWithFrame:CGRectMake(x, y, holderWidth-2*x, 240)];
    self.cartItemsView.delegate = self;
    self.cartItemsView.dataSource = self;
    self.cartItemsView.scrollEnabled = NO;
    self.cartItemsView.backgroundColor = [UIColor clearColor];
    [holderView addSubview:self.cartItemsView];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.cartItems = [TeaHomeAppDelegate.cartsDic allKeys];
    if ([self.cartItems count] <= 0) {
        self.cartItemsView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }else{
        self.cartItemsView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        CGRect rect = self.cartItemsView.frame;
        rect.size.height = 60 * [self.cartItems count];
        self.cartItemsView.frame = rect;
        
        holderView.contentSize = CGSizeMake(holderView.frame.size.width, 90 + 60 *[self.cartItems count]);
    }
    
    [self refreshTotalPrice];
    [self.cartItemsView reloadData];
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    if ([[TeaHomeAppDelegate.cartsDic allValues] count] > 0) {
        [Utils saveDataToUserDefaults:CartItems withValue:TeaHomeAppDelegate.cartsDic];
    }else{
        [Utils saveDataToUserDefaults:CartItems withValue:[NSMutableDictionary dictionary]];
    }
}

-(void)payAction:(id)sender
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    if ([self.nameTF.text isEqualToString:@""]) {
        [Utils saveDataToUserDefaults:NameSetting withValue:UnDefined];
    }else{
        [Utils saveDataToUserDefaults:NameSetting withValue:self.nameTF.text];
    }
    if ([self.phoneTF.text isEqualToString:@""]) {
        [Utils saveDataToUserDefaults:PhoneSetting withValue:UnDefined];
    }else{
        [Utils saveDataToUserDefaults:PhoneSetting withValue:self.phoneTF.text];
    }
    if ([self.addrTF.text isEqualToString:@""]) {
        [Utils saveDataToUserDefaults:AddrSetting withValue:UnDefined];
    }else{
        [Utils saveDataToUserDefaults:AddrSetting withValue:self.addrTF.text];
    }
    
    if ([self.cartItems count] == 0) {
        [Utils showAlertViewWithMessage:@"购物车中没有物品."];
        return;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认订单信息"
                                                    message:[NSString stringWithFormat:@"总额:%.1f元\n收件地址:%@",total,[Utils fetchDataFromUserDefaults:AddrSetting]]
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定购买",@"返回修改", nil];
    [alert show];
    
}

#pragma mark - alertview delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *str = [NSString stringWithFormat:@"%@%@&username=%@",CMD_URL,new_order_cmd,TeaHomeAppDelegate.username];
        NSString *itemsStr = @"&items=";
        for (int i=0;i<[self.cartItems count];i++) {
            id key = self.cartItems[i];
            NSData *ciData = [TeaHomeAppDelegate.cartsDic objectForKey:key];
            CartItem *ci = [NSKeyedUnarchiver unarchiveObjectWithData:ciData];
            NSDictionary *product = ci.product;
            int mount = ci.mount;
            int productId = [[product objectForKey:@"id"] intValue];
            itemsStr = [itemsStr stringByAppendingFormat:@"%d,%d",productId,mount];
            if (i < [self.cartItems count] - 1) {
                itemsStr = [itemsStr stringByAppendingString:@",,"];
            }
        }
        str = [str stringByAppendingString:itemsStr];
        
        NSString *nameStr = [Utils fetchDataFromUserDefaults:NameSetting];
        str = [str stringByAppendingFormat:@"&contact=%@",nameStr];
        
        NSString *addrStr = [Utils fetchDataFromUserDefaults:AddrSetting];
        str = [str stringByAppendingFormat:@"&addr=%@",addrStr];
        
        NSString *phoneStr = [Utils fetchDataFromUserDefaults:PhoneSetting];
        str = [str stringByAppendingFormat:@"&phone=%@",phoneStr];
        
        if ([nameStr isEqualToString:UnDefined] ||
            [addrStr isEqualToString:UnDefined] ||
            [phoneStr isEqualToString:UnDefined]) {
            [Utils showAlertViewWithMessage:@"您的收货信息有误,请设置."];
            return;
        }
        
        if ([[Utils fetchDataFromUserDefaults:PayMethodSetting] isEqualToString:@"支付宝"]) {
            str = [str stringByAppendingFormat:@"&pay=alipay"];
        }else{
            str = [str stringByAppendingFormat:@"&pay=cod"];
            
        }
        
        NSURL *url = [NSURL URLWithString:str];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [NSURLConnection sendAsynchronousRequest:request
                   queue:[NSOperationQueue mainQueue]
        completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
           if (data != nil) {
               NSError *error;
               id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
               if (json != nil) {
                   NSDictionary *result = (NSDictionary *)json;
                   if ([[result objectForKey:@"ret"] isEqualToString:@"ok"]) {
                       [Utils showAlertViewWithMessage:@"成功创建订单."];
                       [TeaHomeAppDelegate.cartsDic removeAllObjects];//删除购物车中的东西
                       
                       int orderId = [[result objectForKey:@"id"] intValue];
                       OrderDetailViewController *ovc = [[OrderDetailViewController alloc] init];
                       ovc.orderId = orderId;
                       [self.navigationController pushViewController:ovc animated:YES];
                   }
               }else{
                   [Utils showAlertViewWithMessage:@"网络连接出错,请稍后再试."];
               }
           }
       }];
    }
}

-(void)refreshTotalPrice
{
    total = 0;
    for (id key in self.cartItems) {
        NSData *ciData = [TeaHomeAppDelegate.cartsDic objectForKey:key];
        CartItem *ci = [NSKeyedUnarchiver unarchiveObjectWithData:ciData];
        NSDictionary *product = ci.product;
        int mount = ci.mount;
        float price = [[product objectForKey:@"price"] floatValue];
        total += price * mount;
    }
    self.title = [NSString stringWithFormat:@"订单总金额:%.1f元",total];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- textfield delegate method
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.nameTF]) {
        
        [self.phoneTF becomeFirstResponder];
    }else if ([textField isEqual:self.phoneTF]){
        
        [self.addrTF becomeFirstResponder];
    }else if ([textField isEqual:self.addrTF]){
        
        [textField resignFirstResponder];
    }
    
    return YES;
}
#pragma mark -- tableview delegate method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.cartItems count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"My_cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    id key = [self.cartItems objectAtIndex:indexPath.row];
    NSData *ciData = [TeaHomeAppDelegate.cartsDic objectForKey:key];
    CartItem *ci = [NSKeyedUnarchiver unarchiveObjectWithData:ciData];
    NSDictionary *product = ci.product;
    int mount = ci.mount;
    
    NSString *title = [product objectForKey:@"title"];
    float price = [[product objectForKey:@"price"] floatValue];
    int productId = [[product objectForKey:@"id"] intValue];
    
    NSString *product_image_url = [NSString stringWithFormat:@"%@%d.jpg",product_image_root_url,productId];
    
    CGFloat x=5,y=5;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 50, 50)];
    imageView.backgroundColor = [UIColor clearColor];
    [imageView sd_setImageWithURL:[NSURL URLWithString:product_image_url] placeholderImage:[UIImage imageNamed:@"image_loading"]];
    [cell addSubview:imageView];
    
    x += 55;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, 25)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 0;
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text = title;
    [cell addSubview:titleLabel];
    
    UILabel *soldLabel = [[UILabel alloc] initWithFrame:CGRectMake(x + 100, y, 60, 25)];
    soldLabel.backgroundColor = [UIColor clearColor];
    soldLabel.numberOfLines = 0;
    soldLabel.font = [UIFont systemFontOfSize:12];
    soldLabel.textColor = [UIColor blackColor];
    soldLabel.text = [NSString stringWithFormat:@"数量:%d份",mount];
    [cell addSubview:soldLabel];
    
    y += 25;
    
    UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, 25)];
    priceLabel.backgroundColor = [UIColor clearColor];
    priceLabel.numberOfLines = 0;
    priceLabel.font = [UIFont systemFontOfSize:12];
    priceLabel.textColor = [UIColor blackColor];
    priceLabel.text = [NSString stringWithFormat:@"价格:%.1f元",price];
    [cell addSubview:priceLabel];
    
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [deleteBtn setImage:[UIImage imageNamed:@"bill_minus_button"] forState:UIControlStateNormal];
    deleteBtn.frame = CGRectMake(x + 100, y, 57, 21);
    deleteBtn.tag = productId;
    [deleteBtn addTarget: self action:@selector(deleteAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:deleteBtn];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)deleteAction:(id)sender
{
    UIButton *b = (UIButton *)sender;
    
    [TeaHomeAppDelegate.cartsDic removeObjectForKey:[NSString stringWithFormat:@"%d",b.tag]];
    self.cartItems = [NSArray arrayWithArray:[TeaHomeAppDelegate.cartsDic allKeys]];
    [self.cartItemsView reloadData];
    
    [self refreshTotalPrice];
}

@end
