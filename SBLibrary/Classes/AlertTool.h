#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AlertTool : NSObject

typedef void(^After)();

typedef void(^AfterCancel)();

+ (void) showTip: (UIViewController *) controller title:(NSString *)title cancelText:(NSString *)cancelText aftrt:(After)after;

+ (void) showTip: (UIViewController *) controller title:(NSString *)title okText:(NSString *)okText cancelText:(NSString *)cancelText aftrt:(After)after afterCancel:(AfterCancel) afterCancel;

+ (void) showGoitTip: (UIViewController *) controller title:(NSString *)title aftrt:(After)after;

+ (void) showGoitTip: (UIViewController *) controller title:(NSString *)title message:(NSString *)message aftrt:(After)after;

@end
