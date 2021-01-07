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
#import "FSABNameModel.h"
#import "FSShare.h"
#import <MJRefresh.h>
#import "UIViewController+BackButtonHandler.h"
#import "AppConfiger.h"
#import "FSBaseAPI.h"
#import <FSUIKit.h>
#import <FSDate.h>
#import "FSOtherAccountsController.h"
#import "FSAccountsAPI.h"

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

- (void)accNameHandleDatas{
    [FSAccountsAPI accounts:self.page type:_type results:^(NSMutableArray<FSABNameModel *> * _Nonnull list) {
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
        
        [self accNameDesignViews];
    }];
}

- (void)accNameDesignViews{
    if (!_tableView) {
        self.title = @"账本";
                
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(bbiAction)];
        UIBarButtonItem *lists = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(allData)];
        self.navigationItem.rightBarButtonItems = @[bbi,lists];
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _fs_statusAndNavigatorHeight(), WIDTHFC, HEIGHTFC - _fs_statusAndNavigatorHeight() - _fs_tabbarBottomMoreHeight()) style:UITableViewStylePlain];
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

- (void)allData {
    FSOtherAccountsController *other = [[FSOtherAccountsController alloc] init];
    other.type = self.type;
    other.push = self.push;
    [self.navigationController pushViewController:other animated:YES];
}

- (void)bbiAction{
    __weak typeof(self)this = self;
    [FSUIKit alertInput:1 controller:self title:@"添加一个新账本" message:nil ok:@"增加" handler:^(UIAlertController *bAlert, UIAlertAction *action) {
        UITextField *textField = [bAlert.textFields firstObject];
        if (!_fs_isValidateString([FSKit cleanString:textField.text])) {
            return;
        }
        NSString *error = [FSAccountsAPI addAccount:textField.text type:this.type];
        if (error) {
            [FSToast show:error];
        } else {
            [this accNameHandleDatas];
        }
    } cancel:@"取消" handler:nil textFieldConifg:^(UITextField *textField) {
        NSDateComponents *c = [FSDate componentForDate:[NSDate date]];
        textField.placeholder = [[NSString alloc] initWithFormat:@"如'%@'",@(c.year)];
    } completion:nil];
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
    return cell;
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"重命名" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        __weak typeof(self)this = self;
        [FSUIKit alertInput:1 controller:self title:@"给账本换个新名字" message:nil ok:@"确认" handler:^(UIAlertController *bAlert, UIAlertAction *action) {
            NSString *name =  [bAlert.textFields.firstObject.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if (name.length == 0) {
                [FSToast show:@"请输入"];
                return;
            }
            FSABNameModel *model = this.dataSource[indexPath.row];
            NSString *error = [FSAccountsAPI renameAccount:name aid:model.aid];
            if (error) {
                [FSToast show:error];
            }else{
                model.name = name;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        } cancel:@"取消" handler:^(UIAlertAction *action) {
            tableView.editing = NO;
        } textFieldConifg:^(UITextField *textField) {
            textField.placeholder = @"输入一个新名字";
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            FSABNameModel *model = this.dataSource[indexPath.row];
            textField.text = model.name;
        } completion:nil];
    }];
    action0.backgroundColor = THISCOLOR;
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"不显示" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        FSABNameModel *model = self->_dataSource[indexPath.row];
        NSString *error = [FSAccountsAPI hideAccount:model.aid hidden:YES];
        if (error) {
            [FSUIKit showAlertWithMessage:error controller:self];
            return;
        }
        [self accNameHandleDatas];
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
    [FSBaseAPI addFreq:_tb_abname field:@"freq" model:model];
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
