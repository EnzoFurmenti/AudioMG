//
//  AuthenticationController.h
//  AudioMG
//
//  Created by EnzoF on 16.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AccessToken;

typedef void(^AuthenticationCompletionBlock)(AccessToken* token);



@interface AuthenticationController : UIViewController

@property (nonatomic,strong) UIWebView *webView;




-(id)initWithCompletionBlock:(AuthenticationCompletionBlock) completionBlock;

@end
