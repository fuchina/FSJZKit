//
//  FSSelectController.h
//  ShareEconomy
//
//  Created by FudonFuchina on 16/6/10.
//  Copyright © 2016年 FudonFuchina. All rights reserved.
//

#import "FSBaseController.h"

@class FSSelectController;
typedef void(^FSSelectControllerBlock)(FSSelectController *bSelectController,NSIndexPath *bIndexPath,NSArray *bArray);

@interface FSSelectController : FSBaseController

@property (nonatomic,strong) NSArray                        *array;
@property (nonatomic,copy) FSSelectControllerBlock          block;

@property (nonatomic,copy) void (^configCell)(UITableViewCell *bCell,NSIndexPath *bIndexPath,NSArray *bArray);

@end
