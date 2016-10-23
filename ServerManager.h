//
//  ServerManager.h
//  AudioMG
//
//  Created by EnzoF on 16.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum{
    ServerManagerSortAddingDate  = 0,
    ServerManagerSortAudioLength = 1,
    ServerManagerSortPop         = 2
}ServerManagerSortType;

@interface ServerManager : NSObject


@property (nonatomic,strong) NSURLSessionDataTask * _Nullable URLSessionDataTask;
@property (nonatomic,strong) NSURLSessionDownloadTask * _Nullable URLSessionDownloadTask;
@property (nonatomic,strong) NSURLSession *_Nullable URLSession;
@property (nonatomic,strong) NSURL *_Nullable baseURL;


+(ServerManager*_Nonnull)sharedManager;

-(void)getAudioSearch:(NSString*_Nonnull)searchStr
      autoTextEditing:(BOOL)autoComplete
        performerOnly:(BOOL)performerOnly
                 sort:(ServerManagerSortType)sort
            searchOwn:(BOOL)searchOwn
               offset:(NSUInteger)offset
                count:(NSUInteger)count
            onSuccess:(void (^_Nullable)(NSArray*_Nullable audioItems, NSInteger numberOfAudio))success
            onFailure:(void (^_Nullable)(NSError*_Nullable error,NSInteger statusCode))failure;


-(void)downLoadAudioTrack:(NSURL*_Nonnull)url
                onSuccess:(void (^_Nullable)(NSURL*_Nullable filePath))success
                onFailure:(void (^_Nullable)(NSError*_Nullable error,NSInteger statusCode))failure;



-(void)authorizeUser:(void (^_Nullable)(BOOL isEmptyAccessToken))AccessTokenBlock;

@end
