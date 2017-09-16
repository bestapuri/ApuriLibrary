#import "AlertTool.h"

@implementation AlertTool

+ (void) showTip: (UIViewController *) controller title:(NSString *)title cancelText:(NSString *)cancelText aftrt:(After)after
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(after){
            after();
        }
    }];
    [alertController addAction:cancelAction];
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void) showTip: (UIViewController *) controller title:(NSString *)title message:(NSString *)message cancelText:(NSString *)cancelText aftrt:(After)after
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(after){
            after();
        }
    }];
    [alertController addAction:cancelAction];
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void) showTip: (UIViewController *) controller title:(NSString *)title okText:(NSString *)okText cancelText:(NSString *)cancelText aftrt:(After)after afterCancel:(AfterCancel) afterCancel
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:okText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(after){
            after();
        }
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(afterCancel){
            afterCancel();
        }
    }];
    
    [alertController addAction:cancelAction];
    
    [alertController addAction:okAction];
    
    [controller presentViewController:alertController animated:YES completion:nil];
}

+ (void) showGoitTip: (UIViewController *) controller title:(NSString *)title message:(NSString *)message aftrt:(After)after
{
    [self showTip:controller title:title message:message cancelText:@"Got it" aftrt:after];
}

+ (void) showGoitTip: (UIViewController *) controller title:(NSString *)title aftrt:(After)after
{
    [self showTip:controller title:title cancelText:@"Got it" aftrt:after];
}

@end
