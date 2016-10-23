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
#import "AudioPlayer.h"

@interface AudioPlayerController ()<AVAudioPlayerDelegate>


@property (nonatomic,strong) UIView* toolbarView;
@property (nonatomic,strong) UIButton *play;
@property (nonatomic,strong) UIButton *stop;
@property (nonatomic,assign) BOOL isMidTrack;

@end
@implementation AudioPlayerController


-(instancetype)initWithPlayer:(AudioPlayer*)audioPlayer{
    self = [super init];
    if(self)
    {
        self.player = audioPlayer;
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(dispatchQueue, ^{
            AVAudioSession* audioSession = [AVAudioSession sharedInstance];
            NSError* error = nil;
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
            if(error)
            {
                NSLog(@"audioSession error %@",[error localizedDescription]);
            }
        });
        self.navigationItem.title = @"AudioMG";
    }
    return self;
}



-(void)viewDidLoad{
    [super viewDidLoad];
    self.isMidTrack = YES;
    self.player.audioPlayer.delegate = self;  //Дебаг
    self.view.backgroundColor = [UIColor purpleColor];
    
    UIImageView* imageViewBG = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"audioMG-LogoImage.png"]];
    imageViewBG.contentMode = UIViewContentModeCenter;
    imageViewBG.alpha = 0.4f;
    imageViewBG.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:imageViewBG];
    
    UIView* toolbarView = [[UIView alloc]init];
    toolbarView.backgroundColor = [self customColorWithRed:102.f green:148.f blue:245.f alpha:0.2f];
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
    self.play.frame = CGRectMake(0.f, 0.f, 50.f, 50.f);
    self.play.layer.cornerRadius = CGRectGetWidth(play.layer.frame) / 2;
    
    [self.play setTitle:@"◀︎" forState:UIControlStateNormal];
    [self.play setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
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
    
    [stop setTitle:@"||" forState:UIControlStateNormal];
    [stop setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [stop addTarget:self action:@selector(actionStop:) forControlEvents:UIControlEventTouchDown];
    [stop addTarget:self action:@selector(actionUpInsideStop:) forControlEvents:UIControlEventTouchUpInside];
    stop.translatesAutoresizingMaskIntoConstraints         = NO;
    self.stop = stop;
    [toolbarView addSubview:self.stop];
    
    UIView* centerBarView = [[UIView alloc]init];
    centerBarView.backgroundColor = [UIColor cyanColor];
    centerBarView.hidden = YES;
    centerBarView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.toolbarView addSubview:centerBarView];
    
    
    UILabel* trackTitle = [[UILabel alloc]init];
    trackTitle.numberOfLines = 5;
    trackTitle.font = [UIFont systemFontOfSize:30.f weight:0.5f];
    trackTitle.textAlignment = NSTextAlignmentCenter;
    trackTitle.text = [NSString stringWithFormat:@"Название дорожки:%@\n"
                                                   "Исполнитель:%@",
                                                    self.player.titleTrack,
                                                    self.player.artist];
    
    
    trackTitle.translatesAutoresizingMaskIntoConstraints    = NO;
    self.trackTitle = trackTitle;
    [self.view addSubview:self.trackTitle];
    
    
    
    NSDictionary* views = NSDictionaryOfVariableBindings(toolbarView,progress,play,stop,centerBarView);
    NSNumber* heigth            = [NSNumber numberWithFloat:100.f];
    NSNumber* padding           = [NSNumber numberWithFloat:20.f];
    NSNumber* space             = [NSNumber numberWithFloat:20.f];
    NSNumber* width             = [NSNumber numberWithFloat:20.f];
    NSNumber* centerRarViewW    = [NSNumber numberWithFloat:20.f];
    NSNumber* centerRarViewH    = [NSNumber numberWithFloat:20.f];
    NSNumber* progressH         = [NSNumber numberWithFloat:5.f];
    NSNumber* buttonsW          = [NSNumber numberWithFloat:50.f];
    NSNumber* buttonsH          = [NSNumber numberWithFloat:50.f];
    NSNumber* trackTitleH       = [NSNumber numberWithFloat:300.f];
    NSNumber* imageViewH        = [NSNumber numberWithFloat:300.f];

    NSDictionary *metrics = NSDictionaryOfVariableBindings(centerRarViewW,
                                                           centerRarViewH,
                                                           heigth,
                                                           padding,
                                                           space,
                                                           width,
                                                           progressH,
                                                           buttonsW,
                                                           buttonsH,
                                                           trackTitleH,
                                                           imageViewH);

    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[imageViewBG]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(imageViewBG)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:imageViewBG
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.f
                                                           constant:0.f]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[imageViewBG(>=imageViewH)]-|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:NSDictionaryOfVariableBindings(imageViewBG)]];
    
    
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[trackTitle]-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:NSDictionaryOfVariableBindings(trackTitle)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.trackTitle
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.f
                                                           constant:0.f]];
 
    
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[trackTitle(>=trackTitleH)]-|"
                                                                      options:0
                                                                      metrics:metrics
                                                                        views:NSDictionaryOfVariableBindings(trackTitle)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[toolbarView(==heigth)]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                     metrics:metrics views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[toolbarView]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:nil views:views]];
    
    
    [self.toolbarView addConstraint:[NSLayoutConstraint constraintWithItem:centerBarView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.toolbarView
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1.f
                                                                  constant:0.f]];
    
    [self.toolbarView addConstraint:[NSLayoutConstraint constraintWithItem:centerBarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.toolbarView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.f
                                                                    constant:0.f]];
    
    
    //[self.toolbarView addConstraints:constraints];
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[centerBarView(==centerRarViewH)]"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics
                                                                               views:views]];
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[centerBarView(==centerRarViewW)]"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics
                                                                               views:views]];
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[progress(==progressH)]"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics
                                                                               views:views]];
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[progress]-(==padding)-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics
                                                                               views:views]];
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[progress]-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:metrics
                                                                               views:views]];
    
    
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[play(==buttonsW)]-(==space)-[centerBarView]-(==space)-[stop(==buttonsW)]"
                                                                             options:0
                                                                             metrics:metrics
                                                                               views:views]];
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[play(==buttonsH)]"
                                                                             options:0
                                                                             metrics:metrics views:views]];
    
    
    [self.toolbarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[stop(==buttonsH)]"
                                                                             options:0
                                                                             metrics:metrics views:views]];

    
    
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self
                                                                         action:@selector(actionTapBarHidden:)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.player.audioPlayer play];
}

#pragma mark - Actions

-(void)actionPlay:(UIButton*)sender{
    if(![self.player.audioPlayer isPlaying])
    {
        [self.player.audioPlayer play];
        [self.stop setTitle:@"||" forState:UIControlStateNormal];
        self.isMidTrack = YES;
    }
    else{
        self.stop.titleLabel.text = @"||";
    }
    sender.backgroundColor = [UIColor darkGrayColor];
}

-(void)actionUpInsidePlay:(UIButton*)sender{
    
    sender.backgroundColor = [UIColor whiteColor];
}

-(void)actionStop:(UIButton*)sender{
    if(![self.player.audioPlayer isPlaying] & self.isMidTrack)
    {
        [self bactToStart];
        self.isMidTrack = YES;
        [self.stop setTitle:@"||" forState:UIControlStateNormal];
        [self.stop setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    else{
        if(self.isMidTrack)
        {
            [self.stop setTitle:@"◼︎" forState:UIControlStateNormal];
        }
        [self.player.audioPlayer stop];
    }
    sender.backgroundColor = [UIColor darkGrayColor];
    
    
}
-(void)actionUpInsideStop:(UIButton*)sender{
    
    sender.backgroundColor = [UIColor whiteColor];
}

#pragma mark - UIGestureRecognizer

-(void)actionTapBarHidden:(UITapGestureRecognizer*)tap{
    if(!self.navigationController.navigationBar.hidden)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
            self.toolbarView.hidden = YES;

    }else{
        [self.navigationController setNavigationBarHidden:NO animated:YES];
            self.toolbarView.hidden = NO;
    }
}

#pragma mark - update

-(void)bactToStart{
    self.player.audioPlayer.numberOfLoops = 1;
    self.player.audioPlayer.currentTime = 0.0f;
    [self.player.audioPlayer play];
    [self.stop setTitle:@"◼︎" forState:UIControlStateNormal];

}

#pragma mark - color

-(UIColor*)customColorWithRed:(CGFloat)redColor green:(CGFloat)greenColor blue:(CGFloat)blueColor alpha:(CGFloat)alpha{
    CGFloat currentAlpha = alpha ? 1.f : alpha;
    return [UIColor colorWithRed:redColor/255.f green:greenColor/255.f blue:blueColor/255.f alpha:currentAlpha];
}


#pragma mark - AVAudioPlayerDelegate


- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"successfull %d",flag);
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    NSLog(@"error %@",[error localizedDescription]);
}

@end
