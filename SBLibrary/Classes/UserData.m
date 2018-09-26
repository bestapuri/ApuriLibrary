//
//  UserData.m
//  VpnNew
//
//  Created by caoyusheng on 6/4/17.
//  Copyright © 2017年 caoyusheng. All rights reserved.
//

#import "UserData.h"

@interface UserData ()

@property(strong, nonatomic) NSDate *commemtTime;

@end

@implementation UserData

static UserData *instance = nil;

- (void) setDue:(NSDate *) date
{
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:Due_Date];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSDate *) getDueDate
{
    NSDate *dueDate = [[NSUserDefaults standardUserDefaults] objectForKey:Due_Date];
//    if (!dueDate) {
//        dueDate = [NSDate date];
//    }
    return dueDate;
}

- (NSString *) getDueDateDisplay {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm";
    NSDate* date = [self getDueDate];
    if(!date) date = [NSDate date];
    return [dateFormatter stringFromDate: date];
}

- (BOOL) hasTimeRest {
    NSInteger restMinute = [self getTimeRestMinute];
    return restMinute > 0;
}

- (NSInteger) getTimeRestMinute {
    NSDate *dueDate = [self getDueDate];
    if(dueDate)
    {
        dueDate = [dueDate dateByAddingTimeInterval:6*60*60];
    }
    else
    {
        return 0;
    }
    NSDate *nowDate = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *calendarComponents = [calendar components:NSCalendarUnitMinute fromDate:nowDate toDate:dueDate options:0];
    
    return calendarComponents.minute;
}

- (NSString *) getTimeRest {
    NSInteger restMinute = [self getTimeRestMinute];
    return [self getTimeDisplay:restMinute];
}

- (NSString *) getTimeDisplay:  (NSInteger) restMinute{
    NSString *restTime = @"0";
    if (restMinute > 0) {
        NSInteger days = restMinute / (24 * 60);
        NSInteger hours = (restMinute - days * (24 * 60)) / 60;
        NSInteger minute = restMinute - days * (24 * 60) - hours * 60;
        
        if (days > 0) {
            if (hours > 0) {
                restTime = [NSString stringWithFormat:@"%ld %@ %ld %@", days, NSLocalizedString(@"Day", nil), hours, NSLocalizedString(@"Hour", nil)];
            }
            else{
                restTime = [NSString stringWithFormat:@"%ld %@", days, NSLocalizedString(@"Day", nil)];
            }
        }
        else{
            if (hours > 0) {
                if (minute > 0) {
                    restTime = [NSString stringWithFormat:@"%ld %@ %ld %@", hours, NSLocalizedString(@"Hour", nil), minute, NSLocalizedString(@"Minute", nil)];
                }
                else{
                    restTime = [NSString stringWithFormat:@"%ld %@", hours, NSLocalizedString(@"Hour", nil)];
                }
            }
            else{
                restTime = [NSString stringWithFormat:@"%ld %@", minute, NSLocalizedString(@"Minute", nil)];
            }
        }
    }
    
    return restTime;
}

- (BOOL) isVip{
    BOOL isFullLifeTime = [[NSUserDefaults standardUserDefaults] boolForKey:@"fullLifeTime"];
    if(isFullLifeTime)return YES;
    return [self hasTimeRest];
}
- (void)setLifeTime:(BOOL)full
{
    [[NSUserDefaults standardUserDefaults] setBool:full forKey:@"fullLifeTime"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void) tried{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Connect_T];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) isTried{
    return [[NSUserDefaults standardUserDefaults] boolForKey: Connect_T];
}

+ (instancetype) sharedInstance
{
    @synchronized (self)
    {
        if (!instance)
        {
            instance = [[UserData alloc] init];
        }
    }
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self)
    {
        if (!instance)
        {
            instance = [super allocWithZone:zone];
        }
    }
    return instance;
}

+ (id)copyWithZone:(struct _NSZone *)zone
{
    return instance;
}

@end
