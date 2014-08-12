//
//  FourthViewController.h
//  AKTabBar Example
//
//  Created by Ali KARAGOZ on 04/05/12.
//  Copyright (c) 2012 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefreshHeaderView.h"

@interface FourthViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property(nonatomic,strong) UISegmentedControl *segControl;


@property(nonatomic,strong) UITableView *promotionView;
@property(nonatomic,strong) NSArray *promotions;

@property(nonatomic,strong) UICollectionView *shopView;
@property(nonatomic,strong) NSArray *shops;
@property(nonatomic,strong) UICollectionViewFlowLayout *shopLayout;

@property(nonatomic,strong) UITableView *productsView;
@property(nonatomic,strong) NSArray *products;

@property(nonatomic,strong) UISearchBar *searchBar;
@property(nonatomic,strong) NSMutableArray *searchResult;


@property(nonatomic,strong) UITableView *evaluatesView;
@property(nonatomic,strong) NSMutableArray *evaluates;
@end
