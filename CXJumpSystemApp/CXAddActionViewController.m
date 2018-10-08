//
//  CXAddActionViewController.m
//  CXJumpSystemApp
//
//  Created by 陈晓辉 on 2018/9/28.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXAddActionViewController.h"
#import "CXAddCalendarEvent.h"
@interface CXAddActionViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 数据 */
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CXAddActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"向 Apple App 添加事件";
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [self getData];
    [self loadTableView];
}
#pragma mark ---------- 数据源 ----------
- (NSArray *)getData {
    
    return  @[@"添加日历事件",@"添加提醒事件"];
}
- (void)loadTableView {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60.0f;
    tableView.tableFooterView = [UIView new];
    [self.view addSubview:tableView];
}
#pragma mark ---------- UITableViewDelegate,UITableViewDataSource ----------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cell_idntify = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_idntify];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cell_idntify];
    }
    
    cell.backgroundColor = indexPath.row %2 == 0 ? [UIColor whiteColor]:[UIColor colorWithRed:(248)/255.0 green:(248)/255.0 blue:(248)/255.0 alpha:1];
    
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDate *startDate = [NSDate dateWithTimeInterval:60 sinceDate:[NSDate date]];//开始时间及第一个闹铃时间
    NSDate *endDate = [NSDate dateWithTimeInterval:1800 sinceDate:[NSDate date]];
    NSDate *remDate = [NSDate dateWithTimeInterval:120 sinceDate:[NSDate date]];//第二个闹铃时间
    if (indexPath.row == 0) { //添加日历事件
        
        [[CXAddCalendarEvent sharedEventCalendar] createEventCalendarTitle:@"生日提醒"
                                                                  location:@"召唤师峡谷"
                                                                 startDate:startDate
                                                                   endDate:endDate
                                                                    allDay:NO
                                                                     notes:@"又老了一岁"
                                                                alarmArray:@[startDate,remDate]
                                                                   success:^(NSString * _Nonnull msg) {
                                                                       
                                                                       [self showAlert:msg success:^{
                                                                           //进入日历
                                                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"calshow:"] options:@{} completionHandler:nil];
                                                                       }];
                                                                   } failure:^(NSString * _Nonnull errorMsg) {
                                                                       [self showAlert:errorMsg success:nil];
                                                                   }];
    }else if (indexPath.row == 1) { //添加提醒事件
        
        [[CXAddCalendarEvent sharedEventCalendar] createReminderTitle:@"好消息!好消息!"
                                                            startDate:startDate
                                                              endDate:endDate
                                                              priority:1
                                                           alarmArray:@[startDate]
                                                              success:^(NSString * _Nonnull msg) {
                                                                  
                                                                  [self showAlert:msg success:nil];
                                                              } failure:^(NSString * _Nonnull errorMsg) {
                                                                  [self showAlert:errorMsg success:nil];
                                                              }];
    }
}

- (void)showAlert:(NSString *)message success:(void(^)(void))success  {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提醒" message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的" style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
        
        if (success) {
            success();
        }
    }];
    [alertVC addAction:action];
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
