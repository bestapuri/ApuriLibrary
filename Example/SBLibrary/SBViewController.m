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
@interface SBViewController ()

@end

@implementation SBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[BuyTool sharedInstance] initShop];
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
    [[BuyTool sharedInstance] showActiveSB2:self];
}

@end
