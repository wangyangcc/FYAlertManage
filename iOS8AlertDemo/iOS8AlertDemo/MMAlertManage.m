//
//  MMAlertManage.m
//  ExtensionDemo
//
//  Created by wangyangyang on 14/10/28.
//  Copyright (c) 2014年 wang yangyang. All rights reserved.
//

#import "MMAlertManage.h"
#import "NSObject+LogDealloc.h"
#import "objc/runtime.h"

#if ! __has_feature(objc_arc)
    #define MMAlertManageAutorelease(__v) ([__v autorelease]);
    #define MMAlertManageAutoreleased FMDBAutorelease

    #define MMAlertManageRetain(__v) ([__v retain]);
    #define MMAlertManageRetained FMDBRetain

    #define MMAlertManageRelease(__v) ([__v release]);

#else
    // -fobjc-arc
    #define MMAlertManageAutorelease(__v)
    #define MMAlertManageReturnAutoreleased(__v) (__v)

    #define MMAlertManageRetain(__v)
    #define MMAlertManageReturnRetained(__v) (__v)

    #define MMAlertManageRelease(__v)
#endif

#define MMIOS8After floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1

@interface MMAlertManage () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (nonatomic, retain) UIAlertView *showAlertView;
@property (nonatomic, retain) UIActionSheet *showActionSheet;

@end

static char MMAlertManageUIAlertViewKey;
static char MMAlertManageUIActionSheetKey;
static char MMAlertManageUIAlertControllerKey;
static char MMAlertManageKey;

@implementation MMAlertManage
@dynamic showActionSheet, showAlertView;

#pragma mark -
#pragma mark - 兼容 iOS8 之前使用UIAlertView

/**
 *   @brief 兼容 iOS8 之前使用UIAlertView
 **/

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<MMAlertManageDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super init];
    if (MMIOS8After) {
        UIAlertController *alertViewCon = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
#if ! __has_feature(objc_arc)
        __unsafe_unretained MMAlertManage *wself = self;
#else
        __weak MMAlertManage *wself = self;
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
            }]];
        }
        else {
            self.cancelButtonIndex = -1;
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
        
        objc_setAssociatedObject(self, &MMAlertManageUIAlertControllerKey, alertViewCon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(alertViewCon, &MMAlertManageKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        objc_setAssociatedObject(self, &MMAlertManageUIAlertViewKey, alertView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(alertView, &MMAlertManageKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        MMAlertManageAutorelease(alertView);
    }
    self.delegate = delegate;
    return self;
}

- (UIAlertView *)showAlertView
{
    if (MMIOS8After == NO) {
        UIAlertView *alertView = objc_getAssociatedObject(self, &MMAlertManageUIAlertViewKey);
        if (alertView) {
            return alertView;
        }
    }
    return nil;
}

- (void)show
{
    if (MMIOS8After) {
        UIAlertController *alertViewCon = objc_getAssociatedObject(self, &MMAlertManageUIAlertControllerKey);
        if (alertViewCon) {
            if ([self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
                [self.delegate willPresentAlertView:self];
            }
#if ! __has_feature(objc_arc)
            __unsafe_unretained MMAlertManage *wself = self;
#else
            __weak MMAlertManage *wself = self;
#endif
            [[self getCurrentCanDisplayVC] presentViewController:alertViewCon animated:YES completion:^{
                if ([wself.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
                    [wself.delegate didPresentAlertView:self];
                }
            }];
        }
    }
    else {
        UIAlertView *alertView = objc_getAssociatedObject(self, &MMAlertManageUIAlertViewKey);
        if (alertView) {
            self.cancelButtonIndex = alertView.cancelButtonIndex;
            [alertView show];
        }
    }
}

- (void)showAlertViewLeftAlignmentMessage:(NSString *)message
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 == NO) {
        UIAlertView *alertViewTemp = objc_getAssociatedObject(self, &MMAlertManageUIAlertViewKey);
        
        @try {
            //调整标题为左对齐
            NSArray *labelArray = [alertViewTemp subviews];
            UILabel *titlelabel = [labelArray objectAtIndex:1];
            titlelabel.lineBreakMode = NSLineBreakByWordWrapping;
            titlelabel.numberOfLines = 0;
            titlelabel.textAlignment = NSTextAlignmentLeft;
        }
        @catch (NSException *exception) {
            
        }

        [self show];
        return;
    }
    if (MMIOS8After) {
        UIAlertController *alertViewCon = objc_getAssociatedObject(self, &MMAlertManageUIAlertControllerKey);
        
        @try {
            //调整标题为左对齐
            NSArray *labelArray = [[[[[[[[[[[alertViewCon.view subviews] firstObject] subviews] lastObject] subviews] firstObject] subviews] firstObject] subviews] firstObject] subviews];
            UILabel *titlelabel = [labelArray objectAtIndex:1];
            titlelabel.lineBreakMode = NSLineBreakByWordWrapping;
            titlelabel.numberOfLines = 0;
            titlelabel.textAlignment = NSTextAlignmentLeft;
        }
        @catch (NSException *exception) {
            
        }
        [self show];
    }
    else {
        UIAlertView *alertViewTemp = objc_getAssociatedObject(self, &MMAlertManageUIAlertViewKey);

        //计算高度
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:message];
        NSRange allRange = NSMakeRange(0, message.length);
        [attrStr addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:15]
                        range:allRange];
        [attrStr addAttribute:NSForegroundColorAttributeName
                        value:[UIColor blackColor]
                        range:allRange];
        CGRect titleLabelRect = [attrStr boundingRectWithSize:CGSizeMake(230, 400) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
        CGSize size = CGSizeMake(titleLabelRect.size.width, titleLabelRect.size.height + 2);
        //end
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, -20, 230, size.height)];
        textLabel.font = [UIFont systemFontOfSize:15];
        textLabel.textColor = [UIColor blackColor];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        textLabel.numberOfLines = 0;
        textLabel.textAlignment = NSTextAlignmentLeft;
        textLabel.text = [NSString stringWithFormat:@" %@",message];
        [alertViewTemp setValue:textLabel forKey:@"accessoryView"];
        
        alertViewTemp.message = @"";
        [self show];
    }
}

- (void)setAlertViewStyle:(UIAlertViewStyle)alertViewStyle
{
    _alertViewStyle = alertViewStyle;
    if (MMIOS8After) {
        UIAlertController *alertViewCon = objc_getAssociatedObject(self, &MMAlertManageUIAlertControllerKey);
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
        UIAlertView *alertView = objc_getAssociatedObject(self, &MMAlertManageUIAlertViewKey);
        if (alertView) {
            alertView.alertViewStyle = alertViewStyle;
        }
    }
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex
{
    if (MMIOS8After) {
        UIAlertController *alertViewCon = objc_getAssociatedObject(self, &MMAlertManageUIAlertControllerKey);
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
        UIAlertView *alertView = objc_getAssociatedObject(self, &MMAlertManageUIAlertViewKey);
        if (alertView) {
            return [alertView textFieldAtIndex:textFieldIndex];
        }
    }
    return nil;
}

- (void)alertViewDealloc
{
    UIAlertView *alertViewTemp = objc_getAssociatedObject(self, &MMAlertManageUIAlertViewKey);
    if (alertViewTemp) {
        objc_setAssociatedObject(alertViewTemp, &MMAlertManageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &MMAlertManageUIAlertViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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

- (instancetype)initWithTitle:(NSString *)title delegate:(id<MMAlertManageDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [super init];
    if (MMIOS8After) {
        UIAlertController *alertViewCon = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
#if ! __has_feature(objc_arc)
        __unsafe_unretained MMAlertManage *wself = self;
#else
        __weak MMAlertManage *wself = self;
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
        
        objc_setAssociatedObject(self, &MMAlertManageUIAlertControllerKey, alertViewCon, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(alertViewCon, &MMAlertManageKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
        
        objc_setAssociatedObject(self, &MMAlertManageUIActionSheetKey, actionSheet, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(actionSheet, &MMAlertManageKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        MMAlertManageRelease(actionSheet);
    }
    self.delegate = delegate;
    return self;
}

- (UIActionSheet *)showActionSheet
{
    if (MMIOS8After == NO) {
        UIActionSheet *actionSheet = objc_getAssociatedObject(self, &MMAlertManageUIActionSheetKey);
        if (actionSheet) {
            return actionSheet;
        }
    }
    return nil;

}

- (void)showInView:(UIView *)view
{
    if (MMIOS8After) {
        UIAlertController *alertViewCon = objc_getAssociatedObject(self, &MMAlertManageUIAlertControllerKey);
        if (alertViewCon) {
            if ([self.delegate respondsToSelector:@selector(willPresentActionSheet:)]) {
                [self.delegate willPresentActionSheet:self];
            }
#if ! __has_feature(objc_arc)
            __unsafe_unretained MMAlertManage *wself = self;
#else
            __weak MMAlertManage *wself = self;
#endif
            [[self getCurrentCanDisplayVC] presentViewController:alertViewCon animated:YES completion:^{
                if ([wself.delegate respondsToSelector:@selector(didPresentActionSheet:)]) {
                    [wself.delegate didPresentActionSheet:self];
                }
            }];
        }
    }
    else {
        UIActionSheet *actionSheet = objc_getAssociatedObject(self, &MMAlertManageUIActionSheetKey);
        if (actionSheet) {
            self.cancelButtonIndex = actionSheet.cancelButtonIndex;
            if ([view isKindOfClass:[UITabBar class]]) {
                [actionSheet showFromTabBar:(UITabBar *)view];
            }
            else if ([view isKindOfClass:[UIToolbar class]]) {
                [actionSheet showFromToolbar:(UIToolbar *)view];
            }
            else {
                [actionSheet showInView:view];
            }
        }
    }
}

- (void)actionSheetDealloc
{
    UIActionSheet *actionSheet = objc_getAssociatedObject(self, &MMAlertManageUIActionSheetKey);
    if (actionSheet) {
        objc_setAssociatedObject(actionSheet, &MMAlertManageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &MMAlertManageUIActionSheetKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

/**
 *  得到当前显示出来的vc
 *
 *  @return vc
 */
- (UIViewController *)getCurrentCanDisplayVC
{
    UIViewController *rootViewController = [[UIApplication sharedApplication] keyWindow].rootViewController;
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        return [(UINavigationController *)rootViewController visibleViewController];
    }
    else if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedViewController = [(UITabBarController *)rootViewController selectedViewController];
        if ([selectedViewController isKindOfClass:[UINavigationController class]]) {
            return [(UINavigationController *)selectedViewController visibleViewController];
        }
        return [(UITabBarController *)rootViewController selectedViewController];
    }
    return rootViewController;
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

- (void)setAlertData:(id)alertData
{
    if (_alertData) {
        _alertData = nil;
    }
    _alertData = [alertData copy];
    //设置 iOS8 之前的数据
    if (MMIOS8After == NO) {
        
        UIActionSheet *actionSheet = objc_getAssociatedObject(self, &MMAlertManageUIActionSheetKey);
        if (actionSheet) {
            actionSheet.alertData = alertData;
        }
        
        UIAlertView *alertView = objc_getAssociatedObject(self, &MMAlertManageUIAlertViewKey);
        if (alertView) {
            alertView.alertData = alertData;
        }
    }
}

- (void)alertControllerDealloc
{
    UIAlertController *alertCon = objc_getAssociatedObject(self, &MMAlertManageUIAlertControllerKey);
    if (alertCon) {
        objc_setAssociatedObject(alertCon, &MMAlertManageKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        objc_setAssociatedObject(self, &MMAlertManageUIAlertControllerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end

/**
 *  给 alertView 添加 alertData 支持
 */
static void *kAlertViewAlertDataKey = &kAlertViewAlertDataKey;
@implementation UIAlertView (alertData)

- (id)alertData
{
    return objc_getAssociatedObject(self, kAlertViewAlertDataKey);
}

- (void)setAlertData:(id)alertData
{
    objc_setAssociatedObject(self, kAlertViewAlertDataKey, alertData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end

/**
 *  给 UIActionSheet 添加 alertData 支持
 */
static void *kActionSheetAlertDataKey = &kActionSheetAlertDataKey;
@implementation UIActionSheet (alertData)

- (id)alertData
{
    return objc_getAssociatedObject(self, kActionSheetAlertDataKey);
}

- (void)setAlertData:(id)alertData
{
    objc_setAssociatedObject(self, kActionSheetAlertDataKey, alertData, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
