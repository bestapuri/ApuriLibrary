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
#import <QuartzCore/QuartzCore.h>
@import CHIPageControl;
//#define NUM_PAGE 4
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
@interface SubscriptionCtrl ()<UIScrollViewDelegate>{
    
    CHIPageControlAji *pageControl;
    UIScrollView *scroll;
    NSMutableArray* arrBtnBuy;
    UIView* _mainView;
    CGFloat _screenHeight;
    UIView* _fullLifeTimeView;
    UIView* _webView;
}
@property (nonatomic, strong) IFTTTAnimator *animator;
@end

@implementation SubscriptionCtrl

- (id)initWithURL:(NSString*)url title:(NSString*)title
{
    if(self = [super init])
    {
        _webURL = url;
        _webTitle = title;
    }
    return self;
}
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
    UIView * myView = [[UIView alloc] initWithFrame:self.view.frame];// initialize view using IBOutlet or programtically
    
    myView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor clearColor];
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
    UIView* sbView;
    if(self.screenType==HALFSCREEN)
    {
        sbView = [self setupSBViewHalfScreen];
        sbView.frame = _mainView.frame;
        [_mainView addSubview:sbView];
        
    }
    else if(self.screenType == WEBSCREEN)
    {
        [self showInternalWebView:_webURL title:_webTitle];
    }
    else
    {
        self.view.backgroundColor = [UIColor whiteColor];
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
        sbView = [self setupSBView:numPages.count];
        [scroll addSubview:sbView];
        IFTTTAlphaAnimation *alphaAnimation = [IFTTTAlphaAnimation animationWithView: sbView];
        [alphaAnimation addKeyframeForTime:x-screen.width alpha:0.f];
        [alphaAnimation addKeyframeForTime:x alpha:1.f];
        [self.animator addAnimation: alphaAnimation];
    }
    

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
    
    //int pageNumber = pageControl.currentPage;
    int pageNumber = 1;
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
    NSArray* products = [[BuyTool sharedInstance] getSubsProducts];
    if(index<products.count)
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
        SubscriptionData* data = products[index];
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
    if(index<products.count)
    {
        SubscriptionData* data = products[index];
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
    if(index<products.count)
    {
        SubscriptionData*data = products[index];
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
    [btnPrivacy addTarget:self action:@selector(privacyAction:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnPrivacy];
    [btnPrivacy mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view.mas_centerX);
        make.top.equalTo(privacyLbl.mas_bottom).offset(10*multiple);
        make.width.equalTo(@(280*multiple));
        make.height.equalTo(@(70*multiple));
    }];
    
    /*
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
    */
    return view;
}
- (void)btnCloseClicked:(id)sender
{
    [_fullLifeTimeView removeFromSuperview];
    if(_blockComplete)
    {
        _blockComplete();
    }
//    [self removeFromParentViewController];
//    [self.view removeFromSuperview];
}
- (void)btnCloseWebClicked:(id)sender
{
    if(self.screenType == WEBSCREEN)
    {
        [_mainView removeFromSuperview];
        if(_blockComplete)
        {
            _blockComplete();
        }
//        [self.view removeFromSuperview];
//        [self removeFromParentViewController];
    }
    else
    {
        [_webView removeFromSuperview];
    }
}
- (void)btnCloseSubClicked:(id)sender
{
    if([BuyTool sharedInstance].getNonConsProducts.firstObject)
    {
        UIView *fullPurchaseView = [[UIView alloc] init];
        [self.view addSubview:fullPurchaseView];
        [fullPurchaseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_centerY);
            make.height.equalTo(self.view.mas_height);
            make.width.equalTo(self.view.mas_width);
        }];
        [self setupSBViewLifeTime:fullPurchaseView];
        _fullLifeTimeView = fullPurchaseView;
    }
    else
    {
        [self btnCloseClicked:nil];
    }
}
- (void)btnBuyClicked:(id)sender
{
    SubscriptionData* data = [[BuyTool sharedInstance] getNonConsProducts].firstObject;
    [[BuyTool sharedInstance] buyInShop:data controller:self];
}
- (void)btnInAppDetailClicked:(id)sender
{
//    WebController *webController = [[WebController alloc] init];
//    webController.url = @"subscriptions";
//    webController.titleKey = @"In-App Purchase";
//    [self.view addSubview:webController.view];
//    [self addChildViewController:webController];
    [self showInternalWebView:@"subscriptions" title:@"In-App Purchase"];
}
-(UIView*) setupSBViewHalfScreen{
    arrBtnBuy = [NSMutableArray arrayWithCapacity:0];
    UIView *view = [[UIView alloc] init];
    UIView * center = [[UIView alloc] init];
    UIView * lastView;
    [view addSubview:center];
    [center mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view.mas_centerY);
        make.centerX.equalTo(view.mas_centerX);
        make.width.equalTo(@(1));
        make.height.equalTo(@(1));
    }];
    view.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    UIButton * btnClose = [[UIButton alloc] init];
    [btnClose setTitle:@"No Thanks!" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btnClose addTarget:self action:@selector(btnCloseSubClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnClose];
    [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX);
        make.right.equalTo(view.mas_right).offset(-10);
        make.bottom.equalTo(view.mas_bottom).offset(-30);
        make.left.equalTo(view.mas_left).offset(10);
        make.height.equalTo(@(30));
    }];
    
    UIView*  separatorView = [[UIButton alloc] init];
    separatorView.backgroundColor = [UIColor lightGrayColor];
    [view addSubview:separatorView];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX);
        make.right.equalTo(view.mas_right).offset(-8);
        make.bottom.equalTo(btnClose.mas_top).offset(-1);
        make.left.equalTo(view.mas_left).offset(8);
        make.height.equalTo(@(1));
    }];
    
    UIButton * btnInAppDetail = [[UIButton alloc] init];
    [btnInAppDetail setTitle:@"In-App Purchase Descriptions!" forState:UIControlStateNormal];
    [btnInAppDetail setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btnInAppDetail addTarget:self action:@selector(btnInAppDetailClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnInAppDetail];
    [btnInAppDetail mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX);
        make.right.equalTo(view.mas_right);
        make.bottom.equalTo(btnClose.mas_top);
        make.left.equalTo(view.mas_left);
        make.height.equalTo(@(50));
    }];
    
    int index = 0;
    UIButton* firstBtn;
    UIButton* lastBtn;
    UIButton* buyBtn = [[UIButton alloc]init];
    if(index<[[BuyTool sharedInstance] getSubsProducts].count)
    {
        SubscriptionData*data = [[BuyTool sharedInstance] getSubsProducts][index];
        if(![data.amountDisplay isEqualToString:@"(null) (null)"])
        {
            [view addSubview:buyBtn];
            buyBtn.tag=index;
            [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(center.mas_left).offset(2);
                make.right.equalTo(view.mas_right).offset(-8);
                make.bottom.equalTo(btnInAppDetail.mas_top);
                make.height.equalTo(@(50));
            }];
            buyBtn.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:70/255.0 alpha:1];
            NSLog(@"price = %@",data.amountDisplay);
            [buyBtn setTitle:[self getDisplayStringWithSubData:data] forState:UIControlStateNormal];
            [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            buyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
            [buyBtn addGestureRecognizer:tap];
            buyBtn.layer.cornerRadius = 10;
            firstBtn = buyBtn;
            lastBtn = buyBtn;
            [arrBtnBuy addObject:lastBtn];
        }
        index++;
    }
    if(index<[[BuyTool sharedInstance] getSubsProducts].count)
    {
        buyBtn = [[UIButton alloc]init];
        SubscriptionData*data = [[BuyTool sharedInstance] getSubsProducts][index];
        if(![data.amountDisplay isEqualToString:@"(null) (null)"])
        {
            [view addSubview:buyBtn];
            buyBtn.tag=index;
            [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(center.mas_left).offset(-5);
                make.left.equalTo(view.mas_left).offset(8);
                make.bottom.equalTo(btnInAppDetail.mas_top);
                make.height.equalTo(@(50));
            }];
            buyBtn.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:70/255.0 alpha:1];
            NSLog(@"price = %@",data.amountDisplay);
            [buyBtn setTitle:[self getDisplayStringWithSubData:data] forState:UIControlStateNormal];
            [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            buyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
            [buyBtn addGestureRecognizer:tap];
            buyBtn.layer.cornerRadius = 10;
            lastBtn = buyBtn;
            [arrBtnBuy addObject:lastBtn];
        }
        index++;
    }
    if(index<[[BuyTool sharedInstance] getSubsProducts].count)
    {
        buyBtn = [[UIButton alloc]init];
        SubscriptionData*data = [[BuyTool sharedInstance] getSubsProducts][index];
        if(![data.amountDisplay isEqualToString:@"(null) (null)"])
        {
            [view addSubview:buyBtn];
            buyBtn.tag=index;
            [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(center.mas_left).offset(2);
                make.right.equalTo(view.mas_right).offset(-8);
                make.bottom.equalTo(firstBtn.mas_top).offset(-5);
                make.height.equalTo(@(50));
            }];
            buyBtn.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:70/255.0 alpha:1];
            NSLog(@"price = %@",data.amountDisplay);
            [buyBtn setTitle:[self getDisplayStringWithSubData:data] forState:UIControlStateNormal];
            [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            buyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
            [buyBtn addGestureRecognizer:tap];
            buyBtn.layer.cornerRadius = 10;
            lastBtn = buyBtn;
            [arrBtnBuy addObject:lastBtn];
        }
        index++;
    }
    if(index<[[BuyTool sharedInstance] getSubsProducts].count)
    {
        buyBtn = [[UIButton alloc]init];
        SubscriptionData*data = [[BuyTool sharedInstance] getSubsProducts][index];
        if(![data.amountDisplay isEqualToString:@"(null) (null)"])
        {
            [view addSubview:buyBtn];
            buyBtn.tag=index;
            [buyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(center.mas_left).offset(-5);
                make.left.equalTo(view.mas_left).offset(8);
                make.bottom.equalTo(firstBtn.mas_top).offset(-5);
                make.height.equalTo(@(50));
            }];
            buyBtn.backgroundColor = [UIColor colorWithRed:107/255.0 green:185/255.0 blue:70/255.0 alpha:1];
            NSLog(@"price = %@",data.amountDisplay);
            [buyBtn setTitle:[self getDisplayStringWithSubData:data] forState:UIControlStateNormal];
            [buyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            buyBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(buyAction:)];
            [buyBtn addGestureRecognizer:tap];
            buyBtn.layer.cornerRadius = 10;
            lastBtn = buyBtn;
            [arrBtnBuy addObject:lastBtn];
        }
        index++;
    }
    UILabel* lblSelect = [[UILabel alloc] init];
    lblSelect.textAlignment = NSTextAlignmentCenter;
    lblSelect.text = @"Tap to choose Pricing Plan";
    [view addSubview:lblSelect];
    [lblSelect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastBtn.mas_top).offset(-5);
        make.left.equalTo(view.mas_left).offset(3);
        make.right.equalTo(view.mas_right).offset(-3);
        make.height.equalTo(@(30));
    }];
    
    NSArray* numFeatures = [BuyTool getCongfigInFile:@"appFeatures"];
    UIView* lastFeatureView = lblSelect;
    for(NSString* feature in numFeatures)
    {
        UIButton *scanBarCodeButton = [[UIButton alloc]init];
        [scanBarCodeButton setImage:[UIImage imageNamed:@"green_check.png"] forState:UIControlStateNormal];
        scanBarCodeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scanBarCodeButton setTitle:feature forState:UIControlStateNormal];
        [scanBarCodeButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [scanBarCodeButton setTitleColor:[UIColor colorWithRed:15.0/255 green:127.0/255 blue:18.0/255 alpha:1] forState:UIControlStateNormal];
        scanBarCodeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 0.0f);
        [scanBarCodeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [view addSubview:scanBarCodeButton];
        [scanBarCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(lastFeatureView.mas_top).offset(-5);
            make.centerX.equalTo(view.mas_centerX);
            make.height.equalTo(@(23));
            make.width.equalTo(@(240));
        }];
        lastFeatureView = scanBarCodeButton;
    }
    
    UILabel* lblSubName = [[UILabel alloc] init];
    lblSubName.textAlignment = NSTextAlignmentCenter;
    lblSubName.text = [BuyTool getCongfigInFile:@"subscriptionName"];;
    lblSubName.textColor = [UIColor redColor];
    lblSubName.font = [UIFont boldSystemFontOfSize:19];
    [view addSubview:lblSubName];
    [lblSubName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastFeatureView.mas_top).offset(-5);
        make.left.equalTo(view.mas_left).offset(3);
        make.right.equalTo(view.mas_right).offset(-3);
        make.height.equalTo(@(40));
    }];
    
    lastView = lblSubName;
    
    UIImageView * imgAppIcon = [[UIImageView alloc] init];
    imgAppIcon.image = [UIImage imageNamed:@"AppDetailIcon"];
    [view addSubview:imgAppIcon];
    [imgAppIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastView.mas_top).offset(-5);
        make.centerX.equalTo(view.mas_centerX);
        make.height.equalTo(@(70));
        make.width.equalTo(@(70));
    }];
    UIImageView * imgBg = [[UIImageView alloc] init];
//    imgAppIcon.image = [UIImage imageNamed:@"AppDetailIcon"];
    imgBg.backgroundColor = [UIColor whiteColor];
    imgBg.layer.cornerRadius = 10;
    imgBg.layer.borderColor = [UIColor redColor].CGColor;
    imgBg.layer.borderWidth = 1;
    [view addSubview:imgBg];
    [imgBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(imgAppIcon.mas_top).offset(-20);
        make.bottom.equalTo(view.mas_bottom).offset(-23);
        make.left.equalTo(view.mas_left).offset(3);
        make.right.equalTo(view.mas_right).offset(-3);
    }];
    [view sendSubviewToBack:imgBg];
    
    return view;
}
-(UIView*) setupSBViewLifeTime:(UIView*)mainView{
    mainView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    UIView *view = [[UIView alloc] init];
    [mainView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(mainView.mas_centerY);
        make.centerX.equalTo(mainView.mas_centerX);
        make.left.equalTo(mainView.mas_left).offset(3);
        make.right.equalTo(mainView.mas_right).offset(-3);
        make.height.equalTo(@(400));
    }];
//    view.backgroundColor = [UIColor greenColor];
    UIView * center = [[UIView alloc] init];
    UIView * lastView;
    [view addSubview:center];
    [center mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view.mas_centerY);
        make.centerX.equalTo(view.mas_centerX);
        make.width.equalTo(@(1));
        make.height.equalTo(@(1));
    }];
    UIButton * btnClose = [[UIButton alloc] init];
    [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnClose.backgroundColor = [UIColor redColor];
    btnClose.layer.cornerRadius = 5;
    [btnClose addTarget:self action:@selector(btnCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnClose];
    [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX);
        make.right.equalTo(center.mas_left).offset(-3);
        make.bottom.equalTo(view.mas_bottom).offset(-10);
        make.left.equalTo(view.mas_left).offset(10);
        make.height.equalTo(@(30));
    }];
    
    UIButton * btnBuy = [[UIButton alloc] init];
    [btnBuy setTitle:@"Buy" forState:UIControlStateNormal];
    [btnBuy setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnBuy.backgroundColor = [UIColor redColor];
    btnBuy.layer.cornerRadius = 5;
    [btnBuy addTarget:self action:@selector(btnBuyClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnBuy];
    [btnBuy mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX);
        make.left.equalTo(center.mas_right).offset(-3);
        make.bottom.equalTo(view.mas_bottom).offset(-10);
        make.right.equalTo(view.mas_right).offset(-10);
        make.height.equalTo(@(30));
    }];
    
    
    UILabel* lblPrice = [[UILabel alloc] init];
    lblPrice.textAlignment = NSTextAlignmentCenter;
    lblPrice.text = [NSString stringWithFormat:@"Only %@",[[BuyTool sharedInstance] getNonConsProducts].firstObject.amountDisplay];
    lblPrice.textColor = [UIColor orangeColor];
    [view addSubview:lblPrice];
    [lblPrice mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btnBuy.mas_top).offset(-5);
        make.left.equalTo(view.mas_left).offset(3);
        make.right.equalTo(view.mas_right).offset(-3);
        make.height.equalTo(@(30));
    }];
    
    NSArray* numFeatures = [BuyTool getCongfigInFile:@"appFeatures"];
    UIView* lastFeatureView = lblPrice;
    for(NSString* feature in numFeatures)
    {
        UIButton *scanBarCodeButton = [[UIButton alloc]init];
        [scanBarCodeButton setImage:[UIImage imageNamed:@"green_check.png"] forState:UIControlStateNormal];
        scanBarCodeButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scanBarCodeButton setTitle:feature forState:UIControlStateNormal];
        [scanBarCodeButton.titleLabel setFont:[UIFont systemFontOfSize:17]];
        [scanBarCodeButton setTitleColor:[UIColor colorWithRed:15.0/255 green:127.0/255 blue:18.0/255 alpha:1] forState:UIControlStateNormal];
        scanBarCodeButton.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 12.0f, 0.0f, 0.0f);
        [scanBarCodeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [view addSubview:scanBarCodeButton];
        [scanBarCodeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(lastFeatureView.mas_top).offset(-5);
            make.centerX.equalTo(view.mas_centerX);
            make.height.equalTo(@(23));
            make.width.equalTo(@(240));
        }];
        lastFeatureView = scanBarCodeButton;
    }
    
    UILabel* lblSubName = [[UILabel alloc] init];
    lblSubName.textAlignment = NSTextAlignmentCenter;
    lblSubName.text = [BuyTool sharedInstance].getNonConsProducts.firstObject.btnText;
    lblSubName.textColor = [UIColor redColor];
    lblSubName.font = [UIFont boldSystemFontOfSize:19];
    [view addSubview:lblSubName];
    [lblSubName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastFeatureView.mas_top).offset(-5);
        make.left.equalTo(view.mas_left).offset(3);
        make.right.equalTo(view.mas_right).offset(-3);
        make.height.equalTo(@(40));
    }];
    
    lastView = lblSubName;
    
    UIImageView * imgAppIcon = [[UIImageView alloc] init];
    imgAppIcon.image = [UIImage imageNamed:@"AppDetailIcon"];
    [view addSubview:imgAppIcon];
    [imgAppIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(lastView.mas_top).offset(-5);
        make.centerX.equalTo(view.mas_centerX);
        make.height.equalTo(@(70));
        make.width.equalTo(@(70));
    }];
    
    UILabel* lblTitleScreen = [[UILabel alloc] init];
    lblTitleScreen.textAlignment = NSTextAlignmentCenter;
    lblTitleScreen.text = @"Don't want to use Subscriptions? Try with One-Off Purchase";
    lblTitleScreen.textColor = [UIColor blackColor];
    lblTitleScreen.font = [UIFont systemFontOfSize:17];
    lblTitleScreen.numberOfLines = 0;
    [view addSubview:lblTitleScreen];
    [lblTitleScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(imgAppIcon.mas_top).offset(-5);
        make.left.equalTo(view.mas_left).offset(20);
        make.right.equalTo(view.mas_right).offset(-20);
        make.height.equalTo(@(60));
    }];
    
    UIImageView * imgBg = [[UIImageView alloc] init];
    //    imgAppIcon.image = [UIImage imageNamed:@"AppDetailIcon"];
    imgBg.backgroundColor = [UIColor whiteColor];
    imgBg.layer.cornerRadius = 10;
    imgBg.layer.borderColor = [UIColor redColor].CGColor;
    imgBg.layer.borderWidth = 1;
    [view addSubview:imgBg];
    [imgBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lblTitleScreen.mas_top).offset(-10);
        make.bottom.equalTo(view.mas_bottom).offset(0);
        make.left.equalTo(view.mas_left).offset(3);
        make.right.equalTo(view.mas_right).offset(-3);
    }];
    [view sendSubviewToBack:imgBg];
    
    return mainView;
}
- (void)showInternalWebView:(NSString*)url title:(NSString*)title
{
    UIView* mainView = [[UIView alloc] init];
    mainView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
    [self.view addSubview:mainView];
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view.mas_centerY);
        make.centerX.equalTo(self.view.mas_centerX);
        make.height.equalTo(self.view.mas_height);
        make.width.equalTo(self.view.mas_width);
    }];
    
    UIView *view = [[UIView alloc] init];
    view.layer.cornerRadius = 10;
    [mainView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(mainView.mas_centerY);
        make.centerX.equalTo(mainView.mas_centerX);
        make.left.equalTo(mainView.mas_left).offset(10);
        make.right.equalTo(mainView.mas_right).offset(-10);
        make.height.equalTo(@(600));
    }];
    view.backgroundColor = [UIColor grayColor];
    UIView * center = [[UIView alloc] init];
    UIView * lastView;
    [view addSubview:center];
    [center mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view.mas_centerY);
        make.centerX.equalTo(view.mas_centerX);
        make.width.equalTo(@(1));
        make.height.equalTo(@(1));
    }];
    UIButton * btnClose = [[UIButton alloc] init];
    [btnClose setTitle:@"Close" forState:UIControlStateNormal];
    [btnClose setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btnClose.backgroundColor = [UIColor redColor];
    btnClose.layer.cornerRadius = 5;
    [btnClose addTarget:self action:@selector(btnCloseWebClicked:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btnClose];
    [btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(view.mas_bottom).offset(-5);
        make.width.equalTo(@(160));
        make.height.equalTo(@(35));
    }];
    
    UILabel* lblTitleScreen = [[UILabel alloc] init];
    lblTitleScreen.textAlignment = NSTextAlignmentCenter;
    lblTitleScreen.text = title;
    lblTitleScreen.textColor = [UIColor whiteColor];
    lblTitleScreen.font = [UIFont systemFontOfSize:17];
    lblTitleScreen.numberOfLines = 0;
    [view addSubview:lblTitleScreen];
    [lblTitleScreen mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view.mas_top).offset(0);
        make.left.equalTo(view.mas_left).offset(20);
        make.right.equalTo(view.mas_right).offset(-20);
        make.height.equalTo(@(40));
    }];
    
    UIWebView * webView = [[UIWebView alloc] init];
    [view addSubview:webView];
    webView.delegate = self;
    [webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lblTitleScreen.mas_bottom).offset(5);
        make.bottom.equalTo(btnClose.mas_top).offset(-5);
        make.left.equalTo(view.mas_left);
        make.right.equalTo(view.mas_right);
    }];
    if([url containsString:@"http"])
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    else
    {
        NSString *htmlPath = [[NSBundle mainBundle] pathForResource:url ofType:@"html"];
        NSURL *htmlUrl = [NSURL fileURLWithPath:htmlPath];
        [webView loadRequest:[NSURLRequest requestWithURL:htmlUrl]];
    }
    _webView = mainView;
    
}
- (void)updatePrice
{
    if(arrBtnBuy.count==0)return;
    int i=0;
    for(SubscriptionData*data in [[BuyTool sharedInstance] getSubsProducts])
    {
        NSLog(@"i=%d,data = %@",i,data.amountDisplay);
        UIButton* button = arrBtnBuy[i];
        [self setupButtonPrice:button data:data];
        i++;
        if(i>=arrBtnBuy.count)break;
    }
}
- (void)setupButtonPrice:(UIButton*)button data:(SubscriptionData*)data
{
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [style setAlignment:NSTextAlignmentCenter];
    [style setLineBreakMode:NSLineBreakByWordWrapping];
    
    UIFont *font1 = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0f];
    UIFont *font2 = [UIFont fontWithName:@"HelveticaNeue-Light"  size:15.0f];
    NSDictionary *dict1 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font1,
                            NSParagraphStyleAttributeName:style}; // Added line
    NSDictionary *dict2 = @{NSUnderlineStyleAttributeName:@(NSUnderlineStyleNone),
                            NSFontAttributeName:font2,
                            NSParagraphStyleAttributeName:style}; // Added line
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] init];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:@""    attributes:dict1]];
    [attString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",[self getStringWithSubData:data],data.amountDisplay]      attributes:dict2]];
    button.titleLabel.numberOfLines = 0;
    [button setAttributedTitle:attString forState:UIControlStateNormal];
}
- (void)buyAction:(id)sender
{
    UITapGestureRecognizer* tap = sender;
    int tag = (int)[tap.view tag];
    SubscriptionData*data = [[BuyTool sharedInstance] getSubsProducts][tag];
    [[BuyTool sharedInstance] buyInShop:data controller:self];
}
- (void)buyNonConsAction:(id)sender
{
    SubscriptionData*data = [[BuyTool sharedInstance] getNonConsProducts].firstObject;
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
//    WebController *webController = [[WebController alloc] init];
//    webController.url = @"private";
//    webController.titleKey = @"Privacy Policy";
//    [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:webController animated:NO completion:nil];
    [self showInternalWebView:@"private" title:@"Privacy Policy"];
}
- (void)tosAction:(id)sender
{
//    WebController *webController = [[WebController alloc] init];
//    webController.url = @"subscriptions";
//    webController.titleKey = @"About Subscriptions";
//    [[[UIApplication sharedApplication].delegate window].rootViewController presentViewController:webController animated:NO completion:nil];
    [self showInternalWebView:@"subscriptions" title:@"In-App Purchase"];
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
        [str appendString:@"1 month (54% OFF)"];
    }
    else if(data.tenorMonth==3)
    {
        [str appendString:@"3 months (77% OFF)"];
    }
    else if(data.tenorMonth==12)
    {
        [str appendString:@"1 year (93% OFF)"];
    }
    else if(data.tenorMonth==0)
    {
        [str appendString:@"1 week"];
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
    else if(data.tenorMonth==3)
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
        [self btnCloseClicked:nil];
    }
    else
    {
        [[BuyTool sharedInstance] verifyReceipt:self after:^(NSInteger status) {
            if (status == 0) {
                if ([[UserData sharedInstance] isVip]){
                    [[[UIApplication sharedApplication].delegate window] setRootViewController:self.successCtrl];
                    [AlertTool showGoitTip:_successCtrl title:@"Thanks for purchasing." aftrt:nil];
                    [self btnCloseClicked:nil];
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
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"url=%@",request.URL.absoluteString);
    if([request.URL.absoluteString containsString:@"restorePurchase"])
    {
        [[BuyTool sharedInstance] restore:self ];
        return NO;
    }
    return YES;
}
@end
