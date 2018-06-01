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
    NSMutableArray* arrBtnBuy;
    UIView* _mainView;
    CGFloat _screenHeight;
}
@property (nonatomic, strong) IFTTTAnimator *animator;
@end

@implementation SubscriptionCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.animator = [IFTTTAnimator new];
    //[self initView];
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
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if(_screenHeight==0)
    {
        CGSize screen = [UIScreen mainScreen].bounds.size;
        CGFloat screenHeight = screen.height;
        if (@available(iOS 11.0, *)) {
            UIWindow *window = UIApplication.sharedApplication.keyWindow;
            CGFloat topPadding = window.safeAreaInsets.top;
            CGFloat bottomPadding = window.safeAreaInsets.bottom;
            screenHeight = screen.height - topPadding - bottomPadding;
            _screenHeight = screenHeight;
        }
        else
        {
            _screenHeight = screenHeight;
        }
        [self setUpPageView];
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
    CGFloat screenHeight = screen.height;
    if(_screenHeight==0) _screenHeight=screenHeight;
    scroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screen.width, _screenHeight)];
    scroll.backgroundColor=[UIColor clearColor];
    scroll.delegate=self;
    scroll.pagingEnabled=YES;
    [scroll setContentSize:CGSizeMake(scroll.frame.size.width*numPages.count, scroll.frame.size.height)];
    
    // page control
    pageControl = [[CHIPageControlAji alloc]initWithFrame:CGRectMake(0, _screenHeight-56, screen.width, 56)];
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
        
        UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(x+0, 0, screen.width, _screenHeight)];
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
    
    UIView * myView = [[UIView alloc] initWithFrame:self.view.frame];// initialize view using IBOutlet or programtically
    
    myView.backgroundColor = [UIColor blackColor];
    self.view.backgroundColor = [UIColor whiteColor];
    myView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:myView];
    if (@available(iOS 11, *)) {
        UILayoutGuide * guide = self.view.safeAreaLayoutGuide;
        [myView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
        [myView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES;
        [myView.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
        [myView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    } else {
        UILayoutGuide *margins = self.view.layoutMarginsGuide;
        [myView.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor].active = YES;
        [myView.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor].active = YES;
        [myView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
        [myView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
    }
    
    _mainView = myView;

    [_mainView addSubview:scroll];
    
    [_mainView addSubview:pageControl];
//    [self setupSafeArea:scroll parent:_mainView];
//    [self setupSafeArea:pageControl parent:_mainView];
}

- (void)setupSafeArea:(UIView*)myView parent:(UIView*)parent
{
    myView.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 11, *)) {
        UILayoutGuide * guide = parent.safeAreaLayoutGuide;
        [myView.leadingAnchor constraintEqualToAnchor:guide.leadingAnchor].active = YES;
        [myView.trailingAnchor constraintEqualToAnchor:guide.trailingAnchor].active = YES;
        [myView.topAnchor constraintEqualToAnchor:guide.topAnchor].active = YES;
        [myView.bottomAnchor constraintEqualToAnchor:guide.bottomAnchor].active = YES;
    } else {
        UILayoutGuide *margins = parent.layoutMarginsGuide;
        [myView.leadingAnchor constraintEqualToAnchor:margins.leadingAnchor].active = YES;
        [myView.trailingAnchor constraintEqualToAnchor:margins.trailingAnchor].active = YES;
        [myView.topAnchor constraintEqualToAnchor:self.topLayoutGuide.bottomAnchor].active = YES;
        [myView.bottomAnchor constraintEqualToAnchor:self.bottomLayoutGuide.topAnchor].active = YES;
    }
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
    arrBtnBuy = [NSMutableArray arrayWithCapacity:0];
    CGSize screen = [UIScreen mainScreen].bounds.size;
    CGFloat screenHeight = screen.height;
    if(_screenHeight==0) _screenHeight=screenHeight;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(screen.width*(numPages-1), 0, screen.width, _screenHeight)];
    CGFloat multiple = 1;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        multiple = 1.3;
    } else if(isiPhone5) {
        multiple = 0.8;
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
        make.width.equalTo(@(70*multiple));
        make.height.equalTo(@(70*multiple));
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
        make.left.equalTo(@(20*multiple));
        make.width.equalTo(@(40*multiple));
        make.height.equalTo(@(40*multiple));
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
//        make.top.equalTo(center.mas_bottom).offset(5*multiple);
        make.top.equalTo(@(40*multiple));
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
        buyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
        [buyBtn addGestureRecognizer:tap];
        buyBtn.layer.cornerRadius = 20;
        lastBtn = buyBtn;
        [arrBtnBuy addObject:lastBtn];
    }
    index++;
    buyBtn = [[UIButton alloc]init];
    if(index<[[BuyTool sharedInstance] getProducts].count)
    {
        SubscriptionData* data = [[BuyTool sharedInstance] getProducts][index];
        if(![data.amountDisplay isEqualToString:@"(null) (null)"])
        {
            [view addSubview:buyBtn];
            buyBtn.tag=index;
            [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(view.mas_centerX);
                make.top.equalTo(lastBtn.mas_bottom).offset(35*multiple);
                make.width.equalTo(@(380*multiple));
                make.height.equalTo(@(70*multiple));
            }];
            buyBtn.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:70/255.0 alpha:1];
            SubscriptionData* data = [[BuyTool sharedInstance] getProducts][index];
            NSLog(@"price = %@",data.amountDisplay);
            [buyBtn setTitle:[self getStringWithSubData:data] forState:UIControlStateNormal];
            [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            buyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
            [buyBtn addGestureRecognizer:tap];
            buyBtn.layer.cornerRadius = 20;
            lastBtn = buyBtn;
            [arrBtnBuy addObject:lastBtn];
            
            UIImageView * popular = [[UIImageView alloc]init];
            popular.contentMode = UIViewContentModeScaleToFill;
            popular.image = [UIImage imageNamed:@"popular_icon"];
            [buyBtn addSubview:popular];
            [popular mas_makeConstraints:^(MASConstraintMaker *make) {
                //make.centerX.equalTo(self.view.mas_centerX);
                make.bottom.equalTo(buyBtn.mas_top).offset(10*multiple);
                make.right.equalTo(@(10*multiple));
                make.height.equalTo(@(35*multiple));
                make.width.equalTo(@(106*multiple));
            }];
        }
    }
    
    index++;
    buyBtn = [[UIButton alloc]init];
    if(index<[[BuyTool sharedInstance] getProducts].count)
    {
        SubscriptionData*data = [[BuyTool sharedInstance] getProducts][index];
        if(![data.amountDisplay isEqualToString:@"(null) (null)"])
        {
            [view addSubview:buyBtn];
            buyBtn.tag=index;
            [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(view.mas_centerX);
                make.top.equalTo(lastBtn.mas_bottom).offset(15*multiple);
                make.width.equalTo(@(380*multiple));
                make.height.equalTo(@(70*multiple));
            }];
            buyBtn.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:70/255.0 alpha:1];
            SubscriptionData* data = [[BuyTool sharedInstance] getProducts][index];
            NSLog(@"price = %@",data.amountDisplay);
            [buyBtn setTitle:[self getStringWithSubData:data] forState:UIControlStateNormal];
            [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            buyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
            [buyBtn addGestureRecognizer:tap];
            buyBtn.layer.cornerRadius = 20;
            lastBtn = buyBtn;
            [arrBtnBuy addObject:lastBtn];
        }
    }
    
    UILabel* privacyLbl = [[UILabel alloc] init];
    privacyLbl.numberOfLines=0;
    privacyLbl.font = [UIFont systemFontOfSize:13];
    privacyLbl.adjustsFontSizeToFitWidth = YES;
    privacyLbl.text = [BuyTool getCongfigInFile:@"privacyText"];
    privacyLbl.textAlignment = NSTextAlignmentCenter;
    [view addSubview:privacyLbl];
    [privacyLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lastBtn.mas_bottom).offset(15*multiple);
        make.centerX.equalTo(view.mas_centerX);
        make.width.equalTo(@(380*multiple));
        make.height.equalTo(@(200*multiple));
    }];
    
    UIButton * btnPrivacy = [[UIButton alloc] init];
    [btnPrivacy setTitle:@"Terms and Privacy Policy" forState:UIControlStateNormal];
    [btnPrivacy setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [btnPrivacy addTarget:self action:@selector(tosAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnPrivacy];
    [btnPrivacy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(privacyLbl.mas_bottom).offset(10*multiple);
        make.width.equalTo(@(280*multiple));
        make.height.equalTo(@(70*multiple));
    }];
    
    UIButton * btnSkip = [[UIButton alloc] init];
    [btnSkip setTitle:@"Remind me later" forState:UIControlStateNormal];
    [btnSkip setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    btnSkip.titleLabel.adjustsFontSizeToFitWidth = YES;
    [btnSkip addTarget:self action:@selector(closeAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnSkip];
    [btnSkip mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(btnPrivacy.mas_bottom).offset(10*multiple);
        make.width.equalTo(@(150*multiple));
        make.height.equalTo(@(70*multiple));
    }];
    
    return view;
}
- (void)updatePrice
{
    if(arrBtnBuy.count==0)return;
    int i=0;
    for(SubscriptionData*data in [[BuyTool sharedInstance] getProducts])
    {
        NSLog(@"i=%d,data = %@",i,data.amountDisplay);
        UIButton* button = arrBtnBuy[i];
//        button.titleLabel.numberOfLines = 0;
//        button.titleLabel.textAlignment = NSTextAlignmentCenter;
//        button.titleLabel.font = [UIFont systemFontOfSize:15];
//        NSString* title = [NSString
//                           stringWithFormat:@"Three days Free Trial!\nthen %@  %@",data.amountDisplay,[self getStringWithSubData:data]];
//        [button setTitle:title forState:UIControlStateNormal];
        [self setupButtonPrice:button data:data];
        i++;
        
    }
}
- (void)setupButtonPrice:(UIButton*)button data:(SubscriptionData*)data
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20.0f];
    UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue-Light"  size:17.0f];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style}; // Added line
    NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font2,
                            NSParagraphStyleAttributeName:style}; // Added line
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Three days Free Trial!\n"    attributes:dict1]];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"then %@  %@",data.amountDisplay,[self getStringWithSubData:data]]      attributes:dict2]];
    button.titleLabel.numberOfLines = 0;
    [button setAttributedTitle:attString forState:UIControlStateNormal];
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
    [[[UIApplication sharedApplication].delegate window] setRootViewController:self.successCtrl];
}
- (NSString*) getStringWithSubData:(SubscriptionData*)data
{
    NSMutableString* str = [NSMutableString stringWithCapacity:0];
    if(data.tenorMonth==1)
    {
        [str appendString:@"per month"];
    }
    else if(data.tenorMonth==3)
    {
        [str appendString:@"every three months"];
    }
    else if(data.tenorMonth==12)
    {
        [str appendString:@"per year"];
    }
    else if(data.tenorMonth==0)
    {
        [str appendString:@"per week"];
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
        [AlertTool showGoitTip:_successCtrl title:@"Thanks for purchasing." aftrt:nil];
    }
    else
    {
        [[BuyTool sharedInstance] verifyReceipt:self after:^(NSInteger status) {
            if (status == 0) {
                if ([[UserData sharedInstance] isVip]){
                    [[[UIApplication sharedApplication].delegate window] setRootViewController:self.successCtrl];
                    [AlertTool showGoitTip:_successCtrl title:@"Thanks for purchasing." aftrt:nil];
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
