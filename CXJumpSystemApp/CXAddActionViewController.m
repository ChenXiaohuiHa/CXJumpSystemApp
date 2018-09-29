//
//  CXAddActionViewController.m
//  CXJumpSystemApp
//
//  Created by 陈晓辉 on 2018/9/28.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXAddActionViewController.h"

@interface CXAddActionViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 数据 */
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CXAddActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"给 App 添加事件";
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [self getData];
    [self loadTableView];
}
#pragma mark ---------- 数据源 ----------
- (NSArray *)getData {
    
    return  @[
              @{@"title":@"自适应高度",@"vcName":@"CXCellHeightViewController"},
              @{@"title":@"下拉菜单",@"vcName":@"CXMenuCellViewController"}
              ];
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
    
    cell.textLabel.text = _dataArray[indexPath.row][@"title"];
    cell.detailTextLabel.text = _dataArray[indexPath.row][@"vcName"];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.dataArray[indexPath.row];
    NSString *VCName = [dic objectForKey:@"vcName"];
    Class class = NSClassFromString(VCName);
    UITabBarController *viewController = [[class alloc]init];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
