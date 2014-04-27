//
//  PlayViewController.m
//  SalarymanSolitaire
//
//  Created by WU on 14-3-8.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "PlayViewController.h"
#import "SSPhysicalView.h"
#import "SSNutrientButton.h"


#define kSolitairePokerColours          4
#define kSolitairePokerCount            13
#define kSolitairePokerColumnMax        7

@interface PlayViewController ()
{

}

#pragma mark - UICollectionViewDelegate

@end

@implementation PlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)initView
{
    [super initView];
    
    // 背景音声音声再生
    [AudioEngine playAudioWith:SolitaireAudioIDPlayMusic];
    
    // 背景イメージビュー
    UIImage *tableImage = [UIImage imageNamed:@"bg_table.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:tableImage];
    [self.view insertSubview:imageView atIndex:0];
    imageView.translatesAutoresizingMaskIntoConstraints  = NO;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(imageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics: 0 views:viewsDictionary]];
    
    // ポーカービュー
    self.pokerView.backgroundColor = [UIColor clearColor];
}


- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)updateView
{
    [super updateView];
}

- (BOOL)shouldShowBannerAD
{
    return NO;
}

@end
