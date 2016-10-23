//
//  AuthenticationController.m
//  AudioMG
//
//  Created by EnzoF on 16.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AuthenticationController.h"
#import "AccessToken.h"



@interface AuthenticationController ()<UIWebViewDelegate>


@property (nonatomic,copy) AuthenticationCompletionBlock completionBlock;


@end


@implementation AuthenticationController

-(id)initWithCompletionBlock:(AuthenticationCompletionBlock) completionBlock{
    self = [super init];
    if(self)
    {
        self.completionBlock = completionBlock;
    }
    
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    UIWebView *webView = self.webView;
    self.webView.delegate = self;
    
    self.navigationController.navigationBar.barTintColor = [self customColorWithRed:68.f green:183.f blue:111.f alpha:1.f];
    
    UIBarButtonItem* cancelBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(actionCancel:)];
    UIBarButtonItem* refreshlBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(actionRefresh:)];
    
    self.navigationItem.leftBarButtonItem = cancelBarButton;
    self.navigationItem.rightBarButtonItem = refreshlBarButton;
    self.navigationItem.title = @"Регистрация";
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *views = NSDictionaryOfVariableBindings(webView);
    
    CGFloat originY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    
    NSNumber *origY = [NSNumber numberWithFloat:originY];
    
    NSDictionary *metrics = NSDictionaryOfVariableBindings(origY);

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[webView]-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics views:views]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat: @"H:|-0-[webView]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.view addConstraints:constraints];
    
    
    NSURLRequest *urlRequest = [self request];
    [self.webView loadRequest:urlRequest];
}

-(void)dealloc{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.webView.delegate = nil;
}
#pragma mark - Lazy Initialization
-(UIWebView*)webView{
    if(!_webView)
    {
        _webView = [[UIWebView alloc]init];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;
        _webView.scalesPageToFit = NO;
        _webView.scrollView.scrollEnabled = NO;
    }
    return _webView;
}

#pragma mark - action

-(void)actionCancel:(UIBarButtonItem*)sender{
    __weak AuthenticationController* weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        weakSelf.completionBlock(nil);
    }];
}

-(void)actionRefresh:(UIBarButtonItem*)sender{
    NSURLRequest *urlRequest = [self request];
    [self.webView loadRequest:urlRequest];
}

#pragma mark - URL

-(NSURLRequest*)request{
    NSString* urlStr = @"https://oauth.vk.com/authorize?"
    "client_id=5670691&"
    "scope=8&"
    "redirect_uri=https://oauth.vk.com/blank.html"
    "display=mobile&"
    "v=5.58&"
    "response_type=token&";
    NSURL* url = [NSURL URLWithString:urlStr];
    return  [NSURLRequest requestWithURL:url];
}

#pragma mark - color

-(UIColor*)customColorWithRed:(CGFloat)redColor green:(CGFloat)greenColor blue:(CGFloat)blueColor alpha:(CGFloat)alpha{
    CGFloat currentAlpha = alpha ? 1.f : alpha;
    return [UIColor colorWithRed:redColor/255.f green:greenColor/255.f blue:blueColor/255.f alpha:currentAlpha];
}

#pragma  mark - UIWebViewDelegate



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    if([[[request URL] description] rangeOfString:@"#access_token"].location != NSNotFound)
    {
        AccessToken *token = [[AccessToken alloc]init];
        NSString *query = [request description];
        NSArray *array = [query componentsSeparatedByString:@"#"];
        
        if([array count] > 1)
        {
            query = [array lastObject];
        }
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        for (NSString* pair in pairs)
        {
            NSArray *values = [pair componentsSeparatedByString:@"="];
            if([values count] == 2)
            {
                NSString* key = [values firstObject];
                if([key isEqualToString:@"access_token"])
                {
                    token.token = [values lastObject];
                    
                }else if([key isEqualToString:@"expires_in"]){
                    NSTimeInterval interval = [[values lastObject] doubleValue];
                    token.expirationDate = [NSDate dateWithTimeIntervalSinceNow:interval];
                    
                }else if([key isEqualToString:@"user_id"]){
                    token.userID = [values lastObject];
                }
            }
        }
        self.webView.delegate = nil;
        if(self.completionBlock)
        {
            self.completionBlock(token);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    }
        return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"start");
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if([error code] == -1009)
    {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Внимание"
                                                                       message:@"Нет доступа в интернет. Проверьте настройки сети и затем перезагрузите диалог"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
   //Дебаг NSLog(@"didFailLoadWithError%@ statusCode = %ld",[error localizedDescription],[error code]);
}

@end
