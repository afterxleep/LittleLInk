//
//  NSArrayControllerExtended.m
//  LittleLink
//
//  Created by Daniel Bernal on 5/05/13.
//  Copyright (c) 2013 Banshai SAS. All rights reserved.
//

#import "NSArrayControllerExtended.h"

@implementation NSArrayControllerExtended

@synthesize delegate;

/*** Add an item to the arrayController and posts
a notification via Notification Center ***/
- (IBAction)addAndNotify:(id)sender {
        
    //Listen to Notification Center
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(objectAdded:)
                                                 name: @"Object Added"
                                               object: self];
    
    [super add:nil];
    
    //We use notification center to tell de delegate when things are ready
    //since is required for the run loop to end
    NSNotification * note = [NSNotification
                             notificationWithName: @"Object Added"
                             object: self];
    
    [[NSNotificationQueue defaultQueue] enqueueNotification: note
                                               postingStyle: NSPostWhenIdle];
    
    
    
}


- (void)objectAdded: (NSNotification *)note
{
    [self.delegate arrayControllerExtended:self didAddObject:YES];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
