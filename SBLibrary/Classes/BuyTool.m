//
//  BuyTool.m
//  LittleWall
//
//  Created by caoyusheng on 8/5/17.
//  Copyright © 2017年 caoyusheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BuyTool.h"
#import "MBProgressHUD.h"
#import "AlertTool.h"
#import "HttpClient.h"
#import "UserData.h"
#import "SubscriptionCtrl.h"
@interface BuyTool () <SKRequestDelegate>

@property (nonatomic, strong) AfterQuery after;

@property (nonatomic, strong) AfterVerify afterVerify;

@property (assign, nonatomic) UIViewController * controller;

@property (strong, nonatomic) NSMutableArray <SubscriptionData *> *products;

@property (strong, nonatomic) NSArray<SKProduct *> *skProducts;

@property (assign, nonatomic) BOOL isLoadingProducts;

@property (weak, nonatomic) UIViewController* successViewCtrl;

@property (strong, nonatomic) SubscriptionCtrl* subCtrl;

@property (strong, nonatomic) SubscriptionCtrl* subCtrlWeb;

@end

@implementation BuyTool

static BuyTool *instance = nil;

- (void)initShop
{
    [[SKPaymentQueue defaultQueue] addTransactionObserver: self];
}
- (void)activeSB:(UIViewController*)ctrl
{
    self.successViewCtrl = ctrl;
    [self initShop];
    if ([[UserData sharedInstance] isVip])
    {
        [[[UIApplication sharedApplication].delegate window] setRootViewController:ctrl];
    }
    else
    {
        SubscriptionCtrl* sbCtrl = [[SubscriptionCtrl alloc] init];
        sbCtrl.successCtrl = ctrl;
        self.subCtrl = sbCtrl;
        [[[UIApplication sharedApplication].delegate window] setRootViewController:sbCtrl];
    }
}
- (void)showActiveSB2:(UIViewController*)ctrl
{
    self.successViewCtrl = ctrl;
    if(!self.subCtrl)
    {
        SubscriptionCtrl* sbCtrl = [[SubscriptionCtrl alloc] init];
        sbCtrl.successCtrl = ctrl;
        self.subCtrl = sbCtrl;
        
    }
    self.subCtrl.screenType = HALFSCREEN;
    [UIView transitionWithView:ctrl.view duration:0.5
options:UIViewAnimationOptionTransitionCrossDissolve //change to whatever animation you like
                    animations:^ {
                        [ctrl.view addSubview:_subCtrl.view];
                        [ctrl addChildViewController:_subCtrl];
                    }
                    completion:nil];
    
}
- (void)showInternalWebView:(UIViewController*)ctrl url:(NSString*)url title:(NSString*)title
{
    self.successViewCtrl = ctrl;
    if(!self.subCtrlWeb)
    {
        SubscriptionCtrl* sbCtrl = [[SubscriptionCtrl alloc] init];
        sbCtrl.successCtrl = ctrl;
        self.subCtrlWeb = sbCtrl;
        
    }
    self.subCtrlWeb.webURL = url;
    self.subCtrlWeb.webTitle = title;
    self.subCtrlWeb.screenType = WEBSCREEN;
    [UIView transitionWithView:ctrl.view duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve //change to whatever animation you like
                    animations:^ {
                        [ctrl.view addSubview:self.subCtrlWeb.view];
                        [ctrl addChildViewController:self.subCtrlWeb];
                    }
                    completion:nil];
    
}
- (void)stopShop
{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


- (void)buyInShop:(SubscriptionData *)data controller:(UIViewController *) controller
{
    if([SKPaymentQueue defaultQueue].transactions && [SKPaymentQueue defaultQueue].transactions.count > 0){
        for (int i = 0; i < [SKPaymentQueue defaultQueue].transactions.count; i++) {
            SKPaymentTransaction *tran = [SKPaymentQueue defaultQueue].transactions[i];
            [[SKPaymentQueue defaultQueue] finishTransaction: tran];
        }
    }
    [self buy:data controller:controller];
}

- (void) buy: (SubscriptionData *)data controller:(UIViewController *) controller{
    [self buyWithIdentifier:data.productIdentifier controller:controller];
}

- (void) buyWithIdentifier: (NSString *)productIdentifier controller:(UIViewController *) controller{
    _controller = controller;
    
    [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
    if ([SKPaymentQueue canMakePayments])
    {
        SKProduct *product = [self getSkProductWithProductIdentifier: productIdentifier];
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
    else
    {
        [MBProgressHUD hideHUDForView:controller.view animated:YES];
        [AlertTool showGoitTip:controller title:@"You do not open the program to pay for the purchase." aftrt:nil];
    }
}

- (void) queryAllProducts: (UIViewController *) controller after:(AfterQuery)after{
    _controller = controller;
    _after = after;
    
    //[MBProgressHUD showHUDAddedTo:_controller.view animated:YES];
    
    _isLoadingProducts = YES;
    
    NSMutableArray <SubscriptionData *> *products = [self getProducts];
    NSMutableArray *productIds = [[NSMutableArray alloc] init];
    for (SubscriptionData *data in products) {
        [productIds addObject:data.productIdentifier];
    }
    NSSet *productIdentifierSet = [[NSSet alloc] initWithArray:productIds];
    
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdentifierSet];
    request.delegate = self;
    [request start];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    [MBProgressHUD hideHUDForView:_controller.view animated:YES];
    
    _isLoadingProducts = NO;
    
    _skProducts = response.products;
    
    NSMutableArray <SubscriptionData *> *buyDatas = [self getProducts];
    for (SubscriptionData *data in buyDatas) {
        SKProduct *product = [self getSkProductWithProductIdentifier:data.productIdentifier];
        
        @try {
            data.amountDisplay = [NSString stringWithFormat:@"%@ %@", [product.priceLocale objectForKey:NSLocaleCurrencySymbol], product.price];
            data.btnText = product.localizedTitle;
            NSLog(@"skProduct price=%@",data.amountDisplay);
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
    }
//    NSLog(@"%@",buyDatas);
    _after();
}

- (void)restore: (UIViewController *) controller
{
    _controller = controller;
    
    [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (BOOL) isLoadingProducts {
    return _isLoadingProducts;
}

- (NSInteger) getProductsCount{
    if (_skProducts && _skProducts.count > 0) {
        return [self getProducts].count;
    }
    else{
        return 0;
    }
}

- (NSMutableArray <SubscriptionData *> *) getProducts{
    if (!_products || _products.count == 0) {
        NSArray* numIAPIds = [BuyTool getCongfigInFile:@"IAPIds"];
        NSArray *tenors = @[@0 , @1 , @12];
        if(numIAPIds.count>0)
        {
            tenors = numIAPIds;
        }
        _products = [[NSMutableArray<SubscriptionData *> alloc] init];
        for (id tenor in tenors) {
            SubscriptionData *data = [[SubscriptionData alloc] init];
            data.tenorMonth = [tenor integerValue];
            data.productIdentifier = [NSString stringWithFormat:@"%@.purchase.%@M", [[NSBundle mainBundle]bundleIdentifier], tenor];
            NSString *tenorDisplay = [NSString stringWithFormat:@"%@Month", tenor];
            data.tenorDisplay = NSLocalizedString(tenorDisplay, nil);
            NSString *amountDisplay = [NSString stringWithFormat:@"%@MonthAmount", tenor];
            data.amountDisplay = NSLocalizedString(amountDisplay, nil);
            NSString *btnText = [NSString stringWithFormat:@"%@MonthBtn", tenor];
            data.btnText = NSLocalizedString(btnText, nil);
            
            [_products addObject:data];
        }
    }
    return _products;
}
- (NSArray<SubscriptionData*>*)getSubsProducts
{
    NSMutableArray* list = [NSMutableArray arrayWithCapacity:0];
    for(SubscriptionData*data in _products)
    {
        if(![data.productIdentifier containsString:@".full"])
        {
            [list addObject:data];
        }
    }
    return list;
}
- (NSArray<SubscriptionData*>*)getNonConsProducts
{
    NSMutableArray* list = [NSMutableArray arrayWithCapacity:0];
    for(SubscriptionData*data in _products)
    {
        if([data.productIdentifier containsString:@".full"])
        {
            [list addObject:data];
        }
    }
    return list;
}
- (SubscriptionData *) getBuyDataWithProductIdentifier: (NSString *)productIdentifier{
    NSMutableArray <SubscriptionData *> *products = [self getProducts];
    for (SubscriptionData *data in products) {
        if ([data.productIdentifier isEqualToString:productIdentifier]) {
            return data;
        }
    }
    return nil;
}

- (SKProduct *) getSkProductWithProductIdentifier: (NSString *)productIdentifier{
    for (SKProduct *product in _skProducts) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            return product;
        }
    }
    return nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction
{
    for(SKPaymentTransaction *tran in transaction)
    {
        switch (tran.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
            {
                [[UserData sharedInstance] tried];
                [MBProgressHUD hideHUDForView:_controller.view animated:YES];
                [queue finishTransaction:tran];
                NSLog(@"purchased");
                [[NSNotificationCenter defaultCenter] postNotificationName:FINISH_PURCHAED_RESTORED object:nil];
                break;
            }
            case SKPaymentTransactionStatePurchasing:
            {
                NSLog(@"payment in queue");
                break;
            }
            case SKPaymentTransactionStateRestored:
            {
                [queue finishTransaction:tran];
                NSLog(@"restored");
                [[NSNotificationCenter defaultCenter] postNotificationName:FINISH_PURCHAED_RESTORED object:nil];
                break;
            }
            case SKPaymentTransactionStateFailed:
            {
                [queue finishTransaction:tran];
                NSLog(@"Purchase error = %@",tran.error.description);
                [MBProgressHUD hideHUDForView:_controller.view animated:YES];
                NSLog(@"purchased failed");
                if(tran.error.code!=2)
                    [AlertTool showGoitTip:_controller title:@"Purchase error. Please try again or check your network." aftrt:nil];
                break;
            }
            default:
                break;
        }
    }
}

- (void) refreshReceipt {
    SKReceiptRefreshRequest *request = [[SKReceiptRefreshRequest alloc] init];
    request.delegate = self;
    [request start];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    if ([request isKindOfClass:[SKProductsRequest class]]) {
        [MBProgressHUD hideHUDForView:_controller.view animated:YES];
        _isLoadingProducts = NO;
        [AlertTool showGoitTip:_controller title:NSLocalizedString(@"NetworkError", nil) aftrt:^{}];
    }
    else if([request isKindOfClass:[SKReceiptRefreshRequest class]]){
        [AlertTool showGoitTip:_controller title:@"Subscription update failed. Please try again later." aftrt:^{
            [self afterVerifyReceipt:-1];
        }];
    }
}

- (void)requestDidFinish:(SKRequest *)request
{
    if ([request isKindOfClass:[SKProductsRequest class]]) {
        [MBProgressHUD hideHUDForView:_controller.view animated:YES];
        _isLoadingProducts = NO;
        
        if (_tryNow) {
            _tryNow = NO;
            SubscriptionData *data = [self getProducts][0];
            [[BuyTool sharedInstance] buyInShop:data controller:_controller];
        }
    }
    else if([request isKindOfClass:[SKReceiptRefreshRequest class]]){
        [self requestVerifyReceipt:Env_AppStore];
    }
}

- (void) verifyReceipt {
    [self requestVerifyReceipt:Env_AppStore];
}

- (void) verifyReceipt: (UIViewController *) controller after:(AfterVerify)after{
    NSLog(@"start verifyReceipt");
    _afterVerify = after;
    _controller = controller;
    [self requestVerifyReceipt:Env_AppStore];
//    [self refreshReceipt];
}

- (void) requestVerifyReceipt: (NSString *) strUrl{
    NSData *receipt = [NSData dataWithContentsOfURL: [[NSBundle mainBundle] appStoreReceiptURL]];
    if (!receipt) {
        [self refreshReceipt];
        return;
    }
    NSError *error;
    NSDictionary *requestContents = @{@"receipt-data": [receipt base64EncodedStringWithOptions:0], @"password":[BuyTool getCongfigInFile:@"shared_secret"]};
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:requestContents options:0 error:&error];
    

    NSURL *storeURL = [NSURL URLWithString: strUrl];
    NSMutableURLRequest *storeRequest = [NSMutableURLRequest requestWithURL:storeURL];
    [storeRequest setHTTPMethod:@"POST"];
    [storeRequest setHTTPBody:requestData];
    
    [NSURLConnection sendAsynchronousRequest:storeRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError) {
            [AlertTool showGoitTip:_controller title:@"Network connection failure" aftrt:^{
                [self afterVerifyReceipt:-1];
            }];
        } else {
            NSError *error;
            NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (jsonResponse) {
                switch ([jsonResponse[@"status"] integerValue]) {
                    case 0:
                        [self processReceipt:jsonResponse];
                        break;
                    case 21007:
                        [self requestVerifyReceipt:Env_Sandbox];
                         break;
                    default:
                        [AlertTool showGoitTip:_controller title:@"Subscription update failed. Please try again later." aftrt:^{
                            [self afterVerifyReceipt:-1];
                        }];
                        break;
                }
            }
            else{
                [AlertTool showGoitTip:_controller title:@"Network connection failure" aftrt:^{
                    [self afterVerifyReceipt:-1];
                }];
            }
        }
    }];

}

- (void) processReceipt: (NSDictionary *)data{
    NSDateFormatter * formatter = [NSDateFormatter new];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss VV";
    
    NSArray *receipts = data[@"receipt"][@"in_app"];
    if (receipts.count > 0) {
        [[UserData sharedInstance] tried];
    }
    
    NSMutableArray <NSDate *>*expiresDates = [[NSMutableArray alloc] init];
    for (int i = 0; i < receipts.count; i++) {
        NSDictionary *receipt = receipts[i];
        NSString *strData = receipt[@"expires_date"];
        if(strData.length>0)
        {
            NSDate *date = [formatter dateFromString:strData];
            [expiresDates addObject:date];
        }
        else
        {
            NSString* product_id = receipt[@"product_id"];
            if([product_id containsString:@".full"])
            {
                [[UserData sharedInstance] setLifeTime:YES];
            }
            else
            {
                NSLog(@"receipt error = %@",receipt);
            }
        }
    }
    
    NSArray *resultDates = [expiresDates sortedArrayUsingComparator:^NSComparisonResult(NSDate *date1, NSDate *date2) {
        return [date1 compare:date2]; //升序
    }];
    
    NSLog(@"%@", resultDates);
    
    if (resultDates && resultDates.count > 0) {
        [[UserData sharedInstance] setDue:resultDates[resultDates.count - 1]];
    }
    
    [self afterVerifyReceipt:0];
}

- (void) afterVerifyReceipt: (NSInteger) status{
    if (_afterVerify) {
        _afterVerify(status);
        _afterVerify = nil;
    }
    [MBProgressHUD hideHUDForView:_controller.view animated:YES];
    NSLog(@"afterVerifyReceipt = %d",status);
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [self verifyReceipt:_controller after:^(NSInteger status) {
        [MBProgressHUD hideHUDForView:_controller.view animated:YES];
        
//        [AlertTool showGoitTip:_controller title:@"Restore success." aftrt:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:FINISH_PURCHAED_RESTORED object:nil];
    }];
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:_controller.view animated:YES];
    [AlertTool showGoitTip:_controller title:@"Restore failed." aftrt:nil];
}

- (void) showTransactionError{
    if (_controller) {
        [AlertTool showGoitTip:_controller title:@"Transaction failure." aftrt:nil];
    }
}

+ (instancetype) sharedInstance
{
    @synchronized (self)
    {
        if (!instance)
        {
            instance = [[BuyTool alloc] init];
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

+ (NSString *) getCongfigInFile: (NSString *)key {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"localConfig" ofType:@"plist"];
    NSMutableDictionary *localConfigData = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    return  localConfigData[key];
}

- (void) showSubscriptionScreen:(UIViewController *) controller
{
    if([UserData sharedInstance].isVip) return;
    if ([[BuyTool sharedInstance] getProductsCount] == 0 && ![[BuyTool sharedInstance] isLoadingProducts]) {
        [[BuyTool sharedInstance] queryAllProducts:controller after:^{
            [[[UIApplication sharedApplication].delegate window] setRootViewController:self.subCtrl];
        }];
    }
    else
    {
        [[BuyTool sharedInstance] queryAllProducts:controller after:^{
            [[[UIApplication sharedApplication].delegate window] setRootViewController:self.subCtrl];
        }];
    }
}
@end
