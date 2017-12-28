//
//  AppDelegate.m
//  LaunchVideoAdvertisement
//
//  Created by houke on 2017/12/27.
//  Copyright © 2017年 personal. All rights reserved.
//

#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"
#import "ViewController.h"

@interface AppDelegate ()<CAAnimationDelegate,AVPlayerItemOutputPullDelegate>

@end

@implementation AppDelegate{
    AVPlayerItem *playerItem ;
    AVPlayer *player;
    AVPlayerLayer *playerLayer;
}

-(void)downLoadVideo
{
    //初始化manager对象：
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
//    NSURL *url = [NSURL URLWithString:@"http://p1b0tkq2t.bkt.clouddn.com/dw.mp4"];
    //    NSURL *url = [NSURL URLWithString:@"http://flv2.bn.netease.com/videolib3/1510/29/pBDMm5528/SD/pBDMm5528-mobile.mp4"];
        NSURL *url = [NSURL URLWithString:@"http://p1b0tkq2t.bkt.clouddn.com/WeChatSight78.mp4"];
    
    //开始请求数据
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //创建downloadtask
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *videoPath = [path stringByAppendingPathComponent:@"LaunchVideos"];
        [[NSFileManager defaultManager] createDirectoryAtPath:videoPath withIntermediateDirectories:YES attributes:nil error:nil];
        
        //删除上一个视频地址
        NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:videoPath error:nil];
        if (files.count>0) {
            NSString *lastVideoPath = [NSString stringWithFormat:@"%@/%@",videoPath,files[0]];
            [[NSFileManager defaultManager] removeItemAtPath:lastVideoPath error:nil];
        }
        
        
        //绝对路径
        return [[NSURL fileURLWithPath:videoPath] URLByAppendingPathComponent:[response suggestedFilename]];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *videoPath = [path stringByAppendingPathComponent:@"LaunchVideos"];
        NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:videoPath error:nil];

        NSLog(@"------%@",files);
    }];
    
    //开始下载
    [downloadTask resume];
}

-(void)playerItemDidReachEnd:(id)sender
{
    NSLog(@"sdddddddd");
    //    CABasicAnimation *animation2 = [CABasicAnimation animation];
    //    animation2.keyPath = @"transform.scale";
    //    animation2.duration = 2.0;
    //    animation2.toValue = @2.0;
    //    animation2.delegate = self;
    //
    //    animation2.removedOnCompletion = NO;
    //    animation2.fillMode = kCAFillModeForwards;
    //    [self.window.layer addAnimation:animation2 forKey:@"scale"];
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 2.0;
    animation.byValue = @(M_PI * 2);
    animation.delegate = self;
    
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [self.window.layer addAnimation:animation forKey:@"rotateAnimation"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [playerLayer removeFromSuperlayer];
    });
    
    
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
    [self downLoadVideo];
    
    ViewController *vc = [[ViewController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor greenColor];
    view.frame = self.window.bounds;
    [self.window addSubview:view];
    
    
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *videoPath = [path stringByAppendingPathComponent:@"LaunchVideos"];
    NSArray *files = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:videoPath error:nil];
    if (files.count>0) {
        NSString *mp4Path = files?[NSString stringWithFormat:@"%@/%@",videoPath,files[0]]:@"";
        NSURL *videoURL = [NSURL fileURLWithPath:mp4Path];
        player = [AVPlayer playerWithURL:videoURL];
        playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        playerItem = [AVPlayerItem playerItemWithURL:videoURL];
        playerLayer.frame = self.window.bounds;
        playerLayer.backgroundColor = [UIColor yellowColor].CGColor;
        [view.layer addSublayer:playerLayer];
        [player play];
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
