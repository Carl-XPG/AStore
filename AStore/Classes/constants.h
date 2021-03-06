//
//  constants.h
//  AStore
//
//  Created by vedon on 10/3/13.
//  Copyright (c) 2013 carl. All rights reserved.
//

#ifndef AStore_constants_h
#define AStore_constants_h

#define IS_SCREEN_4_INCH (([[UIScreen mainScreen] bounds].size.height == 568)?YES:NO)

#define SERVER_URL_Prefix   @"http://www.youjianpuzi.com/youjian.php?"
#define Resource_URL_Prefix @"http://www.youjianpuzi.com/"

#define DUserName   @"uname"
#define DPassword   @"VPassword"
#define DMemberId   @"member_id"
#define DArea       @"area"
#define DLevelName  @"lv_name"
#define DLevelId    @"member_lv_id"
#define DMobile     @"mobile"
#define DLoginName  @"name"
#define DPoint      @"point"
#define DEmail      @"email"


#define chooseBtnTag   1001
#define alterBtnTag    1002
#define deleteBtnTag   1003

#define VOrderNum       @"orderNumber"
#define VOrderTime      @"orderTime"
#define VCommodityName  @"commodityName"
#define VSumMoney       @"Sum"
#define VOrderStatus    @"orderStatus"
#define VTotalCredits   @"totalCredits"


#define VUserName           @"userName"
#define VTelePhone          @"vtelephone"
#define VPhone              @"vphone"
#define VAddress            @"vaddress"
//cartViewController
#define ProductName         @"productName"
#define ProductNumber       @"productNumebr"
#define ProductPrice        @"productPrice"
#define ProductImage        @"productimage"
#define JiFen               @"jifen"

//HTTP Request
#define RequestStatusKey    @"ret"

#define VUserInfo           @"vuserInfo"
#define VServerUserInfo     @"serverUserInfo"

//更新购物车中cell的状态
#define CommodityCellStatus @"CommodityCellStatus"
#define PresentCellStatus   @"PresentCellStatus"

//badgeView
#define UpdateBadgeViewTitle @"UpdateBadgeViewTitle"
#endif
