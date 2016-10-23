//
//  ServerManager.m
//  AudioMG
//
//  Created by EnzoF on 16.10.16.
//  Copyright © 2016 EnzoF. All rights reserved.
//

#import "ServerManager.h"
#import "AuthenticationController.h"
#import "AccessToken.h"

@interface ServerManager ()

@property (nonatomic,strong) AccessToken *accessToken;


@end

@implementation ServerManager

+(ServerManager*)sharedManager{
    static ServerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ServerManager alloc]init];
        manager.baseURL = [[NSURL alloc]initWithString:@"https://api.vk.com/method/"];
    });
    return manager;
}

-(NSURLSession*)URLSession{
    if(!_URLSession)
    {
        _URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    }
    return _URLSession;
}



-(void)getAudioSearch:(NSString*)searchStr
      autoTextEditing:(BOOL)autoComplete
        performerOnly:(BOOL)performerOnly
                 sort:(ServerManagerSortType)sort
            searchOwn:(BOOL)searchOwn
               offset:(NSUInteger)offset
                count:(NSUInteger)count
            onSuccess:(void (^)(NSArray *audioItems, NSInteger numberOfAudio))success
            onFailure:(void (^)(NSError *error,NSInteger statusCode))failure{
    
            NSString*URLstr =[NSString stringWithFormat:@"%@?"
                                                        "q=%@&"
                                                        "auto_complete=%d&"     
                                                        "lyrics=%d&"            
                                                        "performer_only=%d&"
                                                        "sort=%d&"              
                                                        "search_own=%d&"        
                                                        "offset=%lu&"
                                                        "count=%lu&"
                                                        "access_token=%@",
                                                        @"audio.search",
                                                        searchStr,
                                                        autoComplete,
                                                        performerOnly,
                                                        sort,
                                                        searchOwn,
                                                        searchOwn,
                                                        (unsigned long)offset,
                                                        (unsigned long)count,
                                                        self.accessToken.token];
    
    [self POST:URLstr
     onSuccess:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObj, NSData * _Nullable data)
    {
        self.URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
       // NSLog(@"JSON: %@ длина данных %d",responseObj,data.length);  //Дебаг
        
        NSError* error = nil;
        NSArray* array = [[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]objectForKey:@"response"];
        NSMutableArray* mArray = [[NSMutableArray alloc]initWithArray:array];
        if(error)
        {
            NSLog(@"JSONObjectWithData:%@",[error localizedDescription]); //Дебаг
        }
        else{
            
            NSInteger count = [[mArray firstObject] integerValue];
            [mArray removeObjectAtIndex:0];
            NSArray* audioArray = [NSArray arrayWithArray:mArray];
            success(audioArray,count);
           // NSLog(@"%@",mArray);            //Дебаг
        }
        

    } onFailure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        failure(error,[error code]);
        //NSLog(@"Error: %@ statusCode %d",[error description],[task.error code]);        //Дебаг
    }];
    
}

-(void)downLoadAudioTrack:(NSURL*)url
                onSuccess:(void (^)(NSURL *filePath))success
                onFailure:(void (^)(NSError *error,NSInteger statusCode))failure{
    

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    
    self.URLSessionDownloadTask = [self downloadTastWithRequest:urlRequest
                                          completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                                                    if(error)
                                                    {
                                                        failure(error,[error code]);
                                                    }else{
                                                        success(filePath);
                                                    }
    }];
    
}


-(NSURLSessionDataTask*__nullable)POST:(NSString*__nonnull)URLString
                            onSuccess:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObj,NSData * _Nullable data))success
                            onFailure:(void (^_Nullable)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error))failure{
    
    if(self.URLSessionDataTask)
    {
        [self.URLSessionDataTask cancel];
    }
    NSURL *url;
    if(self.baseURL)
    {
        url = [[NSURL alloc]initWithString:URLString relativeToURL:self.baseURL];
    }
    else
    {
        url = [NSURL URLWithString:URLString];
    }
    url = [NSURL URLWithString:[url absoluteString]];

    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSString * params = URLString;
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"URL %@",[url absoluteString]);
    __weak NSURLSessionDataTask* weakURLSessionDataTask = self.URLSessionDataTask;
    self.URLSessionDataTask = [self.URLSession dataTaskWithRequest:urlRequest
                                                 completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error)
        {
            failure(weakURLSessionDataTask,error);
        }
        else
        {
//            NSArray* array = [[NSJSONSerialization JSONObjectWithData:data
//                                                              options:0
//                                                                error:&error]objectForKey:@"response"]; //Дебаг
           // NSLog(@"%@",array);//Дебаг

            success(weakURLSessionDataTask,response,data);
        }
    }];
    if(self.URLSessionDataTask)
    {
        [self.URLSessionDataTask resume];
    }
    
    return self.URLSessionDataTask;
}



-(NSURLSessionDownloadTask*__nullable)downloadTastWithRequest:(NSURLRequest*)request
                                            completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler
{
    
    if(self.URLSessionDownloadTask)
    {
        [self.URLSessionDownloadTask cancel];
    }
    
    self.URLSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
     __weak ServerManager *weekSelf = self;
    dispatch_queue_t queue = dispatch_queue_create("AudioMG.queue.DownLoadTask", DISPATCH_QUEUE_SERIAL);
    dispatch_sync(queue, ^{
        weekSelf.URLSessionDownloadTask = [self.URLSession downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            
            NSURL *destinationURL = nil;
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, true) firstObject];
            NSURL* url = [NSURL URLWithString:[weekSelf.URLSessionDownloadTask.originalRequest.URL absoluteString]];
            if(url)
            {
                NSString *lastComponent = url.lastPathComponent;
                destinationURL = [[NSURL alloc]initFileURLWithPath:[documentsPath stringByAppendingPathComponent:lastComponent]];
                NSError *error = nil;
                if(destinationURL)
                {
                    if(error)
                    {
                        NSLog(@"destinationURL error %@",[error localizedDescription]);
                        NSLog(@"path %@",[destinationURL filePathURL]);
                    }
                    error = nil;
                    if(location)
                    {
                        [[NSFileManager defaultManager] moveItemAtURL:location toURL:destinationURL error:&error];
                    }
                    if(error)
                    {
                        NSLog(@"atURL = %@ destinationURL = %@ error %@",location,[destinationURL absoluteString],[error localizedDescription]);
                    }
                }
            }
        
            completionHandler(response,destinationURL,error);
        }];
    });
    if(self.URLSessionDownloadTask)
    {
        [self.URLSessionDownloadTask resume];
    }
    
    return self.URLSessionDownloadTask;
}


-(void)authorizeUser:(void (^_Nullable)(BOOL isEmptyAccessToken))AccessTokenBlock{
    if(self.accessToken.token)
    {
        AccessTokenBlock(YES);
    }
    else{
        __weak ServerManager *weakSelf = self;
        AuthenticationController *authVC = [[AuthenticationController alloc]initWithCompletionBlock:^(AccessToken *token) {
            weakSelf.accessToken = token;
            if(weakSelf.accessToken)
            {
                AccessTokenBlock(YES);
            }
            else{
                AccessTokenBlock(NO);
            }
            
        }];
        UINavigationController *navC =[[UINavigationController alloc]initWithRootViewController:authVC];
        UIViewController *mainC = [[[[UIApplication sharedApplication] windows] firstObject] rootViewController];
        [mainC presentViewController:navC animated:YES completion:nil];
    }

}

@end
