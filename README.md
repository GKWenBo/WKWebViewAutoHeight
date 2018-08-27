# WKWebViewAutoHeight
### 一、前言
> Important
> Starting in iOS 8.0 and OS X 10.10, use WKWebView to add web content to your app. Do not use UIWebView or WebView.

**WKWebVIew**是iOS8新出的API，旨在替代原有的**UIWebView**，相对于**UIWebView**，**WKWebView**有着更为强大性能和丰富的API。在项目开发过程中，我也更倾向于用**WKWebView**,但在使用过程中也遇到许多的问题。
最近接触使用网页视图比较多，自己在tableView和scrollView中嵌套网页视图，在获取网页视图高度遇到过不少的坑，例如高度不准确、底部留白断层，滚动一直获取高度问题。现在项目中使用的网页视图基本都替换成了**WKWebView**，关于**WKWebView**使用的一些坑，我强烈推荐一篇博客[WKWebView 那些坑](https://mp.weixin.qq.com/s/rhYKLIbXOsUJC_n6dt9UfA)，希望使用**WKWebView**能少走一些弯路，少踩一些坑。好了，话不多说了，我将项目中获取网页视图高度实际经验分享给大家，希望对你有所帮助，下面开始介绍吧！
### 二、目录
- 通过KVO的方式
- 通过代理的方式
- 通过注入JS的方式，添加网页加载完成回调获取
#### 通过KVO的方式
这种方式获取的高度较为准确，但要注意表格中多次回调高度的问题。
- 添加监听者
```objective-c
#pragma mark ------ < Private Method > ------
#pragma mark
- (void)addWebViewObserver {
[self.wkWebView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}
```
- 监听高度变化
```objective-c
#pragma mark ------ < KVO > ------
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
/**  < 法2 >  */
/**  < loading：防止滚动一直刷新，出现闪屏 >  */
if ([keyPath isEqualToString:@"contentSize"]) {
CGRect webFrame = self.wkWebView.frame;
webFrame.size.height = self.wkWebView.scrollView.contentSize.height;
self.wkWebView.frame = webFrame;
[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
}
}
```
- 移除观察者
- ```objective-c
- (void)removeWebViewObserver {
[self.wkWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}
```
#### 通过代理的方式
这种方法通过**WKNavigationDelegate**代理方法`- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation`，网页加载完成通过JS获取网页内容高度，但这种方式不一定就是最真实的高度，这时候可能网页内容还未加载完成，但以实际情况为准。

```objective-c
/**  < 法2 >  */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
//document.body.offsetHeight
//document.body.scrollHeight
//document.body.clientHeight
[webView evaluateJavaScript:@"document.body.offsetHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
CGFloat documentHeight = [result doubleValue];
CGRect webFrame = webView.frame;
webFrame.size.height = documentHeight;
webView.frame = webFrame;
[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
}];


//    CGRect webFrame = self.wkWebView.frame;
//    CGFloat contentHeight = webView.scrollView.contentSize.height;
//    webFrame.size.height = contentHeight;
//    webView.frame = webFrame;
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
}
```
#### 通过注入JS的方式，添加网页加载完成回调获取
第三种通常是接口返回**HTMLString**，然后自己在APP客户端成网页html、head、body这些标签，在合适的位置加入以下js代码：
```js
<script type=\"text/javascript\">\
window.onload = function() {\
window.location.href = \"ready://\" + document.body.scrollHeight;\
}\
</script>
```
然后借助WKWebView代理方法，就能准确获得网页高度：
```objective-c
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
if (navigationAction.navigationType == WKNavigationTypeOther) {
if ([[[navigationAction.request URL] scheme] isEqualToString:@"ready"]) {
float contentHeight = [[[navigationAction.request URL] host] floatValue];
CGRect webFrame = self.wkWebView.frame;
webFrame.size.height = contentHeight;
webView.frame = webFrame;

NSLog(@"onload = %f",contentHeight);

[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];

decisionHandler(WKNavigationActionPolicyCancel);
return;
}
}
decisionHandler(WKNavigationActionPolicyAllow);
}
```

第三种方法在我写的demo中是看不到效果的，有兴趣的朋友可以自己拼接网页HTMLString测试效果。我也贴一个我在项目中添加以上代码片段的位置吧：

```html
<!DOCTYPE html>
<html>

<meta charset=\"utf-8\">

<meta name=\"viewport\"content=\"width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no\">\
<title></title>

<head>

<script type=\"text/javascript\">\
window.onload = function() {\
window.location.href = \"ready://\" + document.body.scrollHeight;\
}\
</script>

</head>

<body>

//接口返回网页内容，拼接在这里

</body>

</html>
```
### 三、问题解决
- 解决web断层问题：[WKWebView刷新机制小探](https://www.jianshu.com/p/1d739e2e7ed2)
```objective-c
#pragma mark ------ < UIScrollViewDeltegate > ------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
/**  < 解决web白屏问题 >  */
/**  < 需要调用私有API：_updateVisibleContentRects >  */
[self.wkWebView setNeedsLayout];
}
```
### 四、demo
最新demo请戳：[WKWebViewAutoHeight](https://github.com/wenmobo/WKWebViewAutoHeight)
### 五、参考资料
- [ios webview自适应实际内容高度5种方法](http://www.skyfox.org/ios-webview-autofit-content-height.html)     
- [iOS中webView嵌套tableView中动态高度问题](https://juejin.im/post/5a38c9055188254b8b3546bf)
- [WKWebView刷新机制小探](https://www.jianshu.com/p/1d739e2e7ed2)


