//
//  MoreTableViewController.m
//  Soil
//
//  Created by Mike on 20/09/2017.
//  Copyright © 2017 Mike. All rights reserved.
//

#import "MoreTableViewController.h"
@import GoogleMobileAds;
#import "AppDelegate.h"
#import "KeywordEntity+CoreDataClass.h"
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>
#import "GADBannerView+LoadAction.h"

@interface MoreTableViewController ()<MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet GADBannerView *bannerView;

@end

@implementation MoreTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.bannerView loadADWithRootViewController:self];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0 && indexPath.row==0) {
        [self deleteAllHistory];
        [self showAlertControllerWithMessage:@"已经清除搜索历史"];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section==1) {
        if ([MFMailComposeViewController canSendMail]) {
            [self sendMail];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    } else if (indexPath.section==2) {
        if (indexPath.row==3) {
            [self jumpToAppStore];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else if (indexPath.row==2) {
            [self showActivityController];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)deleteAllHistory {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSManagedObjectContext *viewContext = delegate.persistentContainer.viewContext;
    NSFetchRequest *request = [KeywordEntity fetchRequest];
    NSArray<KeywordEntity *> *results = [viewContext executeFetchRequest:request error:nil];
    [results enumerateObjectsUsingBlock:^(KeywordEntity * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [viewContext deleteObject:obj];
    }];
    [delegate saveContext];
}

- (void)sendMail {
    // 创建邮件发送界面
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置收件人
    [mailCompose setToRecipients:@[@"qwe123#$%@163.com"]];
    // 设置抄送人
//    [mailCompose setCcRecipients:@[@"1622849369@qq.com"]];
    // 设置密送人
//    [mailCompose setBccRecipients:@[@"15690725786@163.com"]];
    // 设置邮件主题
    [mailCompose setSubject:@"意见反馈"];
    //设置邮件的正文内容
    NSString *emailContent = @"";
    // 是否为HTML格式
    [mailCompose setMessageBody:emailContent isHTML:NO];
    // 如使用HTML格式，则为以下代码
    // [mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
    //添加附件
//    UIImage *image = [UIImage imageNamed:@"qq"];
//    NSData *imageData = UIImagePNGRepresentation(image);
//    [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"qq.png"];
//    NSString *file = [[NSBundle mainBundle] pathForResource:@"EmptyPDF" ofType:@"pdf"];
//    NSData *pdf = [NSData dataWithContentsOfFile:file];
//    [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"EmptyPDF.pdf"];
    // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate的代理方法：
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    NSString *message = nil;
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled: 用户取消编辑");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: 用户保存邮件");
            message = @"已保存邮件";
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent: 用户点击发送");
            message = @"已发送邮件";
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@ : 用户尝试保存或发送邮件失败", [error localizedDescription]);
            message = @"尝试保存或者发送邮件失败";
            break;
    }
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:^{
        if (result==MFMailComposeResultSent || result==MFMailComposeResultSaved || result==MFMailComposeResultFailed) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"反馈作者" message:message preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
            [alertController addAction:action];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }];
}

#pragma mark -

- (void)dismissAlertController:(UIAlertController *)alertController {
    [alertController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showAlertControllerWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:alertController animated:YES completion:^{
        [self performSelector:@selector(dismissAlertController:) withObject:alertController afterDelay:1];
    }];
}

#pragma mark -

- (void)jumpToAppStore {
    UIApplication *app = [UIApplication sharedApplication];
    NSString *appID = @"1287143610";
    NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", appID];
    NSURL *url = [NSURL URLWithString:urlString];
    if ([app canOpenURL:url]) {
        [app openURL:url];
    } else {
        [self showAlertControllerWithMessage:@"打开 App Store 失败"];
    }

}

#pragma mark -

- (void)showActivityController {
    NSString *appID = @"1287143610";
    NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@?action=write-review", appID];
    NSArray *activityItems = @[urlString];
    NSArray *applicationActivities = @[];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    [self presentViewController:activityController animated:YES completion:nil];
}


@end
