//
//  VLocationManager.m
//  VLocationDemo
//
//  Created by Vols on 15/3/17.
//  Copyright (c) 2015年 Vols. All rights reserved.
//

#import "VLocationManager.h"

@interface VLocationManager ()

@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, copy) FailBlock failBlock;

@end

@implementation VLocationManager

+(id)sharedInstance{
    static VLocationManager *instance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id) init {
    self = [super init];
    if (self != nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 100;
        
        if (kIOS8) {
            [_locationManager requestAlwaysAuthorization];
        }
    }
    return self;
}

- (void)start{
    [_locationManager startUpdatingLocation];
}

- (void)stop{
    [_locationManager stopUpdatingLocation];
}

-(void)getUserPos:(CompletionBlock)completion failure:(FailBlock)failure{
    _completionBlock = [completion copy];
    _failBlock = [failure copy];
}

- (void)getUserPosWithFailure:(FailBlock)failure{
    _failBlock = [failure copy];
}


#pragma mark - CLLocation Delegate Methods


#ifdef __IPHONE_8_0
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status)
    {
        case kCLAuthorizationStatusNotDetermined:
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
            {
                [_locationManager requestWhenInUseAuthorization]; //用这个方法，plist里要加字段NSLocationWhenInUseUsageDescription
            }
            break;
        default:
            break;
    }
}
#endif


-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (_startPoint == nil) {
        self.startPoint = newLocation;
    }
    
    NSString *latitude = [NSString stringWithFormat:@"%g\u00B0",newLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%g\u00B0",newLocation.coordinate.longitude];
    
    if(_completionBlock){
        _completionBlock(latitude, longitude);
    }
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    BOOL shouldQuit;
    NSMutableString *errorString = [[NSMutableString alloc] init];
    NSUInteger code = 404;
    
    if ([error domain] == kCLErrorDomain) {
        
        switch ([error code]) {
                
            case kCLErrorDenied:{
                [errorString appendFormat:@"%@\n", @"LocationDenied"];
                [errorString appendFormat:@"%@\n", @"AppWillQuit"];
                shouldQuit = YES;
                code = 400;
                break;
            }
                
            case kCLErrorLocationUnknown:{
                [errorString appendFormat:@"%@\n", @"LocationUnknown"];
                [errorString appendFormat:@"%@\n", @"AppWillQuit"];
                shouldQuit = YES;

                break;
            }
            default:
                [errorString appendFormat:@"%@ %ld\n", @"GenericLocationError", (long)[error code]];
                shouldQuit = NO;
                break;
        }
        
    }else {
        
        [errorString appendFormat:@"Error domain: \"%@\"  Error code: %ld\n", [error domain], (long)[error code]];
        [errorString appendFormat:@"Description: \"%@\"\n", [error localizedDescription]];
        shouldQuit = NO;
    }
    
    // TODO: Send the delegate the alert?
    if (shouldQuit) {
        // do nothing
    }
    
    _failBlock(errorString, code);
}

@end
