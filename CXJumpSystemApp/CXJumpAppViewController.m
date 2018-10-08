//
//  CXJumpAppViewController.m
//  CXJumpSystemApp
//
//  Created by 陈晓辉 on 2018/9/28.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXJumpAppViewController.h"

/** 发短信 / 邮件 */
#import <MessageUI/MessageUI.h>

@interface CXJumpAppViewController ()<UITableViewDelegate,UITableViewDataSource,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>

/** 数据 */
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation CXJumpAppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"App 之间跳转";
    self.view.backgroundColor = [UIColor whiteColor];
    _dataArray = [self getData];
    [self loadTableView];
}
#pragma mark ---------- 数据源 ----------
- (NSArray *)getData {
    
    return  @[
              @{@"title":@"打电话",
                @"data":@[@"方式一:requestWithURL，此方法拨打前弹出提示",@"方式二:openURL(telprompt)此方法拨打前弹出提示,据说会导致App Store审核不通过",@"方式三:利用openURL(tel),此方法在iOS 10.2之前不会添加弹框，需要自己处理，手动添加alert即可"]},
              @{@"title":@"发短信",
                @"data":@[@"方式一:程序外调用系统发短信",@"方式二:程序内调用系统发短信。"]},
              @{@"title":@"发邮件",
                @"data":@[@"方式一:openURL，程序会进入后台，跳转至邮件发送界面",@"方式二:使用模态跳转出邮件发送界面"]},
              @{@"title":@"打开浏览器",
                @"data":@[@"百度"]},
              @{@"title":@"跳转 App Store",
                @"data":@[@"方式一:跳转到AppStore",@"方式二:跳转到应用评分页"]},
              @{@"title":@"打开设置",
                @"data":@[@"方式一:跳转到 设置",@"方式二:跳转到设置具体项, 例,蓝牙, WiFi 等(iOS10之前使用)"]}
              ];
}
- (void)loadTableView {
    //
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.rowHeight = 60.0f;
    tableView.tableFooterView = [self createFootView];
    [self.view addSubview:tableView];
}
- (UILabel *)createFootView {
    UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 150)];
    footLabel.numberOfLines = 0;
    footLabel.textAlignment = NSTextAlignmentCenter;
    footLabel.text = [NSString stringWithFormat:@"详情:https://www.jianshu.com/p/6b746f95b568"];
    return footLabel;
}
#pragma mark ---------- UITableViewDelegate,UITableViewDataSource ----------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSDictionary *dic = self.dataArray[section];
    NSArray *arr = dic[@"data"];
    return arr.count;
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    
    //设置区头文字属性
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.textAlignment = NSTextAlignmentCenter;
    headerView.textLabel.textColor = [UIColor orangeColor];
    headerView.textLabel.font = [UIFont systemFontOfSize:16];
    headerView.backgroundColor = [UIColor lightGrayColor];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    NSDictionary *dic = self.dataArray[section];
    return [NSString stringWithFormat:@"- %@ -",dic[@"title"]];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.backgroundColor = indexPath.row %2 == 0 ? [UIColor whiteColor]:[UIColor colorWithRed:(248)/255.0 green:(248)/255.0 blue:(248)/255.0 alpha:1];
    
    //每区数据
    NSDictionary *sectionDic = self.dataArray[indexPath.section];
    NSArray *sectionArr = sectionDic[@"data"];
    //每行数据
    NSString *rowStr = sectionArr[indexPath.row];
    
    //赋值
    NSMutableAttributedString *titleStr = [self markString:[NSString stringWithFormat:@"%ld.",indexPath.row+1]
                                                     color:[UIColor orangeColor]
                                                     fount:[UIFont fontWithName:@"Marker Felt" size:14]];
    //设置中文倾斜
    CGAffineTransform aTransform = CGAffineTransformMake(1, 0, tanf(5 *M_PI /180), 1, 0, 0);//设置反射, 倾斜角度
    UIFontDescriptor *desc = [UIFontDescriptor fontDescriptorWithName:[UIFont systemFontOfSize:14].fontName matrix:aTransform];//取得系统字符并设置反射
    UIFont *font = [UIFont fontWithDescriptor:desc size:14];
    [titleStr appendAttributedString:[self markString:[NSString stringWithFormat:@"  %@",rowStr]
                                                color:[UIColor grayColor]
                                                fount:font]];
    cell.textLabel.attributedText = titleStr;
    cell.textLabel.numberOfLines = 0;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) { //打电话
        
        if (indexPath.row == 0) {
            [self callPhoneOne];
        }else if (indexPath.row == 1) {
            [self callPhoneTwo];
        }else if (indexPath.row == 2) {
            [self callPhoneThree];
        }
    }else if (indexPath.section == 1) { //发短信
        
        if (indexPath.row == 0) {
            [self sendShortMsgOne];
        }else if (indexPath.row == 1) {
            [self sendShortMsgTwo];
        }
    }else if (indexPath.section == 2) { //发邮件
        
        if (indexPath.row == 0) {
            [self sendEmailOne];
        }else if (indexPath.row == 1) {
            [self sendEmailTwo];
        }
    }else if (indexPath.section == 3) { //打开浏览器
        
        [self openBrowser];
    }else if (indexPath.section == 4) { //跳转 App Store
        
        if (indexPath.row == 0) {
            //跳转 App Store
            [self jumpAppStore];
        }else if (indexPath.row == 1) {
            //跳转到应用评分页
            [self jumpAppStoreComments];
        }
    }else if (indexPath.section == 5) { //跳转设置
        
        if (indexPath.row == 0) {
            
            //跳转设置
            [self jumpSettingOne];
        }else if (indexPath.row == 1) {
            
            //定位服务设置界面
            [self jumpSettingTwo];
        }
    }
}



#pragma mark ---------- 打电话 ----------
- (void)callPhoneOne {
    //MARK: 方法一、requestWithURL，此方法拨打前弹出提示
    NSString *string = [NSString stringWithFormat:@"tel:%@",@"100****0000"];
    UIWebView *callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:string]]];
    [self.view addSubview:callWebview];
}
- (void)callPhoneTwo {
    //MARK: 方法二、openURL(telprompt) ，此方法拨打前弹出提示,据说会导致App Store审核不通过
    NSString *string = [NSString stringWithFormat:@"telprompt:%@",@"100****0000"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string] options:@{} completionHandler:nil];
}
- (void)callPhoneThree {
    //MARK: 方法三、利用openURL(tel),此方法在iOS 10.2之前不会添加弹框，需要自己处理，手动添加alert即可
    NSString *string = [NSString stringWithFormat:@"tel:%@",@"100****0000"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string] options:@{} completionHandler:nil];
}
#pragma mark ---------- 发短信 ----------
- (void)sendShortMsgOne {
    //MARK: 方法一，程序外调用系统发短信
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"sms://100****0000"] options:@{} completionHandler:nil];
}
- (void)sendShortMsgTwo {
    //MARK: 方法二，程序内调用系统发短信。第二种的好处是用户发短信之后还可以回到app。这对app来说非常重要
    
    //2.1 导入MessageUI.framework，并引入头文件
    //2.2 实现代理方法MFMessageComposeViewControllerDelegate
    //2.3 发送短信
    //2.4 调用发短信的方法
    [self showMessageView:[NSArray arrayWithObjects:@"13888888888",@"13999999999", nil] title:@"test" body:@"悠远的天空"];
}
//MARK: 方法二，程序内调用系统发短信
//弹出短信, 并编辑短信内容
- (void)showMessageView:(NSArray *)phones title:(NSString *)title body:(NSString *)body {
    
    if([MFMessageComposeViewController canSendText]) {
        
        //参数phones：发短信的手机号码的数组，数组中是一个即单发,多个即群发
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc] init];
        controller.recipients = phones;// 设置收件人列表,号码数组
        controller.navigationBar.tintColor = [UIColor redColor];
        controller.body = body;// 设置短信内容
        controller.messageComposeDelegate = self;// 设置代理
        [self presentViewController:controller animated:YES completion:nil];
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:title];//修改短信界面标题
    } else {
        
        [self showAlertWithTitle:@"提示信息" message:@"该设备不支持短信功能"];
    }
}
//MARK: MFMessageComposeViewControllerDelegate - 发送结果回调
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    // 关闭短信界面
    [self dismissViewControllerAnimated:YES completion:nil];
    
    switch (result) {
        case MessageComposeResultSent:
            //信息传送成功
            NSLog(@"信息传送成功");
            break;
        case MessageComposeResultFailed:
            //信息传送失败
            NSLog(@"信息传送失败");
            break;
        case MessageComposeResultCancelled:
            //信息被用户取消传送
            NSLog(@"信息被用户取消传送");
            break;
        default:
            break;
    }
}
#pragma mark ---------- 发邮件 ----------
//MARK: 方法一，openURL（原生）——用户体检差，程序会进入后台，跳转至邮件发送界面。具体实现如下
- (void)sendEmailOne {
    
    //创建可变的地址字符串对象
    NSMutableString *mailUrl = [[NSMutableString alloc] init];
    //添加收件人,如有多个收件人，可以使用componentsJoinedByString方法连接，连接符为","
    NSString *recipients = @"111111@qq.com";
    [mailUrl appendFormat:@"mailto:%@?", recipients];
    //添加抄送人
    NSString *ccRecipients = @"222222@qq.com";
    [mailUrl appendFormat:@"&cc=%@", ccRecipients];
    //添加密送人
    NSString *bccRecipients = @"333333@qq.com";
    [mailUrl appendFormat:@"&bcc=%@", bccRecipients];
    //添加邮件主题
    [mailUrl appendFormat:@"&subject=%@",@"设置邮件主题"];
    //添加邮件内容
    [mailUrl appendString:@"&body=<b>Hello</b> World!"];
    //跳转到系统邮件App发送邮件
    NSString *emailPath = [mailUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:emailPath] options:@{} completionHandler:nil];
}
- (void)sendEmailTwo {
    
    //MARK: 方法二，MFMailComposeViewController（原生）——使用模态跳转出邮件发送界面
    //1） 项目需要导入MessageUI.framework框架
    //2） 在对应类里导入头文件：#import <MessageUI/MessageUI.h>
    //3） 对应的类遵从代理：MFMailComposeViewControllerDelegate
    //判断用户是否已设置邮件账户
    if ([MFMailComposeViewController canSendMail]) {
        
        // 创建邮件发送界面
        MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
        // 设置邮件代理
        [mailCompose setMailComposeDelegate:self];
        // 设置收件人
        [mailCompose setToRecipients:@[@"111111@qq.com"]];
        // 设置抄送人
        [mailCompose setCcRecipients:@[@"222222@qq.com"]];
        // 设置密送人
        [mailCompose setBccRecipients:@[@"333333@qq.com"]];
        // 设置邮件主题
        [mailCompose setSubject:@"设置邮件主题"];
        //设置邮件的正文内容
        NSString *emailContent = @"我是邮件内容";
        
        // 是否为HTML格式
        [mailCompose setMessageBody:emailContent isHTML:NO];
        // 如使用HTML格式，则为以下代码
        // [mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
        //添加附件
        UIImage *image = [UIImage imageNamed:@"tu.jpg"];
        NSData *imageData = UIImagePNGRepresentation(image);
        [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"tu.jpg"];
        NSString *file = [[NSBundle mainBundle] pathForResource:@"no" ofType:@"pdf"];
        NSData *pdf = [NSData dataWithContentsOfFile:file];
        [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"no.pdf"];
        // 弹出邮件发送视图
        [self presentViewController:mailCompose animated:YES completion:nil];
    }else{
        //给出提示,设备未开启邮件服务
        [self showAlertWithTitle:@"提示信息" message:@"设备未开启邮件服务"];
    }
}

//MARK: MFMailComposeViewControllerDelegate - 发送邮件回调
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled: 用户取消编辑");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: 用户保存邮件");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent: 用户点击发送");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@ : 用户尝试保存或发送邮件失败", [error localizedDescription]);
            break;
    }
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark ---------- 打开浏览器 ----------
- (void)openBrowser {
    
    NSURL *url = [NSURL URLWithString:@"https://m.baidu.com"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}
#pragma mark ---------- 跳转 App Store ----------
//MARK: 方式一: 跳转到AppStore
- (void)jumpAppStore {
    
    //以 itms-apps://或https:// 开头的应用详情页链接，跳转到AppStore
    //MARK: 方式一: 以itms:// 开头的应用详情页连接，跳转到 iTunes Store，打开的仍然是应用的下载页
    NSString *appId = @"1014939463";
    NSString *url = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",appId];
    //或者
    //惊奇的发现https://开头的连接也可以跳转到appstore
    //NSString *url2 = [NSString stringWithFormat:@"https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",appId];
    //
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
}
//MARK: 方式二: 跳转到应用评分页
- (void)jumpAppStoreComments {
    
    //itms-apps://和itms://开头的链接都可以，而此时https:// 开头的链接不可以
    NSString *appId = @"1014939463";
    NSString *url3 = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",appId];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url3] options:@{} completionHandler:nil];
}
#pragma mark ---------- 跳转设置 ----------
//https://www.cnblogs.com/xujiahui/p/6911481.html
- (void)jumpSettingOne {
    
    //MARK: 方式一: 跳转设置总页面（iOS10+以及之前的都可以用：ios10+ 是跳转到了应用到设置界面）
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        
         [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
}
- (void)jumpSettingTwo {
    
    //MARK: 方式二: iOS10 之前
    //参数配置: prefs
    //在项目中的info中添加 URL types
    //URL计划就是实现跳转URL协议的名称（可以多个）。 而APP的跳转就需要设置“URL Schemes”来实现：
    
    //例:定位服务设置界面
    NSURL *url = [NSURL URLWithString:@"App-Prefs:root=General&path=About"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }
    /*
     看到这几个例子，大家有没有发现，想跳到哪个设置界面只需要prefs:root=后面的值即可！是的，就是这样的。
     
     prefs:root=General&path=About
     prefs:root=General&path=ACCESSIBILITY
     prefs:root=AIRPLANE_MODE
     prefs:root=General&path=AUTOLOCK
     prefs:root=General&path=USAGE/CELLULAR_USAGE
     prefs:root=Brightness    //打开Brightness(亮度)设置界面
     prefs:root=Bluetooth    //打开蓝牙设置
     prefs:root=General&path=DATE_AND_TIME    //日期与时间设置
     prefs:root=FACETIME    //打开FaceTime设置
     prefs:root=General    //打开通用设置
     prefs:root=General&path=Keyboard    //打开键盘设置
     prefs:root=CASTLE    //打开iClound设置
     prefs:root=CASTLE&path=STORAGE_AND_BACKUP    //打开iCloud下的储存空间
     prefs:root=General&path=INTERNATIONAL    //打开通用下的语言和地区设置
     prefs:root=LOCATION_SERVICES    //打开隐私下的定位服务
     prefs:root=ACCOUNT_SETTINGS
     prefs:root=MUSIC    //打开设置下的音乐
     prefs:root=MUSIC&path=EQ    //打开音乐下的均衡器
     prefs:root=MUSIC&path=VolumeLimit  //打开音乐下的音量
     prefs:root=General&path=Network    //打开通用下的网络
     prefs:root=NIKE_PLUS_IPOD
     prefs:root=NOTES    //打开设置下的备忘录设置
     prefs:root=NOTIFICATIONS_ID    //打开设置下的通知设置
     prefs:root=Phone    //打开电话设置
     prefs:root=Photos    //打开设置下照片和相机设置
     prefs:root=General&path=ManagedConfigurationList    //打开通用下的描述文件
     prefs:root=General&path=Reset    //打开通用下的还原设置
     prefs:root=Sounds&path=Ringtone
     prefs:root=Safari    //打开设置下的safari设置
     prefs:root=General&path=Assistant    //打开siri不成功
     prefs:root=Sounds    //打开设置下的声音设置
     prefs:root=General&path=SOFTWARE_UPDATE_LINK    //打开通用下的软件更新
     prefs:root=STORE    //打开通用下的iTounes Store和App Store设置
     prefs:root=TWITTER    //打开设置下的twitter设置
     prefs:root=FACEBOOK    //打开设置下的Facebook设置
     prefs:root=General&path=USAGE    //打开通用下的用量
     prefs:root=VIDEO
     prefs:root=General&path=Network/VPN        //打开通用下的vpn设置
     prefs:root=Wallpaper    //打开设置下的墙纸设置
     prefs:root=WIFI    //打开wifi设置
     prefs:root=INTERNET_TETHERING
     
     蜂窝数据 — prefs:root=MOBILE_DATA_SETTINGS_ID
     */
}

#pragma mark ---------- 其他 ----------
//MARK: 富文本
- (NSMutableAttributedString *)markString:(NSString *)string color:(UIColor *)color fount:(UIFont *)font {
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [attributedString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, string.length)];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    
    return attributedString;
}
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil, nil];
    [alert show];
}
@end
