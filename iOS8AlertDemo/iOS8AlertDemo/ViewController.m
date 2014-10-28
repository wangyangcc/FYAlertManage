//
//  ViewController.m
//  iOS8AlertDemo
//
//  Created by wangyangyang on 14/10/28.
//  Copyright (c) 2014年 wang yangyang. All rights reserved.
//

#import "ViewController.h"
#import "FYAlertManage.h"

@interface ViewController () <FYAlertManageDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)normalAlertView:(id)sender
{
    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" message:@"内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    [alertMan show];
#if ! __has_feature(objc_arc)
    [alertMan release];
#endif
}

- (IBAction)normalMoreButtonAlertView:(id)sender
{
    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" message:@"内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"第一个按钮",@"第一个按钮",nil];
    [alertMan show];
#if ! __has_feature(objc_arc)
    [alertMan release];
#endif
}

- (IBAction)normalTextAlertView:(id)sender
{
    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" message:@"请输入内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alertMan.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertMan show];
    alertMan.tag = 111;
#if ! __has_feature(objc_arc)
    [alertMan release];
#endif
}

- (IBAction)normalPwAlertView:(id)sender
{
    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" message:@"请输入密码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alertMan.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alertMan.tag = 222;
    [alertMan show];
#if ! __has_feature(objc_arc)
    [alertMan release];
#endif
}

- (IBAction)textInAlertView:(id)sender
{
    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" message:@"请输入内容和密码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alertMan.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alertMan.tag = 333;
    [alertMan show];
#if ! __has_feature(objc_arc)
    [alertMan release];
#endif
}


- (IBAction)normalActionSheet:(id)sender
{
    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"第一个按钮",@"第二个按钮",nil];
    [alertMan showInView:self.view];
#if ! __has_feature(objc_arc)
    [alertMan release];
#endif
}

- (IBAction)destructiveActionSheet:(id)sender
{
    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"特别提醒按钮" otherButtonTitles:@"第一个按钮",nil];
    [alertMan showInView:self.view];
#if ! __has_feature(objc_arc)
    [alertMan release];
#endif
}

#pragma mark - FYAlertManageDelegate

- (void)alertView:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView---clickedButtonAtIndex-----%@",@(buttonIndex));
    if ((NSInteger)[alertView tag] > 0) {
        UITextField *field = [alertView textFieldAtIndex:0];
        if (field) {
            NSLog(@"alertView---输入的第一个字段是-----%@",[field text]);
        }
    }
    
    if ((NSInteger)[alertView tag] > 222) {
        UITextField *fieldTwo = [alertView textFieldAtIndex:1];
        if (fieldTwo) {
            NSLog(@"alertView---输入的第二个字段是-----%@",[fieldTwo text]);
        }
    }
}

- (void)willPresentAlertView:(id)alertView
{
    NSLog(@"alertView---willPresentAlertView-----");
}

- (void)didPresentAlertView:(id)alertView
{
    NSLog(@"alertView---didPresentAlertView-----");
}

- (void)alertView:(id)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"alertView---didDismissWithButtonIndex-----%@",@(buttonIndex));
}

- (void)actionSheet:(id)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet---clickedButtonAtIndex-----%@",@(buttonIndex));
}

- (void)willPresentActionSheet:(id)actionSheet
{
    NSLog(@"alertView---willPresentActionSheet-----");
}

- (void)didPresentActionSheet:(id)actionSheet
{
    NSLog(@"alertView---didPresentActionSheet-----");
}

- (void)actionSheet:(id)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionSheet---didDismissWithButtonIndex-----%@",@(buttonIndex));
}

@end
