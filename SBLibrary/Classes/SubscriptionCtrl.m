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
#import "IFTTTJazzHands.h"
@import CHIPageControl;
//#define NUM_PAGE 4
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
@interface SubscriptionCtrl ()<UIScrollViewDelegate>{
    
    CHIPageControlAji *pageControl;
    UIScrollView *scroll;
    NSMutableArray* arrLabel;
}
@property (nonatomic, strong) IFTTTAnimator *animator;
@end

@implementation SubscriptionCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.animator = [IFTTTAnimator new];
    //[self initView];
    [self setUpPageView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishPurchasedRestore) name:FINISH_PURCHAED_RESTORED object:nil];
    if ([[BuyTool sharedInstance] getProductsCount] == 0 && ![[BuyTool sharedInstance] isLoadingProducts]) {
        [[BuyTool sharedInstance] queryAllProducts:self after:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updatePrice];
            });
        }];
    }
    else
    {
        [[BuyTool sharedInstance] queryAllProducts:self after:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updatePrice];
            });
        }];
    }
}
- (void)setUpPageView
{
    NSArray* numPagesArr = [BuyTool getCongfigInFile:@"tutorials"];
    if(numPagesArr.count==0)
    {
        assert("define tutorials in localConfig.plist");
        return;
    }
    NSMutableArray* numPages = [NSMutableArray arrayWithArray:numPagesArr];
    [numPages addObject:@""];//add this for sbview
    // Scroll View
    CGSize screen = [UIScreen mainScreen].bounds.size;
    scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screen.width, screen.height)];
    scroll.backgroundColor=[UIColor clearColor];
    scroll.delegate=self;
    scroll.pagingEnabled=YES;
    [scroll setContentSize:CGSizeMake(scroll.frame.size.width*numPages.count, scroll.frame.size.height)];
    
    // page control
    pageControl = [[CHIPageControlAji alloc]initWithFrame:CGRectMake(0, screen.height-56, screen.width, 56)];
    pageControl.backgroundColor=[UIColor clearColor];
    pageControl.numberOfPages=numPages.count;
    pageControl.radius = 4;
    pageControl.tintColor = UIColor.blackColor;
    pageControl.currentPageTintColor = UIColor.blackColor;
    pageControl.padding = 6;
    [pageControl addTarget:self action:@selector(pageChanged) forControlEvents:UIControlEventValueChanged];
    
    CGFloat x=0;
    for(int i=1;i<=numPages.count-1;i++)
    {
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(x+0, 0, screen.width, screen.height)];
        NSString* filename = numPages[i-1];
        [image setImage:[UIImage imageNamed:filename]];
        [scroll addSubview:image];
        x+=screen.width;
        IFTTTAlphaAnimation *alphaAnimation = [IFTTTAlphaAnimation animationWithView: image];
        if(i>1)
            [alphaAnimation addKeyframeForTime:x-screen.width*2 alpha:0.f];
        [alphaAnimation addKeyframeForTime:x-screen.width alpha:1.f];
        [alphaAnimation addKeyframeForTime:x alpha:0.f];
        [self.animator addAnimation: alphaAnimation];
        
    }
    UIView* sbView = [self setupSBView:numPages.count];
    [scroll addSubview:sbView];
    
    IFTTTAlphaAnimation *alphaAnimation = [IFTTTAlphaAnimation animationWithView: sbView];
    [alphaAnimation addKeyframeForTime:x-screen.width alpha:0.f];
    [alphaAnimation addKeyframeForTime:x alpha:1.f];
    [self.animator addAnimation: alphaAnimation];
    
    [self.view addSubview:scroll];
    
    [self.view addSubview:pageControl];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updatePrice];
}
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView{
    
    CGFloat viewWidth = _scrollView.frame.size.width;
    // content offset - tells by how much the scroll view has scrolled.
    
    int pageNumber = floor((_scrollView.contentOffset.x - viewWidth/50) / viewWidth) +1;
    
    pageControl.progress=pageNumber;
    [self.animator animate:_scrollView.contentOffset.x];
}
- (void)pageChanged {
    
    int pageNumber = pageControl.currentPage;
    
    CGRect frame = scroll.frame;
    frame.origin.x = frame.size.width*pageNumber;
    frame.origin.y=0;
    
    [scroll scrollRectToVisible:frame animated:YES];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(UIView*) setupSBView:(int)numPages {
    arrLabel = [NSMutableArray arrayWithCapacity:0];
    CGSize screen = [UIScreen mainScreen].bounds.size;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(screen.width*(numPages-1), 0, screen.width, screen.height)];
    CGFloat multiple = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        multiple = 1.3;
    } else if(isiPhone5) {
        multiple = 1;
    } else
    {
        multiple = 0.8;
    }
    
    UIView * center = [[UIView alloc] init];
    [view addSubview:center];
    [center mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(view.mas_centerY);
        make.centerX.equalTo(view.mas_centerX);
        make.width.equalTo(view.mas_height);
        make.height.equalTo(@(1));
    }];
    view.backgroundColor = [UIColor whiteColor];
    UIImageView * bg = [[UIImageView alloc] init];
    bg.contentMode = UIViewContentModeScaleToFill;
    bg.image = [UIImage imageNamed:@"bgSB.jpg"];
    [view addSubview:bg];
    [bg mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(@(0*multiple));
        make.left.equalTo(@(0*multiple));
        make.right.equalTo(@(0*multiple));
        make.bottom.equalTo(center.mas_top);
    }];
    UIButton * btnClose = [[UIButton alloc] init];
    [btnClose setBackgroundImage:[UIImage imageNamed:@"helpSB"] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(tosAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnClose];
    [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX);
        make.right.equalTo(@(-30*multiple));
        make.top.equalTo(@(30*multiple));
        make.width.equalTo(@(50*multiple));
        make.height.equalTo(@(50*multiple));
    }];

    //设置按钮setting
    UIImageView *setImgView = [[UIImageView alloc]init];
    //setImgView.frame = CGRectMake(SWidth-35, 25, 25, 25);
    setImgView.image = [UIImage imageNamed:@"iap-close1"];
    setImgView.userInteractionEnabled = YES;
    [view addSubview:setImgView];
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
    title.text = [BuyTool getCongfigInFile:@"appName"];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont boldSystemFontOfSize:30];
    [view addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(center.mas_bottom).offset(5*multiple);
        make.width.equalTo(@(320*multiple));
        make.height.equalTo(@(40*multiple));
    }];
    
    UILabel* subTitle = [[UILabel alloc] init];
    subTitle.numberOfLines=2;
    subTitle.font = [UIFont systemFontOfSize:13];
    subTitle.text = [BuyTool getCongfigInFile:@"appUnlock"];
    subTitle.textAlignment = NSTextAlignmentCenter;
    [view addSubview:subTitle];
    [subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        //        make.centerX.equalTo(logoImageView.mas_centerX);
        //        make.centerY.equalTo(logoImageView.mas_centerY);
        make.top.equalTo(title.mas_bottom).offset(5*multiple);
        make.centerX.equalTo(view.mas_centerX);
        make.width.equalTo(@(320*multiple));
        make.height.equalTo(@(40*multiple));
    }];
    UIButton* lastBtn;
    UIButton * buyBtn = [[UIButton alloc]init];
    int index=0;
    if(index<[[BuyTool sharedInstance] getProducts].count)
    {
        [view addSubview:buyBtn];
        buyBtn.tag=index;
        [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view.mas_centerX);
            make.top.equalTo(subTitle.mas_bottom).offset(5*multiple);
            make.width.equalTo(@(380*multiple));
            make.height.equalTo(@(70*multiple));
        }];
        buyBtn.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:70/255.0 alpha:1];
        SubscriptionData* data = [[BuyTool sharedInstance] getProducts][index];
        NSLog(@"price = %@",data.amountDisplay);
        [buyBtn setTitle:[self getStringWithSubData:data] forState:UIControlStateNormal];
        [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        buyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:21];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
        [buyBtn addGestureRecognizer:tap];
        buyBtn.layer.cornerRadius = 20;
        lastBtn = buyBtn;
    }
    index++;
    UIView * buyBtn2 = [[UIView alloc]init];
    SubscriptionData* data = [[BuyTool sharedInstance] getProducts][index];
    if(![data.amountDisplay isEqualToString:@"(null) (null)"])
    {
        buyBtn2.tag=index;
        [view addSubview:buyBtn2];
        [buyBtn2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view.mas_centerX);
            make.top.equalTo(buyBtn.mas_bottom).offset(35*multiple);
            make.width.equalTo(@(380*multiple));
            make.height.equalTo(@(70*multiple));
        }];
        buyBtn2.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
        NSLog(@"price = %@",data.amountDisplay);
        UILabel*leftTitle = [[UILabel alloc] init];
        leftTitle.text  = [self getStringWithSubData:data];
        leftTitle.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        leftTitle.font = [UIFont boldSystemFontOfSize:21];
        leftTitle.textAlignment = NSTextAlignmentLeft;
        [buyBtn2 addSubview:leftTitle];
        [leftTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(15*multiple));
            make.centerY.equalTo(buyBtn2.mas_centerY);
            make.width.equalTo(@(180*multiple));
            make.height.equalTo(@(70*multiple));
        }];
        
        UILabel*rightTitle = [[UILabel alloc] init];
        rightTitle.text  = [self getDisplayStringWithSubData:data];
        rightTitle.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        rightTitle.font = [UIFont boldSystemFontOfSize:21];
        rightTitle.textAlignment = NSTextAlignmentRight;
        [buyBtn2 addSubview:rightTitle];
        [rightTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-15*multiple));
            make.centerY.equalTo(buyBtn2.mas_centerY);
            make.width.equalTo(@(180*multiple));
            make.height.equalTo(@(60*multiple));
        }];
        [arrLabel addObject:rightTitle];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
        [buyBtn2 addGestureRecognizer:tap];
        buyBtn2.layer.cornerRadius = 20;
        lastBtn = buyBtn2;
        
        UIImageView * popular = [[UIImageView alloc]init];
        popular.contentMode = UIViewContentModeScaleToFill;
        popular.image = [UIImage imageNamed:@"popular_icon"];
        [buyBtn2 addSubview:popular];
        [popular mas_makeConstraints:^(MASConstraintMaker *make) {
            //make.centerX.equalTo(self.view.mas_centerX);
            make.bottom.equalTo(buyBtn2.mas_top).offset(10*multiple);
            make.right.equalTo(@(10*multiple));
            make.height.equalTo(@(35*multiple));
            make.width.equalTo(@(106*multiple));
        }];
    }
    
    
    
    
    index++;
    UIView * buyBtn3 = [[UIView alloc]init];
    data = [[BuyTool sharedInstance] getProducts][index];
    if(![data.amountDisplay isEqualToString:@"(null) (null)"])
    {
        buyBtn3.tag=index;
        [view addSubview:buyBtn3];
        [buyBtn3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(view.mas_centerX);
            make.top.equalTo(buyBtn2.mas_bottom).offset(15*multiple);
            make.width.equalTo(@(380*multiple));
            make.height.equalTo(@(60*multiple));
        }];
        
        buyBtn3.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1];
        UILabel*leftTitle = [[UILabel alloc] init];
        leftTitle.text  = [self getStringWithSubData:data];
        leftTitle.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        leftTitle.font = [UIFont boldSystemFontOfSize:21];
        leftTitle.textAlignment = NSTextAlignmentLeft;
        [buyBtn3 addSubview:leftTitle];
        [leftTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(15*multiple));
            make.centerY.equalTo(buyBtn3.mas_centerY);
            make.width.equalTo(@(180*multiple));
            make.height.equalTo(@(60*multiple));
        }];
        
        UILabel*rightTitle = [[UILabel alloc] init];
        rightTitle.text  = [self getDisplayStringWithSubData:data];
        rightTitle.textColor = [UIColor colorWithRed:90/255.0 green:90/255.0 blue:90/255.0 alpha:1];
        rightTitle.font = [UIFont boldSystemFontOfSize:21];
        rightTitle.textAlignment = NSTextAlignmentRight;
        [buyBtn3 addSubview:rightTitle];
        [rightTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-15*multiple));
            make.centerY.equalTo(buyBtn3.mas_centerY);
            make.width.equalTo(@(180*multiple));
            make.height.equalTo(@(60*multiple));
        }];
        [arrLabel addObject:rightTitle];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
        [buyBtn3 addGestureRecognizer:tap];
        
        
        buyBtn3.layer.cornerRadius = 20;
        lastBtn = buyBtn3;
    }
    return view;
}
- (void)updatePrice
{
    if(arrLabel.count==0)return;
    int i=0;
    for(SubscriptionData*data in [[BuyTool sharedInstance] getProducts])
    {
        if(i==0)
        {
            i++;
            continue;
        }
        UILabel* label= arrLabel[i-1];
        label.text = data.amountDisplay;
        i++;
    }
}
- (void)buyAction:(id)sender
{
    UITapGestureRecognizer* tap = sender;
    int tag = (int)[tap.view tag];
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
    [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:webController animated:NO completion:nil];
}
- (void)closeAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SUBSCRIPTION_CLOSE" object:nil];
}
- (NSString*) getStringWithSubData:(SubscriptionData*)data
{
    NSMutableString* str = [NSMutableString stringWithCapacity:0];
    if(data.tenorMonth==1)
    {
        [str appendString:@"MONTHLY"];
    }
    else if(data.tenorMonth==12)
    {
        [str appendString:@"ANNUALLY"];
    }
    else if(data.tenorMonth==0)
    {
        [str appendString:@"TRY FOR FREE"];
    }
    return str;
}
- (NSString*) getDisplayStringWithSubData:(SubscriptionData*)data
{
    NSMutableString* str = [NSMutableString stringWithCapacity:0];
    if(data.tenorMonth==1)
    {
        [str appendString:data.amountDisplay];
    }
    else if(data.tenorMonth==12)
    {
        [str appendString:data.amountDisplay];
    }
    else if(data.tenorMonth==0)
    {
        [str appendString:data.amountDisplay];
    }
    return str;
}
- (void)finishPurchasedRestore
{
    if ([[UserData sharedInstance] isVip])
    {
        [[[UIApplication sharedApplication].delegate window] setRootViewController:self.successCtrl];
    }
    else
    {
        [[BuyTool sharedInstance] verifyReceipt:self after:^(NSInteger status) {
            if (status == 0) {
                if ([[UserData sharedInstance] isVip]){
                    [[[UIApplication sharedApplication].delegate window] setRootViewController:self.successCtrl];
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
