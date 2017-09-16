//
//  SubscriptionCtrl.m
//  PhotoSecurity
//
//  Created by チャン ビングエン on 2017/08/24.
//  Copyright © 2017 xiaopin. All rights reserved.
//

#import "SubscriptionCtrl.h"
#import "View+MASAdditions.h"
#import "WebController.h"
#import "BuyTool.h"
#import "UserData.h"
#import "AlertTool.h"
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
@interface SubscriptionCtrl ()

@end

@implementation SubscriptionCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPurchasedRestore) name:FINISH_PURCHAED_RESTORED object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void) initView {
    
    CGFloat multiple = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        multiple = 1.3;
    } else if(isiPhone5) {
        multiple = 1;
    } else
    {
        multiple = 0.8;
    }
    self.view.backgroundColor = [UIColor colorWithRed:90/255.0 green:190/255.0 blue:240/255.0 alpha:1];
    //设置按钮setting
    UIImageView *setImgView = [[UIImageView alloc]init];
    //setImgView.frame = CGRectMake(SWidth-35, 25, 25, 25);
    setImgView.image = [UIImage imageNamed:@"iap-close1"];
    setImgView.userInteractionEnabled = YES;
    [self.view addSubview:setImgView];
    [setImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(@(35*multiple));
        make.right.equalTo(@(-20*multiple));
        make.width.equalTo(@(25*multiple));
        make.height.equalTo(@(25*multiple));
    }];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeAction:)];
    [setImgView addGestureRecognizer:singleTap];
    
    //节点背景
    
    UILabel* title = [[UILabel alloc] init];
    title.text = @"UNLIMITED MEMBERSHIP";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(@(50*multiple));
        make.width.equalTo(@(320*multiple));
        make.height.equalTo(@(40*multiple));
    }];
    
    UILabel* subTitle = [[UILabel alloc] init];
    subTitle.numberOfLines=2;
    subTitle.font = [UIFont systemFontOfSize:13];
    subTitle.text = @"In order to enjoy the full feature of this app, please select a package";
    subTitle.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:subTitle];
    [subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerX.equalTo(logoImageView.mas_centerX);
        //        make.centerY.equalTo(logoImageView.mas_centerY);
        make.top.equalTo(title.mas_bottom).offset(5*multiple);
        make.centerX.equalTo(self.view.mas_centerX);
        make.width.equalTo(@(320*multiple));
        make.height.equalTo(@(60*multiple));
    }];
    UIButton* lastBtn;
    UIButton * buyBtn = [[UIButton alloc]init];
    int index=0;
    if(index<[[BuyTool sharedInstance] getProducts].count)
    {
        [self.view addSubview:buyBtn];
        buyBtn.tag=index;
        [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(subTitle.mas_bottom).offset(5*multiple);
            make.width.equalTo(@(300*multiple));
            make.height.equalTo(@(50*multiple));
        }];
        buyBtn.backgroundColor = [UIColor colorWithRed:220/255.0 green:100/255.0 blue:50/255.0 alpha:1];
        SubscriptionData* data = [[BuyTool sharedInstance] getProducts][index];
        NSLog(@"price = %@",data.amountDisplay);
        [buyBtn setTitle:[self getStringWithSubData:data] forState:UIControlStateNormal];
        [buyBtn addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
        lastBtn = buyBtn;
    }
    index++;
    UIButton * buyBtn2 = [[UIButton alloc]init];
    SubscriptionData* data = [[BuyTool sharedInstance] getProducts][index];
    if(![data.amountDisplay isEqualToString:@"(null) (null)"])
    {
        buyBtn2.tag=index;
        [self.view addSubview:buyBtn2];
        [buyBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(buyBtn.mas_bottom).offset(5*multiple);
            make.width.equalTo(@(300*multiple));
            make.height.equalTo(@(50*multiple));
        }];
        buyBtn2.backgroundColor = [UIColor colorWithRed:0/255.0 green:187/255.0 blue:156/255.0 alpha:1];
        NSLog(@"price = %@",data.amountDisplay);
        [buyBtn2 setTitle:[self getStringWithSubData:data] forState:UIControlStateNormal];
        [buyBtn2 addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
        lastBtn = buyBtn2;
    }
    
    index++;
    UIButton * buyBtn3 = [[UIButton alloc]init];
    data = [[BuyTool sharedInstance] getProducts][index];
    if(![data.amountDisplay isEqualToString:@"(null) (null)"])
    {
        buyBtn3.tag=index;
        [self.view addSubview:buyBtn3];
        [buyBtn3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(buyBtn2.mas_bottom).offset(5*multiple);
            make.width.equalTo(@(300*multiple));
            make.height.equalTo(@(50*multiple));
        }];
        
        buyBtn3.backgroundColor = [UIColor colorWithRed:0/255.0 green:187/255.0 blue:156/255.0 alpha:1];
        NSLog(@"price = %@",data.amountDisplay);
        [buyBtn3 setTitle:[self getStringWithSubData:data] forState:UIControlStateNormal];
        [buyBtn3 addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
        lastBtn = buyBtn3;
    }
    
    index++;
    UIButton * buyBtn4 = [[UIButton alloc]init];
    data = [[BuyTool sharedInstance] getProducts][index];
    if(![data.amountDisplay isEqualToString:@"(null) (null)"])
    {
        buyBtn4.tag=index;
        [self.view addSubview:buyBtn4];
        [buyBtn4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.top.equalTo(buyBtn3.mas_bottom).offset(5*multiple);
            make.width.equalTo(@(300*multiple));
            make.height.equalTo(@(50*multiple));
        }];
        buyBtn4.backgroundColor = [UIColor colorWithRed:0/255.0 green:187/255.0 blue:156/255.0 alpha:1];
        NSLog(@"price = %@",data.amountDisplay);
        [buyBtn4 setTitle:[self getStringWithSubData:data] forState:UIControlStateNormal];
        [buyBtn4 addTarget:self action:@selector(buyAction:) forControlEvents:UIControlEventTouchUpInside];
        lastBtn = buyBtn4;
    }
    
    
    NSString* iapDesc = [BuyTool getCongfigInFile:@"iap_desc"];
    if(iapDesc.length>0)
    {
        iapDesc = [iapDesc stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        UILabel* cancelTitle = [[UILabel alloc] init];
        cancelTitle.font = [UIFont systemFontOfSize:13];
        cancelTitle.numberOfLines = 3;
        cancelTitle.text = iapDesc;
//        cancelTitle.text = @"* Record high-quality video\n* Unlimited Support \nYou can cancel anytime";
        cancelTitle.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:cancelTitle];
        [cancelTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            //        make.centerX.equalTo(logoImageView.mas_centerX);
            //        make.centerY.equalTo(logoImageView.mas_centerY);
            make.top.equalTo(lastBtn.mas_bottom).offset(5*multiple);
            make.centerX.equalTo(self.view.mas_centerX);
            make.width.equalTo(@(320*multiple));
            make.height.equalTo(@(60*multiple));
        }];
    }
    
    
    //footer
    
    UIButton * btnRestore = [[UIButton alloc]init];
    [self.view addSubview:btnRestore];
    [btnRestore mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(@(-80*multiple));
        make.width.equalTo(@(250*multiple));
        make.height.equalTo(@(50*multiple));
    }];
    btnRestore.backgroundColor = [UIColor colorWithRed:250/255.0 green:150/255.0 blue:100/255.0 alpha:1];
    //    btnRestore.layer.cornerRadius = 8;
    //    btnRestore.layer.masksToBounds = YES;
    [btnRestore setTitle:@"Restore" forState:UIControlStateNormal];
    [btnRestore addTarget:self action:@selector(restoreAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * btnContinue = [[UIButton alloc]init];
    btnContinue.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.view addSubview:btnContinue];
    [btnContinue mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(btnRestore.mas_bottom).offset(5*multiple);
        make.width.equalTo(@(300));
        make.height.equalTo(@(20*multiple));
    }];
    [btnContinue setTitle:@"No, I want to continue with the limited version" forState:UIControlStateNormal];
    [btnContinue setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnContinue addTarget:self action:@selector(continueAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * btnPrivacy = [[UIButton alloc]init];
    btnPrivacy.titleLabel.font = [UIFont systemFontOfSize:13];
    btnPrivacy.titleLabel.textAlignment = NSTextAlignmentRight;
    [self.view addSubview:btnPrivacy];
    [btnPrivacy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(30*multiple));
        make.top.equalTo(btnContinue.mas_bottom).offset(5*multiple);
        make.width.equalTo(@(140*multiple));
        make.height.equalTo(@(20*multiple));
    }];
    [btnPrivacy setTitle:@"Privacy Policy" forState:UIControlStateNormal];
    [btnPrivacy setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnPrivacy addTarget:self action:@selector(privacyAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton * btnTOS = [[UIButton alloc]init];
    btnTOS.titleLabel.font = [UIFont systemFontOfSize:13];
    btnTOS.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:btnTOS];
    [btnTOS mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-30*multiple));
        make.top.equalTo(btnContinue.mas_bottom).offset(5*multiple);
        make.width.equalTo(@(140));
        make.height.equalTo(@(20*multiple));
    }];
    [btnTOS setTitle:@"About Subscriptions" forState:UIControlStateNormal];
    [btnTOS setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnTOS addTarget:self action:@selector(tosAction:) forControlEvents:UIControlEventTouchUpInside];

}
- (void)buyAction:(id)sender
{
    int tag = (int)[sender tag];
    SubscriptionData*data = [[BuyTool sharedInstance] getProducts][tag];
    [[BuyTool sharedInstance] buyInShop:data controller:self];
}
- (void)restoreAction:(id)sender
{
    [[BuyTool sharedInstance] restore:self];
}
- (void)continueAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)privacyAction:(id)sender
{
    WebController *webController = [[WebController alloc] init];
    webController.url = @"private";
    webController.titleKey = @"Privacy Policy";
    [self dismissViewControllerAnimated:YES completion:^{
        
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:webController animated:NO completion:nil];
    }];
}
- (void)tosAction:(id)sender
{
    WebController *webController = [[WebController alloc] init];
    webController.url = @"subscriptions";
    webController.titleKey = @"About Subscriptions";
    [self dismissViewControllerAnimated:YES completion:^{
        [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:webController animated:NO completion:nil];
    }];
}
- (void)closeAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SUBSCRIPTION_CLOSE" object:nil];
    }];
}
- (NSString*) getStringWithSubData:(SubscriptionData*)data
{
    NSMutableString* str = [NSMutableString stringWithCapacity:0];
    if(data.tenorMonth==1)
    {
        [str appendString:@"Free Trial (3 days)"];
//        [str appendFormat:@" (%@)",data.amountDisplay];
    }
    else if(data.tenorMonth==3)
    {
        [str appendString:@"QUATERLY"];
        [str appendFormat:@" (%@)",data.amountDisplay];
    }
    else if(data.tenorMonth==12)
    {
        [str appendString:@"YEARLY"];
        [str appendFormat:@" (%@)",data.amountDisplay];
    }
    else if(data.tenorMonth==0)
    {
        [str appendString:@"START NOW"];
    }
    else if(data.tenorMonth==6)
    {
        [str appendString:@"6 MONTHS"];
        [str appendFormat:@" (%@)",data.amountDisplay];
    }
    else if(data.tenorMonth==2)
    {
        [str appendString:@"6 MONTHS"];
        [str appendFormat:@" (%@)",data.amountDisplay];
    }
    return str;
}
- (void)finishPurchasedRestore
{
    if ([[UserData sharedInstance] isVip])
    {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
    else
    {
        [[BuyTool sharedInstance] verifyReceipt:self after:^(NSInteger status) {
            if (status == 0) {
                if ([[UserData sharedInstance] isVip]){
                    [self dismissViewControllerAnimated:NO completion:nil];
                }
                else{
                    
                    [AlertTool showGoitTip:self title:@"Your subscription expired." message:@"If you have renewed your subscription, please try to relaunch our app." aftrt:^{}];
                }
            }
            else{
                
            }
        }];

    }
}
@end
