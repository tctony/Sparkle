//
//  SUCommandLineDriver.m
//  sparkle-cli
//
//  Created by Mayur Pawashe on 4/10/16.
//  Copyright © 2016 Sparkle Project. All rights reserved.
//

#import "SUCommandLineDriver.h"
#import <Sparkle/Sparkle.h>
#import "SUCommandLineUserDriver.h"

@interface SUCommandLineDriver () <SUUpdaterDelegate>

@property (nonatomic, readonly) SUUpdater *updater;
@property (nonatomic, readonly) NSString *applicationBundlePath;

@end

@implementation SUCommandLineDriver

@synthesize updater = _updater;
@synthesize applicationBundlePath = _applicationBundlePath;

- (instancetype)initWithUpdateBundlePath:(NSString *)updateBundlePath applicationBundlePath:(nullable NSString *)applicationBundlePath updatePermission:(nullable SUUpdatePermission *)updatePermission deferInstallation:(BOOL)deferInstallation verbose:(BOOL)verbose
{
    self = [super init];
    if (self != nil) {
        NSBundle *updateBundle = [NSBundle bundleWithPath:updateBundlePath];
        if (updateBundle == nil) {
            return nil;
        }
        
        NSBundle *applicationBundle = nil;
        if (applicationBundlePath == nil) {
            applicationBundle = updateBundle;
        } else {
            applicationBundle = [NSBundle bundleWithPath:(NSString * _Nonnull)applicationBundlePath];
            if (applicationBundle == nil) {
                return nil;
            }
        }
        
        _applicationBundlePath = applicationBundle.bundlePath;
        
        id <SUUserDriver> userDriver = [[SUCommandLineUserDriver alloc] initWithApplicationBundle:applicationBundle updatePermission:updatePermission deferInstallation:deferInstallation verbose:verbose];
        _updater = [[SUUpdater alloc] initWithHostBundle:updateBundle userDriver:userDriver delegate:self];
    }
    return self;
}

- (BOOL)updaterShouldInheritInstallPrivileges:(SUUpdater *)__unused updater
{
    return YES;
}

- (NSString *)pathToRelaunchForUpdater:(SUUpdater *)__unused updater
{
    return self.applicationBundlePath;
}

- (void)runAndCheckForUpdatesNow:(BOOL)checkForUpdatesNow
{
    if (checkForUpdatesNow) {
        // When we start the updater, this scheduled check will start afterwards too
        [self.updater checkForUpdates];
    }
    
    NSError *updaterError = nil;
    if (![self.updater startUpdater:&updaterError]) {
        fprintf(stderr, "Error: Failed to initialize updater with error (%ld): %s\n", updaterError.code, updaterError.localizedDescription.UTF8String);
        exit(EXIT_FAILURE);
    }
}

@end
