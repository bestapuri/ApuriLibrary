#import <Foundation/Foundation.h>

@interface SubscriptionData : NSObject

@property (strong, nonatomic) NSString *productIdentifier;

@property (strong, nonatomic) NSString *tenorDisplay;

@property (strong, nonatomic) NSString *amountDisplay;

@property (strong, nonatomic) NSString *btnText;

@property (assign, nonatomic) NSInteger tenorMonth;

@end
