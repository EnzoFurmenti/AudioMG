//
//  AudioTableViewController.m
//  AudioMG
//
//  Created by EnzoF on 15.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "AudioTableViewController.h"
#import "AuthenticationController.h"
#import "ServerManager.h"
#import "Track.h"
#import "AudioPlayerController.h"
#import "AudioPlayer.h"

#import <AudioToolbox/AudioFile.h>


#define ADDAUDIO 40
#define INDENTV  20.f

typedef void(^AccessTokenBlock)(BOOL obj1 );

static NSString* kAudioPlayerArray                        = @"AudioPlayerArray";
static NSString* kAudioPlayerDictionaryPropertyTitleTrack = @"AudioPlayerDictionaryPropertyTitleTrack";
static NSString* kAudioPlayerDictionaryPropertyArtist     = @"AudioPlayerDictionaryPropertyArtist";
static NSString* kAudioPlayerDictionaryPropertyFileData   = @"AudioPlayerDictionaryPropertyFileData";
static NSString* kAudioPlayerDictionaryPropertyFilePath   = @"AudioPlayerDictionaryPropertyFilePath";



static NSString* kAudioDictionaryArtist                   = @"artist";
static NSString* kAudioDictionaryTitle                    = @"title";
static NSString* kAudioDictionaryDuration                 = @"duration";
static NSString* kAudioDictionaryURL                      = @"url";


@interface AudioTableViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray<Track*>* tracks;
@property (nonatomic,strong) NSMutableArray* localAudioMA;
@property (nonatomic,strong) NSArray* audioItems;
@property (nonatomic,assign) NSInteger nextUpdateRow;

@property (nonatomic,strong) UISwitch* onoffSwitch;
@property (nonatomic,strong) UIActivityIndicatorView* activityIndicator;
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) UISearchBar* searchBar;

@property (nonatomic,strong) UIView* topBarSpacerView;


@property (nonatomic,assign) BOOL startAuthC;

@end

@implementation AudioTableViewController

-(void)loadView{
    [super loadView];
    [self loadAudioCash];
}

-(void)viewDidLoad{
    [super viewDidLoad];
    [self.view addSubview:self.searchBar];
    [self.searchBar setDelegate:self];
    
    [self.view addSubview:self.tableView];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    self.nextUpdateRow = 0;
    
    UISearchBar* searchBar = self.searchBar;
    UITableView* tableView = self.tableView;
    
    [self.view addSubview:self.activityIndicator];
    
    
    UIView* topBarSpacerView = [[UIView alloc]initWithFrame:self.navigationController.navigationBar.frame];
    self.topBarSpacerView = topBarSpacerView;
    self.topBarSpacerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
   // self.topBarSpacerView.translatesAutoresizingMaskIntoConstraints  = NO;
    [self.view addSubview:self.topBarSpacerView];
    
    
    NSMutableArray *constraints = [[NSMutableArray alloc]init];
   //     UINavigationBar* navC = self.navigationController.navigationBar;
    NSDictionary *views = NSDictionaryOfVariableBindings(tableView,searchBar,topBarSpacerView);
    
    CGFloat originY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    
    NSNumber *origY = [NSNumber numberWithFloat:originY];
    
    NSDictionary *metrics = NSDictionaryOfVariableBindings(origY);
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[topBarSpacerView]-[searchBar]"
                                                                             options:0
                                                                             metrics:metrics views:views]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[searchBar]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:nil views:views]];
    
    NSLayoutConstraint *vSpacing = [NSLayoutConstraint constraintWithItem:self.searchBar
                                                                attribute:NSLayoutAttributeBottom
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self.tableView
                                                                attribute:NSLayoutAttributeTop
                                                               multiplier:1.f
                                                                 constant:0.f];
    [constraints addObject:vSpacing];
    
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[tableView]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:nil
                                                                               views:views]];
    
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[tableView]-0-|"
                                                                             options:NSLayoutFormatAlignmentMask
                                                                             metrics:nil
                                                                               views:views]];
    
    [self.view addConstraints:constraints];
    
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1.f
                                                           constant:0.f]];

    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicator
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.view
                                                          attribute:NSLayoutAttributeCenterY
                                                         multiplier:1.f
                                                           constant:0.f]];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEdgeInsetsTableScrollViewWhenWillShownKeyBoardNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeEdgeInsetsTableScrollViewWhenWillHideKeyBoardNotification:) name:UIKeyboardWillHideNotification object:nil];
    
    
    self.onoffSwitch =[[UISwitch alloc]init];
    self.onoffSwitch.onTintColor = [UIColor greenColor];
    self.onoffSwitch.on = NO;
    [self.onoffSwitch addTarget:self action:@selector(actionOnOffMode:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem* onOffModeBarButton = [[UIBarButtonItem alloc]initWithCustomView:self.onoffSwitch];
    
    self.navigationItem.rightBarButtonItem = onOffModeBarButton;
    
    
    
    [self startUpdateTable:self.localAudioMA];
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    self.topBarSpacerView.frame = self.navigationController.navigationBar.frame;
}


#pragma mark - action

-(void)actionOnOffMode:(UISwitch*)sender{
    if([sender isOn])
    {
        self.nextUpdateRow = 0;
        [self autorizeScreen];
        self.navigationItem.title = @"AudioMG-Online";
        [self startUpdateTable:self.tracks];
        [self.activityIndicator stopAnimating];
        
    }
    else{
        self.navigationItem.title = @"AudioMG-Offline";
        [self.searchBar resignFirstResponder];
        self.searchBar.text = @"";
        [self.tracks removeAllObjects];
        [self startUpdateTable:self.localAudioMA];
    }
}

#pragma mark - Lazy initialization

-(UISearchBar*)searchBar{
    if(!_searchBar)
    {
        CGRect frame = self.navigationController.navigationBar.frame;
        CGRect rect = CGRectMake(CGRectGetMinX(self.view.bounds),CGRectGetMaxY(frame), CGRectGetWidth(frame), 44.f);
        _searchBar = [[UISearchBar alloc]initWithFrame:rect];
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        _searchBar.alpha = 1.f;
    }
    return _searchBar;
}

-(UITableView*)tableView{
    if(!_tableView)
    {
        CGFloat originY = CGRectGetMaxY(self.searchBar.frame) + INDENTV;
        CGFloat height = CGRectGetHeight(self.view.bounds) - originY;
        CGRect rect = CGRectMake(CGRectGetMinX(self.view.bounds),originY, CGRectGetWidth(self.view.bounds), height);
        _tableView = [[UITableView alloc]initWithFrame:rect style:UITableViewStylePlain];
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.backgroundColor = [self customColorWithRed:102.f green:148.f blue:245.f alpha:0.7f];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        _tableView.alpha = 1.f;
    }
    return _tableView;
}
-(UIActivityIndicatorView*)activityIndicator{
    if(!_activityIndicator)
    {
        _activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.hidesWhenStopped = YES;
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _activityIndicator;
}

-(NSMutableArray*)tracks{
    if(!_tracks)
    {
        _tracks = [[NSMutableArray alloc]init];
    }
    return _tracks;
}

-(NSMutableArray*)localAudioMA{
    if(!_localAudioMA)
    {
        _localAudioMA = [[NSMutableArray alloc]init];
    }
    return _localAudioMA;
}


#pragma mark - color

-(UIColor*)customColorWithRed:(CGFloat)redColor
                        green:(CGFloat)greenColor
                         blue:(CGFloat)blueColor
                        alpha:(CGFloat)alpha{
    CGFloat currentAlpha = alpha ? 1.f : alpha;
    
    return [UIColor colorWithRed:redColor/255.f
                           green:greenColor/255.f
                            blue:blueColor/255.f
                           alpha:currentAlpha];
}

#pragma  mark - URL & Registration

-(void)autorizeScreen{
    
    __weak AudioTableViewController* weakself = self;
   AccessTokenBlock accessTokenBlock = ^(BOOL obj1){
            if(obj1)
            {
                weakself.navigationItem.title = @"AudioMG-Online";
            }
            else{
                weakself.onoffSwitch.on = NO;
                weakself.navigationItem.title = @"AudioMG-Offline";
                [weakself insertRowTable:weakself.localAudioMA withNumberOfRows:[weakself.localAudioMA count]];
            }
    };
    
    [[ServerManager sharedManager] authorizeUser:accessTokenBlock];
}

-(void)getAudioSearch:(NSString*)searchStr{
    NSInteger offset = [self.tracks count] + ADDAUDIO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[ServerManager sharedManager] getAudioSearch:searchStr autoTextEditing:0
                                    performerOnly:0
                                             sort:ServerManagerSortPop
                                        searchOwn:0
                                           offset:offset
                                            count:ADDAUDIO
                                        onSuccess:^(NSArray * _Nullable audioItems, NSInteger numberOfAudio) {
                                            
                                            __weak AudioTableViewController* weakSelf = self;
                                            self.audioItems = audioItems;
                                            [self.tracks addObjectsFromArray:[self parseAudioArray:audioItems]];
                                            
                                            self.nextUpdateRow = 0;
                                            if([self.tracks count] > [self.audioItems count])
                                            {
                                                self.nextUpdateRow = [self.tracks count] - 5;
                                            }
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                
                                                [weakSelf insertRowTable:weakSelf.tracks withNumberOfRows:[weakSelf.audioItems count]];
                                            });
                                        } onFailure:^(NSError * _Nullable error, NSInteger statusCode) {
                                            
                                            NSLog(@"%@%ld",[error localizedDescription],(long)statusCode);
                                        }];
}

#pragma mark - parse

-(NSArray<Track*>*_Nullable)parseAudioArray:(NSArray*)array{
    NSMutableArray* mArray = nil;
    if(array)
    {
        mArray = [[NSMutableArray alloc]init];
        for (NSDictionary*audioDict in array)
        {
            Track* track = [[Track alloc]init];
            track.artist = [audioDict objectForKey:kAudioDictionaryArtist];
            track.title = [audioDict objectForKey:kAudioDictionaryTitle];
            track.duration = [[audioDict objectForKey:kAudioDictionaryDuration] integerValue];
            track.url = [audioDict objectForKey:kAudioDictionaryURL];
            [mArray addObject:track];
        }
    }
    return mArray;
}

#pragma mark - update

-(void)startUpdateTable:(NSArray*)array{

    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger animationMode = arc4random() % 4;
        UITableViewRowAnimation animation = [self randomAnimationMode:animationMode];;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.tableView beginUpdates];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
        [self.tableView endUpdates];

    });
}

-(void)insertRowTable:(NSArray*)array withNumberOfRows:(NSInteger)numberOfRows{
    NSInteger startRow = [array count] - numberOfRows;
    NSMutableArray* mArrayIndexSet = [[NSMutableArray alloc]init];
    for(NSInteger i = startRow; i <[array count];i++)
    {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [mArrayIndexSet addObject:newIndexPath];
    }    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSInteger animationMode = arc4random() % 4;
        UITableViewRowAnimation animation = [self randomAnimationMode:animationMode];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [self.tableView beginUpdates];
        [self.tableView insertRowsAtIndexPaths:mArrayIndexSet withRowAnimation:animation];
        [self.tableView endUpdates];
    });
}


-(UITableViewRowAnimation)randomAnimationMode:(NSInteger)animationMode{
    UITableViewRowAnimation animation = UITableViewRowAnimationNone;
    switch(animationMode){
        case 0:
            animation = UITableViewRowAnimationBottom;
            break;
        case 1:
            animation = UITableViewRowAnimationFade;
            break;
        case 2:
            animation = UITableViewRowAnimationRight;
            break;
        case 3:
            animation = UITableViewRowAnimationLeft;
            break;
        case 4:
            animation = UITableViewRowAnimationTop;
            break;
            
        case 5:
            animation = UITableViewRowAnimationMiddle;
            break;
    }

    return animation;
}

#pragma  mark - UISearchBarDelegate

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
    
    return YES;
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{

    return [self.onoffSwitch isOn];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [searchBar setShowsCancelButton:YES animated:YES];
    
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    self.tracks = nil;
    [self.tableView reloadData];
    if([searchBar.text length])
    {
        if([ServerManager sharedManager].URLSessionDataTask)
        {
            [[ServerManager sharedManager].URLSessionDataTask cancel];
        }
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSCharacterSet* expectedCharSet = [NSCharacterSet URLQueryAllowedCharacterSet];
        NSString* searchStr = [searchBar.text stringByAddingPercentEncodingWithAllowedCharacters:expectedCharSet];
        [self getAudioSearch:searchStr];
    }
}


#pragma  mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   if([self.onoffSwitch isOn])
   {
        if([ServerManager sharedManager].URLSessionDataTask)
        {
            [[ServerManager sharedManager].URLSessionDataTask cancel];
        }

        Track* track =  [self.tracks objectAtIndex:indexPath.row];
        NSString* keyFile = track.url;
        
        __weak AudioTableViewController* weakSelf = self;
       
       NSDictionary* audioDict = nil;
       for (NSArray* array in self.localAudioMA)
       {
           if([[array firstObject] isEqualToString:keyFile])
           {
               audioDict = [array lastObject];
           }
       }
       
       NSData* datafFile = [audioDict objectForKey:kAudioPlayerDictionaryPropertyFileData];
        __block AudioPlayer* audioPlayer = nil;
       if(datafFile)
       {
           audioPlayer = [[AudioPlayer alloc]initWithData:datafFile];
       }
        if(!audioPlayer)
        {
            [self.activityIndicator startAnimating];
            NSURL* url = [NSURL URLWithString:keyFile];
            [[ServerManager sharedManager] downLoadAudioTrack:url onSuccess:^(NSURL * _Nullable filePath) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.activityIndicator stopAnimating];
                    AudioPlayer* audioPlayer = [[AudioPlayer alloc]initWithContentsOfURL:filePath];
                    audioPlayer.titleTrack = track.title;
                    audioPlayer.artist = track.artist;
                    NSData* dataFile = [[NSData alloc]initWithContentsOfURL:filePath];
                    NSString* path = [NSString stringWithFormat:@"%@",keyFile];
                    
                    NSDictionary* audioDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                track.title,kAudioPlayerDictionaryPropertyTitleTrack,
                                                track.artist,kAudioPlayerDictionaryPropertyArtist,
                                                dataFile,kAudioPlayerDictionaryPropertyFileData,
                                                path,kAudioPlayerDictionaryPropertyFilePath,nil];
                    
                    NSArray* audioArray = [[NSArray alloc]initWithObjects:path,audioDictionary, nil];
                    [weakSelf.localAudioMA addObject:audioArray];
                    [weakSelf saveAudioCash];
                    [weakSelf player:audioPlayer];
                });
            } onFailure:^(NSError * _Nullable error, NSInteger statusCode) {
               //Дебаг NSLog(@"didSelectRowAtIndexPath error %@ statusCode = %ld",[error localizedDescription],[error code]);
                [weakSelf.activityIndicator stopAnimating];
            }];
        }
        else{
            [self player:audioPlayer];
        }
       
       
   }
   else{
       NSDictionary* audioDict = [[self.localAudioMA objectAtIndex:indexPath.row] lastObject];
       NSData* dataFile = [audioDict objectForKey:kAudioPlayerDictionaryPropertyFileData];
       AudioPlayer* audioplayer = [[AudioPlayer alloc]initWithData:dataFile];
       audioplayer.titleTrack = [audioDict objectForKey:kAudioPlayerDictionaryPropertyTitleTrack];
       audioplayer.artist = [audioDict objectForKey:kAudioPlayerDictionaryPropertyArtist];
       [self player:audioplayer];
   }
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 75.f;
}


#pragma  mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.onoffSwitch isOn] ? [self.tracks count] : [self.localAudioMA count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   if([self.onoffSwitch isOn] && indexPath.row > [self.tracks count] - 3  && indexPath.row > self.nextUpdateRow)
   {
       [self getAudioSearch:self.searchBar.text];
   }
    static NSString *identifierCellFile = @"TrackCell";

  __block  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierCellFile];
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifierCellFile];
    }
    if([self.onoffSwitch isOn])
    {
        Track*track = [self.tracks objectAtIndex:indexPath.row];
        cell.textLabel.text  = track.title;
        cell.detailTextLabel.text = track.artist;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            
            //Фото default
            UIImage* image =nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(image)
                {
                        cell.imageView.image = image;
                }else{
                    cell.imageView.image = [UIImage imageNamed:@"imageCellDefault.png"];
                }
            });
                           });
    }
    else{
        NSDictionary* audioDict = [[self.localAudioMA objectAtIndex:indexPath.row] lastObject];
        NSString* filePath =  [audioDict objectForKey:kAudioPlayerDictionaryPropertyFilePath];
        NSURL* urlFile = [NSURL fileURLWithPath:filePath];
        
        cell.textLabel.text = [audioDict objectForKey:kAudioPlayerDictionaryPropertyTitleTrack];
        cell.detailTextLabel.text = [audioDict objectForKey:kAudioPlayerDictionaryPropertyArtist];
        __weak AudioTableViewController* weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
            UIImage* image = [weakSelf localAudioArt:urlFile];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(image)
                {
                    cell.imageView.image = image;
                }else{
                    cell.imageView.image = [UIImage imageNamed:@"imageCellDefault.png"];
                }
            });
        });
    }
    
    if(indexPath.row % 2)
    {
        cell.backgroundColor = [self customColorWithRed:255.f green:255.f blue:0.f alpha:0.5f];
    }else{
        cell.backgroundColor = [UIColor colorWithRed:0.f green:122.f blue:255.f alpha:0.5f];
    }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - start audioPlayer
-(void)player:(AudioPlayer*)audioPlayer{
    AudioPlayerController* audioPlayerController = [[AudioPlayerController alloc]initWithPlayer:audioPlayer];
    
    [self.navigationController pushViewController:audioPlayerController animated:YES];
}

#pragma mark - AudioDictionaryCashUserDefaults

-(void)saveAudioCash{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kAudioPlayerArray];
    NSArray* array = [[NSArray alloc]initWithArray:self.localAudioMA];
                [userDefaults setObject:array forKey:kAudioPlayerArray];
}

-(void)loadAudioCash{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    self.localAudioMA =[[NSMutableArray alloc] initWithArray:[userDefaults objectForKey:kAudioPlayerArray]];
   }

#pragma mark - NotificationCenter

- (void)changeEdgeInsetsTableScrollViewWhenWillShownKeyBoardNotification:(NSNotification *)notification{
    NSDictionary *NotificationUserInfo = [notification userInfo];
    NSValue *rect =[NotificationUserInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyBoardBounds;
    [rect getValue:&keyBoardBounds];
    CGFloat bottomEfge = keyBoardBounds.size.height;
    [self changeEdge:YES newEdge:bottomEfge];
}

- (void)changeEdgeInsetsTableScrollViewWhenWillHideKeyBoardNotification:(NSNotification *)notification{
    [self changeEdge:NO newEdge:0];
}

- (void) changeEdge:(BOOL)ShownKeyBoard newEdge:(CGFloat)newEdge{
    UIEdgeInsets rectEdge;
    if(ShownKeyBoard)
    {
       rectEdge = UIEdgeInsetsMake(0.f, 0.f, newEdge, 0.f);
    }
    else{
       rectEdge = UIEdgeInsetsZero;
    }
    self.tableView.contentInset = rectEdge;
    self.tableView.scrollIndicatorInsets = rectEdge;
}



#pragma mark - Audio Tag Parser
//TODO
-(UIImage*_Nullable)localAudioArt:(NSURL*)audioPath{
/*
    NSURL* url = audioPath;
    AudioFileID audioFile;
    OSStatus theErr = noErr;
    theErr = AudioFileOpenURL((__bridge CFURLRef)url, kAudioFileReadPermission, 0, &audioFile);
    assert(theErr == noErr);
    UInt32 dictionarySize = 0;
    theErr = AudioFileGetPropertyInfo(audioFile, kAudioFilePropertyInfoDictionary, &dictionarySize, 0);
    
    CFDataRef dataRef;
    theErr = AudioFileGetProperty(audioFile, kAudioFilePropertyAlbumArtwork, &dictionarySize, &dataRef);
    
     assert (theErr == noErr);
    
    CGDataProviderRef imgProvider = CGDataProviderCreateWithCFData(dataRef);
    CGImageRef imageRef = CGImageCreateWithPNGDataProvider(imgProvider, NULL, true, kCGRenderingIntentDefault);
    UIImage* image = [[UIImage alloc]initWithCGImage:imageRef];
    
    CFRelease (dataRef);
    theErr = AudioFileClose (audioFile);
    assert (theErr == noErr);
    return image;
 */
    return nil;
}
@end
