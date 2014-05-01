//
//  WindowController.h
//  LittleLink
//
//  Created by Daniel Bernal on 5/05/13.
//  Copyright (c) 2013 Banshai SAS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSArrayControllerExtended.h"

@interface PreferencesWindowController : NSWindowController <NSTableViewDelegate, NSArrayControllerExtendedDelegate> {
    
    NSUserDefaults *userDefaults;
    
}

@property (strong) NSUserDefaults *userDefaults;
@property (strong) IBOutlet NSArrayControllerExtended *arrayController;
@property (strong) IBOutlet NSTableView *tableView;



@end
