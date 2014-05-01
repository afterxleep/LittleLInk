//
//  AppDelegate.h
//  Smallink
//
//  Created by Daniel Bernal on 1/05/13.
//  Copyright (c) 2013 Banshai SAS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesWindowController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {
    IBOutlet NSMenu *statusMenu;
    NSStatusItem *statusItem;
    NSImage *statusImage;
    NSImage *statusHighlightImage;
    NSString *original_link;
    NSString *shortened_link;
    NSString *pasteBoardContents;
    NSPasteboard *pasteBoard;
    NSUserDefaults *userDefaults;
    IBOutlet NSMenuItem *autoShortMenuItem;
    IBOutlet NSMenuItem *manualShortMenuItem;
    IBOutlet NSMenuItem *manualShortMenuItemSeparator;
    IBOutlet NSMenuItem *displayNotificationsMenuItem;
    IBOutlet NSMenuItem *availableServicesMenuItem;
    IBOutlet NSMenuItem *launchAtLoginMenuItem;
    IBOutlet NSMenuItem *preferencesMenuItem;
    NSMutableData *receivedData;
    
    PreferencesWindowController *prefsWindow;
    

    
    int web_service;
}

@property (assign) IBOutlet NSWindow *window;
@property (strong) NSString *original_link;
@property (strong) NSString *shortened_link;
@property (strong) NSPasteboard *pasteBoard;
@property (strong) NSString *pasteBoardContents;
@property (strong) NSUserDefaults *userDefaults;
@property (strong) NSArray *availableServices;
@property (strong) NSMenuItem *autoShortMenuItem;
@property (strong) NSMenuItem *manualShortMenuItem;
@property (strong) NSMenuItem *manualShortMenuItemSeparator;
@property (strong) NSMenuItem *displayNotificationsMenuItem;
@property (strong) NSMenuItem *availableServicesMenuItem;
@property (strong) NSMenuItem *launchAtLoginMenuItem;
@property (strong) NSMenuItem *preferencesMenuItem;

@property (assign) int web_service;


- (IBAction) generateShortLinkManually:(id)sender;
- (IBAction) quit:(id)sender;
- (IBAction) setAutomaticBehavior:(id)sender;
- (IBAction) setNotificationsBehavior:(id)sender;
- (IBAction) changeShorteningService:(id)sender;
- (IBAction) changeLoginStatus:(id)sender;
- (IBAction) showPreferences:(id)sender;

- (BOOL) isValidLink:(NSString *)link;
- (BOOL) hasExcludedText:(NSString *)link;

- (void) generateIsGdShortlink;
- (void) generateGooGlShortlink;
- (void) generateToLyShortlink;
- (void) generateUrCxShortlink;
- (void) generateTinyurlComLink;

- (void) copyToClipBoard;
- (void) displayError:(NSString *)error;
- (void) showNotificationWithTitle:(NSString *)title andText:(NSString*)text;
- (void) pollPasteBoard;


@end
