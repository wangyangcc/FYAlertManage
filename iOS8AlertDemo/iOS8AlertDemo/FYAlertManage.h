//
//  FYAlertManage.h
//  ExtensionDemo
//
//  Created by wangyangyang on 14/10/28.
//  Copyright (c) 2014年 wang yangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FYAlertManageDelegate;

@interface FYAlertManage : NSObject

/**
 *   @brief 兼容 iOS8 之前使用UIAlertView
 **/

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<FYAlertManageDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)show;

@property(nonatomic,assign) UIAlertViewStyle alertViewStyle;
- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

/**
 *   @brief 兼容 iOS8 之前使用UIActionSheet
 **/

- (instancetype)initWithTitle:(NSString *)title delegate:(id<FYAlertManageDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... NS_REQUIRES_NIL_TERMINATION;

- (void)showInView:(UIView *)view;

/**
 *   @brief 兼容 iOS8 之前使用 UIAlertView 和 UIActionSheet 的通用属性
 **/

@property(nonatomic,assign) id<FYAlertManageDelegate> delegate;
@property(nonatomic) NSInteger cancelButtonIndex;
@property(nonatomic)        NSInteger tag;                // default is 0

@end

@protocol FYAlertManageDelegate <NSObject>

@optional

//除了下面指定的代理方法外，别的代理方法在 iOS8 之后不会被调用，并且iOS8后第一个传值对象都为FYAlertManage 类型,iOS8之前为对应的 UIAlertView 或者 UIActionSheet

#pragma mark for UIAlertView Delegate

- (void)alertView:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)willPresentAlertView:(id)alertView;
- (void)didPresentAlertView:(id)alertView;

- (void)alertView:(id)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;

#pragma mark for UIActionSheet Delegate

- (void)actionSheet:(id)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)willPresentActionSheet:(id)actionSheet;
- (void)didPresentActionSheet:(id)actionSheet;

- (void)actionSheet:(id)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;

@end
