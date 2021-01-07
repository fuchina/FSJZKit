//
//  FSAccountsAPI.m
//  FSJZKit
//
//  Created by FudonFuchina on 2021/1/7.
//

#import "FSAccountsAPI.h"
#import "FSDBSupport.h"
#import "FSMacro.h"

@implementation FSAccountsAPI

+ (void)accounts:(NSInteger)page type:(NSInteger)type results:(void(^)(NSMutableArray<FSABNameModel *> *list))accounts {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *sql = [self sql:page type:type];
        NSMutableArray *list = [FSDBSupport querySQL:sql class:FSABNameModel.class tableName:_tb_abname];
        dispatch_async(dispatch_get_main_queue(), ^{
            accounts(list);
        });
    });
}

+ (NSString *)sql:(NSInteger)page type:(NSInteger)type {
    NSInteger unit = 50;
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE type = '%@' and flag = '0' order by cast(freq as INTEGER) DESC limit %@,%@;",_tb_abname,@(type),@(unit * page),@(unit)];
    return sql;
}

+ (NSString *)addAccount:(NSString *)account type:(NSInteger)type {
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *same = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE type = '%@' and name = '%@' and flag = '0'",_tb_abname,@(type),account];
    NSArray *list = [master querySQL:same tableName:_tb_abname];
    if (list.count) {
        return @"已存在同名账本";
    }
    NSInteger count = [master countForTable:_tb_abname];
    NSString *tableName = [self accountTable:count];
    BOOL exist = [master checkTableExist:tableName];
    if (exist) {
        return @"账本已存在";
    }
    
    return [self createAccountBook:tableName name:account type:type];
}

+ (NSString *)accountTable:(NSInteger)count{
    NSString *tableName = [[NSString alloc] initWithFormat:@"%@%@",_SPEC_FLAG_A,@(count)];
    return tableName;
}

+ (NSString *)createAccountBook:(NSString *)tableName name:(NSString *)name type:(NSInteger)type {
    if (!([name isKindOfClass:NSString.class] && name.length)) {
        return @"请输入账本名";
    }
    if (!([tableName isKindOfClass:NSString.class] && tableName.length)) {
        return @"表名不正确";
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *error = [master insert_fields_values:@{
                                                     @"time":@(_fs_integerTimeIntevalSince1970()),
                                                     @"name":name,
                                                     @"tb":tableName,
                                                     @"type":@(type),
                                                     @"freq":@0,
                                                     @"flag":@0
                                                     } table:_tb_abname];
    
    return error;
}

+ (NSString *)hideAccount:(NSNumber *)aid {
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET flag = '1' WHERE aid = %@;",_tb_abname,aid];
    NSString *error = [master updateSQL:sql];
    return error;
}

+ (NSString *)renameAccount:(NSString *)name aid:(NSNumber *)aid {
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET name = '%@' WHERE aid = %@;",_tb_abname,name,aid];
    NSString *error = [master updateSQL:sql];
    return error;
}

+ (void)otherAccounts:(void(^)(NSArray<FSABNameModel *> *list))otherAccounts {
    
    if (otherAccounts) {
        otherAccounts(nil);
    }
}

@end
