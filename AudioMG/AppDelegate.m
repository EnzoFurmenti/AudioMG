//
//  AppDelegate.m
//  AudioMG
//
//  Created by EnzoF on 15.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AppDelegate.h"
#import "AudioPlayerController.h"
#import "AudioTableViewController.h"
#import "AuthenticationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    AudioTableViewController*audioTVC = [[AudioTableViewController alloc]init];
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:audioTVC];
    self.window.rootViewController = navC;
    [self.window makeKeyAndVisible];
  

    UIImage *logo = [UIImage imageNamed:@"audioMG-LogoImage.png"];
    UIImageView *logoImageView = [[UIImageView alloc]initWithImage:logo];

    CGFloat widthLogo = MIN(CGRectGetWidth(self.window.bounds),CGRectGetHeight(self.window.bounds));
    CGFloat heightLogo = widthLogo;

    logoImageView.frame = CGRectMake(0.f, 0.f, widthLogo, heightLogo);
    logoImageView.center = CGPointMake(CGRectGetMidX(self.window.bounds), CGRectGetMidY(self.window.bounds));

    UILabel *labelCopyright = [[UILabel alloc]init];
    labelCopyright.text = @"Copyright © 2016 EnzoF. All rights reserved.";
    labelCopyright.textAlignment = NSTextAlignmentCenter;
    labelCopyright.font = [UIFont systemFontOfSize:30.f];
    labelCopyright.numberOfLines = 1;
    labelCopyright.adjustsFontSizeToFitWidth = YES;
    labelCopyright.minimumScaleFactor = 0.5f;
    labelCopyright.translatesAutoresizingMaskIntoConstraints = NO;

    
    UIView *backGView = [[UIView alloc]initWithFrame:self.window.bounds];
    backGView.translatesAutoresizingMaskIntoConstraints = NO;
    [backGView addSubview:labelCopyright];
    [audioTVC.view addSubview:logoImageView];
    [audioTVC.view addSubview:backGView];
    [audioTVC.view bringSubviewToFront:backGView];
    [audioTVC.view bringSubviewToFront:logoImageView];
    [backGView bringSubviewToFront:labelCopyright];

    NSDictionary *views = NSDictionaryOfVariableBindings(labelCopyright,logoImageView,backGView);

    CGFloat w = CGRectGetWidth(backGView.bounds);
    NSNumber* width = [NSNumber numberWithFloat:w];

    NSDictionary*   metrics     = NSDictionaryOfVariableBindings(width);
    NSMutableArray* constraints = [[NSMutableArray alloc]init];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[backGView]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics views:views]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backGView]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics views:views]];
    [audioTVC.view addConstraints:constraints];
    
    
    
    [constraints removeAllObjects];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[labelCopyright]-|"
                                                                             options:NSLayoutFormatAlignAllBottom
                                                                             metrics:metrics views:views]];

    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[labelCopyright]-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics views:views]];

    [backGView addConstraints:constraints];
    backGView.backgroundColor = [self customColorWithRed:68.f green:183.f blue:111.f alpha:1.f];
    
    [audioTVC.navigationController setNavigationBarHidden:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.window
                          duration:1.f
                           options:UIViewAnimationOptionCurveEaseInOut
                        animations:^{
                            audioTVC.navigationController.navigationBar.alpha = 1.f;
                            [audioTVC.navigationController setNavigationBarHidden:NO animated:YES];
                            audioTVC.navigationController.navigationBar.barTintColor = [self customColorWithRed:70.f
                                                                                                          green:190.f
                                                                                                           blue:169.f
                                                                                                          alpha:0.5f];
                            audioTVC.navigationItem.title = @"AudioMG-Offline";
                            backGView.alpha = 0.f;
                            logoImageView.alpha = 0.f;
                            labelCopyright.alpha = 0.f;
                            logoImageView.transform = CGAffineTransformScale(logoImageView.transform, 2.f, 2.f);
        }
                        completion:^(BOOL finished) {
                            [labelCopyright removeFromSuperview];
                            [logoImageView removeFromSuperview];
                            [backGView removeFromSuperview];
        }];
    });
    return YES;
}

#pragma mark - color

-(UIColor*)customColorWithRed:(CGFloat)redColor green:(CGFloat)greenColor blue:(CGFloat)blueColor alpha:(CGFloat)alpha{
    CGFloat currentAlpha = alpha ? 1.f : alpha;
    return [UIColor colorWithRed:redColor/255.f green:greenColor/255.f blue:blueColor/255.f alpha:currentAlpha];
}

@end
