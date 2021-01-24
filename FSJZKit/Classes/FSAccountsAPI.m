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
    NSString *tableName = [[NSString alloc] initWithFormat:@"%@%@",_SPEC_FLAG_A,@(_fs_integerTimeIntevalSince1970())];
    BOOL exist = [master checkTableExist:tableName];
    if (exist) {
        return @"账本已存在";
    }
    
    return [self createAccountBook:tableName name:account type:type];
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

+ (NSString *)hideAccount:(NSNumber *)aid hidden:(BOOL)hidden {
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET flag = '%d' WHERE aid = %@;",_tb_abname,hidden ? 1: 0,aid];
    NSString *error = [master updateSQL:sql];
    return error;
}

+ (NSString *)renameAccount:(NSString *)name aid:(NSNumber *)aid {
    FSDBMaster *master = [FSDBMaster sharedInstance];
    NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET name = '%@' WHERE aid = %@;",_tb_abname,name,aid];
    NSString *error = [master updateSQL:sql];
    return error;
}

+ (NSString *)deleteAccount:(NSNumber *)aid table:(NSString *)table {
    FSDBMaster *master = [FSDBMaster sharedInstance];
    BOOL exist = [master checkTableExist:table];
    if (exist) {
        NSString *error = [master dropTable:table];
        if (error) {
            return error;
        }
    }
    NSString *error = [master deleteSQL:_tb_abname aid:aid];
    return error;
}

+ (void)otherAccounts:(NSInteger)page type:(NSInteger)type results:(void(^)(NSArray<FSABNameModel *> *list))otherAccounts {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger unit = 50;
        NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE type = '%@' and flag = '1' order by cast(freq as INTEGER) DESC limit %@,%@;",_tb_abname,@(type),@(unit * page),@(unit)];
        NSMutableArray *list = [FSDBSupport querySQL:sql class:FSABNameModel.class tableName:_tb_abname];
        dispatch_async(dispatch_get_main_queue(), ^{
            otherAccounts(list);
        });
    });
}

@end
