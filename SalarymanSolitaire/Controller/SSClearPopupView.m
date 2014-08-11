//
//  SSClearPopupView.m
//  SalarymanSolitaire
//
//  Created by IfelseGo on 14-3-29.
//  Copyright (c) 2014年 IfelseGo.Inc. All rights reserved.
//

#import "SSClearPopupView.h"
#import "SharingMessage.h"
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>

@interface SSClearPopupView ()<MFMailComposeViewControllerDelegate>
{
    // 共用メッセージ
    SharingMessage                      *_sharingMessage;
    UIWindow *_alertWindow;
    NSString *_stageName;
}

// ステージタイトル
@property (nonatomic, weak) IBOutlet UILabel *stageLabel;

// 共用メッセージ取得
- (SharingMessage *)sharingMessage;

// ボタン「次へ」押下した処理
- (IBAction)nextStageAction:(id)sender;

// ボタン「Mail共有」押下した処理
- (IBAction)shareByMailAction:(id)sender;

// ボタン「facebook次へ共有」押下した処理
- (IBAction)shareByFacebookAction:(id)sender;

// ボタン「twitter共有」押下した処理
- (IBAction)shareByTritterAction:(id)sender;

// ボタン「新作アプリ」押下した処理
- (IBAction)newAppAction:(id)sender;

@end

@implementation SSClearPopupView
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.top = 90.0f;
    }
    return self;
}

- (void)setStageTitle:(NSString *)stageName
{
    _stageName = stageName;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.stageLabel setText:_stageName];
}

// 共用メッセージ取得
- (SharingMessage *)sharingMessage;
{
    if (!_sharingMessage) {
        _sharingMessage = [[SharingMessage alloc] init];
    }
    return _sharingMessage;
}

// ボタン「次へ」押下した処理
- (IBAction)nextStageAction:(id)sender;
{
    if ([self.delegate respondsToSelector:@selector(nextStageButtonDidTaped)]) {
        [self.delegate nextStageButtonDidTaped];
    }
    [self dismiss];
}

// ボタン「Mail共有」押下した処理
- (IBAction)shareByMailAction:(id)sender;
{
    // 共有方式を「メール」で設定する
    SharingMessage *sharingMessage = [self sharingMessage];
    sharingMessage.sharingType = SharingTypeMail;
    
    // メール送信画面表示
    [self sendMail];
}

// ボタン「facebook次へ共有」押下した処理
- (IBAction)shareByFacebookAction:(id)sender;
{
    // 共有方式を「facebook」で設定する
    SharingMessage *sharingMessage = [self sharingMessage];
    sharingMessage.sharingType = SharingTypeFacebook;
    
    // Facebook送信画面表示
    [self sendFacebook];
}

// ボタン「twitter共有」押下した処理
- (IBAction)shareByTritterAction:(id)sender;
{
    // 共有方式を「twitter」で設定する
    SharingMessage *sharingMessage = [self sharingMessage];
    sharingMessage.sharingType = SharingTypeTwitter;
    
    // Twitter送信画面表示
    [self sendTwitter];
}

// ボタン「新作アプリ」押下した処理
- (IBAction)newAppAction:(id)sender;
{
    //TODO:広告画面表示
    if ([self.delegate respondsToSelector:@selector(newAppShow)]) {
        [self.delegate newAppShow];
    }
    [self dismiss];
}

#pragma mark - メール共有
- (void)sendMail
{
    // メール送信可否チェック
    if (![MFMailComposeViewController canSendMail]) {
        DebugLog(@"送信不可");
    }
    
    // 送信画面作成
    SharingMessage *sharingMessage = [self sharingMessage];
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    
    // メール標題設定
    [mailController setSubject:[sharingMessage title]];

    // メッセージ設定
    NSString *emailBody = [sharingMessage message];
    [mailController setMessageBody:emailBody isHTML:NO];
    [self presentViewController:mailController animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error __OSX_AVAILABLE_STARTING(__MAC_NA,__IPHONE_3_0);
{
    // メール送信画面を閉じる
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // エラーメッセージ表示
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    DebugLog(@"%@", msg);
}

- (void)sendTwitter
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)sendFacebook
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [self presentViewController:controller animated:YES completion:nil];

}
@end
