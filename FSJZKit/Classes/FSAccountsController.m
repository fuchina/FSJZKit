//
//  FSAccNameController.m
//  myhome
//
//  Created by FudonFuchina on 2017/4/5.
//  Copyright © 2017年 fuhope. All rights reserved.
//

#import "FSAccountsController.h"
#import "FSDBSupport.h"
#import <MessageUI/MessageUI.h>
//#import "FSAccountConfiger.h"
#import "FSABNameModel.h"
//#import "FSDBTool.h"
//#import "FSHTMLController.h"
#import "FSShare.h"
#import <MJRefresh.h>
#import "UIViewController+BackButtonHandler.h"
#import "FSAPP.h"
//#import "FSWebKitController.h"
#import "AppConfiger.h"
#import "FSBaseAPI.h"
#import <FSUIKit.h>
#import <FSDate.h>
#import "FSTrack.h"
#import "FSTrackKeys.h"
#import "FSKitDuty.h"

@interface FSAccountsController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray     *dataSource;
@property (nonatomic,strong) UITableView        *tableView;
@property (nonatomic,assign) NSInteger          page;

@end

@implementation FSAccountsController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self accNameHandleDatas];
}

- (void)mailAction{
    [FSShare emailShareWithSubject:NSLocalizedString(@"Questions about account", nil) on:self messageBody:nil recipients:@[_feedback_Email] fileData:nil fileName:nil mimeType:nil];
}

- (void)accountExplain{
    [self event:_UMeng_Event_acc_show];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"note" ofType:@"pdf"];
//    FSHTMLController *html = [[FSHTMLController alloc] init];
//    html.title = @"说明";
//    html.localUrlString = path;
//    [self.navigationController pushViewController:html animated:YES];
    
//    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(mailAction)];
//    html.navigationItem.rightBarButtonItem = bbi;
}

- (void)accNameHandleDatas{    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *sql = [self sql:self->_page];
        NSMutableArray *list = [FSDBSupport querySQL:sql class:FSABNameModel.class tableName:_tb_abname];
        if (self.page) {
            [self.dataSource addObjectsFromArray:list];
        }else{
            self->_dataSource = list;
            if (list.count == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self bbiAction];
                });
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self accNameDesignViews];
        });
    });
}

- (NSString *)sql:(NSInteger)page{
    NSInteger unit = 50;
    NSString *sql = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE type = '%@' and flag = '0' order by cast(freq as INTEGER) DESC limit %@,%@;",_tb_abname,@(_type),@(unit * page),@(unit)];
    return sql;
}

- (void)accNameDesignViews{
    if (!_tableView) {
        self.title = NSLocalizedString(@"Account", nil);
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [button addTarget:self action:@selector(accountExplain) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *mail = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(bbiAction)];
        if (self.type == 2) {
            self.navigationItem.rightBarButtonItems = @[bbi,mail];
        }else{
            self.navigationItem.rightBarButtonItem = bbi;
        }
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
        [self.view addSubview:_tableView];
        WEAKSELF(this);
        _tableView.mj_header= [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            this.page = 0;
            [this accNameHandleDatas];
        }];
        this.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            this.page ++;
            [this accNameHandleDatas];
        }];
    }else{
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        [_tableView reloadData];
    }
}

- (void)twoMinutesLearnAccount{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(0, HEIGHTFC - 44 - (FS_iPhone_X?34:0), WIDTHFC, 44);
    [button setTitle:NSLocalizedString(@"Learn to bookkeeping in two minutes", nil) forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = FSAPPCOLOR;
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)buttonClick{
//    NetworkStatus status = [FSKitDuty networkStatus];
//    if (status == ReachableViaWWAN) {
//        [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:NSLocalizedString(@"You are using WWAN, and watch it?", nil) message:nil actionTitles:@[NSLocalizedString(@"Watch", nil)] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
//            [self seeTheVideo];
//        }];
//    }else{
//        [self seeTheVideo];
//    }
}

- (void)seeTheVideo{
//    FSWebKitController *webController = [[FSWebKitController alloc] init];
//    webController.urlString = _Watch_Account;
//    [self.navigationController pushViewController:webController animated:YES];
//    [self event:_UMeng_Event_watch_video];
}

- (void)bbiAction{
    __weak typeof(self)this = self;
    [FSUIKit alertInput:1 controller:self title:NSLocalizedString(@"Add a new account", nil) message:nil ok:NSLocalizedString(@"Add", nil) handler:^(UIAlertController *bAlert, UIAlertAction *action) {
        UITextField *textField = [bAlert.textFields firstObject];
        if (!_fs_isValidateString([FSKit cleanString:textField.text])) {
            return;
        }
        FSDBMaster *master = [FSDBMaster sharedInstance];
        NSString *same = [[NSString alloc] initWithFormat:@"SELECT * FROM %@ WHERE type = '%@' and name = '%@' and flag = '0'",_tb_abname,@(this.type),textField.text];
        NSArray *list = [master querySQL:same tableName:_tb_abname];
        if (list.count) {
            [FSToast show:NSLocalizedString(@"The same name exists", nil)];
            return;
        }
        NSInteger count = [master countForTable:_tb_abname];
        NSString *tableName = [this accountTable:count];
        BOOL exist = [master checkTableExist:tableName];
        if (exist) {
            [FSToast toast:NSLocalizedString(@"The account exists", nil)];
            return;
        }
        [this createAccountBook:tableName name:textField.text];
        [this accNameHandleDatas];
    } cancel:NSLocalizedString(@"Cancel", nil) handler:nil textFieldConifg:^(UITextField *textField) {
        NSDateComponents *c = [FSDate componentForDate:[NSDate date]];
        textField.placeholder = [[NSString alloc] initWithFormat:@"如'%@'",@(c.year)];
    } completion:nil];
}

- (NSString *)accountTable:(NSInteger)count{
    NSString *tableName = [[NSString alloc] initWithFormat:@"%@%@",_SPEC_FLAG_A,@(count)];
    return tableName;
}

- (void)createAccountBook:(NSString *)tableName name:(NSString *)name {
    if (!([name isKindOfClass:NSString.class] && name.length)) {
        [FSToast show:NSLocalizedString(@"Please input account name", nil)];
        return;
    }
    if (!([tableName isKindOfClass:NSString.class] && tableName.length)) {
        return;
    }
    FSDBMaster *master = [FSDBMaster sharedInstance];    
    NSString *error = [master insert_fields_values:@{
                                                     @"time":@(_fs_integerTimeIntevalSince1970()),
                                                     @"name":name,
                                                     @"tb":tableName,
                                                     @"type":@(_type),
                                                     @"freq":@0,
                                                     @"flag":@0
                                                     } table:_tb_abname];
    
    if (error) {
        [FSUIKit showAlertWithMessage:error controller:self];
        return;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    FSABNameModel *model = _dataSource[indexPath.row];
    cell.textLabel.text = model.name;
//    NSString *text = [FSAPP messageForTable:model.tb];
//    cell.detailTextLabel.text = text?:NSLocalizedString(@"Nothing", nil);
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Rename", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        __weak typeof(self)this = self;
        [FSUIKit alertInput:1 controller:self title:NSLocalizedString(@"Name the account a new one", nil) message:nil ok:NSLocalizedString(@"Confirm", nil) handler:^(UIAlertController *bAlert, UIAlertAction *action) {
            NSString *name =  [bAlert.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (name.length == 0) {
                [FSToast show:NSLocalizedString(@"Please input", nil)];
                return;
            }
            FSABNameModel *model = this.dataSource[indexPath.row];
            FSDBMaster *master = [FSDBMaster sharedInstance];
            NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET name = '%@' WHERE aid = %@;",_tb_abname,name,model.aid];
            NSString *error = [master updateSQL:sql];
            if (error) {
                [FSToast show:error];
            }else{
                model.name = name;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        } cancel:NSLocalizedString(@"Cancel", nil) handler:^(UIAlertAction *action) {
            tableView.editing = NO;
        } textFieldConifg:^(UITextField *textField) {
            textField.placeholder = NSLocalizedString(@"Input new name", nil);
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            FSABNameModel *model = this.dataSource[indexPath.row];
            textField.text = model.name;
        } completion:nil];
    }];
    action0.backgroundColor = THISCOLOR;
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        FSABNameModel *model = self->_dataSource[indexPath.row];
        NSString *name = [[NSString alloc] initWithFormat:@"%@ '%@'?",NSLocalizedString(@"Confirm delete account", nil),model.name];
        [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:name message:nil actionTitles:@[NSLocalizedString(@"Delete", nil)] styles:@[@(UIAlertActionStyleDestructive)] handler:^(UIAlertAction *action) {
            FSDBMaster *master = [FSDBMaster sharedInstance];
            NSString *sql = [[NSString alloc] initWithFormat:@"UPDATE %@ SET flag = '1' WHERE aid = %@;",_tb_abname,model.aid];
            NSString *error = [master updateSQL:sql];
            if (error) {
                [FSUIKit showAlertWithMessage:error controller:self];
                return;
            }
            [self accNameHandleDatas];
        } cancelTitle:NSLocalizedString(@"Cancel", nil) cancel:^(UIAlertAction *action) {
            tableView.editing = NO;
        } completion:nil];
    }];
    return @[action1, action0];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FSABNameModel *model = _dataSource[indexPath.row];
    if (self.push) {
        self.push(model.tb, model.name);
    }
    [self updateFreq:model];
    
    //        FSABCompanyOverviewController *company = [[FSABCompanyOverviewController alloc] init];
    //        company.accountName = model.tb;
    //        company.title = model.name;
    //        [self.navigationController pushViewController:company animated:YES];
}

- (void)updateFreq:(FSABNameModel *)model{
    [FSBaseAPI addFreq:_tb_abname field:@"freq" model:model];
}

-(BOOL)navigationShouldPopOnBackButton{
    BOOL success = [FSKit popToController:@"HAToolController" navigationController:self.navigationController animated:YES];
    BOOL bSuccess = [FSKit popToController:@"FSCompanyPartController" navigationController:self.navigationController animated:YES];
    if (!(success || bSuccess)) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
