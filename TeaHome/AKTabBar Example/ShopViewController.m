//
//  ShopViewController.m
//  TeaHome
//
//  Created by andylee on 14-6-27.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import "ShopViewController.h"
#import "ProductViewController.h"
#import "ShopViewDetailCell.h"
#import "ShopViewDetailHeader.h"

#define get_shop_cats_cmd @"get_shop_cats"
#define share_shop_url @"shop/html/"

@interface ShopViewController ()

@end

@implementation ShopViewController

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

    self.title = [self.shop objectForKey:@"title"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.hidesBottomBarWhenPushed = YES;
    
    self.favor = [[self.shop objectForKey:@"favor"] boolValue];
    self.like = [[self.shop objectForKey:@"like"] boolValue];
    self.likeCount = [[self.shop objectForKey:@"like_count"] intValue];
    self.favorCount = [[self.shop objectForKey:@"favor_count"] intValue];
    self.tid = [[self.shop objectForKey:@"id"] intValue];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = YES;
    [self.view addSubview:self.searchBar];
    
    self.holderView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height, self.view.bounds.size.width, self.view.frame.size.height - self.searchBar.frame.size.height - 100)];
    self.holderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.holderView];
    [self initShopInfoView];
    [self initCatsView];
//    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithTitle:@"分享"
//                                                              style:UIBarButtonItemStyleBordered
//                                                             target:self
//                                                             action:@selector(shareAction:)];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:share, nil];
    UIImage *likeImage = [UIImage imageNamed:@"like_down"];
    self.likeView = [[UIImageView alloc] initWithFrame:CGRectMake(50, self.view.bounds.size.height - 100, 30, 30)];
    self.likeView.backgroundColor = [UIColor clearColor];
    self.likeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLikeTapAction:)];
    [self.likeView addGestureRecognizer:gesture];
    [self.likeView setImage:likeImage];
    [self.view addSubview:self.likeView];
    
    self.likeLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, self.view.bounds.size.height - 100, 40, 30)];
    self.likeLabel.numberOfLines = 0;
    self.likeLabel.textAlignment = NSTextAlignmentRight;
    self.likeLabel.textColor = [UIColor grayColor];
    self.likeLabel.font = [UIFont systemFontOfSize:14];
    self.likeLabel.text = [NSString stringWithFormat:@"%d赞",[[self.shop objectForKey:@"like_count"] intValue]];
    [self.view addSubview:self.likeLabel];
    
    UIImage *favImage = [UIImage imageNamed:@"like_no"];
    self.favView = [[UIImageView alloc] initWithFrame:CGRectMake(140, self.view.bounds.size.height - 100, 30, 30)];
    self.favView.backgroundColor = [UIColor clearColor];
    self.favView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFavTapAction:)];
    [self.favView addGestureRecognizer:gesture2];
    [self.favView setImage:favImage];
    [self.view addSubview:self.favView];
    
    self.favorLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, self.view.bounds.size.height - 100, 70, 30)];
    self.favorLabel.numberOfLines = 0;
    self.favorLabel.textAlignment = NSTextAlignmentRight;
    self.favorLabel.textColor = [UIColor grayColor];
    self.favorLabel.font = [UIFont systemFontOfSize:14];
    self.favorLabel.text = [NSString stringWithFormat:@"%d收藏",[[self.shop objectForKey:@"favor_count"] intValue]];
    [self.view addSubview:self.favorLabel];
    
    self.favor = [[self.shop objectForKey:@"favor"] boolValue];
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
    
    self.like = [[self.shop objectForKey:@"like"] boolValue];
    
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
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=shop&id=%d",CMD_URL,@"unfavor",TeaHomeAppDelegate.username
               ,TeaHomeAppDelegate.password,self.tid];
    } else {
        favImage = [UIImage imageNamed:@"like_yes"];
        self.fav_state = true;
        self.favorCount = self.favorCount + 1;
        self.favorLabel.text = [NSString stringWithFormat:@"%d收藏",self.favorCount];
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=shop&id=%d",CMD_URL,@"favor",TeaHomeAppDelegate.username
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
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=shop&id=%d",CMD_URL,@"unlike",TeaHomeAppDelegate.username
               ,TeaHomeAppDelegate.password,self.tid];
    } else {
        likeImage = [UIImage imageNamed:@"like_up"];
        self.like_state = true;
        self.likeCount = self.likeCount + 1;
        self.likeLabel.text = [NSString stringWithFormat:@"%d赞",self.likeCount];
        
        str = [NSString stringWithFormat:@"%@%@&username=%@&password=%@&type=shop&id=%d",CMD_URL,@"like",TeaHomeAppDelegate.username
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

//-(void)shareAction:(UIBarButtonItem *)item
//{
//    NSString *url = [NSString stringWithFormat:@"%@%@%d",share_root_url,share_shop_url,[[self.shop objectForKey:@"id"] intValue]];
//    
//}


-(void)initCatsView
{
    int shopId = [[self.shop objectForKey:@"id"] intValue];
    //所有店铺
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&shop=%d&username=%@",CMD_URL,get_shop_cats_cmd,shopId,TeaHomeAppDelegate.username];
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
               self.cats = [NSArray arrayWithArray:(NSArray *)jsonObj];
               
               if (self.catsView == nil) {
                   self.layout = [[UICollectionViewFlowLayout alloc] init];
                   self.layout.minimumInteritemSpacing = 20;
                   self.layout.minimumLineSpacing = 10;
                   self.layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
                   self.layout.itemSize = CGSizeMake(90, 170);
                   self.layout.headerReferenceSize = CGSizeMake(320, 20);
                   
                   self.catsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
                   CGFloat height = 0;
                   for (NSDictionary *dic in self.cats) {
                       NSArray *products = [dic objectForKey:@"items"];
                       if ([products count] % 3 > 0) {
                           height += ([products count] / 3 + 1) * 160 + 30;
                       }else{
                           height += [products count] / 3 * 160 + 30;
                       }
                   }
                   self.catsView.frame = CGRectMake(0, self.shopInfoView.bounds.size.height + 10, self.view.bounds.size.width,height);
                   self.catsView.scrollEnabled = NO;
                   self.catsView.backgroundColor = [UIColor whiteColor];
                   self.catsView.dataSource = self;
                   self.catsView.delegate = self;
                   [self.holderView addSubview:self.catsView];
                   
                   self.holderView.contentSize = CGSizeMake(self.holderView.bounds.size.width, self.shopInfoView.frame.size.height + self.catsView.frame.size.height + 108);
                   
                   [self.catsView registerClass:[ShopViewDetailCell class] forCellWithReuseIdentifier:NSStringFromClass([ShopViewDetailCell class])];
                   [self.catsView registerClass:[ShopViewDetailHeader class]  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([ShopViewDetailHeader class])];
               }
               
               [self.catsView reloadData];
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


-(void)initShopInfoView
{
    int shopId = [[self.shop objectForKey:@"id"] intValue];
    
    self.shopInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    self.shopInfoView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.shopInfoView.backgroundColor = [UIColor whiteColor];
    [self.holderView addSubview:self.shopInfoView];
    self.holderView.contentSize = CGSizeMake(self.holderView.bounds.size.width, self.shopInfoView.frame.size.height);
    
    NSString *product_image_url = [NSString stringWithFormat:@"%@%d.jpg",shop_image_root_url,shopId];
    NSURL *url = [NSURL URLWithString:product_image_url];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 120, 60)];
    imageView.backgroundColor = [UIColor clearColor];
    [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.shopInfoView addSubview:imageView];
    
    NSString *title = [self.shop objectForKey:@"title"];
    NSString *desc = [self.shop objectForKey:@"desc"];
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(140, 5, 120, 60)];
    infoLabel.numberOfLines = 0;
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.text = [NSString stringWithFormat:@"%@\n%@",title,desc];
    [self.shopInfoView addSubview:infoLabel];
    
}
#pragma mark -- search delegate method
-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    NSString *searchText = searchBar.text;
    if (![searchText isEqualToString:@""]) {
        self.searchResult = [NSMutableArray array];
        for (int i=0;i<[self.cats count];i++) {
            NSDictionary *cat = self.cats[i];
            NSMutableDictionary *scat = [NSMutableDictionary dictionaryWithDictionary:cat];
            NSArray *products = [cat objectForKey:@"items"];
            NSPredicate *predict = [NSPredicate predicateWithFormat:@"title CONTAINS %@",searchText];
            NSArray *match = [products filteredArrayUsingPredicate:predict];
            [scat setObject:match forKey:@"items"];
            [self.searchResult addObject:scat];
        }
        
        CGFloat height = 0;
        for (NSDictionary *dic in self.searchResult) {
            NSArray *products = [dic objectForKey:@"items"];
            if ([products count] % 3 > 0) {
                height += ([products count] / 3 + 1) * 180 + 30;
            }else{
                height += [products count] / 3 * 180 + 30;
            }
        }
        self.catsView.frame = CGRectMake(0, self.shopInfoView.bounds.size.height + 10, self.view.bounds.size.width,height);
        self.holderView.contentSize = CGSizeMake(self.holderView.bounds.size.width, self.shopInfoView.frame.size.height + self.catsView.frame.size.height + 108);
        [self.catsView reloadData];
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    self.searchResult = nil;
    [self.catsView reloadData];
    CGFloat height = 0;
    for (NSDictionary *dic in self.cats) {
        NSArray *products = [dic objectForKey:@"items"];
        if ([products count] % 3 > 0) {
            height += ([products count] / 3 + 1) * 160 + 30;
        }else{
            height += [products count] / 3 * 160 + 30;
        }
    }
    self.catsView.frame = CGRectMake(0, self.shopInfoView.bounds.size.height + 10, self.view.bounds.size.width,height);
    self.holderView.contentSize = CGSizeMake(self.holderView.bounds.size.width, self.shopInfoView.frame.size.height + self.catsView.frame.size.height + 108);
    [self.catsView reloadData];
}


#pragma mark - collection view delegate method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.searchResult) {
        NSArray *products = [[self.searchResult objectAtIndex:section] objectForKey:@"items"];
        return [products count];
    }
    NSArray *products = [[self.cats objectAtIndex:section] objectForKey:@"items"];
    return [products count];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.searchResult) {
        return [self.searchResult count];
    }
    return [self.cats count];
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    ShopViewDetailHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([ShopViewDetailHeader class]) forIndexPath:indexPath];
    
    NSDictionary *cat ;
    if (self.searchResult) {
        cat = [self.searchResult objectAtIndex:indexPath.section];
    }else{
        cat = [self.cats objectAtIndex:indexPath.section];
    }
    header.catLabel.text = [NSString stringWithFormat:@"商品种类:%@",[cat objectForKey:@"name"]];
    
    return header;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShopViewDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ShopViewDetailCell class]) forIndexPath:indexPath];
    
    NSDictionary *product ;
    if (self.searchResult) {
        product = [self.searchResult[indexPath.section] objectForKey:@"items"][indexPath.row];
    }else{
        product = [self.cats[indexPath.section] objectForKey:@"items"][indexPath.row];
    }
    NSString *title = [product objectForKey:@"title"];
    float price = [[product objectForKey:@"price"] floatValue];
    int productId = [[product objectForKey:@"id"] intValue];
    int sold = [[product objectForKey:@"sold"] intValue];
    
    NSString *product_image_url = [NSString stringWithFormat:@"%@%d.jpg",product_image_root_url,productId];
    NSURL *url = [NSURL URLWithString:product_image_url];
    
    [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
    cell.titleLabel.text = title;
    [cell.titleLabel sizeToFit];
    if (sold > 0) {
        cell.soldLabel.text = [NSString stringWithFormat:@"折后:%d",sold];
    }
    cell.priceLabel.text = [NSString stringWithFormat:@"价格:￥%d",(int)(price)];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    NSDictionary *product ;
    if (self.searchResult) {
        product = [self.searchResult[indexPath.section] objectForKey:@"items"][indexPath.row];
    }else{
        product = [self.cats[indexPath.section] objectForKey:@"items"][indexPath.row];
    }

    ProductViewController *pvc = [[ProductViewController alloc] init];
    pvc.product = product;
    [self.navigationController pushViewController:pvc animated:YES];
}
@end
