//
//  FSABSearchController.h
//  myhome
//
//  Created by fudon on 2017/5/22.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSBaseController.h"

@interface FSABSearchController : FSBaseController

@property (nonatomic,copy) NSString     *placeholder;
@property (nonatomic,strong) UIView     *resultView;

@property (nonatomic,copy) void (^searchEvent)(FSABSearchController *searchController,NSString *text);
@property (nonatomic,copy) UITableView* (^resultTableView)(FSABSearchController *searchController);

+ (CGFloat)searchViewHeight;

@end
