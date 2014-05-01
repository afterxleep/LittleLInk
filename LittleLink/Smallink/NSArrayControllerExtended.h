//
//  NSArrayControllerExtended.h
//  LittleLink
//
//  Created by Daniel Bernal on 5/05/13.
//  Copyright (c) 2013 Banshai SAS. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NSArrayControllerExtended;
@protocol NSArrayControllerExtendedDelegate <NSObject>

@optional
- (void)arrayControllerExtended:(NSArrayControllerExtended *)arrayControllerExtended didAddObject:(BOOL)flag;
@end

@interface NSArrayControllerExtended : NSArrayController {
    NSString *bar;
    id <NSArrayControllerExtendedDelegate> delegate;
}

@property (strong) id <NSArrayControllerExtendedDelegate> delegate;

- (IBAction)addAndNotify:(id)sender;
- (void)objectAdded: (NSNotification *)note;

@end




