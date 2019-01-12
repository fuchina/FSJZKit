//
//  FSAccountsController.h
//  myhome
//
//  Created by FudonFuchina on 2017/5/21.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSBaseController.h"

@interface FSAccountsController : FSBaseController

@property (nonatomic,assign) NSInteger  type;   // 1.公司 2.个人 3.存货管理 4.自定义账本

@property (nonatomic,copy) void (^push)(NSString *table, NSString *name);  // push

@end
