//
//  FSAccountsAPI.h
//  FSJZKit
//
//  Created by FudonFuchina on 2021/1/7.
//

#import <Foundation/Foundation.h>
#import "FSABNameModel.h"
#import "FSBaseAPI.h"

NS_ASSUME_NONNULL_BEGIN

@interface FSAccountsAPI : FSBaseAPI

+ (void)accounts:(NSInteger)page type:(NSInteger)type results:(void(^)(NSMutableArray<FSABNameModel *> *list))accounts;

+ (NSString *)addAccount:(NSString *)account type:(NSInteger)type;

+ (NSString *)hideAccount:(NSNumber *)aid;

+ (NSString *)renameAccount:(NSString *)name aid:(NSNumber *)aid;

+ (void)otherAccounts:(void(^)(NSArray<FSABNameModel *> *list))otherAccounts;

@end

NS_ASSUME_NONNULL_END