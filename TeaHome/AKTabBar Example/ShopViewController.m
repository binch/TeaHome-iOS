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
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    self.searchBar.delegate = self;
    self.searchBar.showsCancelButton = YES;
    [self.view addSubview:self.searchBar];
    
    self.holderView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.searchBar.frame.size.height, self.view.bounds.size.width, self.view.frame.size.height - self.searchBar.frame.size.height)];
    self.holderView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.holderView];
    [self initShopInfoView];
    [self initCatsView];
//    UIBarButtonItem *share = [[UIBarButtonItem alloc] initWithTitle:@"分享"
//                                                              style:UIBarButtonItemStyleBordered
//                                                             target:self
//                                                             action:@selector(shareAction:)];
//    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:share, nil];
    
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
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&shop=%d",CMD_URL,get_shop_cats_cmd,shopId];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
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
                   self.layout.itemSize = CGSizeMake(90, 150);
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
                height += ([products count] / 3 + 1) * 160 + 30;
            }else{
                height += [products count] / 3 * 160 + 30;
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
    cell.soldLabel.text = [NSString stringWithFormat:@"销量:%d",sold];
    cell.priceLabel.text = [NSString stringWithFormat:@"价格:%.1f元",price];
    
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
