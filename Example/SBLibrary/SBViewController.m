//
//  SBViewController.m
//  SBLibrary
//
//  Created by NguyenTran on 08/24/2017.
//  Copyright (c) 2017 NguyenTran. All rights reserved.
//

#import "SBViewController.h"
#import <SBLibraryV2/BuyTool.h>
#import <SBLibraryV2/UserData.h>
#import "SBAppDelegate.h"
@interface SBViewController ()

@end

@implementation SBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[BuyTool sharedInstance] initShop];
    [[BuyTool sharedInstance] queryAllProducts:self after:^{
        //do nothing
    }];

    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnTestClicked:(id)sender {
    UIViewController* ctrl = ((SBAppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController;
    __block UIViewController* returnCtrl = [[BuyTool sharedInstance] showActiveSB2:ctrl completion:^{
        [returnCtrl removeFromParentViewController];
        [returnCtrl.view removeFromSuperview];
        returnCtrl = nil;
    }];
}
- (IBAction)btn2Clicked:(id)sender {
    UIViewController* ctrl = ((SBAppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController;
    __block UIViewController* returnCtrl = [[BuyTool sharedInstance] showInternalWebView:ctrl url:@"subscriptions" title:@"btn2" completion:^{
        [returnCtrl removeFromParentViewController];
        [returnCtrl.view removeFromSuperview];
        returnCtrl = nil;
    }];
}
- (IBAction)btn3Clicked:(id)sender {
    UIViewController* ctrl = ((SBAppDelegate*)([UIApplication sharedApplication].delegate)).window.rootViewController;
    __block UIViewController* returnCtrl = [[BuyTool sharedInstance] showInternalWebView:ctrl url:@"private" title:@"btn3" completion:^{
        [returnCtrl removeFromParentViewController];
        [returnCtrl.view removeFromSuperview];
        returnCtrl = nil;
    }];
}
- (IBAction)btn4Clicked:(id)sender {
//    [[BuyTool sharedInstance] restore:self];
    [[BuyTool sharedInstance] activeSB:self];
}

@end
