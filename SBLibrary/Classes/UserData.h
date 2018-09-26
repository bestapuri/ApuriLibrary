//
//  UserData.h
//  VpnNew
//
//  Created by caoyusheng on 6/4/17.
//  Copyright © 2017年 caoyusheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserData : NSObject

+ (instancetype) sharedInstance;

- (void) setDue:(NSDate *) date;

- (NSDate *) getDueDate;

- (NSString *) getDueDateDisplay;

- (BOOL) hasTimeRest;

- (void)setLifeTime:(BOOL)full;

- (NSString *) getTimeRest;

- (NSString *) getTimeDisplay: (NSInteger) restMinute;

- (BOOL) isVip;

- (void) tried;

- (BOOL) isTried;

@end

#define Due_Date @"dueDate"
#define PaymentList @"PaymentList"

#define Connect_P @"Connect_P"

#define Connect_T @"Connect_T"

