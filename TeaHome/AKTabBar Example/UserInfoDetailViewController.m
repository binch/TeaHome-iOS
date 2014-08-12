//
//  UserInfoDetailViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-14.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "UserInfoDetailViewController.h"

typedef NS_ENUM(int, kAlertType){
    kAlertTypeUserName = 0,
    kAlertTypeNickName,
    kAlertTypeDesc,
    kAlertTypeIcon,
    kAlertTypePoint,
    kAlertTypeGrade,
};

@interface UserInfoDetailViewController ()

@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) NSMutableData *recievedData;


@property(nonatomic,strong) NSString *nickname;
@property(nonatomic,strong) NSString *desc;
@property(nonatomic,strong) NSString *thumb;
@property(nonatomic,strong) NSString *grade;
@property(nonatomic,assign) int point;

@end

@implementation UserInfoDetailViewController

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
    
    self.nickname = [self.userInfo objectForKey:@"nickname"];
    self.thumb = [self.userInfo objectForKey:@"thumb"];
    self.grade = [self.userInfo objectForKey:@"grade"];
    self.point = [[self.userInfo objectForKey:@"point"] intValue];
    self.desc = [self.userInfo objectForKey:@"desc"];
    self.hidesBottomBarWhenPushed = YES;

}

-(void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -- tableview delegat method
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
   cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat margin = 20;
    CGFloat labelWidth = 100,labelHeight = 30;
    
    if (indexPath.row == 0) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, labelWidth, labelHeight)];
        titleLabel.text = @"用户名";
        titleLabel.textColor = [UIColor blackColor];
        [cell addSubview:titleLabel];
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160+margin, margin, labelWidth, labelHeight)];
        usernameLabel.text = TeaHomeAppDelegate.username;
        usernameLabel.textAlignment = NSTextAlignmentRight;
        usernameLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        [cell addSubview:usernameLabel];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if (indexPath.row == 1) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, labelWidth, labelHeight)];
        titleLabel.text = @"我的昵称";
        titleLabel.textColor = [UIColor blackColor];
        [cell addSubview:titleLabel];
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160+margin, margin, labelWidth, labelHeight)];
        usernameLabel.text = self.nickname;
        usernameLabel.textAlignment = NSTextAlignmentRight;
        usernameLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        [cell addSubview:usernameLabel];
    }else if (indexPath.row == 2) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, labelWidth, labelHeight)];
        titleLabel.text = @"我的简介";
        titleLabel.textColor = [UIColor blackColor];
        [cell addSubview:titleLabel];
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160+margin, margin, labelWidth, labelHeight)];
        usernameLabel.text = self.desc;
        usernameLabel.textAlignment = NSTextAlignmentRight;
        usernameLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        [cell addSubview:usernameLabel];
    }else if (indexPath.row == 3) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, labelWidth, labelHeight)];
        titleLabel.text = @"我的头像";
        titleLabel.textColor = [UIColor blackColor];
        [cell addSubview:titleLabel];
        
        UIImage *home_icon = [UIImage imageNamed:@"user_icon_preset"];
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.frame = CGRectMake(240, 15, home_icon.size.width, home_icon.size.height);
        if ([self.thumb isEqualToString:@""] || self.thumb == nil) {
            [iconView setImage:home_icon];
        }else{
            [iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,self.thumb]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
        }
        [cell addSubview:iconView];
    }else if (indexPath.row == 4) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, labelWidth, labelHeight)];
        titleLabel.text = @"我的积分";
        titleLabel.textColor = [UIColor blackColor];
        [cell addSubview:titleLabel];
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160+margin, margin, labelWidth, labelHeight)];
        usernameLabel.text = [NSString stringWithFormat:@"%d",self.point];
        usernameLabel.textAlignment = NSTextAlignmentRight;
        usernameLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        [cell addSubview:usernameLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else if (indexPath.row == 5) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin, labelWidth, labelHeight)];
        titleLabel.text = @"我的等级";
        titleLabel.textColor = [UIColor blackColor];
        [cell addSubview:titleLabel];
        
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(160+margin, margin, labelWidth, labelHeight)];
        usernameLabel.text = self.grade;
        usernameLabel.textAlignment = NSTextAlignmentRight;
        usernameLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        [cell addSubview:usernameLabel];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //do nothing
    }else if (indexPath.row == 1) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert setTitle:@"修改昵称:"];
        [alert addButtonWithTitle:@"确定"];
        [alert addButtonWithTitle:@"取消"];
        [alert setDelegate: self];
        [alert setTag:kAlertTypeNickName];
        [alert show];
    }else if (indexPath.row == 2) {
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        [alert setTitle:@"修改简介:"];
        [alert addButtonWithTitle:@"确定"];
        [alert addButtonWithTitle:@"取消"];
        [alert setDelegate: self];
        [alert setTag:kAlertTypeDesc];
        [alert show];
    }else if (indexPath.row == 3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改头像:"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"从相册选取",@"从相机选取",@"取消", nil];
        alert.tag = kAlertTypeIcon;
        [alert show];
    }else if (indexPath.row == 4) {
        //do nothing
    }else if (indexPath.row == 5) {
        //do nothing
    }
}

#pragma mark -- update user info
-(void)updateUserInfo
{
    NSString *str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&thumb=%@&desc=%@&nickname=%@",CMD_URL,update_userinfo_cmd,TeaHomeAppDelegate.username,TeaHomeAppDelegate.password,[Utils getHtmlStringFromString:self.thumb],[Utils getHtmlStringFromString:self.desc],[Utils getHtmlStringFromString:self.nickname]];
    id json = [Utils getJsonDataFromWeb:str];
    if (json != nil) {
        if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
            NSLog(@"更新成功.");
            [self.tableView reloadData];
        }else{
            [Utils showAlertViewWithMessage:[json objectForKey:@"reason"]];
        }
    }
    
}

#pragma mark -- alert view delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case kAlertTypeNickName:
        {
            if (buttonIndex == 0) {
                UITextField *tf = [alertView textFieldAtIndex:0];
                if (![tf.text isEqualToString:@""]) {
                    self.nickname = tf.text;
                    [self updateUserInfo];
                }
            }
            
        }
            break;
        case kAlertTypeDesc:
        {
            if (buttonIndex == 0) {
                UITextField *tf = [alertView textFieldAtIndex:0];
                if (![tf.text isEqualToString:@""]) {
                    self.desc = tf.text;
                    [self updateUserInfo];
                }
            }
        }
            break;
        case kAlertTypeIcon:
        {
            if (buttonIndex == 0) {
                [self pickImageFromAlbum];
            }else if (buttonIndex == 1){
                [self pickImageFromCamera];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 从用户相册获取活动图片
- (void)pickImageFromAlbum
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [Utils showAlertViewWithMessage:@"不支持从相册选取图片."];
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark 从摄像头获取活动图片
- (void)pickImageFromCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [Utils showAlertViewWithMessage:@"不支持从相机选取图片."];
        return;
    }
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *imageName = [NSString stringWithFormat:@"%@.png",[dateFormatter stringFromDate:[NSDate date]]];
    
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    [self saveImage:image WithName:imageName];
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    [self upLoadImageToServer:imageName];
}

#pragma mark 保存图片到document
- (void)saveImage:(UIImage *)tempImage WithName:(NSString *)imageName
{
    int fiftyK = 100 * 1024;
    CGFloat width = 800;
    if (UIImageJPEGRepresentation(tempImage, 1) != nil) {
        NSData *originData = UIImageJPEGRepresentation(tempImage, 1);
        if (originData.length > fiftyK) {
            UIImage *image = tempImage;
            //先缩放
            if (tempImage.size.width > width) {
                image = [self imageWithImage:tempImage scaledToSize:CGSizeMake(width, tempImage.size.height * width / tempImage.size.width)];
            }else if(tempImage.size.height > width){
                image = [self imageWithImage:tempImage scaledToSize:CGSizeMake(tempImage.size.width * width / tempImage.size.height, width)];
            }
            originData = UIImageJPEGRepresentation(image, 1);
            CGFloat scale = 0.1;
            while (originData.length > fiftyK) {
                //无损保真压缩
                originData = UIImageJPEGRepresentation(image, scale);
                scale *= 0.1;
            }
        }
        NSString* fullPathToFile = [[self documentFolderPath] stringByAppendingPathComponent:imageName];
        // and then we write it out
        [originData writeToFile:fullPathToFile atomically:YES];
    }else{
        NSData *originData = UIImagePNGRepresentation(tempImage);
        if (originData.length > fiftyK) {
            //先缩放
            UIImage *image = [self imageWithImage:tempImage scaledToSize:CGSizeMake(tempImage.size.width * 0.1, tempImage.size.height * 0.1)];
            originData = UIImagePNGRepresentation(image);
        }
        // Now we get the full path to the file
        NSString* fullPathToFile = [[self documentFolderPath] stringByAppendingPathComponent:imageName];
        // and then we write it out
        [originData writeToFile:fullPathToFile atomically:YES];
    }
    
}

//对图片尺寸进行压缩--
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // End the context
    UIGraphicsEndImageContext();
    
    // Return the new image.
    return newImage;
}

#pragma mark 从文档目录下获取Documents路径
- (NSString *)documentFolderPath
{
    return NSTemporaryDirectory();
}

- (void)upLoadImageToServer:(NSString *)imageName
{
    NSURL *url = [NSURL URLWithString:upload_image_to_server_url];
    
    NSString *TWITTERFON_FORM_BOUNDARY = @"0xKhTmLbOuNdArY";
    //根据url初始化request
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //得到图片的data
    NSData* data;
    UIImage *image=[UIImage imageWithContentsOfFile:[[self documentFolderPath] stringByAppendingPathComponent:imageName]];
    //判断图片是不是png格式的文件
    if (UIImageJPEGRepresentation(image, 1)) {
        data = UIImageJPEGRepresentation(image, 1);
    }else {
        data = UIImagePNGRepresentation(image);
    }
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    
    ////添加分界线，换行
    [body appendFormat:@"%@\r\n",MPboundary];
    
    //声明pic字段，文件名为boris.png
    [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",@"image",imageName];
    //声明上传文件的格式
    [body appendFormat:@"Content-Type:image/jpeg, image/png\r\n\r\n"];
    
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    //将image的data加入
    [myRequestData appendData:data];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    self.hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    [self.view addSubview:self.hud];
    [self.hud show:YES];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

#pragma mark - nsurlconnection delegate method
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    /* bytesWritten                     How many bytes were sent to server at this time */
    /* totalBytesWritten               The number of bytes that were sent to the server currently */
    /* totalBytesExpectedToWrite     The number of bytes that we want to send to the server */
    CGFloat progress   = totalBytesWritten / (CGFloat)totalBytesExpectedToWrite;
    self.hud.progress = progress;
    if (progress == 1) {
        [self.hud hide:YES];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

// 收到回应
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (self.recievedData == nil) {
        self.recievedData = [NSMutableData data];
    }
    NSLog(@"receive the response");
    // 注意这里将NSURLResponse对象转换成NSHTTPURLResponse对象才能去
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    if ([response respondsToSelector:@selector(allHeaderFields)]) {
        NSDictionary *dictionary = [httpResponse allHeaderFields];
        NSLog(@"allHeaderFields: %@",dictionary);
    }
    [self.recievedData setLength:0];
}

// 接收数据
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"get some data");
    [self.recievedData appendData:data];
}

// 数据接收完毕
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.recievedData options:kNilOptions error:nil];
    if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
        self.thumb = [json objectForKey:@"name"];
        [self updateUserInfo];
    }
    
}

// 返回错误
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", error);
}
@end
