//
//  VLocationManager.h
//  VLocationDemo
//
//  Created by Vols on 15/3/17.
//  Copyright (c) 2015年 Vols. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

#define kIOS8               ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) ? YES : NO

typedef void(^CompletionBlock)(NSString *lat,NSString *lng);
typedef void(^FailBlock)(NSString *errorString, NSUInteger Code);

@interface VLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation        *startPoint;

+ (id)sharedInstance;

- (void)getUserPos:(CompletionBlock)completion failure:(FailBlock)failure;
//- (void)getUserPosWithFailure:(FailBlock)failure;

- (void)start;
- (void)stop;

@end
