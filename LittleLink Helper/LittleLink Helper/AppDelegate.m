//
//  AppDelegate.m
//  LittleLink Helper
//
//  Created by Daniel Bernal on 16/05/13.
//  Copyright (c) 2013 Banshai SAS. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    [[NSWorkspace sharedWorkspace] launchApplication:@"/Applications/LittleLink.app/Contents/MacOS/LittleLink"];        
    [NSApp terminate:nil];
}

@end
