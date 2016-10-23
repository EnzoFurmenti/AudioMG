//
//  AudioPlayer.h
//  AudioMG
//
//  Created by EnzoF on 18.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioPlayer.h"



@interface AudioPlayerController : UIViewController


@property (nonatomic,strong) UILabel* trackTitle;
@property (nonatomic,strong) AudioPlayer* player;
@property (nonatomic,strong) NSString* audioTitle;
@property (nonatomic,strong) NSString* artist;




-(instancetype)initWithPlayer:(AudioPlayer*)audioPlayer;

@end
