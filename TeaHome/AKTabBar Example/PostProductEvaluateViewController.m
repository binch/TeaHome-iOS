//
//  PostProductEvaluateViewController.m
//  TeaHome
//
//  Created by andylee on 14-7-14.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "PostProductEvaluateViewController.h"

#define post_item_comment_cmd @"post_item_comment"


@interface PostProductEvaluateViewController ()<UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSURLConnectionDataDelegate>
{
    UIScrollView *holderView;
    UITextField *titleField;
    UITextView *contentTextView;
    
    
    int xqPoint;
    int zwPoint;
    int npPoint;
    int yxPoint;
    
    NSMutableArray *uploadImages;
    
//    BOOL dataErr;
}

@property(nonatomic,strong) UIScrollView *imageView;
@property(nonatomic,strong) MBProgressHUD *hud;
@property(nonatomic,strong) NSMutableData *recievedData;

@end

@implementation PostProductEvaluateViewController

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
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hidesBottomBarWhenPushed = YES;
    
    xqPoint = -1;
    zwPoint = -1;
    npPoint = -1;
    yxPoint = -1;
    uploadImages = [NSMutableArray array];
    
    holderView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    holderView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:holderView];
    
    CGFloat x = 20, y = 20;
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 160, 30)];
    label1.textColor = [Utils hexStringToColor:navigation_bar_color];
    label1.font = [UIFont systemFontOfSize:17];
    label1.text = [NSString stringWithFormat:@"%@",@"发表您的评价"];
    [holderView addSubview:label1];
    
    y += label1.frame.size.height;
    
    y += 2;
    //分割线
    UIImage *lineImage1 = [UIImage imageNamed:@"grey_space_line"];
    UIImageView *lineIV1 = [[UIImageView alloc] initWithImage:lineImage1];
    lineIV1.frame = CGRectMake(x, y, holderView.frame.size.width - 2*x, lineImage1.size.height);
    [holderView addSubview:lineIV1];
    y += 2;
    
    y += 20;
    
    UIImage *like = [UIImage imageNamed:@"like_yes"];
    UIImage *unlike = [UIImage imageNamed:@"like_no"];
    
    x += 10;
    
    //香气
    UILabel *xiangqiLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, 20)];
    xiangqiLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    xiangqiLabel.font = [UIFont boldSystemFontOfSize:15];
    xiangqiLabel.text = @"香气";
    [holderView addSubview:xiangqiLabel];
    
    //评分图
    
    CGFloat pointx = xiangqiLabel.frame.origin.x + xiangqiLabel.frame.size.width;
    for (int i=1; i<6; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(pointx, y, 20, 20);
        [b setImage:unlike forState:UIControlStateNormal];
        [b setImage:like forState:UIControlStateHighlighted];
        [b setImage:like forState:UIControlStateSelected];
        [b addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
        b.tag = i;
        [holderView addSubview:b];
        pointx += 30;
    }
    
    y += 30;
    
    //滋味
    UILabel *ziweiLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, 20)];
    ziweiLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    ziweiLabel.font = [UIFont boldSystemFontOfSize:15];
    ziweiLabel.text = @"滋味";
    [holderView addSubview:ziweiLabel];
    
    //评分图
    
    pointx = ziweiLabel.frame.origin.x + ziweiLabel.frame.size.width;
    for (int i=6; i<11; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(pointx, y, 20, 20);
        [b setImage:unlike forState:UIControlStateNormal];
        [b setImage:like forState:UIControlStateHighlighted];
        [b setImage:like forState:UIControlStateSelected];
        [b addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
        b.tag = i;
        [holderView addSubview:b];
        pointx += 30;
    }
    
    y += 30;
    
    //耐泡度
    UILabel *naipaoLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, 20)];
    naipaoLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    naipaoLabel.font = [UIFont boldSystemFontOfSize:15];
    naipaoLabel.text = @"耐泡度";
    [holderView addSubview:naipaoLabel];
    
    //评分图
    
    pointx = naipaoLabel.frame.origin.x + naipaoLabel.frame.size.width;
    for (int i=11; i<16; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(pointx, y, 20, 20);
        [b setImage:unlike forState:UIControlStateNormal];
        [b setImage:like forState:UIControlStateHighlighted];
        [b setImage:like forState:UIControlStateSelected];
        [b addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
        b.tag = i;
        [holderView addSubview:b];
        pointx += 30;
    }
    
    y += 30;
    
    //叶形
    UILabel *yexingLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 100, 20)];
    yexingLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
    yexingLabel.font = [UIFont boldSystemFontOfSize:15];
    yexingLabel.text = @"叶形";
    [holderView addSubview:yexingLabel];
    
    //评分图
    
    pointx = yexingLabel.frame.origin.x + yexingLabel.frame.size.width;
    for (int i=16; i<21; i++) {
        UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
        b.frame = CGRectMake(pointx, y, 20, 20);
        [b setImage:unlike forState:UIControlStateNormal];
        [b setImage:like forState:UIControlStateHighlighted];
        [b setImage:like forState:UIControlStateSelected];
        [b addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];
        b.tag = i;
        [holderView addSubview:b];
        pointx += 30;
    }
    
    y += 40;
    
    x -= 10;
    
    y += 2;
    //分割线
    UIImage *lineImage2 = [UIImage imageNamed:@"grey_space_line"];
    UIImageView *lineIV2 = [[UIImageView alloc] initWithImage:lineImage2];
    lineIV2.frame = CGRectMake(x, y, holderView.frame.size.width - 2*x, lineImage2.size.height);
    [holderView addSubview:lineIV2];
    y += 2;
    
    x += 5;
    y += 10;
    
    //标题textfield
    UIImage *tfImage = [UIImage imageNamed:@"ask_title"];
    titleField = [[UITextField alloc] initWithFrame:CGRectMake(x, y, tfImage.size.width, tfImage.size.height)];
    titleField.background = tfImage;
    titleField.delegate = self;
    titleField.returnKeyType = UIReturnKeyNext;
    titleField.placeholder = @"添加标题";
    [holderView addSubview:titleField];
    
    y += tfImage.size.height + 10;
    
    UIImage *tvImage = [UIImage imageNamed:@"ask_content"];
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, tfImage.size.width, tvImage.size.height)];
    contentTextView.backgroundColor = [UIColor colorWithPatternImage:tvImage];
    contentTextView.delegate = self;
    [holderView addSubview:contentTextView];
    
    y += tvImage.size.height + 10;
    
    UIImage *addImage = [UIImage imageNamed:@"ask_add_photo"];
    UIButton *addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addImageBtn.frame = CGRectMake(x, y, 60, 54);
    [addImageBtn setImage:addImage forState:UIControlStateNormal];
    [addImageBtn addTarget:self action:@selector(addImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [holderView addSubview:addImageBtn];
    
    UIImage *postImage = [UIImage imageNamed:@"ask_confirm"];
    UIButton *postBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    postBtn.frame = CGRectMake(holderView.frame.size.width - x - postImage.size.width , y, postImage.size.width,postImage.size.height);
    [postBtn setImage:postImage forState:UIControlStateNormal];
    [postBtn addTarget:self action:@selector(postAction:) forControlEvents:UIControlEventTouchUpInside];
    [holderView addSubview:postBtn];
    
    y += postImage.size.height + 20;
    
    holderView.contentSize = CGSizeMake(holderView.frame.size.width, y);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    UIImage *image = [UIImage imageNamed:@"andy"];
//    [self saveImage:image WithName:@"andy.png"];
//    [self upLoadImageToServer:@"andy.png"];

}

-(void)likeAction:(UIButton *)sender
{
    int point = sender.tag;
    if (point >= 1 && point < 6) {
        xqPoint = point;
        for (int i=1; i<6; i++) {
            UIButton *b = (UIButton *)[holderView viewWithTag:i];
            if (i <= point) {
                b.selected = YES;
            }else{
                b.selected = NO;
            }
        }
    }else if (point >= 6 && point < 11) {
        zwPoint = point - 5;
        for (int i=6; i<11; i++) {
            UIButton *b = (UIButton *)[holderView viewWithTag:i];
            if (i <= point) {
                b.selected = YES;
            }else{
                b.selected = NO;
            }
        }
    }else if (point >= 11 && point < 16) {
        npPoint = point - 10;
        for (int i=11; i<16; i++) {
            UIButton *b = (UIButton *)[holderView viewWithTag:i];
            if (i <= point) {
                b.selected = YES;
            }else{
                b.selected = NO;
            }
        }
    }else if (point >= 16 && point < 21) {
        yxPoint = point - 15;
        for (int i=16; i<21; i++) {
            UIButton *b = (UIButton *)[holderView viewWithTag:i];
            if (i <= point) {
                b.selected = YES;
            }else{
                b.selected = NO;
            }
        }
    }
}

-(void)addImageAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改头像:"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"从相册选取",@"从相机选取",@"取消", nil];
    [alert show];
}

-(void)postAction:(id)sender
{
    [titleField resignFirstResponder];
    [contentTextView resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect r = self.view.frame;
        r.origin.y = 0;
        self.view.frame = r;
    }];
    
    if ([titleField.text isEqualToString:@""]) {
        [Utils showAlertViewWithMessage:@"标题不可为空."];
        return;
    }
    if ([contentTextView.text isEqualToString:@""]) {
        [Utils showAlertViewWithMessage:@"内容不可为空."];
        return;
    }
    if (xqPoint < 0 || zwPoint <0 || npPoint < 0 || yxPoint < 0) {
        [Utils showAlertViewWithMessage:@"还没打分哦."];
        return;
    }
    NSString *str = [NSString stringWithFormat:
                     @"%@%@&item=%d&username=%@&password=%@&xiangqi=%d&ziwei=%d&naipao=%d&yexing=%d&title=%@&content=%@&images=",
                     CMD_URL,post_item_comment_cmd,self.pid,
                     TeaHomeAppDelegate.username,TeaHomeAppDelegate.password,
                     xqPoint,zwPoint,npPoint,yxPoint,
                     [Utils getHtmlStringFromString:titleField.text],[Utils getHtmlStringFromString:contentTextView.text]];
    if ([uploadImages count] > 0) {
        for (int i=0;i<[uploadImages count];i++) {
            NSString *name = [uploadImages objectAtIndex:i];
            str = [ str stringByAppendingString:name];
            if (i < [uploadImages count] - 1) {
                str = [str stringByAppendingString:@","];
            }
        }
    }
    
    id json = [Utils getJsonDataFromWeb:str];
    if (json != nil) {
        if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
            [Utils showAlertViewWithMessage:@"发表评价成功."];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [Utils showAlertViewWithMessage:@"发表评价失败."];
        }
    }

}

-(void)handleTapAction:(UITapGestureRecognizer *)tap
{
    NSMutableArray *photos = [NSMutableArray array];
    for (NSString *name in uploadImages) {
        IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,name]]];
        [photos addObject:photo];
    }
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
    browser.displayActionButton = NO;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    [self presentViewController:browser animated:YES completion:nil];
}

#pragma mark -text field delegate method
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect r = self.view.frame;
        if (r.size.height > 480) {
            r.origin.y -= 130;
        }else{
            r.origin.y -= 130+88;
        }
        
        self.view.frame = r;
    }];
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [contentTextView becomeFirstResponder];
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
//    [UIView animateWithDuration:0.3 animations:^{
//        CGRect r = self.view.frame;
//        r.origin.y -= 30;
//        self.view.frame = r;
//    }];
    return YES;
}

#pragma mark -- alert view delegate method
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self pickImageFromAlbum];
    }else if (buttonIndex == 1){
        [self pickImageFromCamera];
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
    
    UIImage *image= [info objectForKey:@"UIImagePickerControllerOriginalImage"];
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
        [uploadImages addObject:[json objectForKey:@"name"]];

        if (self.imageView == nil) {
            self.imageView = [[UIScrollView alloc] initWithFrame:CGRectMake(25,contentTextView.frame.size.height + contentTextView.frame.origin.y + 80, holderView.bounds.size.width, 80)];
            self.imageView.backgroundColor = [UIColor clearColor];
            self.imageView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
            [self.imageView addGestureRecognizer:tap];
            
            [holderView addSubview:self.imageView];
            
            holderView.contentSize = CGSizeMake(holderView.frame.size.width, holderView.frame.size.height + 100);
        }
    
        UIImageView *iv = [[UIImageView alloc] init];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [iv sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,[json objectForKey:@"name"]]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
        iv.frame = CGRectMake(100*([uploadImages count]-1) , 0, 80, 80);
        [self.imageView addSubview:iv];
        self.imageView.contentSize = CGSizeMake(100*[uploadImages count] + 25, 80);
    }
    
}

// 返回错误
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", error);
}

@end
