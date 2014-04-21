//
//  PopupNotificationView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-4-20.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "PopupNotificationView.h"

@interface PopupNotificationView ()
{
        NSURL                               *_URL;
}

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation PopupNotificationView

// お知らせ表示
- (id)initWithURL:(NSURL *)URL;
{
    self = [self initPopupViewWithNibName:@"PopupNotificationView"];
    if (self) {
        _URL = URL;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // お知らせ表示
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    [_webView loadRequest:[NSURLRequest requestWithURL:_URL]];
}
@end
