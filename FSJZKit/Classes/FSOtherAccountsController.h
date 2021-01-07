//
//  FSOtherAccountsController.h
//  FSJZKit
//
//  Created by FudonFuchina on 2021/1/7.
//

#import "FSBaseController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSOtherAccountsController : FSBaseController

@property (nonatomic, assign) NSInteger     type;

@property (nonatomic,copy) void (^push)(NSString *table, NSString *name);  // push

@end

NS_ASSUME_NONNULL_END
