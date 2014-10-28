//
//  FYAlertManage.m
//  ExtensionDemo
//
//  Created by wangyangyang on 14/10/28.
//  Copyright (c) 2014年 wang yangyang. All rights reserved.
//

#import "FYAlertManage.h"
#import "NSObject+LogDealloc.h"
#import "objc/runtime.h"

#if ! __has_feature(objc_arc)
    #define FYAlertManageAutorelease(__v) ([__v autorelease]);
    #define FYAlertManageAutoreleased FMDBAutorelease

    #define FYAlertManageRetain(__v) ([__v retain]);
    #define FYAlertManageRetained FMDBRetain

    #define FYAlertManageRelease(__v) ([__v release]);

#else
    // -fobjc-arc
    #define FYAlertManageAutorelease(__v)
    #define FYAlertManageReturnAutoreleased(__v) (__v)

    #define FYAlertManageRetain(__v)
    #define FYAlertManageReturnRetained(__v) (__v)

    #define FYAlertManageRelease(__v)
#endif

#define FYIOS8After floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1

@interface FYAlertManage () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) UIAlertView *showAlertView;
@property (nonatomic, retain) UIActionSheet *showActionSheet;

@end

static char FYAlertManageUIAlertViewKey;
static char FYAlertManageUIActionSheetKey;
static char FYAlertManageUIAlertControllerKey;
static char FYAlertManageKey;

@implementation FYAlertManage
@dynamic showActionSheet, showAlertView;

#pragma mark -
#pragma mark - 兼容 iOS8 之前使用UIAlertView

/**
 *   @brief 兼容 iOS8 之前使用UIAlertView
 **/

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<FYAlertManageDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super init];
    if (FYIOS8After) {
        UIAlertController *alertViewCon = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        [alertViewCon logOnDealloc];
#if ! __has_feature(objc_arc)
        __unsafe_unretained FYAlertManage *wself = self;
#else
        __weak FYAlertManage *wself = self;
#endif
        
        if (cancelButtonTitle) {
            [alertViewCon addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                if ([wself.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
                    [wself.delegate alertView:self clickedButtonAtIndex:0];
                }
                if ([wself.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
                    [wself.delegate alertView:self didDismissWithButtonIndex:0];
                }
                [wself alertControllerDealloc];
                self.cancelButtonIndex = 0;
            }]];
        }
        
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
        {
            NSInteger actionNum = [alertViewCon actions].count;
            [alertViewCon addAction:[UIAlertAction actionWithTitle:arg style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([wself.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
                    [wself.delegate alertView:self clickedButtonAtIndex:actionNum];
                }
                if ([wself.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
                    [wself.delegate alertView:self didDismissWithButtonIndex:actionNum];
                }
                [wself alertControllerDealloc];
            }]];
        }
        va_end(args);
        
        objc_setAssociatedObject(self, &FYAlertManageUIAlertControllerKey, alertViewCon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(alertViewCon, &FYAlertManageKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *buttonTitle = otherButtonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString*)) {
            [alertView addButtonWithTitle:buttonTitle];
        }
        va_end(args);
        
        alertView.delegate = self;
        [alertView logOnDealloc];
        objc_setAssociatedObject(self, &FYAlertManageUIAlertViewKey, alertView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(alertView, &FYAlertManageKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        FYAlertManageAutorelease(alertView);
    }
    self.delegate = delegate;
    [self logOnDealloc];
    return self;
}

- (UIAlertView *)showAlertView
{
    if (FYIOS8After == NO) {
        UIAlertView *alertView = objc_getAssociatedObject(self, &FYAlertManageUIAlertViewKey);
        if (alertView) {
            return alertView;
        }
    }
    return nil;
}

- (void)show
{
    if (FYIOS8After) {
        UIAlertController *alertViewCon = objc_getAssociatedObject(self, &FYAlertManageUIAlertControllerKey);
        if (alertViewCon) {
            if ([self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
                [self.delegate willPresentAlertView:self];
            }
#if ! __has_feature(objc_arc)
            __unsafe_unretained FYAlertManage *wself = self;
#else
            __weak FYAlertManage *wself = self;
#endif
            [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertViewCon animated:YES completion:^{
                if ([wself.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
                    [wself.delegate didPresentAlertView:self];
                }
            }];
        }
    }
    else {
        UIAlertView *alertView = objc_getAssociatedObject(self, &FYAlertManageUIAlertViewKey);
        if (alertView) {
            self.cancelButtonIndex = alertView.cancelButtonIndex;
            [alertView show];
        }
    }
}

- (void)setAlertViewStyle:(UIAlertViewStyle)alertViewStyle
{
    _alertViewStyle = alertViewStyle;
    if (FYIOS8After) {
        UIAlertController *alertViewCon = objc_getAssociatedObject(self, &FYAlertManageUIAlertControllerKey);
        if (alertViewCon == nil) {
            return;
        }
        switch (alertViewStyle) {
            case UIAlertViewStyleSecureTextInput:{
                [alertViewCon addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    [textField setSecureTextEntry:YES];
                }];
                break;
            }
            case UIAlertViewStylePlainTextInput:{
                [alertViewCon addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    
                }];
                break;
            }
            case UIAlertViewStyleLoginAndPasswordInput:{
                [alertViewCon addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    
                }];
                [alertViewCon addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    [textField setSecureTextEntry:YES];
                }];
                break;
            }
            default:
                break;
        }
    }
    else
    {
        UIAlertView *alertView = objc_getAssociatedObject(self, &FYAlertManageUIAlertViewKey);
        if (alertView) {
            alertView.alertViewStyle = alertViewStyle;
        }
    }
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
    if (FYIOS8After) {
        UIAlertController *alertViewCon = objc_getAssociatedObject(self, &FYAlertManageUIAlertControllerKey);
        if (alertViewCon) {
            if (textFieldIndex < 0) {
                textFieldIndex = 0;
            }
            if (textFieldIndex >= alertViewCon.textFields.count) {
                return nil;
            }
            return alertViewCon.textFields[textFieldIndex];
        }
        return nil;
    }
    else {
        UIAlertView *alertView = objc_getAssociatedObject(self, &FYAlertManageUIAlertViewKey);
        if (alertView) {
            return [alertView textFieldAtIndex:textFieldIndex];
        }
    }
    return nil;
}

- (void)alertViewDealloc
{
    UIAlertView *alertViewTemp = objc_getAssociatedObject(self, &FYAlertManageUIAlertViewKey);
    if (alertViewTemp) {
        objc_setAssociatedObject(alertViewTemp, &FYAlertManageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &FYAlertManageUIAlertViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:alertView clickedButtonAtIndex:buttonIndex];
    }
}


- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if ([self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.delegate willPresentAlertView:alertView];
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if ([self.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [self.delegate didPresentAlertView:alertView];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
        [self.delegate alertView:alertView didDismissWithButtonIndex:buttonIndex];
    }
    [self alertViewDealloc];
}

#pragma mark -
#pragma mark - 兼容 iOS8 之前使用UIActionSheet

/**
 *   @brief 兼容 iOS8 之前使用UIActionSheet
 **/

- (instancetype)initWithTitle:(NSString *)title delegate:(id<FYAlertManageDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super init];
    if (FYIOS8After) {
        UIAlertController *alertViewCon = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertViewCon logOnDealloc];
        
#if ! __has_feature(objc_arc)
        __unsafe_unretained FYAlertManage *wself = self;
#else
        __weak FYAlertManage *wself = self;
#endif

        __block NSInteger beginNumber = 0;
        if (destructiveButtonTitle) {
            [alertViewCon addAction:[UIAlertAction actionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                if ([wself.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
                    [wself.delegate actionSheet:self clickedButtonAtIndex:beginNumber];
                }
                if ([wself.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
                    [wself.delegate actionSheet:self didDismissWithButtonIndex:beginNumber];
                }
                beginNumber ++;
                [wself alertControllerDealloc];
            }]];
        }

        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
        {
            NSInteger actionNum = [alertViewCon actions].count;
            [alertViewCon addAction:[UIAlertAction actionWithTitle:arg style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                if ([wself.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
                    [wself.delegate actionSheet:self clickedButtonAtIndex:actionNum];
                }
                if ([wself.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
                    [wself.delegate actionSheet:self didDismissWithButtonIndex:actionNum];
                }
                [wself alertControllerDealloc];
            }]];
        }
        va_end(args);
        
        if (cancelButtonTitle) {
            NSInteger actionNum = [alertViewCon actions].count;
            self.cancelButtonIndex = actionNum;
            [alertViewCon addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                if ([wself.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
                    [wself.delegate actionSheet:self clickedButtonAtIndex:actionNum];
                }
                if ([wself.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
                    [wself.delegate actionSheet:self didDismissWithButtonIndex:actionNum];
                }
                [wself alertControllerDealloc];
            }]];
        }
        
        objc_setAssociatedObject(self, &FYAlertManageUIAlertControllerKey, alertViewCon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(alertViewCon, &FYAlertManageKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
        
        NSInteger cancelButtonNum = 0;
        if (destructiveButtonTitle) {
            cancelButtonNum ++;
        }
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString *buttonTitle = otherButtonTitles; buttonTitle != nil; buttonTitle = va_arg(args, NSString*)) {
            [actionSheet addButtonWithTitle:buttonTitle];
            cancelButtonNum ++;
        }
        va_end(args);
        
        if (cancelButtonTitle) {
            [actionSheet addButtonWithTitle:cancelButtonTitle];
            [actionSheet setCancelButtonIndex:cancelButtonNum];
        }
        
        [actionSheet logOnDealloc];
        objc_setAssociatedObject(self, &FYAlertManageUIActionSheetKey, actionSheet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(actionSheet, &FYAlertManageKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        FYAlertManageRelease(actionSheet);
    }
    self.delegate = delegate;
    [self logOnDealloc];
    return self;
}

- (UIActionSheet *)showActionSheet
{
    if (FYIOS8After == NO) {
        UIActionSheet *actionSheet = objc_getAssociatedObject(self, &FYAlertManageUIActionSheetKey);
        if (actionSheet) {
            return actionSheet;
        }
    }
    return nil;

}

- (void)showInView:(UIView *)view
{
    if (FYIOS8After) {
        UIAlertController *alertViewCon = objc_getAssociatedObject(self, &FYAlertManageUIAlertControllerKey);
        if (alertViewCon) {
            if ([self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
                [self.delegate willPresentActionSheet:self];
            }
#if ! __has_feature(objc_arc)
            __unsafe_unretained FYAlertManage *wself = self;
#else
            __weak FYAlertManage *wself = self;
#endif
            [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:alertViewCon animated:YES completion:^{
                if ([wself.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
                    [wself.delegate didPresentActionSheet:self];
                }
            }];
        }
    }
    else {
        UIActionSheet *actionSheet = objc_getAssociatedObject(self, &FYAlertManageUIActionSheetKey);
        if (actionSheet) {
            self.cancelButtonIndex = actionSheet.cancelButtonIndex;
            [actionSheet showInView:view];
        }
    }
}

- (void)actionSheetDealloc
{
    UIActionSheet *actionSheet = objc_getAssociatedObject(self, &FYAlertManageUIActionSheetKey);
    if (actionSheet) {
        objc_setAssociatedObject(actionSheet, &FYAlertManageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &FYAlertManageUIActionSheetKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([self.delegate respondsToSelector:@selector(actionSheet:clickedButtonAtIndex:)]) {
        [self.delegate actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if ([self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
        [self.delegate willPresentActionSheet:actionSheet];
    }
}

- (void)didPresentActionSheet:(UIActionSheet *)actionSheet
{
    if ([self.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
        [self.delegate didPresentActionSheet:actionSheet];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if ([self.delegate respondsToSelector:@selector(actionSheet:didDismissWithButtonIndex:)]) {
        [self.delegate actionSheet:actionSheet didDismissWithButtonIndex:buttonIndex];
    }
    [self actionSheetDealloc];
}

#pragma mark -
#pragma mark - 兼容 iOS8 之前使用 UIAlertView 和 UIActionSheet 的通用属性

/**
 *   @brief 兼容 iOS8 之前使用 UIAlertView 和 UIActionSheet 的通用属性
 **/

- (void)setTag:(NSInteger)tag
{
    _tag = tag;
    if ([self showAlertView]) {
        self.showAlertView.tag = self.tag;
    }
    else if ([self showActionSheet]) {
        self.showActionSheet.tag = self.tag;
    }
}

- (void)alertControllerDealloc
{
    UIAlertController *alertCon = objc_getAssociatedObject(self, &FYAlertManageUIAlertControllerKey);
    if (alertCon) {
        objc_setAssociatedObject(alertCon, &FYAlertManageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &FYAlertManageUIAlertControllerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
