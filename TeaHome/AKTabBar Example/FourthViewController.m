	//
//  FourthViewController.m
//  AKTabBar Example
//
//  Created by Ali KARAGOZ on 04/05/12.
//  Copyright (c) 2012 Ali Karagoz. All rights reserved.
//

//商店


#import "FourthViewController.h"
#import "ShopViewController.h"
#import "ProductViewController.h"
#import "LoginViewController.h"
#import "ProductCommentDetailViewController.h"
#import "SimpleUserinfoViewController.h"
#import "FourthViewShopCell.h"

#define get_promotions_cmd @"get_promotions"
#define get_shops_cmd @"get_shops"
#define get_products_cmd @"get_all_items"
#define get_all_item_comments_cmd @"get_all_item_comments"

#define get_item_cmd @"get_item"

static int page = 1;
@interface FourthViewController ()
{
    BOOL hasNewData ;
    BOOL pullDownRefresh;
    BOOL dataErr;
}
@end

@implementation FourthViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"商店";
    }
    return self;
}

- (NSString *)tabImageName
{
	return @"shop_icon";
}

- (NSString *)tabTitle
{
	return self.title;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    hasNewData = YES;
    pullDownRefresh = YES;
    dataErr = NO;
    
    self.segControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"促销",@"店铺",@"商品",@"评价",nil]];
    self.segControl.frame = CGRectMake(0, 0, 240, 20);
    [self.segControl addTarget:self action:@selector(handleSegmentControlEvent:) forControlEvents:UIControlEventValueChanged];
    [self.segControl setSelectedSegmentIndex:0];
    
    self.navigationItem.titleView = self.segControl;
    
    self.searchResult = nil;
    self.promotions = [NSArray array];
    self.shops = [NSArray array];
    self.products = [NSArray array];
    self.evaluates = [NSMutableArray array];
    
    self.promotionView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.promotionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.promotionView.backgroundColor = [UIColor whiteColor];
    self.promotionView.dataSource = self;
    self.promotionView.delegate = self;
    [self.view addSubview:self.promotionView];
    
    [self.promotionView addHeaderWithTarget:self action:@selector(headerRereshing)];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [self.searchBar setShowsCancelButton:YES];
    self.searchBar.delegate = self;
    [self.view addSubview:self.searchBar];
    UIView *topView = self.searchBar.subviews[0];
    for (id v in topView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *cancelBtn = (UIButton *)v;
            [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        }
    }
    
    CGFloat space = 15;
    self.shopLayout = [[UICollectionViewFlowLayout alloc] init];
    self.shopLayout.minimumInteritemSpacing = 10;
    self.shopLayout.minimumLineSpacing = space;
    self.shopLayout.sectionInset = UIEdgeInsetsMake(space, space, space, space);
    self.shopLayout.itemSize = CGSizeMake(140, 160);
    
    self.shopView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44) collectionViewLayout:self.shopLayout];
    self.shopView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.shopView.backgroundColor = [UIColor whiteColor];
    self.shopView.dataSource = self;
    self.shopView.delegate = self;
    self.shopView.scrollEnabled = YES;
    self.shopView.alwaysBounceVertical = YES;
    [self.view addSubview:self.shopView];
    [self.shopView addHeaderWithTarget:self action:@selector(shopsHeaderRereshing)];
    
    [self.shopView registerClass:[FourthViewShopCell class] forCellWithReuseIdentifier:NSStringFromClass([FourthViewShopCell class])];
    
    self.productsView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 44)];
    self.productsView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.productsView.backgroundColor = [UIColor whiteColor];
    self.productsView.dataSource = self;
    self.productsView.delegate = self;
    [self.view addSubview:self.productsView];
    [self.productsView addHeaderWithTarget:self action:@selector(itemsHeaderRereshing)];
    
    self.evaluatesView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self.evaluatesView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.evaluatesView.backgroundColor = [UIColor whiteColor];
    self.evaluatesView.dataSource = self;
    self.evaluatesView.delegate = self;
    [self.view addSubview:self.evaluatesView];
    [self.evaluatesView addHeaderWithTarget:self action:@selector(productsCommentsHeaderRereshing)];
    [self.evaluatesView addFooterWithTarget:self action:@selector(productsCommentsFooterRereshing)];
    
    
    [self handleSegmentControlEvent:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    if ([TeaHomeAppDelegate.username isEqualToString:@""]) {
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        [self.navigationController pushViewController:lvc animated:YES];
    }
    
}

#pragma mark 开始进入刷新状态
- (void)headerRereshing
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [self.promotionView headerEndRefreshing];
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",CMD_URL,get_promotions_cmd];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       if (data != nil) {
           NSError *error;
           id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (jsonObj != nil) {
               self.promotions = [NSArray arrayWithArray:(NSArray *)jsonObj];
               [self.promotionView reloadData];
               [self.promotionView headerEndRefreshing];
           }else{
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
           }
       }
   }];
}

-(void)handleSegmentControlEvent:(id)sender
{
    switch (self.segControl.selectedSegmentIndex) {
        case 0:
        {
            [self.view bringSubviewToFront:self.promotionView];
            [self.searchBar resignFirstResponder];
            self.searchResult = nil;
            [self.promotionView headerBeginRefreshing];
        }
            break;
        case 1:
        {
            [self.view bringSubviewToFront:self.searchBar];
            [self.view bringSubviewToFront:self.shopView];
            
            [self.searchBar resignFirstResponder];
            self.searchResult = nil;
            self.searchBar.text = @"";
            [self.shopView headerBeginRefreshing];
        }
            break;
        case 2:
        {
            //所有商品
            [self.view bringSubviewToFront:self.searchBar];
            [self.view bringSubviewToFront:self.productsView];
            
            [self.searchBar resignFirstResponder];
            self.searchResult = nil;
            self.searchBar.text = @"";
            [self.productsView headerBeginRefreshing];
        }
            break;
        case 3:
        {
            [self.view bringSubviewToFront:self.evaluatesView];
            [self.searchBar resignFirstResponder];
            self.searchResult = nil;
            [self.evaluatesView headerBeginRefreshing];
        }
            break;

            
        default:
            break;
    }
}

#pragma mark -- 店铺下拉刷新
-(void)shopsHeaderRereshing
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [self.shopView headerEndRefreshing];
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    //所有店铺
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&username=%@",CMD_URL,get_shops_cmd,TeaHomeAppDelegate.username];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       if (data != nil) {
           NSError *error;
           id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (jsonObj != nil) {
               self.shops = [NSArray arrayWithArray:(NSArray *)jsonObj];
               [self.shopView reloadData];
               [self.shopView headerEndRefreshing];
           }else{
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
           }
       }
   }];
}

#pragma mark -- 商品下拉刷新
-(void)itemsHeaderRereshing
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [self.productsView headerEndRefreshing];
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&username=%@",CMD_URL,get_products_cmd,TeaHomeAppDelegate.username];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request
                   queue:[NSOperationQueue mainQueue]
       completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//           [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
           if (data != nil) {
               NSError *error;
               id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
               if (jsonObj != nil) {
                   self.products = [NSArray arrayWithArray:(NSArray *)jsonObj];
                   [self.productsView reloadData];
                   [self.productsView headerEndRefreshing];
               }else{
                   [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
               }
           }
       }];
}

#pragma mark 开始进入刷新状态
- (void)productsCommentsHeaderRereshing
{
    pullDownRefresh = YES;
    
    [self getProductsCommentsFromWebWithPage:1];
    
}

- (void)productsCommentsFooterRereshing
{
    pullDownRefresh = NO;
    
    page += 1;
    
    [self getProductsCommentsFromWebWithPage:page];
}

-(void)getProductsCommentsFromWebWithPage:(int)aPage
{
    if (TeaHomeAppDelegate.networkIsReachable == NO) {
        [self.evaluatesView headerEndRefreshing];
        [Utils showAlertViewWithMessage:@"无网络,请稍后再试."];
        return;
    }
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@&page=%d",CMD_URL,get_all_item_comments_cmd,aPage];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [NSURLConnection sendAsynchronousRequest:request
               queue:[NSOperationQueue mainQueue]
   completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
//       [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
       if (data != nil) {
           NSError *error;
           id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if (jsonObj != nil) {
               dataErr = NO;
               if ([jsonObj isKindOfClass:[NSArray class]]) {
                   if (pullDownRefresh == NO && [jsonObj count] == 0) {
                       page -- ;
                       hasNewData = NO;
                       [self.evaluatesView footerEndRefreshing];
                       return ;
                   }
                   jsonObj = (NSArray *)jsonObj;
                   if (pullDownRefresh == YES) {
                       if ([self.evaluates count] > 0) {
                           if ([[[self.evaluates objectAtIndex:0] objectForKey:@"id"]
                                isEqual:[[jsonObj objectAtIndex:0] objectForKey:@"id"]]) {
                                   hasNewData = NO;
                                   [self.evaluatesView headerEndRefreshing];
                                   return;
                               }
                       }else{
                           hasNewData = YES;
                           [self.evaluates addObjectsFromArray:jsonObj];
                           [self.evaluatesView reloadData];
                           [self.evaluatesView headerEndRefreshing];
                           return;
                       }
                   }
                   hasNewData = YES;
                   for (NSDictionary *d in jsonObj) {
                       int continueValue = 0;
                       for (NSDictionary *od in self.evaluates) {
                           if ([[od objectForKey:@"id"] isEqual:[((NSDictionary *)jsonObj) objectForKey:@"id"]]) {
                                   continueValue = 1;
                               }
                       }
                       if (continueValue == 0) {
                           if (pullDownRefresh == YES) {
                               [self.evaluates insertObject:d  atIndex:0];
                           }else{
                               [self.evaluates addObject:d];
                           }
                           continueValue = 0;
                       }
                   }
               }else{
                   //dictionary
                   if ([self.evaluates count] > 0) {
                       int exist = 0;
                       
                       for (NSDictionary *od in self.evaluates) {
                           if ([[od objectForKey:@"id"] isEqualToString:[((NSDictionary *)jsonObj) objectForKey:@"id"]]) {
                                   exist = 1;
                               }
                       }
                       if (exist == 0) {
                           if (pullDownRefresh == 1) {
                               [self.evaluates insertObject:jsonObj  atIndex:0];
                           }else{
                               [self.evaluates addObject:jsonObj];
                           }
                           exist = 0;
                       }
                   }else{
                       [self.evaluates addObject:jsonObj];
                   }
               }
           }else{
               dataErr = YES;
           }

           if (dataErr) {
               if (pullDownRefresh == NO) {
                   // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
                   [self.evaluatesView footerEndRefreshing];
               }else{
                   [self.evaluatesView headerEndRefreshing];
               }
               [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
               return ;
           }
           //有新数据的时候重新加载数据
           if (hasNewData) {
               [self.evaluatesView reloadData];
               if (pullDownRefresh == NO) {
                   // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
                   [self.evaluatesView footerEndRefreshing];
               }else{
                   [self.evaluatesView headerEndRefreshing];
               }
           }else{
               if (pullDownRefresh == 1) {
                   [Utils showAlertViewWithMessage:@"没有更新的评论."];
               }else{
                   [Utils showAlertViewWithMessage:@"没有更多的评论."];
                   
               }
           }
       }
   }];
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:hud];
//    [hud showAnimated:YES whileExecutingBlock:^{
//        NSString *str = [NSString stringWithFormat:@"%@%@&page=%d",CMD_URL,get_all_item_comments_cmd,aPage];
//        id jsonObj = [Utils getJsonDataFromWeb:str];
//        if (jsonObj != nil) {
//            dataErr = NO;
//            if ([jsonObj isKindOfClass:[NSArray class]]) {
//                if (pullDownRefresh == NO && [jsonObj count] == 0) {
//                    page -- ;
//                    hasNewData = NO;
//                    [self.evaluatesView footerEndRefreshing];
//                    return ;
//                }
//                jsonObj = (NSArray *)jsonObj;
//                if (pullDownRefresh == YES) {
//                    if ([self.evaluates count] > 0) {
//                        if ([[[self.evaluates objectAtIndex:0] objectForKey:@"title"]
//                             isEqualToString:[[jsonObj objectAtIndex:0] objectForKey:@"title"]]&&
//                            [[[self.evaluates objectAtIndex:0] objectForKey:@"create_time"]
//                             isEqualToString:
//                             [[jsonObj objectAtIndex:0] objectForKey:@"create_time"]]
//                            &&
//                            [[[self.evaluates objectAtIndex:0] objectForKey:@"username"]
//                             isEqualToString:[[jsonObj objectAtIndex:0] objectForKey:@"username"]]) {
//                            hasNewData = NO;
//                            [self.evaluatesView headerEndRefreshing];
//                            return;
//                        }
//                    }else{
//                        hasNewData = YES;
//                        [self.evaluates addObjectsFromArray:jsonObj];
//                        return;
//                    }
//                }
//                hasNewData = YES;
//                for (NSDictionary *d in jsonObj) {
//                    int continueValue = 0;
//                    for (NSDictionary *od in self.evaluates) {
//                        if ([[od objectForKey:@"title"] isEqualToString:[d objectForKey:@"title"]]&&
//                            [[[self.evaluates objectAtIndex:0] objectForKey:@"create_time"]
//                             isEqualToString:
//                             [[jsonObj objectAtIndex:0] objectForKey:@"create_time"]]
//                            &&
//                            [[[self.evaluates objectAtIndex:0] objectForKey:@"username"]
//                             isEqualToString:[[jsonObj objectAtIndex:0] objectForKey:@"username"]]) {
//                            continueValue = 1;
//                        }
//                    }
//                    if (continueValue == 0) {
//                        if (pullDownRefresh == YES) {
//                            [self.evaluates insertObject:d  atIndex:0];
//                        }else{
//                            [self.evaluates addObject:d];
//                        }
//                        continueValue = 0;
//                    }
//                }
//            }else{
//                //dictionary
//                if ([self.evaluates count] > 0) {
//                    int exist = 0;
//                    
//                    for (NSDictionary *od in self.evaluates) {
//                        if ([[od objectForKey:@"title"] isEqualToString:[((NSDictionary *)jsonObj) objectForKey:@"title"]]&&
//                            [[[self.evaluates objectAtIndex:0] objectForKey:@"create_time"]
//                             isEqualToString:
//                             [[jsonObj objectAtIndex:0] objectForKey:@"create_time"]]
//                            &&
//                             [[[self.evaluates objectAtIndex:0] objectForKey:@"username"]
//                             isEqualToString:[[jsonObj objectAtIndex:0] objectForKey:@"username"]]) {
//                            exist = 1;
//                        }
//                    }
//                    if (exist == 0) {
//                        if (pullDownRefresh == 1) {
//                            [self.evaluates insertObject:jsonObj  atIndex:0];
//                        }else{
//                            [self.evaluates addObject:jsonObj];
//                        }
//                        exist = 0;
//                    }
//                }else{
//                    [self.evaluates addObject:jsonObj];
//                }
//            }
//        }else{
//            dataErr = YES;
//        }
//        
//    } completionBlock:^{
//        if (dataErr) {
//            if (pullDownRefresh == NO) {
//                // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
//                [self.evaluatesView footerEndRefreshing];
//            }else{
//                [self.evaluatesView headerEndRefreshing];
//            }
//            [Utils showAlertViewWithMessage:@"网络链接出错，请稍后再试."];
//            return ;
//        }
//        //有新数据的时候重新加载数据
//        if (hasNewData) {
//            [self.evaluatesView reloadData];
//            if (pullDownRefresh == NO) {
//                // (最好在刷新表格后调用)调用endRefreshing可以结束刷新状态
//                [self.evaluatesView footerEndRefreshing];
//            }else{
//                [self.evaluatesView headerEndRefreshing];
//            }
//        }else{
//            if (pullDownRefresh == 1) {
//                [Utils showAlertViewWithMessage:@"没有更新的评论."];
//            }else{
//                [Utils showAlertViewWithMessage:@"没有更多的评论."];
//                
//            }
//        }
//    }];

}

#pragma mark -- 
//-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    [self.searchBar resignFirstResponder];
//}

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
        if (self.segControl.selectedSegmentIndex == 1) {
            //搜索店铺
            NSPredicate *predict = [NSPredicate predicateWithFormat:@"title CONTAINS %@",searchText];
            self.searchResult = [NSMutableArray arrayWithArray:[self.shops filteredArrayUsingPredicate:predict]];
            [self.shopView reloadData];
        }else{
            //搜索商品
            NSPredicate *predict = [NSPredicate predicateWithFormat:@"title CONTAINS %@",searchText];
            self.searchResult = [NSMutableArray arrayWithArray:[self.products filteredArrayUsingPredicate:predict]];
            [self.productsView reloadData];
        }
    }
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
    self.searchResult = nil;
    if (self.segControl.selectedSegmentIndex == 1) {
        [self.shopView reloadData];
    }else{
        [self.productsView reloadData];
    }
}

#pragma mark -- collection view delegate method
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.searchResult) {
        return [self.searchResult count];
    }
    return [self.shops count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FourthViewShopCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([FourthViewShopCell class]) forIndexPath:indexPath];
    
    NSDictionary *shop = nil;
    if (self.searchResult) {
        shop = [self.searchResult objectAtIndex:indexPath.row];
    }else{
        shop = [self.shops objectAtIndex:indexPath.row];
    }
    NSString *title = [shop objectForKey:@"title"];
    int shopId = [[shop objectForKey:@"id"] intValue];
    NSString *desc = [shop objectForKey:@"desc"];
    int recommend = 12;//TODO:
    
    cell.titleLabel.text = title;
    
    NSString *shop_image_url = [NSString stringWithFormat:@"%@%d.jpg",shop_image_root_url,shopId];
    NSURL *url = [NSURL URLWithString:shop_image_url];
    
    [cell.imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
    
    cell.descLabel.text = desc;
    
    //cell.recommendLabel.text = [NSString stringWithFormat:@"%d 人推荐该店",recommend];
   
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    NSDictionary *shop = nil;
    if ([self.searchResult count] > 0) {
        shop = [self.searchResult objectAtIndex:indexPath.row];
    }else{
        shop = [self.shops objectAtIndex:indexPath.row];
    }
    
    ShopViewController *svc = [[ShopViewController alloc] init];
    svc.shop = shop;
    [self.navigationController pushViewController:svc animated:YES];
}


#pragma mark -- table view delegate method
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"FourthTableViewCell";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([tableView isEqual:self.promotionView]) {
        //促销
        NSDictionary *promotion = [self.promotions objectAtIndex:indexPath.row];
        
        NSString *imageName = [promotion objectForKey:@"image_name"];
        
        NSString *product_image_url = [NSString stringWithFormat:@"%@%@",promotion_image_root_url,imageName];
        NSURL *url = [NSURL URLWithString:product_image_url];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, cell.bounds.size.width - 40, 80)];
        imageView.backgroundColor = [UIColor clearColor];
        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
        [cell addSubview:imageView];
        
        return cell;

    }else if ([tableView isEqual:self.productsView]){
        //商品
        NSDictionary *product = nil;
        if ([self.searchResult count] > 0) {
            product = [self.searchResult objectAtIndex:indexPath.row];
        }else{
            product = [self.products objectAtIndex:indexPath.row];
        }
        NSString *title = [product objectForKey:@"title"];
        float price = [[product objectForKey:@"price"] floatValue];
        int productId = [[product objectForKey:@"id"] intValue];
        int sold = [[product objectForKey:@"sold"] intValue];
        
        NSString *product_image_url = [NSString stringWithFormat:@"%@%d.jpg",product_image_root_url,productId];
        NSURL *url = [NSURL URLWithString:product_image_url];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 80, 80)];
        imageView.backgroundColor = [UIColor clearColor];
        [imageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"image_loading"]];
        [cell addSubview:imageView];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 10, 140, 40)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 0;
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = [UIColor blueColor];
        titleLabel.text = title;
        [cell addSubview:titleLabel];
        
        UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 50, 140, 15)];
        categoryLabel.backgroundColor = [UIColor clearColor];
        categoryLabel.numberOfLines = 0;
        categoryLabel.font = [UIFont systemFontOfSize:12];
        categoryLabel.textColor = [UIColor lightGrayColor];
        categoryLabel.text = @"[品种] : 乌龙茶";//TODO:
        //[cell addSubview:categoryLabel];
        
        UILabel *produceLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 70, 140, 15)];
        produceLabel.backgroundColor = [UIColor clearColor];
        produceLabel.numberOfLines = 0;
        produceLabel.font = [UIFont systemFontOfSize:12];
        produceLabel.textColor = [UIColor lightGrayColor];
        produceLabel.text = @"[产地] : 台湾";//TODO:
        //[cell addSubview:produceLabel];
        
        
        UILabel *soldLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 50, 140, 15)];
        soldLabel.backgroundColor = [UIColor clearColor];
        soldLabel.numberOfLines = 0;
        soldLabel.textColor = [UIColor redColor];
        soldLabel.font = [UIFont systemFontOfSize:12];
        soldLabel.text = [NSString stringWithFormat:@"折后: %d元",sold];;
        if (sold > 0) {
            [cell addSubview:soldLabel];
        }
        
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, 70, 140, 15)];
        priceLabel.backgroundColor = [UIColor clearColor];
        priceLabel.numberOfLines = 0;
        priceLabel.textColor = [UIColor blackColor];
        priceLabel.font = [UIFont systemFontOfSize:12];
        priceLabel.text = [NSString stringWithFormat:@"价格: %.1f元",price];
        [cell addSubview:priceLabel];
        
        return cell;

    }else{
        //商品评价
        NSDictionary *comment = [self.evaluates objectAtIndex:indexPath.row];
        NSString *nickname = [comment objectForKey:@"nickname"];
        int naipao = [[comment objectForKey:@"naipao"] intValue];
        int xiangqi = [[comment objectForKey:@"xiangqi"] intValue];
        int ziwei = [[comment objectForKey:@"ziwei"] intValue];
        int yexing = [[comment objectForKey:@"yexing"] intValue];
        NSString *title = [comment objectForKey:@"title"];
        NSString *itemTitle = [comment objectForKey:@"item_title"];
        NSString *thumb = [comment objectForKey:@"thumb"];
        NSString *createTime = [comment objectForKey:@"create_time"];
        CGFloat x = 20, y = 20;
        
        //用户头像
        UIImage *image = [UIImage imageNamed:@"user_icon"];
        UIImageView *userIconView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 30, 30)];
        if ([thumb isEqualToString:@""] || thumb == nil) {
            [userIconView setImage:image];
        }else{
            [userIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",upload_image_root_url,thumb]] placeholderImage:[UIImage imageNamed:@"image_loading"]];
        }
        
        userIconView.userInteractionEnabled = YES;
        userIconView.tag = indexPath.row;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userIconAction:)];
        [userIconView addGestureRecognizer:tap];
        
        [cell addSubview:userIconView];
        
        //用户名
        UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+40, y, 100, 15)];
        usernameLabel.textColor = [UIColor blackColor];
        usernameLabel.font = [UIFont systemFontOfSize:13];
        usernameLabel.text = [NSString stringWithFormat:@"%@",nickname];
        [cell addSubview:usernameLabel];
        
        //回复时间
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x+40, y+20, 100, 10)];
        timeLabel.textColor = [UIColor lightGrayColor];
        timeLabel.font = [UIFont systemFontOfSize:10];
        timeLabel.text = [createTime substringWithRange:NSMakeRange(5, 14)];
        [cell addSubview:timeLabel];

        //标题
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y, 140, 15)];
        titleLabel.textColor = [Utils hexStringToColor:navigation_bar_color];
        titleLabel.textAlignment = NSTextAlignmentRight;
        titleLabel.font = [UIFont systemFontOfSize:13];
        titleLabel.text = [NSString stringWithFormat:@"%@(%@)",title,itemTitle];
        [cell addSubview:titleLabel];
        
        //评分
        UILabel *pointLabel = [[UILabel alloc] initWithFrame:CGRectMake(160, y+20, 70, 10)];
        pointLabel.textColor = [UIColor lightGrayColor];
        pointLabel.textAlignment = NSTextAlignmentRight;
        pointLabel.font = [UIFont systemFontOfSize:10];
        pointLabel.text = @"综合评分";
        [cell addSubview:pointLabel];
        
        x = 230;
        y += 20;
        //评分图
        int currentPoint =  naipao + xiangqi + ziwei + yexing;
        UIImage *like = [UIImage imageNamed:@"like_yes"];
        UIImage *unlike = [UIImage imageNamed:@"like_no"];
        
        for (int i=1; i<6; i++) {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, 10, 10)];
            if (currentPoint >= i*4) {
                iv.image = like;
            }else{
                iv.image = unlike;
            }
            [cell addSubview:iv];
            
            x += 10;
        }
        return cell;
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:self.promotionView]) {
        //促销
        return 100;
    }else if ([tableView isEqual:self.productsView]){
        //商品
        return 100;
    }
    //商品评价
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.searchBar resignFirstResponder];
    NSDictionary *product = nil;
    if ([tableView isEqual:self.promotionView]) {
        //促销
        NSDictionary *promotion = [self.promotions objectAtIndex:indexPath.row];
        
        int itemId = [[promotion objectForKey:@"item"] intValue];
        NSString *url = [NSString stringWithFormat:@"%@%@&item=%d&username=%@",CMD_URL,get_item_cmd,itemId,TeaHomeAppDelegate.username];
        id jsonObj = [Utils getJsonDataFromWeb:url];
        if (jsonObj != nil) {
            product = (NSDictionary *)jsonObj;
            ProductViewController *pvc = [[ProductViewController alloc] init];
            pvc.product = product;
            [self.navigationController pushViewController:pvc animated:YES];
        }
    }else if  ([tableView isEqual:self.productsView]) {
        //商品
        if ([self.searchResult count] > 0) {
            product = [self.searchResult objectAtIndex:indexPath.row];
        }else{
            product = [self.products objectAtIndex:indexPath.row];
        }
        ProductViewController *pvc = [[ProductViewController alloc] init];
        pvc.product = product;
        [self.navigationController pushViewController:pvc animated:YES];
    }else if ([tableView isEqual:self.evaluatesView]){
        //商品评价
        ProductCommentDetailViewController *pcdvc = [[ProductCommentDetailViewController alloc] init];
        pcdvc.comment = [self.evaluates objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:pcdvc animated:YES];
    }
    
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.promotionView]) {
        //促销
        return [self.promotions count];
    }else if ([tableView isEqual:self.productsView]){
        //商品
        if (self.searchResult) {
            return [self.searchResult count];
        }
        return  [self.products count];
    }else{
        //商品评价
        return [self.evaluates count];
    }
    
}

#pragma mark -- 点击头像查看个人详情
-(void)userIconAction:(UITapGestureRecognizer *)tap
{
    int tag = tap.view.tag;
    NSString *username = nil;
    //答复区
    NSDictionary *dic = [self.evaluates objectAtIndex:tag];
    username = [dic objectForKey:@"username"];
    
    SimpleUserinfoViewController *suvc = [[SimpleUserinfoViewController alloc] init];
    suvc.username = username;
    [self.navigationController pushViewController:suvc animated:YES];
}
@end
