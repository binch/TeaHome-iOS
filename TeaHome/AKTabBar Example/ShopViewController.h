//
//  ShopViewController.h
//  TeaHome
//
//  Created by andylee on 14-6-27.
//  Copyright (c) 2014年 Ali Karagoz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,UISearchBarDelegate>

@property(nonatomic,strong) NSDictionary *shop;

@property(nonatomic,strong) UIScrollView *holderView;
@property(nonatomic,strong) UIView *shopInfoView;

@property(nonatomic,strong) UICollectionView *catsView;
@property(nonatomic,strong) NSArray *cats;
@property(nonatomic,strong) UICollectionViewFlowLayout *layout;

@property(nonatomic,strong) UISearchBar *searchBar;
@property(nonatomic,strong) NSMutableArray *searchResult;

@property(nonatomic,strong) UILabel *favorLabel;
@property(nonatomic,strong) UILabel *likeLabel;
@property(nonatomic,strong) UIImageView *likeView;
@property(nonatomic,strong) UIImageView *favView;
@property(nonatomic,assign) bool favor;
@property(nonatomic,assign) bool like;
@property(nonatomic,assign) bool fav_state;
@property(nonatomic,assign) bool like_state;
@property(nonatomic,assign) int favorCount;
@property(nonatomic,assign) int likeCount;
@property(nonatomic,assign) int tid;

@end
