//
//  AccessToken.h
//  AudioMG
//
//  Created by EnzoF on 16.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject

@property (nonatomic,strong) NSString *token;
@property (nonatomic,strong) NSDate *expirationDate;
@property (nonatomic,strong) NSString *userID;

@end
