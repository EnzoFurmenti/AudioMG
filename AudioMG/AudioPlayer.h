//
//  AudioPlayer.h
//  AudioMG
//
//  Created by EnzoF on 20.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AudioPlayer : NSObject

@property (nonatomic,strong) NSString *titleTrack;
@property (nonatomic,strong) NSString *artist;
@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,strong) NSURL *url;


-(instancetype)initWithContentsOfURL:(NSURL*)url;
-(instancetype)initWithData:(NSData*)data;

@end
