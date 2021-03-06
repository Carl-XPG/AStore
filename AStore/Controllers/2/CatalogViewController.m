//
//  CatalogViewController.m
//  AStore
//
//  Created by Carl on 13-9-26.
//  Copyright (c) 2013年 carl. All rights reserved.
//

#import "CatalogViewController.h"
#import "ChildCatalogViewContaollerViewController.h"
#import "UIViewController+LeftTitle.h"
#import "HttpHelper.h"
#import "CategoryInfo.h"
#import "AppDelegate.h"
#import "SubCatalogViewController.h"
@interface CatalogViewController ()
{
    NSMutableArray * totalCatalogData;
    NSString  * promptStr;
}
@property (strong, nonatomic) NSArray *firstSectionData;
@property (strong, nonatomic) NSArray *secondSectionData;
@property (strong, nonatomic) NSArray *thirdSectionData;
@property (strong, nonatomic) NSString * firstSectionKey;
@property (strong, nonatomic) NSString * secondSectionKey;
@property (strong, nonatomic) NSString * thirdSectionKey;

@property (strong,nonatomic) NSMutableDictionary * dictionary;
@end

@implementation CatalogViewController
@synthesize firstSectionData,secondSectionData,thirdSectionData;
@synthesize loadingView;

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
    [self setLeftTitle:@"全部分类"];
    loadingView = [[MBProgressHUD alloc]initWithView:self.view];
    loadingView.dimBackground = YES;
    loadingView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    promptStr = @"正在加载...";
    loadingView.detailsLabelText = promptStr;
    [loadingView setMode:MBProgressHUDModeDeterminate];   //圆盘的扇形进度显示
    loadingView.taskInProgress = YES;
    [self.view addSubview:loadingView];
    [loadingView hide:NO];
    [loadingView show:YES];

}


-(void)viewWillAppear:(BOOL)animated
{
    
    [HttpHelper getAllCatalogWithSuccessBlock:^(NSDictionary *catInfo) {
        if ([catInfo count]) {
            totalCatalogData = [catInfo objectForKey:@"totalObj"];
            NSDictionary * catalogInfo = [catInfo objectForKey:@"catalogInfo"];
            _dictionary = (NSMutableDictionary *)catalogInfo;
            _firstSectionKey = [[_dictionary allKeys]objectAtIndex:0];
            _secondSectionKey = [[_dictionary allKeys]objectAtIndex:1];
            _thirdSectionKey = [[_dictionary allKeys]objectAtIndex:2];
            firstSectionData = (NSArray *)[_dictionary objectForKey:_firstSectionKey];
            secondSectionData = (NSArray *)[_dictionary objectForKey:_secondSectionKey];
            thirdSectionData = (NSArray *)[_dictionary objectForKey:_thirdSectionKey];
            [self performSelectorOnMainThread:@selector(refreshTableview) withObject:nil waitUntilDone:NO];
        }
        
    } errorBlock:^(NSError *error) {
        if ([[error domain] isEqualToString:@"NSURLErrorDomain"]) {
            promptStr = @"请检查网络";
        }else
        {
            promptStr = @"非常抱歉，分类没有产品！";
        }
        [self resetLoadingText];
    }];
}

-(void)resetLoadingText
{
    loadingView.detailsLabelText = promptStr;
    [self performSelector:@selector(hideLoadingView) withObject:nil afterDelay:2.0];
    
}

-(void)hideLoadingView
{
    [loadingView show:NO];
    [loadingView hide:YES];
}

-(void)refreshTableview
{
    [loadingView show:NO];
    [loadingView hide:YES];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)tabImageName
{
	return @"分类icon-n";
}

- (void)viewDidUnload {
    [self setTableView:nil];
    [super viewDidUnload];
}


#pragma mark - UITableViewDataSource Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_dictionary allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    NSString * key = [[_dictionary allKeys] objectAtIndex:section];
    return ((NSArray *)[_dictionary objectForKey:key]).count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"分类背景"]];
    [imageView setContentMode:UIViewContentModeScaleToFill];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 120, 35)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor blackColor]];
    [label setFont:[UIFont systemFontOfSize:20]];
    UIView * headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 45)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    if (section == 0 ) {
        label.text = _firstSectionKey;
    } else if(section == 1){
        label.text = _secondSectionKey;
    }else
    {
        label.text =_thirdSectionKey;
    }
    [headerView addSubview:imageView];
    [headerView addSubview:label];
    imageView = nil;
    label = nil;
    return headerView;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.indentationLevel = 3;
        cell.textLabel.textColor = [UIColor darkGrayColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
   
    NSString * key = [[_dictionary allKeys] objectAtIndex:indexPath.section];
    NSArray * array = (NSArray *)[_dictionary objectForKey:key];
    ;
    cell.textLabel.text = [[array objectAtIndex:indexPath.row]objectForKey:@"cat_name"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return  cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0) {
        NSDictionary * tempDic = [firstSectionData objectAtIndex:indexPath.row];
        NSString * parent_idStr = [tempDic objectForKey:@"cat_id"];
        NSMutableArray * tempArray = [NSMutableArray array];
        for (NSDictionary * dic in totalCatalogData) {
            if ([[dic objectForKey:@"parent_id"] isEqualToString:parent_idStr])
            {
                [tempArray addObject:dic];
            }
        }

        if ([tempArray count]) {
            SubCatalogViewController * subViewController = [[SubCatalogViewController alloc]initWithNibName:@"SubCatalogViewController" bundle:nil];
            [subViewController setDataSource:tempArray];
            tempArray = nil;
            [subViewController setTitleStr:[tempDic objectForKey:@"cat_name"]];
            [self.navigationController pushViewController:subViewController animated:YES];
        }else
        {
            ChildCatalogViewContaollerViewController * cCatList = [[ChildCatalogViewContaollerViewController alloc] initWithNibName:nil bundle:nil];

            [cCatList setCat_id:[[firstSectionData objectAtIndex:indexPath.row]objectForKey:@"cat_id"]];
            [cCatList setCat_name:[[firstSectionData objectAtIndex:indexPath.row]objectForKey:@"cat_name"]];
            [self.navigationController pushViewController:cCatList animated:YES];
        }
        
    }else if(indexPath.section ==1)
    {
        NSDictionary * tempDic = [secondSectionData objectAtIndex:indexPath.row];
        NSString * parent_idStr = [tempDic objectForKey:@"cat_id"];
        NSMutableArray * tempArray = [NSMutableArray array];
        for (NSDictionary * dic in totalCatalogData) {
            if ([[dic objectForKey:@"parent_id"] isEqualToString:parent_idStr])
            {
                [tempArray addObject:dic];
            }
        }
        
        if ([tempArray count]) {
            SubCatalogViewController * subViewController = [[SubCatalogViewController alloc]initWithNibName:@"SubCatalogViewController" bundle:nil];
            [subViewController setDataSource:tempArray];
            tempArray = nil;
            [subViewController setTitleStr:[tempDic objectForKey:@"cat_name"]];
            [self.navigationController pushViewController:subViewController animated:YES];
        }else
        {
            ChildCatalogViewContaollerViewController * cCatList = [[ChildCatalogViewContaollerViewController alloc] initWithNibName:nil bundle:nil];
            
            [cCatList setCat_id:[[secondSectionData objectAtIndex:indexPath.row]objectForKey:@"cat_id"]];
            [cCatList setCat_name:[[secondSectionData objectAtIndex:indexPath.row]objectForKey:@"cat_name"]];
             [self.navigationController pushViewController:cCatList animated:YES];
        }
    }else
    {
        NSDictionary * tempDic = [thirdSectionData objectAtIndex:indexPath.row];
        NSString * parent_idStr = [tempDic objectForKey:@"cat_id"];
        NSMutableArray * tempArray = [NSMutableArray array];
        for (NSDictionary * dic in totalCatalogData) {
            if ([[dic objectForKey:@"parent_id"] isEqualToString:parent_idStr])
            {
                [tempArray addObject:dic];
            }
        }
        
        if ([tempArray count]) {
            SubCatalogViewController * subViewController = [[SubCatalogViewController alloc]initWithNibName:@"SubCatalogViewController" bundle:nil];
            [subViewController setDataSource:tempArray];
            tempArray = nil;
            [subViewController setTitleStr:[tempDic objectForKey:@"cat_name"]];
            [self.navigationController pushViewController:subViewController animated:YES];
        }else
        {
            ChildCatalogViewContaollerViewController * cCatList = [[ChildCatalogViewContaollerViewController alloc] initWithNibName:nil bundle:nil];
            
            [cCatList setCat_id:[[thirdSectionData objectAtIndex:indexPath.row]objectForKey:@"cat_id"]];
            [cCatList setCat_name:[[thirdSectionData objectAtIndex:indexPath.row]objectForKey:@"cat_name"]];
            [self.navigationController pushViewController:cCatList animated:YES];
        }
    }
}

@end
