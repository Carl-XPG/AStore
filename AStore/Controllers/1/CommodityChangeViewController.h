//
//  CommodityChangeViewController.h
//  AStore
//
//  Created by Carl on 13-9-28.
//  Copyright (c) 2013年 carl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+LeftTitle.h"
@class MBProgressHUD;
@interface CommodityChangeViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong ,nonatomic) MBProgressHUD * loadingView;
@end
