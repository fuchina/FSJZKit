//
//  FSCommonGroupController.m
//  myhome
//
//  Created by FudonFuchina on 2018/3/2.
//  Copyright © 2018年 fuhope. All rights reserved.
//

#import "FSCommonGroupController.h"
#import "FSDBGroupAPI.h"
#import <MJRefresh.h>
#import "UIViewController+BackButtonHandler.h"
#import "FSHalfView.h"
#import <FSUIKit.h>
#import "FSMacro.h"

@interface FSCommonGroupController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView        *tableView;
@property (nonatomic,strong) NSMutableArray     *list;
@property (nonatomic,assign) NSInteger          page;
@property (nonatomic,strong) FSHalfView         *halfView;
@property (nonatomic,strong) NSArray            *zones;
@property (nonatomic,strong) FSDBGroupModel     *model;

@end

@implementation FSCommonGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonGroupHandleDatas];
}

- (void)commonGroupHandleDatas{
    _fs_dispatch_global_main_queue_async(^{
        NSMutableArray *list = [FSDBGroupAPI groups:self->_table link:self->_link page:self->_page];
        if (self->_page) {
            [self->_list addObjectsFromArray:list];
            if (!list.count) {
                self->_page = MAX(0, --self->_page);
            }
        }else{
            self->_list = list;
        }
    }, ^{
        [self commonGroupDesignViews];
    });
}

- (void)bbiAction{  //只能增加目录
    __weak typeof(self)this = self;
    [self addZoneActionIn:_link completion:^{
        [this commonGroupHandleDatas];
    }];
}

- (void)addGroupOrData:(NSString *)name sid:(NSString *)sid{
    NSString *group = @"增加组";
    NSString *data = @"增加数据";
    NSNumber *type = @(UIAlertActionStyleDefault);
    NSString *title = @"这组还没有数据，选择增加类型";
    __weak typeof(self)this = self;
    [FSUIKit alert:UIAlertControllerStyleActionSheet controller:self title:nil message:title actionTitles:@[group,data] styles:@[type,type] handler:^(UIAlertAction *action) {
        if ([action.title isEqualToString:group]) {
            [self addZoneActionIn:sid completion:^{
                FSCommonGroupController *group = [[FSCommonGroupController alloc] init];
                group.table = this.table;
                group.link = sid;
                group.seeData = this.seeData;
                group.addData = this.addData;
                [this.navigationController pushViewController:group animated:YES];
            }];
        }else if ([action.title isEqualToString:data]){
            if (self.addData) {
                self.addData(sid,name);
            }
        }
    }];
}

- (void)addZoneActionIn:(NSString *)link completion:(void (^)(void))completion{
    __weak typeof(self)this = self;
    [FSUIKit alertInput:1 controller:self title:NSLocalizedString(@"Add group", nil) message:nil ok:NSLocalizedString(@"Add", nil) handler:^(UIAlertController *bAlert, UIAlertAction *action) {
        NSString *zone = bAlert.textFields.firstObject.text;
        if ([FSKit cleanString:zone].length == 0) {
            [FSToast show:NSLocalizedString(@"Please input group name", nil)];
            return;
        }
        NSString *error = [FSDBGroupAPI addGroup:zone type:this.table link:link];
        if (error) {
            [FSUIKit showAlertWithMessage:error controller:this];
            return;
        }
        if (completion) {
            completion();
        }
    } cancel:NSLocalizedString(@"Cancel", nil) handler:nil textFieldConifg:^(UITextField *textField) {
        textField.placeholder = NSLocalizedString(@"Please input group name", nil);
    } completion:nil];
}

- (void)commonGroupDesignViews{
    if (!_tableView) {
        self.title = [FSDBGroupAPI titleForTable:_table];

        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(bbiAction)];
        self.navigationItem.rightBarButtonItem = bbi;
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 60;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_tableView];
        __weak typeof(self)this = self;
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            this.page = 0;
            [this commonGroupHandleDatas];
        }];
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
            this.page ++;
            [this commonGroupHandleDatas];
        }];
    }else{
        [_tableView.mj_header endRefreshing];
        [_tableView.mj_footer endRefreshing];
        [_tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:8];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    FSDBGroupModel *model = [_list objectAtIndex:indexPath.row];
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = model.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FSDBGroupModel *model = [_list objectAtIndex:indexPath.row];
    BOOL hasData = [FSDBGroupAPI hasData:_table group:model.time];
    if (hasData) {
        if (self.seeData) {
            self.seeData(model.time,model.name);
            [FSDBGroupAPI updateFreq:model];
        }
    }else{
        NSMutableArray *list = [FSDBGroupAPI groups:_table link:model.time page:0];
        if (list.count) {
            [FSDBGroupAPI updateFreq:model];
            
            FSCommonGroupController *group = [[FSCommonGroupController alloc] init];
            group.table = _table;
            group.link = model.time;
            group.seeData = self.seeData;
            group.addData = self.addData;
            [self.navigationController pushViewController:group animated:YES];
        }else{
            [self addGroupOrData:model.name sid:model.time];
        }
    }
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    FSDBGroupModel *model = [_list objectAtIndex:indexPath.row];
    BOOL canDelete = [FSDBGroupAPI canDeleteWithTable:_table zone:model.time];
    NSArray *array = [FSDBGroupAPI zonesForChange:_table model:model];
    BOOL canMove = _fs_isValidateArray(array);
    
    NSMutableArray *edits = [[NSMutableArray alloc] init];
    if (canMove) {
        UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Move", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            tableView.editing = NO;
            [self showHalfView:model];
        }];
        action0.backgroundColor = THISCOLOR;
        [edits addObject:action0];
    }
    if (canDelete) {
        UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"Delete", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
            FSDBGroupModel *model = [self->_list objectAtIndex:indexPath.row];
            [FSDBGroupAPI deleteModelBusiness:model table:_tb_group controller:self success:^{
                [self.list removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            } fail:^(NSString *error) {
                [FSUIKit showAlertWithMessage:error controller:self];
            } cancel:^{
                tableView.editing = NO;
            }];
        }];
        [edits insertObject:action1 atIndex:0];
    }
    
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"Rename", nil) handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        FSDBGroupModel *model = [self->_list objectAtIndex:indexPath.row];
        [self rename:model];
        tableView.editing = NO;
    }];
    action.backgroundColor = FS_GreenColor;
    [edits addObject:action];
    return [edits copy];
}

- (void)rename:(FSDBGroupModel *)model{
    __weak typeof(self)this = self;
    [FSUIKit alertInput:1 controller:self title:nil message:@"更改组名" ok:@"更改" handler:^(UIAlertController *bAlert, UIAlertAction *action) {
        NSString *text = bAlert.textFields.firstObject.text;
        if (!_fs_isValidateString(text)) {
            [FSToast toast:@"请输入新组名"];
            return;
        }
        NSString *error = [FSDBGroupAPI renameModel:model newName:text forTable:this.table];
        if (error) {
            [FSUIKit showAlertWithMessage:error controller:this];
        }else{
            [FSToast toast:@"更改组名成功"];
            [this commonGroupHandleDatas];
        }
    } cancel:@"取消" handler:nil textFieldConifg:^(UITextField *textField) {
        textField.placeholder = model.name;
    } completion:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (BOOL)navigationShouldPopOnBackButton{
    if (_link) {
        return YES;
    }
    BOOL success = [FSKit popToController:@"HAToolController" navigationController:self.navigationController animated:YES];
    if (!success) {
        return YES;
    }
    return NO;
}

- (void)showHalfView:(FSDBGroupModel *)model{
    self.zones = [FSDBGroupAPI zonesForChange:_table model:model];
    self.model = model;
    if (!self.halfView) {
        WEAKSELF(this);
        self.halfView = [[FSHalfView alloc] initWithFrame:CGRectMake(0, 64, WIDTHFC, HEIGHTFC - 64)];
        self.halfView.dataSource = self.zones;
        [self.view addSubview:self.halfView];
        [_halfView setConfigCell:^(UITableView *bTB, NSIndexPath *bIP,UITableViewCell *bCell) {
            NSDictionary *dic = this.zones[bIP.row];
            NSString *name = dic[@"name"];
            bCell.textLabel.text = name;
            NSString *zone = dic[@"time"];
            if ([this.model.time isEqualToString:zone]) {
                bCell.detailTextLabel.text = @"已是此组";
            }else{
                bCell.detailTextLabel.text = @"";
            }
        }];
        [_halfView setSelectCell:^(UITableView *bTB, NSIndexPath *bIP) {
            NSDictionary *dic = this.zones[bIP.row];
            NSString *zone = dic[@"time"];
            if ([this.model.time isEqualToString:zone]) {
                [this.navigationController popViewControllerAnimated:YES];
                return;
            }
            NSString *z = dic[@"name"];
            NSString *message = [[NSString alloc] initWithFormat:@"确定将'%@'组换到'%@'组下?",this.model.name,z];
            [FSUIKit alert:UIAlertControllerStyleActionSheet controller:this title:nil message:message actionTitles:@[NSLocalizedString(@"Confirm", nil)] styles:@[@(UIAlertActionStyleDefault)] handler:^(UIAlertAction *action) {
                NSString *error = [FSDBGroupAPI changeModel:this.model toZone:zone table:this.table];
                if (!error) {
                    [this commonGroupHandleDatas];
                    [FSToast toast:@"换组成功"];
                }else{
                    [FSUIKit showAlertWithMessage:error controller:this];
                }
            }];
        }];
    }else{
        self.halfView.dataSource = self.zones;
        [self.halfView showHalfView:YES];
    }
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
