//
//  DBResources.m
//  DBQRCode
//
//  Created by bob on 2019/4/4.
//

#import "DBResources.h"

#define BUNDLE_NAME @"DBQRCode.bundle"

@interface DBResources  ()

@property (nonatomic, copy) NSString * bundlePath;


@end

@implementation DBResources

+ (instancetype)sharedInstance {
    static DBResources *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
        sharedInstance.bundlePath = [[NSBundle bundleForClass:[self class]].resourcePath stringByAppendingPathComponent:BUNDLE_NAME];;
    });

    return sharedInstance;
}

+ (UIImage *)imageNamed:(NSString *)imageName {
    NSBundle *resource_bundle = [NSBundle bundleWithPath:[DBResources sharedInstance].bundlePath];
    return [UIImage imageNamed:imageName inBundle:resource_bundle compatibleWithTraitCollection:nil];;
}

@end
