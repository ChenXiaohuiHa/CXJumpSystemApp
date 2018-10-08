//
//  CXAddCalendarEvent.m
//  CXJumpSystemApp
//
//  Created by 陈晓辉 on 2018/10/5.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import "CXAddCalendarEvent.h"
#import <UIKit/UIKit.h>

/** 1. 导入依赖库 */
#import <EventKit/EventKit.h>

@implementation CXAddCalendarEvent

static CXAddCalendarEvent *_instance = nil;
+ (instancetype)sharedEventCalendar {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CXAddCalendarEvent alloc] init];
    });
    return _instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

/**
 *  将App事件添加到系统日历提醒事项，实现闹铃提醒的功能
 *
 *  @param title      事件标题
 *  @param location   事件位置
 *  @param startDate  开始时间
 *  @param endDate    结束时间
 *  @param allDay     是否全天
 *  @param alarmArray 闹钟集合
 */
- (void)createEventCalendarTitle:(NSString *)title location:(NSString *)location startDate:(NSDate *)startDate endDate:(NSDate *)endDate allDay:(BOOL)allDay notes:(nonnull NSString *)notes alarmArray:(nonnull NSArray *)alarmArray success:(nonnull void (^)(NSString * _Nonnull))success failure:(nonnull void (^)(NSString * _Nonnull))failure {
    
    //创建事件容器
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (error) { //出现错误
                    
                    if (failure) {
                        failure(@"添加失败，请稍后重试");
                    }
                }else if (!granted) { //用户拒绝, 访问日历
                    
                    if (failure) {
                        failure(@"不允许使用日历,请在设置中允许此App使用日历");
                    }
                }else{ //用户允许访问日历, 添加事件
                    
                    //创建事件
                    EKEvent *event = [EKEvent eventWithEventStore:eventStore];
                    //给事件添加标题
                    event.title = title;
                    //设置地点
                    event.location = location;
                    
                    //设置时间格式
                    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setAMSymbol:@"AM"];
                    [dateFormatter setPMSymbol:@"PM"];
                    [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mmaaa"];
                    
                    
                    //开始时间(必须)
                    event.startDate = startDate;
                    //结束时间(必须)
                    event.endDate = endDate;
                    //全天事件
                    event.allDay = allDay;
                    
                    //事件内容备注
                    event.notes = notes;
                    
                    //添加闹钟提醒
                    if (alarmArray && alarmArray.count > 0) {
                        //alarmArray, 提醒时间数组, 通过遍历来添加
                        for (NSDate *remDate in alarmArray) {
                            
                            //遍历数组,循环添加多个提醒时间点
                            [event addAlarm:[EKAlarm alarmWithAbsoluteDate:remDate]];
                        }
                    }
                    
                    //添加事件到日历中
                    [event setCalendar:[eventStore defaultCalendarForNewEvents]];
                    
                    NSError *err;
                    [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    
                    //返回成功
                    if (success) {
                        success(@"已添加到系统日历中");
                    }
                }
            });
        }];
    }
}


- (void)createReminderTitle:(NSString *)title startDate:(NSDate *)startDate endDate:(NSDate *)endDate priority:(NSInteger)priority alarmArray:(nonnull NSArray *)alarmArray success:(void(^)(NSString *msg))success failure:(void(^)(NSString *errorMsg))failure {
    
    EKEventStore *eventDB = [[EKEventStore alloc] init];
    //申请提醒权限
    
    [eventDB requestAccessToEntityType:EKEntityTypeReminder completion:^(BOOL granted, NSError * _Nullable error) {
        
        if (error) { //出现错误
            
            if (failure) {
                failure(@"添加失败，请稍后重试");
            }
        }else if (!granted) { //用户拒绝, 访问日历
            
            if (failure) {
                failure(@"不允许使用日历,请在设置中允许此App使用提醒");
            }
        }else{ //用户允许访问提醒, 添加事件
            
            //创建一个提醒功能
            EKReminder *reminder = [EKReminder reminderWithEventStore:eventDB];
            //标题
            reminder.title = title;
            //添加日历
            [reminder setCalendar:[eventDB defaultCalendarForNewReminders]];
            
            NSCalendar *cal = [NSCalendar currentCalendar];
            [cal setTimeZone:[NSTimeZone systemTimeZone]];
            NSInteger flags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
            NSDateComponents *startDateComp = [cal components:flags fromDate:startDate];
            startDateComp.timeZone = [NSTimeZone systemTimeZone];
            //
            NSDateComponents *endDateComp = [cal components:flags fromDate:endDate];
            endDateComp.timeZone = [NSTimeZone systemTimeZone];
            
            //开始时间
            reminder.startDateComponents = startDateComp;
            //到期时间
            reminder.dueDateComponents = endDateComp;
            //优先级
            reminder.priority = priority?priority:1;
            
            //添加闹钟提醒
            if (alarmArray && alarmArray.count > 0) {
                //alarmArray, 提醒时间数组, 通过遍历来添加
                for (NSDate *remDate in alarmArray) {
                    
                    //遍历数组,循环添加多个提醒时间点
                    [reminder addAlarm:[EKAlarm alarmWithAbsoluteDate:remDate]];
                }
            }
            
            NSError *err;
            [eventDB saveReminder:reminder commit:YES error:&err];
            
            if (err) {
                
                if (failure) {
                    failure(err.localizedDescription);
                }
            }else{
                
                //返回成功
                if (success) {
                    success(@"已添加到系统提醒中");
                }
            }
        }
        
    }];
}


@end
