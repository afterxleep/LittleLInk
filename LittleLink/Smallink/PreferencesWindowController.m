//
//  WindowController.m
//  LittleLink
//
//  Created by Daniel Bernal on 5/05/13.
//  Copyright (c) 2013 Banshai SAS. All rights reserved.
//

#import "PreferencesWindowController.h"

@interface PreferencesWindowController ()

@end

@implementation PreferencesWindowController

@synthesize userDefaults;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.arrayController.delegate = self;
}

- (void)arrayControllerExtended:(NSArrayControllerExtended *)arrayControllerExtended didAddObject:(BOOL)addObject {
 
    NSLog(@"Object Added to the table"); 
    [[self tableView] editColumn:0
                             row:[self.tableView numberOfRows] -1
                          withEvent:nil
                          select:YES];
    
}

@end
