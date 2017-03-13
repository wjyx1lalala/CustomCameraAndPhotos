# ZYSuspensionView
* 开发阶段可用于测试功能
* 每个界面都可以使用

 ![image](https://raw.githubusercontent.com/ripperhe/ZYSuspensionView/master/image/look.png)

公司工程里所集成的测试控件[Bugtags](https://www.bugtags.com/)就是利用UIWindow实现的，可以悬浮在任意页面，主要用于测试人员提bug，直接手机上提bug。

对于这个可拉拽的悬浮球，我也比较好奇，所以自己着手实现了一下，原理也挺简单。

> 1.创建一个按钮大小的window并显示		
> 2.将其windowLevel设置得较高		
> 3.在按钮上添加拖拽手势，随着手势移动，并添加一些边界控制

那就有人问了，这个东西有什么用？

因为公司的工程里确实没有什么需要需要用到这个东西，但是我后来发现这个东西还是有那么一点用😁。不过不是用在正式代码之中，而是开发测试阶段。

1.做个一键登陆功能（公司的项目开发需要频繁换号，输密码太麻烦）
> 如果不用换账号，直接写死一个账号，点击悬浮球直接登录
> 
> 如果需要频繁换账号的，可以把登录过的账号都记录下来，写到NSUserDefaults等地方，以后每次需要登陆时，点击浮球，出来一个列表，选其中一个登陆

2.一些调试的时候想要反复执行的某句代码

---

✨如果有用，还望朋友能给个star，谢谢。