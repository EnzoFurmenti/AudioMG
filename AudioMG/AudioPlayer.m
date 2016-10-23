//
//  AudioPlayer.m
//  AudioMG
//
//  Created by EnzoF on 20.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AudioPlayer.h"

@implementation AudioPlayer

-(instancetype)initWithContentsOfURL:(NSURL*)url{
    self = [super init];
    if(self)
    {
        NSError *error = nil;
        self.url = url;
        self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:&error];
        if(error)
        {
            NSLog(@"error init AudioPlayer %@",[error localizedDescription]);
        }
        else{
            if(self.audioPlayer)
            {
                [self.audioPlayer prepareToPlay];
            }
            else{
                NSLog(@"audioPlayer isEpmty");
            }
        }
    }
    return self;
}



-(instancetype)initWithData:(NSData*)data{
    self = [super init];
    if(self)
    {
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc]initWithData:data error:&error];
        if(error)
        {
            NSLog(@"error init AudioPlayer %@",[error localizedDescription]);
        }
        else{
            if(self.audioPlayer)
            {
                [self.audioPlayer prepareToPlay];
            }
            else{
                NSLog(@"audioPlayer isEpmty");
            }
        }
    }
    return self;
}

@end
