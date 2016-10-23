//
//  Track.h
//  AudioMG
//
//  Created by EnzoF on 18.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Track : NSObject

@property (nonatomic,strong) NSString *artist;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) NSInteger duration;
@property (nonatomic,strong) NSString *url;
@end
