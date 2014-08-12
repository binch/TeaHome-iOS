//
//  PostThreadViewController.m
//  TeaHome
//
//  Created by andylee on 14-6-25.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//
//回帖，发帖，提问，回答问题

#import "PostThreadViewController.h"
#import "SNPopupView+UsingPrivateMethod.h"
#import <ImageIO/ImageIO.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define post_thread_cmd @"post_thread"
#define post_reply_cmd @"post_reply"
#define post_question_cmd @"post_question"
#define post_answer_cmd @"post_answer"
#define get_cats_cmd @"get_qa_cats"

@interface PostThreadViewController ()

@property(nonatomic,strong) MBProgressHUD *postHUD;
@property(nonatomic,strong) UIImagePickerController *imagePicker;
@property(nonatomic,strong) SNPopupView *popview;

@end

@implementation PostThreadViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.hidesBottomBarWhenPushed=YES;
    
    if (self.style == kPostStyleQuestion) {
        UIImage *titleBackImage = [UIImage imageNamed:@"ask_title"];
        self.titeLabel = [[UITextField alloc] initWithFrame:CGRectMake(20, 10, titleBackImage.size.width, titleBackImage.size.height)];
        self.titeLabel.background = titleBackImage;
        self.titeLabel.placeholder = @"请输入标题";
        self.titeLabel.font = [UIFont systemFontOfSize:13];
        self.titeLabel.textColor = [UIColor blackColor];
        [self.view addSubview:self.titeLabel];
    }
    
    UIImage *contentBackimage = [UIImage imageNamed:@"ask_content"];
    self.contentView = [[UITextView alloc] init];
    if (self.titeLabel) {
        self.contentView.frame = CGRectMake(self.titeLabel.frame.origin.x, 10 + self.titeLabel.frame.origin.y + self.titeLabel.frame.size.height, contentBackimage.size.width, contentBackimage.size.height);
    }else{
        self.contentView.frame = CGRectMake((self.view.bounds.size.width - contentBackimage.size.width) / 2, 10, contentBackimage.size.width, contentBackimage.size.height);
    }
    self.contentView.backgroundColor = [UIColor colorWithPatternImage:contentBackimage];
    self.contentView.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:self.contentView];
    
    
    UIImage *addImage = [UIImage imageNamed:@"ask_add_photo"];
    self.addImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self.titeLabel) {
        self.addImageBtn.frame = CGRectMake(self.contentView.frame.origin.x, 10 + self.contentView.frame.origin.y + self.contentView.frame.size.height, addImage.size.width, addImage.size.height);
    }else{
        self.addImageBtn.frame = CGRectMake(self.contentView.frame.origin.x, 10 + self.contentView.frame.origin.y + self.contentView.frame.size.height, addImage.size.width, addImage.size.height);
    }
    [self.addImageBtn addTarget:self action:@selector(chooseImageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.addImageBtn setImage:addImage forState:UIControlStateNormal];
    [self.view addSubview:self.addImageBtn];
    
    self.uploadImages = [NSMutableArray array];
    
    UIBarButtonItem *postItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStyleBordered target:self action:@selector(postAction:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:postItem, nil];
    
    if (self.style == kPostStyleReply) {
        [self.contentView becomeFirstResponder];
        self.contentView.text = [NSString stringWithFormat:@"@%@ ",self.nickname];
    }
    
    self.postHUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.postHUD.labelText = @"取消";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelHUD:)];
    [self.postHUD addGestureRecognizer:tap];
    
    [self.view addSubview:self.postHUD];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    UIImage *image = [UIImage imageNamed:@"test.jpg"];
//    [self saveImage:image WithName:@"test.png"];
//    [self upLoadImageToServer:@"test.png"];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)chooseImageAction:(UIBarButtonItem *)item
{
//    UIImage *image = [UIImage imageNamed:@"test.jpg"];
//    [self saveImage:image WithName:@"test.png"];
//    [self upLoadImageToServer:@"test.png"];
//    return;
    //TODO
    UIView *chooseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 81)];
    
    UIButton *album = [UIButton buttonWithType:UIButtonTypeCustom];
    album.frame = CGRectMake(0, 0, 100, 40);
    album.backgroundColor = [UIColor clearColor];
    album.titleLabel.font = [UIFont systemFontOfSize:15];
    [album addTarget:self action:@selector(pickImageFromAlbum) forControlEvents:UIControlEventTouchUpInside];
    [album setTitle:@"从相册选取" forState:UIControlStateNormal];
    [chooseView addSubview:album];
    
    UIButton *cam = [UIButton buttonWithType:UIButtonTypeCustom];
    cam.frame = CGRectMake(0,41, 100, 40);
    cam.backgroundColor = [UIColor clearColor];
    cam.titleLabel.font = [UIFont systemFontOfSize:15];
    [cam addTarget:self action:@selector(pickImageFromCamera) forControlEvents:UIControlEventTouchUpInside];
    [cam setTitle:@"从相机选取" forState:UIControlStateNormal];
    [chooseView addSubview:cam];

    
    self.popview = [[SNPopupView alloc] initWithContentView:chooseView contentSize:chooseView.bounds.size];
    CGPoint point = CGPointMake(self.addImageBtn.frame.origin.x + self.addImageBtn.frame.size.width/2, self.addImageBtn.frame.size.height + self.addImageBtn.frame.origin.y);
    [self.popview presentModalAtPoint:point inView:self.view];
}

#pragma mark 从用户相册获取活动图片
- (void)pickImageFromAlbum
{
    [self.popview dismiss:YES];
    
    if (self.imagePicker) {
        self.imagePicker = nil;
    }
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark 从摄像头获取活动图片
- (void)pickImageFromCamera
{
    [self.popview dismiss:YES];
    
    if (self.imagePicker) {
        self.imagePicker = nil;
    }
    
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *imageName = [NSString stringWithFormat:@"%@.jpg",[dateFormatter stringFromDate:[NSDate date]]];

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
            originData = UIImageJPEGRepresentation(image, 0.1);
//            CGFloat scale = 0.1;
//            while (originData.length > fiftyK) {
//                //无损保真压缩
//                originData = UIImageJPEGRepresentation(image, scale);
//                scale *= 0.1;
//            }
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
    self.hud.labelText = @"取消";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelHUD:)];
    [self.hud addGestureRecognizer:tap];
    
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
//    NSString *results = [[NSString alloc]
//                         initWithBytes:[self.recievedData bytes]
//                         length:[self.recievedData length]
//                         encoding:NSUTF8StringEncoding];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:self.recievedData options:kNilOptions error:nil];
    if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
        [self.uploadImages addObject:[json objectForKey:@"name"]];
        [Utils showAlertViewWithMessage:@"上传图片成功."];
        
        if (self.imageView == nil) {
            self.imageView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, self.addImageBtn.frame.origin.y + self.addImageBtn.frame.size.height + 10, self.view.bounds.size.width, 80)];
            self.imageView.backgroundColor = [UIColor clearColor];
            self.imageView.userInteractionEnabled = YES;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
            [self.imageView addGestureRecognizer:tap];
            
            [self.view addSubview:self.imageView];
        }
        
        UIImageView *iv = [[UIImageView alloc] init];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [iv sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.thumb.jpg",upload_image_root_url,[json objectForKey:@"name"]]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
        iv.frame = CGRectMake(100*([self.uploadImages count]-1) , 0, 80, 80);
        [self.imageView addSubview:iv];
        self.imageView.contentSize = CGSizeMake(100*[self.uploadImages count]+20, 80);
    }

}

// 返回错误
-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed: %@", error);
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [Utils showAlertViewWithMessage:[NSString stringWithFormat:@"%@",error]];
}

#pragma mark -- photo browser delegate method
-(void)handleTapAction:(UITapGestureRecognizer *)tap
{
    NSMutableArray *photos = [NSMutableArray new];
    for (NSString *fileName in self.uploadImages) {
        IDMPhoto *photo = [IDMPhoto photoWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,fileName]]];
        [photos addObject:photo];
    }
    
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
    browser.displayActionButton = NO;
    browser.displayArrowButton = YES;
    browser.displayCounterLabel = YES;
    
    [self presentViewController:browser animated:YES completion:nil];
}

-(void)postAction:(id)sender
{
    [self.titeLabel resignFirstResponder];
    [self.contentView resignFirstResponder];
    switch (self.style) {
        case kPostStyleThread:
        {
            if ([self.contentView.text isEqualToString:@""]) {
                [Utils showAlertViewWithMessage:@"内容为空."];
            }else{
                [self postThread];
            }
           
        }
            break;
        case kPostStyleReply:
        {
            if ([self.contentView.text isEqualToString:@""]) {
                [Utils showAlertViewWithMessage:@"内容为空."];
            }else{
                [self postReply];
            }
        }
            break;
        case kPostStyleQuestion:
        {
            if ([self.titeLabel.text isEqualToString:@""]) {
                [Utils showAlertViewWithMessage:@"标题为空."];
            }else{
                if ([self.contentView.text isEqualToString:@""]) {
                    [Utils showAlertViewWithMessage:@"内容为空."];
                }else{
                      [self postQuestion];
                }
            }
          
        }
            break;
        case kPostStyleAnswer:
        {
            if ([self.contentView.text isEqualToString:@""]) {
                [Utils showAlertViewWithMessage:@"内容为空."];
            }else{
                [self postAnswer];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark -- 点击hud取消
-(void)cancelHUD:(UITapGestureRecognizer *)tap
{
    MBProgressHUD *ahud = (MBProgressHUD *)tap.view;
    [ahud hide:YES];
}

//发布帖子
-(void)postThread
{
    //发布帖子
    NSString *str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&content=%@&board=%d&images=",CMD_URL,post_thread_cmd,TeaHomeAppDelegate.username
                     ,TeaHomeAppDelegate.password,[Utils getHtmlStringFromString:self.contentView.text],self.postId];
    if ([self.uploadImages count] > 0) {
        for (int i=0;i<[self.uploadImages count];i++) {
            NSString *name = [self.uploadImages objectAtIndex:i];
            str = [ str stringByAppendingString:name];
            if (i < [self.uploadImages count] - 1) {
                str = [str stringByAppendingString:@","];
            }
        }
    }
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.postHUD show:YES];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       if ([[MBProgressHUD allHUDsForView:self.view] count] == 0) {
           return ;
       }
       [self.postHUD hide:YES];
       if (data != nil) {
           NSError *error;
           id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (json != nil) {
               if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
                   [Utils showAlertViewWithMessage:@"发表帖子成功."];
                   [self.navigationController popViewControllerAnimated:YES];
                   [[NSNotificationCenter defaultCenter] postNotificationName:kPostThreadSuccessNotification object:nil];
               }else{
                   [Utils showAlertViewWithMessage:@"发表帖子失败."];
               }
           }else{
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
           }
       }
   }];
}

//回复帖子
-(void)postReply
{
    //发表帖子
    NSString *str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&title=%@&content=%@&thread=%d&images=",CMD_URL,post_reply_cmd,TeaHomeAppDelegate.username,TeaHomeAppDelegate.password,[Utils getHtmlStringFromString:self.titeLabel.text],[Utils getHtmlStringFromString:self.contentView.text],self.postId];
    if ([self.uploadImages count] > 0) {
        for (int i=0;i<[self.uploadImages count];i++) {
            NSString *name = [self.uploadImages objectAtIndex:i];
            str = [ str stringByAppendingString:name];
            if (i < [self.uploadImages count] - 1) {
                str = [str stringByAppendingString:@","];
            }
        }
    }
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.postHUD show:YES];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       if ([[MBProgressHUD allHUDsForView:self.view] count] == 0) {
           return ;
       }
       [self.postHUD hide:YES];
       if (data != nil) {
           NSError *error;
           id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (json != nil) {
               if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
                   [Utils showAlertViewWithMessage:@"发表回复成功."];
                   [self.navigationController popViewControllerAnimated:YES];
               }else{
                   [Utils showAlertViewWithMessage:@"发表回复失败."];
               }
           }else{
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
           }
       }
   }];
}

-(void)postQuestion
{
    NSString *str = [NSString stringWithFormat:@"%@%@",CMD_URL,get_cats_cmd];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.postHUD show:YES];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       if ([[MBProgressHUD allHUDsForView:self.view] count] == 0) {
           return ;
       }
       [self.postHUD hide:YES];
       if (data != nil) {
           NSError *error;
           id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (json != nil) {
               self.questionCats = (NSArray *)json;
               UIAlertView *alert = [[UIAlertView alloc] init];
               [alert setTitle:@"选择问题分类"];
               [alert setDelegate: self];
               for (NSDictionary *dic in self.questionCats) {
                   [alert addButtonWithTitle:[dic objectForKey:@"name"]];
               }
               [alert addButtonWithTitle:@"取消"];
               [alert show];
           }else{
               [Utils showAlertViewWithMessage:@"网络出错,请稍后再试."];
           }
       }
   }];
}

//发布问题
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex >= [self.questionCats count]) {
        return;
    }
    int cat = [[[self.questionCats objectAtIndex:buttonIndex] objectForKey:@"id"] intValue];
    //发表问题
    NSString *str = [NSString stringWithFormat:@"%@%@&username=%@&images=&title=%@&content=%@&category=%d&images=",CMD_URL,post_question_cmd,TeaHomeAppDelegate.username,[Utils getHtmlStringFromString:self.titeLabel.text],[Utils getHtmlStringFromString:self.contentView.text],cat];
    if ([self.uploadImages count] > 0) {
        for (int i=0;i<[self.uploadImages count];i++) {
            NSString *name = [self.uploadImages objectAtIndex:i];
            str = [ str stringByAppendingString:name];
            if (i < [self.uploadImages count] - 1) {
                str = [str stringByAppendingString:@","];
            }
        }
    }
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.postHUD show:YES];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       if ([[MBProgressHUD allHUDsForView:self.view] count] == 0) {
           return ;
       }
       [self.postHUD hide:YES];
       if (data != nil) {
           NSError *error;
           id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (json != nil) {
               if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
                   [Utils showAlertViewWithMessage:@"发表问题成功."];
                   [self.navigationController popViewControllerAnimated:YES];
                   [[NSNotificationCenter defaultCenter] postNotificationName:kPostQuestionSuccessNotification object:nil];
               }else{
                   [Utils showAlertViewWithMessage:@"发表问题失败."];
               }
           }else{
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
           }
       }
   }];
}

//回复问答
-(void)postAnswer
{
    //发表答案
    NSString *str = [NSString stringWithFormat:@"%@%@&username=%@&content=%@&question=%d&images=",CMD_URL,post_answer_cmd,TeaHomeAppDelegate.username,[Utils getHtmlStringFromString:self.contentView.text],self.postId];
    if ([self.uploadImages count] > 0) {
        for (int i=0;i<[self.uploadImages count];i++) {
            NSString *name = [self.uploadImages objectAtIndex:i];
            str = [ str stringByAppendingString:name];
            if (i < [self.uploadImages count] - 1) {
                str = [str stringByAppendingString:@","];
            }
        }
    }
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.postHUD show:YES];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
       if ([[MBProgressHUD allHUDsForView:self.view] count] == 0) {
           return ;
       }
       [self.postHUD hide:YES];
       if (data != nil) {
           NSError *error;
           id json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (json != nil) {
               if ([[json objectForKey:@"ret"] isEqualToString:@"ok"]) {
                   [Utils showAlertViewWithMessage:@"发表答案成功."];
                   [self.navigationController popViewControllerAnimated:YES];
               }else{
                   [Utils showAlertViewWithMessage:@"发表答案失败."];
               }
           }else{
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
           }
       }
   }];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //点击背景，收起数字键盘
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.view.frame;
        rect.origin.y = 64;
        self.view.frame = rect;
    }];
}
@end
