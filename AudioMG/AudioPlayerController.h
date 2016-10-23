//
//  AudioPlayer.h
//  AudioMG
//
//  Created by EnzoF on 18.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVAudioPlayer;

@interface AudioPlayerController : UIViewController

@property(nonatomic,strong) AVAudioPlayer* audioPlayer;
@property (nonatomic,strong) UILabel* trackTitle;


-(instancetype)initWithFilePath:(NSURL*)fileURL;

@end
