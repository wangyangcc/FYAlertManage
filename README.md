FYAlertManage
=============

use to display "UIAlertView" and "UIActionSheet” , that support iOS8 and iOS8 before

#### When you use "UIAlertView" and "UIActionSheet” in iOS8，screen direction changed lead to view show abnormal.

##### As you can see

> UIActionSheet ![](/pic/QQ20141028-1@2x.png)

> UIAlertView ![](/pic/QQ20141028-2@2x.png)

##### In iOS8 after，system provide a new class `UIAlertController` replace `UIAlertView` and `UIActionSheet`.

##### If you need support iOS8 before，you can use `FYAlertManage` to support iOS8 and iOS8 before.
---

It provides:
- ARC and no ARC support
- Arm64 support
- Display a `UIAlertView` and `UIActionSheet` in iOS8 and iOS8 before support

##### How To Use

----------

Display a `UIAlertView`

<pre><code>

    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" message:@"内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"第一个按钮",@"第一个按钮",nil];
    [alertMan show];
`#if ! __has_feature(objc_arc)
    [alertMan release];
`#endif
</pre></code>

Display a `UIAlertView` with Login And Password Input

<pre><code>
    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" message:@"请输入内容和密码" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alertMan.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
    alertMan.tag = 333;
    [alertMan show];
 #if ! __has_feature(objc_arc)
    [alertMan release];
 #endif
</pre></code>

Display a `UIActionSheet`

<pre><code>

    FYAlertManage *alertMan = [[FYAlertManage alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"特别提醒按钮" otherButtonTitles:@"第一个按钮",nil];
    [alertMan showInView:self.view];
 #if ! __has_feature(objc_arc)
    [alertMan release];
 #endif
</pre></code>

## Licenses
---
All source code is licensed under the [MIT License](https://github.com/wangyangcc/FYAlertManage).