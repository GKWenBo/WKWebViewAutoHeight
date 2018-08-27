//
//  ViewController.m
//  MyDemo
//
//  Created by Admin on 2017/11/10.
//  Copyright © 2017年 Admin. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,WKUIDelegate,WKNavigationDelegate>
{
    CGFloat wkWebViewHeight;
}

@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ViewController

- (void)dealloc {
//    [self removeWebViewObserver];
}
#pragma mark ------ < Life Cycle > ------
#pragma mark
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initializeDataSource];
    [self initializeUserInterface];
}

#pragma mark ------ < Initialize > ------
#pragma mark
- (void)initializeDataSource {
    
}

- (void)initializeUserInterface {
    [self.view addSubview:self.tableView];
    [self setupWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ------ < Request > ------
#pragma mark

#pragma mark ------ < Event Response > ------
#pragma mark

#pragma mark ------ < Private Method > ------
#pragma mark
- (void)setupWebView {
    wkWebViewHeight = 0.f;
    NSURL *url = [NSURL URLWithString:@"https://www.jianshu.com/p/22f39afdaa44"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [self.wkWebView loadRequest:urlRequest];
//    [self addWebViewObserver];
}

/** < 方式一 > */
//- (void)addWebViewObserver {
//    [self.wkWebView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
//}

//- (void)removeWebViewObserver {
//    [self.wkWebView.scrollView removeObserver:self forKeyPath:@"contentSize"];
//}

//#pragma mark ------ < KVO > ------
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
//    /**  < 法2 >  */
//    /**  < loading：防止滚动一直刷新，出现闪屏 >  */
//    if ([keyPath isEqualToString:@"contentSize"]) {
//        CGRect webFrame = self.wkWebView.frame;
//        webFrame.size.height = self.wkWebView.scrollView.contentSize.height;
//        self.wkWebView.frame = webFrame;
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
//    }
//}

#pragma mark ------ < UITableViewDelegate,UITableViewDataSource > ------
#pragma mark
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 3:
            return self.wkWebView.frame.size.height;
            break;
        default:
            return 50;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 3:
        {
            UITableViewCell *webCell = [tableView dequeueReusableCellWithIdentifier:@"WebViewCell" forIndexPath:indexPath];
            [webCell.contentView addSubview:self.wkWebView];
            return webCell;
        }
            break;
        default:
        {
            UITableViewCell *defaultCell = [tableView dequeueReusableCellWithIdentifier:@"DefaultCell" forIndexPath:indexPath];
            defaultCell.textLabel.text = [NSString stringWithFormat:@"普通的cell，编号：%ld", indexPath.row];
            return defaultCell;
        }
            break;
    }
}

#pragma mark ------ < UIScrollViewDeltegate > ------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    /**  < 解决web白屏问题 >  */
    /**  < 需要调用私有API：_updateVisibleContentRects >  */
    [self.wkWebView setNeedsLayout];
}

#pragma mark ------ < WKUIDelegate,WKNavigationDelegate > ------
#pragma mark
/**  < 法2 >  */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //document.body.offsetHeight
    //document.body.scrollHeight
    //document.body.clientHeight
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
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

//- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
//    if (navigationAction.navigationType == WKNavigationTypeOther) {
//        if ([[[navigationAction.request URL] scheme] isEqualToString:@"ready"]) {
//            float contentHeight = [[[navigationAction.request URL] host] floatValue];
//            CGRect webFrame = self.wkWebView.frame;
//            webFrame.size.height = contentHeight;
//            webView.frame = webFrame;
//            
//            NSLog(@"onload = %f",contentHeight);
//            
//            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:3 inSection:0], nil] withRowAnimation:UITableViewRowAnimationNone];
//            
//            decisionHandler(WKNavigationActionPolicyCancel);
//            return;
//        }
//    }
//    decisionHandler(WKNavigationActionPolicyAllow);
//}

#pragma mark ------ < getter > ------
#pragma mark
- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        wkWebConfig.userContentController = wkUController;
        /** << 自适应屏幕宽度js > */
        NSMutableString *JSString = [NSMutableString string];
        
        /** < 法3 > */
        NSString *windowLocationString = @"<script type=\"text/javascript\">\
        window.onload = function() {\
        window.location.href = \"ready://\" + document.body.scrollHeight;\
        }\
        </script>";
        
        [JSString appendString:windowLocationString];
        
        NSString *jSString = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
        
        [JSString appendString:jSString];
        
        
        WKUserScript *wkUserScript = [[WKUserScript alloc] initWithSource:JSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        /** << 添加js调用 > */
        [wkUController addUserScript:wkUserScript];
        _wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1) configuration:wkWebConfig];
        _wkWebView.UIDelegate = self;
        _wkWebView.navigationDelegate = self;
        _wkWebView.opaque = NO;
        _wkWebView.scrollView.scrollEnabled = NO;
        _wkWebView.scrollView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0,*)) {
            _wkWebView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _wkWebView.scrollView.bounces = NO;
        _wkWebView.backgroundColor = [UIColor clearColor];
    }
    return _wkWebView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc]init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 50.f;
        if (@available(iOS 11.0,*)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"WebViewCell"];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"DefaultCell"];
    }
    return _tableView;
}


@end
