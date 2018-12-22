//
//  FSDBGroupAPI.h
//  myhome
//
//  Created by FudonFuchina on 2018/3/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSDBGroupModel.h"
#import "FSBaseAPI.h"

@interface FSDBGroupAPI : FSBaseAPI

+ (NSMutableArray<FSDBGroupModel *> *)groups:(NSString *)type link:(NSString *)link page:(NSInteger)page;

+ (NSString *)addGroup:(NSString *)name type:(NSString *)type link:(NSString *)link;

+ (BOOL)hasData:(NSString *)table group:(NSString *)group;

+ (BOOL)canDeleteWithTable:(NSString *)table zone:(NSString *)zone;

// objectForKey:@"name"
+ (NSArray<NSDictionary *> *)allZones:(NSString *)table zone:(NSString *)myZone;

+ (void)updateFreq:(FSDBGroupModel *)model;

+ (NSString *)titleForTable:(NSString *)table;

/*
1.不能移到自己目录下，也不能移到自己的子目录下；
2.如果目标目录下有数据，也不能移入；
3.不能移入到父目录下，因为已经在该目录下。
 */
+ (NSArray<NSDictionary *> *)zonesForChange:(NSString *)table model:(FSDBGroupModel *)model;

+ (NSString *)changeModel:(FSDBGroupModel *)model toZone:(NSString *)zone table:(NSString *)table;

+ (NSString *)renameModel:(FSDBGroupModel *)model newName:(NSString *)name forTable:(NSString *)table;

@end
