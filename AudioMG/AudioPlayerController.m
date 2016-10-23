//
//  AudioPlayer.m
//  AudioMG
//
//  Created by EnzoF on 18.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AudioPlayerController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVPlayer.h>

@interface AudioPlayerController ()<AVAudioPlayerDelegate>

@property (nonatomic,strong) UIView* toolbarView;

@property (nonatomic,strong) UIButton *play;
@property (nonatomic,strong) UIButton *stop;

@property (nonatomic,assign) BOOL isMidTrack;

@end
@implementation AudioPlayerController

/*+(AudioPlayer*)sharedAudioPlayer{
    static AudioPlayer *audioPlayer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioPlayer = [[AudioPlayer alloc]init];
    });
    [audioPlayer cacheWithFiles:nil];
    return audioPlayer;
}
*/
-(instancetype)initWithFilePath:(NSURL*)fileURL{
    self = [super init];
    if(self)
    {
        NSError*error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
        if(error)
        {
            NSLog(@"init AudioPlayer %@",[error localizedDescription]);
        }
        if(self.audioPlayer)
        {
            [self.audioPlayer prepareToPlay];
        }
    }
    return self;
}



-(void)viewDidLoad{
    [super viewDidLoad];
    self.isMidTrack = YES;
    self.audioPlayer.delegate = self;  //Дебаг
    self.view.backgroundColor = [UIColor purpleColor];
    UIImageView* imageViewBG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"audioMG-LogoImage.png"]];
    imageViewBG.contentMode = UIViewContentModeCenter;
    imageViewBG.alpha = 0.4f;
    imageViewBG.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageViewBG];
    UIView* toolbarView = [[UIView alloc]init];
    toolbarView.backgroundColor = [UIColor greenColor];
    toolbarView.translatesAutoresizingMaskIntoConstraints = NO;
    self.toolbarView = toolbarView;
    [self.view addSubview:toolbarView];
    
    UIProgressView* progress = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    progress.trackTintColor = [UIColor redColor];
    progress.progressTintColor = [UIColor greenColor];
    progress.translatesAutoresizingMaskIntoConstraints    = NO;
    [toolbarView addSubview:progress];
    
    
    UIButton* play = [UIButton buttonWithType:UIButtonTypeCustom];
    self.play = play;
    self.play.layer.borderWidth = 2.f;
    self.play.layer.borderColor = [UIColor magentaColor].CGColor;
    self.play.layer.backgroundColor = [UIColor whiteColor].CGColor;
    [self.play setTitle:@"◀︎" forState:UIControlStateNormal];
    [self.play setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];

    
    self.play.frame = CGRectMake(0.f, 0.f, 50.f, 50.f);
    self.play.layer.cornerRadius = CGRectGetWidth(play.layer.frame) / 2;
    [self.play addTarget:self action:@selector(actionPlay:) forControlEvents:UIControlEventTouchDown];
    [self.play addTarget:self action:@selector(actionUpInsidePlay:) forControlEvents:UIControlEventTouchUpInside];

    self.play.translatesAutoresizingMaskIntoConstraints    = NO;
    
    [toolbarView addSubview:self.play];
    
    UIButton* stop = [UIButton buttonWithType:UIButtonTypeCustom];
    stop.layer.borderWidth = 2.f;
    stop.layer.borderColor = [UIColor magentaColor].CGColor;
    stop.layer.backgroundColor = [UIColor whiteColor].CGColor;
    stop.frame = CGRectMake(0.f, 0.f, 50.f, 50.f);
    stop.layer.cornerRadius = CGRectGetWidth(stop.layer.frame) / 2;
    [stop setTitle:@"◼︎" forState:UIControlStateNormal];
    [stop setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [stop addTarget:self action:@selector(actionStop:) forControlEvents:UIControlEventTouchDown];
    [stop addTarget:self action:@selector(actionUpInsideStop:) forControlEvents:UIControlEventTouchUpInside];
    stop.translatesAutoresizingMaskIntoConstraints         = NO;
    [toolbarView addSubview:stop];
    
    UIView* centerBarView = [[UIView alloc]init];
    centerBarView.backgroundColor = [UIColor cyanColor];
    centerBarView.hidden = YES;
    centerBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolbarView addSubview:centerBarView];
    
    
    UILabel* trackTitle = [[UILabel alloc]init];
    trackTitle.numberOfLines = 5;
    
    trackTitle.font = [UIFont systemFontOfSize:30.f weight:0.5f];
    trackTitle.textAlignment = NSTextAlignmentCenter;
    
    trackTitle.text = @"1.Название трека, и название испольнителя данной аудиодорожки.Название трека, и название испольнителя данной аудиодорожки.Название трека, и название испольнителя данной аудиодорожки";
    
    
    trackTitle.translatesAutoresizingMaskIntoConstraints    = NO;
    self.trackTitle = trackTitle;
    [self.view addSubview:self.trackTitle];
    
    
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
    NSDictionary *views = NSDictionaryOfVariableBindings(toolbarView,progress,play,stop,centerBarView);
    NSNumber *heigth = [NSNumber numberWithFloat:100.f];
    NSNumber *padding = [NSNumber numberWithFloat:20.f];
    NSNumber *space = [NSNumber numberWithFloat:20.f];
    NSNumber *width = [NSNumber numberWithFloat:20.f];
    NSNumber *centerRarViewW = [NSNumber numberWithFloat:20.f];
    NSNumber *centerRarViewH = [NSNumber numberWithFloat:20.f];
    NSNumber *progressH = [NSNumber numberWithFloat:5.f];
    NSNumber *buttonsW = [NSNumber numberWithFloat:50.f];
    NSNumber *buttonsH = [NSNumber numberWithFloat:50.f];
    NSNumber *trackTitleH = [NSNumber numberWithFloat:300.f];
    NSNumber *imageViewH = [NSNumber numberWithFloat:300.f];

    NSDictionary *metrics = NSDictionaryOfVariableBindings(centerRarViewW,centerRarViewH,heigth,padding,space,width,progressH,buttonsW,buttonsH,trackTitleH,imageViewH);
    
    
    
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageViewBG]-|"
                                                                      options:0
                                                                      metrics:nil views:NSDictionaryOfVariableBindings(imageViewBG)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageViewBG attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[imageViewBG(>=imageViewH)]-|"
                                                                      options:0
                                                                      metrics:metrics views:NSDictionaryOfVariableBindings(imageViewBG)]];
    
    
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[trackTitle]-|"
                                                                             options:0
                                                                             metrics:nil views:NSDictionaryOfVariableBindings(trackTitle)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trackTitle attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f]];
 
    
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[trackTitle(>=trackTitleH)]-|"
                                                                      options:0
                                                                      metrics:metrics views:NSDictionaryOfVariableBindings(trackTitle)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbarView(==heigth)]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                     metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolbarView]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:nil views:views]];
    
    
        NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:centerBarView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.toolbarView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0.f];
        [constraints addObject:centerX];
    
        NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:centerBarView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.toolbarView attribute:NSLayoutAttributeCenterY multiplier:1.f constant:0.f];
        [constraints addObject:centerY];
    
    
    [self.toolbarView addConstraints:constraints];
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[centerBarView(==centerRarViewH)]"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics views:views]];
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[centerBarView(==centerRarViewW)]"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics views:views]];
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[progress(==progressH)]"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics views:views]];
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[progress]-(==padding)-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics views:views]];
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[progress]-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics views:views]];
    
    
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[play(==buttonsW)]-(==space)-[centerBarView]-(==space)-[stop(==buttonsW)]"
                                                                             options:0
                                                                             metrics:metrics views:views]];
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[play(==buttonsH)]"
                                                                             options:0
                                                                             metrics:metrics views:views]];
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[stop(==buttonsH)]"
                                                                             options:0
                                                                             metrics:metrics views:views]];

    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionTapBarHidden:)];
    
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.audioPlayer play];
//    self.play.enabled = NO;
//    self.play.backgroundColor = [UIColor lightGrayColor];
//    self.stop.enabled = YES;
}

#pragma mark - Actions

-(void)actionPlay:(UIButton*)sender{
    if(![self.audioPlayer isPlaying])
    {
        [self.audioPlayer play];
        self.isMidTrack = YES;
    }
    else{
        self.stop.titleLabel.text = @"||";
    }
    sender.backgroundColor = [UIColor darkGrayColor];
    //[self.audioPlayer play];
    //запуск сна
}

-(void)actionUpInsidePlay:(UIButton*)sender{
    
    sender.backgroundColor = [UIColor whiteColor];
}

-(void)actionStop:(UIButton*)sender{
    if(![self.audioPlayer isPlaying] & self.isMidTrack)
    {
        [self bactToStart];
        self.isMidTrack = NO;
        self.stop.titleLabel.text = @"||";
    }
    else{
        if(self.isMidTrack)
        {
            [self.stop setTitle:@"◼︎" forState:UIControlStateNormal];
        }
        [self.audioPlayer stop];
    }
    sender.backgroundColor = [UIColor darkGrayColor];
    
    
}
-(void)actionUpInsideStop:(UIButton*)sender{
    
    sender.backgroundColor = [UIColor whiteColor];
}

#pragma mark -- UIGestureRecognizer

-(void)actionTapBarHidden:(UITapGestureRecognizer*)tap{
    if(!self.navigationController.navigationBar.hidden)
    {
            self.navigationController.navigationBar.hidden = YES;
            self.toolbarView.hidden = YES;

    }else{
            self.navigationController.navigationBar.hidden = NO;
            self.toolbarView.hidden = NO;
    }
}

#pragma mark - updateActionButton

-(void)bactToStart{
    //self.audioPlayer.volume = 0.5f;
    self.audioPlayer.numberOfLoops = 1;
    self.audioPlayer.currentTime = 0.0f;
    [self.audioPlayer play];
    self.stop.titleLabel.text = @"◼︎";
}


#pragma mark - AVAudioPlayerDelegate


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    NSLog(@"successfull %d",flag);
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    NSLog(@"error %@",[error localizedDescription]);
}

@end
