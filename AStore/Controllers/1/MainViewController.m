//
//  MainViewController.m
//  AStore
//
//  Created by Carl on 13-9-26.
//  Copyright (c) 2013年 carl. All rights reserved.
//

#define TABLE_CELL_HEIGHT_1 124
#define TABLE_CELL_HEIGHT_2 122
#define TABLE_CELL_HEIGHT_3 94
#define TABLE_CELL_HEIGHT_4 94
#define TABLE_CELL_HEIGHT_5 145
#define TABLE_CELL_HEIGHT_6 145
//#define ImageViewTagPrefix   


#import "MainViewController.h"
#import "NoticeListViewController.h"
#import "YHJViewController.h"
#import "CommodityChangeViewController.h"
#import "TZMarketViewController.h"
#import "SearchResultViewController.h"
#import "MainCell2.h"
#import "MainCell3.h"
#import "MainCell4.h"
#import "MainCell5.h"
#import "MainCell6.h"
#import "HttpHelper.h"
#import "MainCommodityViewController.h"
#import "Commodity.h"
#import "CommodityViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AdViewController.h"
#import "CycleScrollView.h"
@interface MainViewController ()<UITextFieldDelegate,CycleScrollViewDelegate>
{
    UITextField * searchField;
    NSArray * recommandFootData;
    NSArray * recommandCommodityData;
    NSThread * fetchDataThread;
    BOOL isFetchFoodDataSuccess;
    BOOL isFetchStuffDataSuccess;
    NSMutableArray * imagesArray;
    CycleScrollView * scrollView;
    NSInteger imageCouont;
}
@end

@implementation MainViewController

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
    imagesArray = [NSMutableArray array];
    scrollView = nil;
    
    [HttpHelper getAdsWithURL:@"http://www.youjianpuzi.com/" withNodeClass:@"focus" withSuccessBlock:^(NSArray *items) {
        NSLog(@"%@",items);

        if ([items count]) {
            imageCouont = [items count];
            for (NSDictionary *dic in items) {
                UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, TABLE_CELL_HEIGHT_1)];
                NSURL *url = [NSURL URLWithString:[dic objectForKey:@"image"]];
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
                __weak UIImageView * weakImageView = imageView;
                __weak MainViewController * weakSelf =self;
                [imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                    [weakImageView setImage:image];
                    [weakSelf configureImagesArrayWithObj:@{@"FecthImage": image,@"url":dic[@"url"]}];
                    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                    NSLog(@"%@",[error description]);
                }];
            }
            
        }
    } errorBlock:^(NSError *error) {
        
    }];
    
    UIImage * logo = [UIImage imageNamed:@"logo"];
    UIImageView * logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, logo.size.width, logo.size.height)];
    logoView.image = logo;
    UIBarButtonItem * logoItem = [[UIBarButtonItem alloc] initWithCustomView:logoView];
    self.navigationItem.leftBarButtonItem = logoItem;
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 165, 35)];
    searchField.textAlignment = NSTextAlignmentLeft;
    searchField.delegate = self;
    [searchField setBackground:[UIImage imageNamed:@"search背景"]];
    searchField.returnKeyType = UIReturnKeySearch;
    self.navigationItem.titleView = searchField;
    UIButton * searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setFrame:CGRectMake(0, 0, 54, 53)];
    [searchBtn setImage:[UIImage imageNamed:@"搜索btn"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * searchItem = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    self.navigationItem.rightBarButtonItem = searchItem;
    
    
    UINib * cell2NIb = [UINib nibWithNibName:@"MainCell2" bundle:[NSBundle bundleForClass:[MainCell2 class]]];
    [_tableView registerNib:cell2NIb forCellReuseIdentifier:@"MainCell2"];
    
    UINib * cell3Nib = [UINib nibWithNibName:@"MainCell3" bundle:[NSBundle bundleForClass:[MainCell3 class]]];
    [_tableView registerNib:cell3Nib forCellReuseIdentifier:@"MainCell3"];
    
    UINib * cell4Nib = [UINib nibWithNibName:@"MainCell4" bundle:[NSBundle bundleForClass:[MainCell4 class]]];
    [_tableView registerNib:cell4Nib forCellReuseIdentifier:@"MainCell4"];
    
    UINib * cell5Nib = [UINib nibWithNibName:@"MainCell5" bundle:[NSBundle bundleForClass:[MainCell5 class]]];
    [_tableView registerNib:cell5Nib forCellReuseIdentifier:@"MainCell5"];
    
    UINib * cell6Nib = [UINib nibWithNibName:@"MainCell6" bundle:[NSBundle bundleForClass:[MainCell6 class]]];
    [_tableView registerNib:cell6Nib forCellReuseIdentifier:@"MainCell6"];
    
    isFetchFoodDataSuccess = NO;
    isFetchStuffDataSuccess = NO;
    fetchDataThread = [[NSThread alloc]initWithTarget:self selector:@selector(fetchDataThreadMethod) object:nil];
    [fetchDataThread start];

    
}

-(void)configureImagesArrayWithObj:(NSDictionary *)dic
{
    [imagesArray addObject:dic];
    if ([imagesArray count] == imageCouont) {
        NSMutableArray * tempArray = [NSMutableArray array];
        for (int i = 0 ;i < [imagesArray count];i++) {
            NSDictionary *dic = [imagesArray objectAtIndex:i];
            UIImageView * imageview = [[UIImageView alloc]initWithImage:dic[@"FecthImage"]];
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pushToAdViewcontroller:)];
            [imageview addGestureRecognizer:tapGesture];
            imageview.userInteractionEnabled = YES;
            imageview.tag = i;
            [tempArray addObject:dic[@"FecthImage"]];
        }

        scrollView = [[CycleScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, TABLE_CELL_HEIGHT_1)
                                                         cycleDirection:CycleDirectionLandscape
                                                               pictures:tempArray autoScroll:YES];
        scrollView.delegate = self;
        [self.tableView reloadData];
    }
   
}


-(void)pushToAdViewcontroller:(UIGestureRecognizer *)recon
{
    NSLog(@"%s",__func__);
    UIImageView * tempImg = (UIImageView *)recon.view;
    NSDictionary * dic = [imagesArray objectAtIndex:tempImg.tag];
    NSLog(@"%@",dic[@"url"]);
    __weak MainViewController * viewController = self;
    [HttpHelper getSpecificUrlContentOfAdUrl:dic[@"url"] completedBlock:^(id item, NSError *error) {
        NSString * str = (NSString *)item;
        [viewController performSelector:@selector(adView:) withObject:str];
    }];
}


-(void)adView:(id)obj
{
    AdViewController * viewController = [[AdViewController alloc]initWithNibName:@"AdViewController" bundle:nil];
    [viewController setContentStr:(NSString *)obj];
    [viewController setTitleStr:@"微信公众平台专享特价"];
    [self.navigationController pushViewController:viewController animated:YES];
    viewController = nil;

}
-(void)fetchDataThreadMethod
{
    while (!isFetchFoodDataSuccess||!isFetchStuffDataSuccess) {
        if ([fetchDataThread isCancelled]) {
            isFetchFoodDataSuccess = YES;
            isFetchStuffDataSuccess = YES;
        }else
        {
                NSLog(@"%s",__func__);
                if (!isFetchFoodDataSuccess) {
                    [HttpHelper getCommodityWithCatalogTabID:15 withTagName:@"热门商品" withStart:0 withCount:10 withSuccessBlock:^(NSArray *commoditys) {
                        if ([commoditys count]) {
                            recommandFootData = commoditys;
                            isFetchFoodDataSuccess = YES;
                        }
                        
                    } withErrorBlock:^(NSError *error) {
                        NSLog(@"获取热门食品失败 %@", [error description]);
                    }];
                }
                if (!isFetchStuffDataSuccess) {
                    [HttpHelper getCommodityWithCatalogTabID:57 withTagName:@"热门商品" withStart:0 withCount:10 withSuccessBlock:^(NSArray *commoditys) {
                        if ([commoditys count]) {
                            recommandCommodityData = commoditys;
                            isFetchStuffDataSuccess = YES;

                        }
                    } withErrorBlock:^(NSError *error) {
                        NSLog(@"获取热门日用品失败 %@", [error description]);
                    }];
                }
                [NSThread sleepForTimeInterval:8.0];
            }
        }
        
}

-(void)stopFetchDataThread
{
    [fetchDataThread cancel];
    [NSThread exit];
    fetchDataThread = nil;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tabImageName
{
	return @"首页icon-n";
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)search:(id)sender
{
    [searchField resignFirstResponder];
    SearchResultViewController * searchResultController = [[SearchResultViewController alloc] initWithNibName:nil bundle:nil];
    [searchResultController setSearchStr:searchField.text];
    searchResultController.lTitle = @"搜索结果";
    [self.navigationController pushViewController:searchResultController animated:YES];
    searchResultController = nil;
}


#pragma mark - UITableViewDataSource Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        return TABLE_CELL_HEIGHT_1;
    }
    else if(indexPath.row == 1)
    {
        return TABLE_CELL_HEIGHT_2;
    }
    else if (indexPath.row == 2)
    {
        return TABLE_CELL_HEIGHT_3;
    }
    else if(indexPath.row == 3)
    {
        return TABLE_CELL_HEIGHT_4;
    }
    else if(indexPath.row == 4)
    {
        return TABLE_CELL_HEIGHT_5;
    }
    else
    {
        return TABLE_CELL_HEIGHT_6;
    }
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0)
    {
        UIView * view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, TABLE_CELL_HEIGHT_1)];
        view1.backgroundColor = [UIColor grayColor];
        UIView * view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, TABLE_CELL_HEIGHT_1)];
        view2.backgroundColor = [UIColor blueColor];
        UITableViewCell * cell_1 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ScrollCell"];
        if (scrollView) {
            [cell_1.contentView addSubview:scrollView];
        }
        return cell_1;
        
    }
    else if(indexPath.row == 1)
    {
        MainCell2 * cell_2 = (MainCell2 *)[_tableView dequeueReusableCellWithIdentifier:@"MainCell2"];
        [cell_2.button_1 addTarget:self action:@selector(cell2BtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell_2.button_2 addTarget:self action:@selector(cell2BtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell_2.button_3 addTarget:self action:@selector(cell2BtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell_2.button_4 addTarget:self action:@selector(cell2BtnClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell_2;
        
    }
    else if (indexPath.row == 2)
    {
        MainCell3 * cell_3 = (MainCell3 *)[_tableView dequeueReusableCellWithIdentifier:@"MainCell3"];
        [cell_3 setBlock:[self configureCell3Block]];
        return cell_3;
    }
    else if(indexPath.row == 3)
    {
        MainCell4 * cell_4 = (MainCell4 *)[_tableView dequeueReusableCellWithIdentifier:@"MainCell4"];
        [cell_4 setBlock:[self configureCell4Block]];
        return cell_4;
    }
    else if(indexPath.row == 4)
    {
        MainCell5 * cell_5 = (MainCell5 *)[_tableView dequeueReusableCellWithIdentifier:@"MainCell5"];
        if (recommandFootData) {
            [cell_5 setDataSource:recommandFootData];
            [cell_5 updateScrollView];
            [cell_5 setNeedsLayout];
            recommandFootData = nil;
            [cell_5 setBlock:[self configureCell5Block]];
        }
        
        return cell_5;

    }else
    {
        MainCell6 * cell_6 = (MainCell6 *)[_tableView dequeueReusableCellWithIdentifier:@"MainCell6"];
        if (recommandCommodityData) {
            [cell_6 setDataSource:recommandCommodityData];
            [cell_6 updateScrollView];
            [cell_6 setNeedsLayout];
            recommandCommodityData = nil;
             [cell_6 setBlock:[self configureCell6Block]];
        }
       
       return cell_6;

    }
    if (!recommandFootData&&!recommandCommodityData) {
        if (![fetchDataThread isCancelled]) {
            NSLog(@"Canceled FetchDataThread");
            [fetchDataThread cancel];
        }
    }
    return nil;
}


-(MainCell3ConfigureBlock )configureCell3Block
{
    MainCell3ConfigureBlock block = ^(id item)
    {
        NSString * titleStr = (NSString * )item;
        if ([titleStr isEqualToString:@"清仓特卖"]) {
            titleStr = @"清仓";
        }
        NSLog(@"%@",titleStr);
        MainCommodityViewController * viewController = [[MainCommodityViewController alloc]initWithNibName:@"MainCommodityViewController" bundle:nil];
        [viewController setTitleStr:titleStr];
        //15 表示食品
        [viewController setTabId:@"15"];
        [self.navigationController pushViewController:viewController animated:YES];
        viewController = nil;

    };
    return block;
}
-(MainCell4ConfigureBlock )configureCell4Block
{
    MainCell3ConfigureBlock block = ^(id item)
    {
        NSString * titleStr = (NSString * )item;
        if ([titleStr isEqualToString:@"清仓特卖"]) {
            titleStr = @"清仓";
        }

        NSLog(@"%@",titleStr);
        MainCommodityViewController * viewController = [[MainCommodityViewController alloc]initWithNibName:@"MainCommodityViewController" bundle:nil];
        [viewController setTitleStr:titleStr];
        [viewController setTabId:@"57"];
        [self.navigationController pushViewController:viewController animated:YES];
        viewController = nil;
        
    };
    return block;
}
-(MainCell5Block )configureCell5Block
{
    MainCell5Block block = ^(id item1)
    {
        Commodity * info = (Commodity *)item1;
        [Commodity printCommodityInfo:info];
        CommodityViewController *viewController = [[CommodityViewController alloc]initWithNibName:@"CommodityViewController" bundle:nil];
        [viewController setComodityInfo:info];
        [self.navigationController pushViewController:viewController animated:YES];
        viewController = nil;
    };
    return block;
}

-(MainCell6Block )configureCell6Block
{
    MainCell5Block block = ^(id item)
    {
        Commodity * info = (Commodity *)item;
        [Commodity printCommodityInfo:info];
        CommodityViewController *viewController = [[CommodityViewController alloc]initWithNibName:@"CommodityViewController" bundle:nil];
        [viewController setComodityInfo:info];
        [self.navigationController pushViewController:viewController animated:YES];
        viewController = nil;
    };
    return block;
}
#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)cell2BtnClick:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if(btn.tag == 1)
    {
        CommodityChangeViewController * commodityChange = [[CommodityChangeViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:commodityChange animated:YES];
    }
    else if(btn.tag == 2)
    {
        YHJViewController * yhjViewController = [[YHJViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:yhjViewController animated:YES];
    }
    else if(btn.tag == 3)
    {
        TZMarketViewController * marketViewController = [[TZMarketViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:marketViewController animated:YES];
    }
    else if(btn.tag == 4)
    {
        NoticeListViewController * noticeList = [[NoticeListViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController pushViewController:noticeList animated:YES];
    }
}

#pragma mark - CycleScrollViewDelegate
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didSelectImageView:(int)index {
    
    NSLog(@"%s",__func__);
    NSDictionary *dic = [imagesArray objectAtIndex:index-1];
    __weak MainViewController * viewController = self;
    [HttpHelper getSpecificUrlContentOfAdUrl:dic[@"url"] completedBlock:^(id item, NSError *error) {
        NSString * str = (NSString *)item;
        [viewController performSelector:@selector(adView:) withObject:str];
    }];
}


@end
