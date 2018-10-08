//
//  CXAddCalendarEvent.h
//  CXJumpSystemApp
//
//  Created by 陈晓辉 on 2018/10/5.
//  Copyright © 2018年 陈晓辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CXAddCalendarEvent : NSObject

+ (instancetype)sharedEventCalendar;

/**
 将App事件添加到系统日历提醒事项，实现闹铃提醒的功能
 
 @param title      事件标题
 @param location   事件位置
 @param startDate  开始时间
 @param endDate    结束时间
 @param allDay     是否全天
 @param notes      事件备注
 @param alarmArray 闹钟集合
 */
- (void)createEventCalendarTitle:(NSString *)title location:(NSString *)location startDate:(NSDate *)startDate endDate:(NSDate *)endDate allDay:(BOOL)allDay notes:(NSString *)notes alarmArray:(NSArray *)alarmArray success:(void(^)(NSString *msg))success failure:(void(^)(NSString *errorMsg))failure;


/**
 将App事件添加到系统日历提醒事项，实现闹铃提醒的功能

 @param title 事件标题
 @param startDate 开始时间
 @param endDate 结束时间
 @param priority 优先级 (1-9,1最高,9最低)
 @param alarmArray 闹钟集合
 */
- (void)createReminderTitle:(NSString *)title startDate:(NSDate *)startDate endDate:(NSDate *)endDate priority:(NSInteger)priority alarmArray:(nonnull NSArray *)alarmArray success:(void(^)(NSString *msg))success failure:(void(^)(NSString *errorMsg))failure;

@end

NS_ASSUME_NONNULL_END
