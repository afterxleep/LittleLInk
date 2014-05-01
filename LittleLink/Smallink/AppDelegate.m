//
//  AppDelegate.m
//  Smallink
//
//  Created by Daniel Bernal on 1/05/13.
//  Copyright (c) 2013 Banshai SAS. All rights reserved.
//

#import "AppDelegate.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation AppDelegate

@synthesize pasteBoard, original_link, shortened_link, web_service, autoShortMenuItem, userDefaults, pasteBoardContents, manualShortMenuItem, manualShortMenuItemSeparator, displayNotificationsMenuItem, availableServicesMenuItem, launchAtLoginMenuItem, preferencesMenuItem, availableServices;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application

    //Initializes pasteboard
    self.pasteBoard = [NSPasteboard generalPasteboard];
    [self.pasteBoard clearContents];
    
    //Initializes user Defaults
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    //Initializes Available services
    availableServices = [[NSArray alloc] initWithObjects:@"is.gd", @"su.pr", @"goo.gl", @"to.ly", @"ur.cx", @"tinyurl.com", nil];
    
    //If the app has not launched, configure defaults
    if (![self.userDefaults boolForKey:@"ALREADY_LAUNCHED"]) {
        [self.userDefaults setBool:YES forKey:@"ALREADY_LAUNCHED"];
        [self.userDefaults setBool:YES forKey:@"SHORT_AUTOMATICALLY"];
        [self.userDefaults setInteger:10 forKey:@"SERVICE"];  //Set to be is.gd by default
        [self.userDefaults setBool:NO forKey:@"DISPLAY_NOTIFICATIONS"];
        [self.userDefaults setBool:NO forKey:@"LAUNCH_AT_LOGIN"];

        //Set the first menu to be the default
        [[[[[[availableServicesMenuItem menu] itemWithTag:1] submenu] itemArray] objectAtIndex:0] setState:1];
        
        //Set the default exclusions
        NSArray *default_exclusions = [[NSArray alloc] initWithObjects:
                                       @"j.mp",
                                       @"dlvr.it",
                                       @"own.li",
                                       @"v.gd",
                                       @"cl.ly",
                                       @"t.co",
                                       @"ow.ly",
                                       @"lnk.in",
                                       @"tokn.co",
                                       @"loopu.in",
                                       @"zite.to",
                                       @"4sq.com",
                                       @"youtu.be",
                                       @"dropbox.com",
                                       @"localhost",
                                       @"127.0.0.1",
                                       nil];
        NSMutableArray *exclusions = [[NSMutableArray alloc] init];

        for (id object in default_exclusions) {
            [exclusions addObject:[NSDictionary dictionaryWithObjectsAndKeys:object, @"url", nil]];
        }
        [self.userDefaults setObject:exclusions forKey:@"EXCLUDED_STRINGS"];
    }
        
    [self.userDefaults synchronize];
    
    //Select the enabled service in the menu
    NSArray *services = [[[[availableServicesMenuItem menu] itemWithTag:1] submenu] itemArray];
    //Select the current service
    for (id object in services) {
        if ([object tag] == [self.userDefaults integerForKey:@"SERVICE"]) {
            [object setState:1];
        }
    }
    
    //Shows the manual menu if automatic is disabled
    if (![self.userDefaults boolForKey:@"SHORT_AUTOMATICALLY"]) {
        //Disable Manual Menu By Default
        [self.manualShortMenuItem setHidden:NO];
        [self.manualShortMenuItemSeparator setHidden:NO];
        [self.autoShortMenuItem setState:0];
    }
    
    //Shows the manual menu if automatic is disabled
    [self.displayNotificationsMenuItem setState:2];
    if (![self.userDefaults boolForKey:@"DISPLAY_NOTIFICATIONS"]) {
        [self.displayNotificationsMenuItem setState:0];
    }
    
    //Disable the "Launch at login" if not configured
    [self.launchAtLoginMenuItem setState:1];
    if (![self.userDefaults boolForKey:@"LAUNCH_AT_LOGIN"]) {
        [self.launchAtLoginMenuItem setState:0];
    }
    
    //Set the timer
    [NSTimer scheduledTimerWithTimeInterval:2
                                     target:self
                                   selector:@selector(pollPasteBoard)
                                   userInfo:nil
                                    repeats:YES];
    
    
    //Sets up notifications delegate
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
    
}

- (void)awakeFromNib {
    
    //Sets up the app Interface
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    statusImage = [NSImage imageNamed:@"228"];
    statusHighlightImage = [NSImage imageNamed:@"230"];
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
    [statusItem setMenu:statusMenu];
    [statusItem setToolTip:@"Link"];
    [statusItem setHighlightMode:YES];

}

- (IBAction) setAutomaticBehavior:(id)sender {
    switch ([sender state]) {
        case 1:
            [self.userDefaults setBool:NO forKey:@"SHORT_AUTOMATICALLY"];
            [self.autoShortMenuItem setState:0];
            [self.manualShortMenuItem setHidden:0];
            [self.manualShortMenuItemSeparator setHidden:0];
        break;
        case 0:
            [self.userDefaults setBool:YES forKey:@"SHORT_AUTOMATICALLY"];
            [self.autoShortMenuItem setState:1];
            [self.manualShortMenuItem setHidden:1];
            [self.manualShortMenuItemSeparator setHidden:1];
        default:
            break;
    }
    [self.userDefaults synchronize];
}

- (IBAction) setNotificationsBehavior:(id)sender {
    switch ([sender state]) {
        case 1:
            NSLog(@"Disabiling notifications");
            [self.userDefaults setBool:NO forKey:@"DISPLAY_NOTIFICATIONS"];
            [self.displayNotificationsMenuItem setState:0];
            break;
        case 0:
            NSLog(@"Enabling notifications"); 
            [self.userDefaults setBool:YES forKey:@"DISPLAY_NOTIFICATIONS"];
            [self.displayNotificationsMenuItem setState:1];
        default:
            break;
    }
    [self.userDefaults synchronize];
}


- (IBAction) changeShorteningService:(id)sender {
        
    //Disable the selected items
    NSArray *services = [[sender menu] itemArray];
    for (id object in services) {
        [object setState:0];
    }
    
    //Select the current one
    [sender setState:1];
    
    //Set the selected service based on the tag
    [self.userDefaults setInteger:[sender tag] forKey:@"SERVICE"];
    [self.userDefaults synchronize];
    
    
    
    
}

- (IBAction) generateShortLinkManually:(id)sender {
    
    
    self.pasteBoardContents = [self.pasteBoard stringForType:NSPasteboardTypeString];
    if ([self isValidLink:self.pasteBoardContents]) {
        self.original_link = self.pasteBoardContents;
        [self generateShortLink];
    }
    else {
        [self displayError:@"Clipboard contents do not look like a valid URL"];
    }
    
}

- (IBAction)quit:(id)sender {
    [[NSApplication sharedApplication] terminate:nil];
}



- (BOOL) isValidLink:(NSString *)link {
    NSLog(@"%@", link);
    NSURL *candidateURL = [NSURL URLWithString:link];
    if (candidateURL && candidateURL.scheme && candidateURL.host) {
        return YES;
        
    }
    return NO;
    
}


- (BOOL) hasExcludedText:(NSString *)link {
    
    
    //Check if the URL is in the services list
    for (id object in availableServices) {
        NSLog(@"Checking %@ in services list ", object);
        
        NSRegularExpression *domain = [NSRegularExpression regularExpressionWithPattern:object options:NSRegularExpressionCaseInsensitive error:nil];
        
        NSUInteger numberOfMatches = [domain numberOfMatchesInString:link options:0 range:NSMakeRange(0, [link length])];
        
        if (numberOfMatches > 0) {
            NSLog(@"Url is excluded by service: %@", object);
            return YES;
        }
        
    }
    
    //Check if the URL is in the exlusions list
     for (id object in [userDefaults objectForKey:@"EXCLUDED_STRINGS"]) {
         NSLog(@"Checking %@", [object valueForKey:@"url"]);

         NSRegularExpression *domain = [NSRegularExpression regularExpressionWithPattern:[object valueForKey:@"url"] options:NSRegularExpressionCaseInsensitive error:nil];

         NSUInteger numberOfMatches = [domain numberOfMatchesInString:link options:0 range:NSMakeRange(0, [link length])];
         
         if (numberOfMatches > 0) {
             NSLog(@"Url is excluded based on: %@", [object valueForKey:@"url"]);
             return YES;
         }
     
     }
        
    return NO;

    
}


- (void) generateShortLink {
    
    NSLog(@"%li", (long)[self.userDefaults integerForKey:@"SERVICE"]);
    
    [statusItem setImage:[NSImage imageNamed:@"229"]];
    
    //Create a link based on the selected service
    switch ([self.userDefaults integerForKey:@"SERVICE"]) {
        case 10:
            NSLog(@"Generating link via is.gd");
            [self generateIsGdShortlink];
        break;
        case 20:
            NSLog(@"Generating link via goo.gl");
            [self generateGooGlShortlink];
        break;
        case 30:
            NSLog(@"Generating link via to.ly");
           [self generateToLyShortlink];
        break;
        case 40:
            NSLog(@"Generating link via ur.cx");
            [self generateUrCxShortlink];
        break;
        case 50:
            NSLog(@"Generating link via tinyurl");
            [self generateTinyurlComLink];
        break;
        case 60:
            NSLog(@"Generating link via SuPr");
            [self generateSuPrShortlink];
        break;

    
    }
    
}

- (void)copyToClipBoard {
    [self.pasteBoard clearContents];
    [self.pasteBoard writeObjects:[NSArray arrayWithObject:self.shortened_link]];
    NSLog(@"Link Ready! %@", self.shortened_link);
    
    [self showNotificationWithTitle:@"Link Ready!" andText:[NSString stringWithFormat:@"Your new LittleLink is ready and copied to the ClipBoard."]];
    

}


- (void)displayError:(NSString *)error {
    [self showNotificationWithTitle:@"Ooops!" andText:error];

}


-(void) showNotificationWithTitle:(NSString *)title andText:(NSString*)text {
    
    if ([self.userDefaults boolForKey:@"DISPLAY_NOTIFICATIONS"]) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        notification.title = title;
        notification.informativeText = text;
        notification.soundName = NSUserNotificationDefaultSoundName;
        
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];        
    }
    
    //Reset Icon
    [statusItem setImage:[NSImage imageNamed:@"228"]];

    
}

- (void)pollPasteBoard {
    
    //If automatic shortening is enabled
    if ([self.userDefaults boolForKey:@"SHORT_AUTOMATICALLY"]) {
        if(![self.pasteBoardContents isEqualToString:[self.pasteBoard stringForType:NSPasteboardTypeString]]) {
            self.pasteBoardContents = [self.pasteBoard stringForType:NSPasteboardTypeString];
            
            //Generate the shortened link only if different from the previous one
            if (![self.pasteBoardContents isEqualToString:self.original_link] && ![self.pasteBoardContents isEqualToString:self.shortened_link]) {
                if([self isValidLink:self.pasteBoardContents] && ![self hasExcludedText:self.pasteBoardContents] ) {
                    self.original_link = self.pasteBoardContents;
                    [self generateShortLink];
                }
            }
            
        }

    }
    
}





#pragma mark Short link methods per service
/**** Short Link Methods per service ***/

/*** is.gd ***/
- (void)generateIsGdShortlink {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://is.gd/create.php?format=simple&url=%@", self.original_link]];
        NSData *linkData = [[NSData alloc] initWithContentsOfURL:url];
        NSString *link = [[NSString alloc] initWithData:linkData encoding:NSUTF8StringEncoding];
        self.shortened_link = link;
        if([self isValidLink:self.shortened_link]) {
            [self copyToClipBoard];
        }
        else {
            [self displayError:@"The URL you entered is is.gd internal blacklist or already shortened."];
        }

    });
    
        
}

/*** goo.gl ***/
- (void)generateGooGlShortlink {
    
    
        NSString* googString = @"https://www.googleapis.com/urlshortener/v1/url";
        NSURL* googUrl = [NSURL URLWithString:googString];
        
        NSMutableURLRequest* googReq = [NSMutableURLRequest requestWithURL:googUrl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
        [googReq setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSString* longUrlString = [NSString stringWithFormat:@"{\"longUrl\": \"%@\"}",self.original_link];
        
        NSData* longUrlData = [longUrlString dataUsingEncoding:NSUTF8StringEncoding];
        [googReq setHTTPBody:longUrlData];
        [googReq setHTTPMethod:@"POST"];
        
        NSURLConnection* connect = [[NSURLConnection alloc] initWithRequest:googReq delegate:self];
        connect = nil;

    
    
   }

-(void)parseGooGlResponse:(NSData *)data {

    NSError* error = nil;
    
    NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
    
    NSString* shortenedURL;
    if (error == nil) {
        if ([jsonArray valueForKey:@"id"] != nil) {
            shortenedURL = self.shortened_link = [jsonArray valueForKey:@"id"];
            [self copyToClipBoard];
        }
    } else {
        [self displayError:@"There was an error with the Google Shortener service.  Please try later."];
    }
}

/*** ur.cx ***/
- (void)generateUrCxShortlink {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://ur.cx/api/create.php?url=%@", self.original_link]];
        NSData *linkData = [[NSData alloc] initWithContentsOfURL:url];
        NSString *link = [[NSString alloc] initWithData:linkData encoding:NSUTF8StringEncoding];
        self.shortened_link = link;
        if([self isValidLink:self.shortened_link]) {
            [self copyToClipBoard];
        }
        else {
            [self displayError:@"There was an error shortening that URL."];
        }
    });
    
    
    
}

/*** to.ly ***/
- (void)generateToLyShortlink {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://to.ly/api.php?longurl=%@", self.original_link]];
        NSData *linkData = [[NSData alloc] initWithContentsOfURL:url];
        NSString *link = [[NSString alloc] initWithData:linkData encoding:NSUTF8StringEncoding];
        self.shortened_link = link;
        if([self isValidLink:self.shortened_link]) {
            [self copyToClipBoard];
        }
        else {
            [self displayError:@"There was an error shortening that URL.."];
        }
    });
    
    
    
}

/*** tinyurl.com ***/
- (void)generateTinyurlComLink {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url==%@", self.original_link]];
        NSData *linkData = [[NSData alloc] initWithContentsOfURL:url];
        NSString *link = [[NSString alloc] initWithData:linkData encoding:NSUTF8StringEncoding];
        self.shortened_link = link;
        if([self isValidLink:self.shortened_link]) {
            [self copyToClipBoard];
        }
        else {
            [self displayError:@"There was an error shortening that URL."];
        }
    });
    
    
    
}

/*** su.pr ***/
- (void)generateSuPrShortlink {
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                             (unsigned long)NULL), ^(void) {
        NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://su.pr/api/simpleshorten?url=%@", self.original_link]];
        NSData *linkData = [[NSData alloc] initWithContentsOfURL:url];
        NSString *link = [[NSString alloc] initWithData:linkData encoding:NSUTF8StringEncoding];
        self.shortened_link = link;
        if([self isValidLink:self.shortened_link]) {
            [self copyToClipBoard];
        }
        else {
            [self displayError:@"There was an error shortening that URL."];
        }
    });
    
    
    
}







/*** Connection responses ****/
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    switch ([self.userDefaults integerForKey:@"SERVICE"]) {
        case 20:
            NSLog(@"Parsing results from goo.gl");
            [self parseGooGlResponse:data];
        break;
    }
    

    
}

- (IBAction) changeLoginStatus:(id)sender {
    
    switch ([self.userDefaults boolForKey:@"LAUNCH_AT_LOGIN"]) {
        case NO:
            [self toggleLaunchAtLogin:NO];
            [self.launchAtLoginMenuItem setState:1];
            [self.userDefaults setBool:YES forKey:@"LAUNCH_AT_LOGIN"];
            NSLog(@"Adding app to login items");
        break;
        
        case YES:
            [self toggleLaunchAtLogin:YES];
            [self.launchAtLoginMenuItem setState:0];
            [self.userDefaults setBool:NO forKey:@"LAUNCH_AT_LOGIN"];
            NSLog(@"Removing app from login items");
        break;
    }
    
    [self.userDefaults synchronize];
    
}

- (IBAction) showPreferences:(id)sender {
    
    if(!prefsWindow) {
        prefsWindow = [[PreferencesWindowController alloc] initWithWindowNibName:@"PreferencesWindowController"];
    }
    [prefsWindow showWindow:nil];
}


- (void) toggleLaunchAtLogin:(BOOL)status
{
    
    if (!status) { // ON
        // Turn on launch at login
        if (!SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.banshai.LittleLink-Helper", YES)) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"Couldn't set LittleLink to launch at login. ¿Are you an Administrator?"];
            [alert runModal];
        }
    }
    else { // OFF
        // Turn off launch at login
        if (!SMLoginItemSetEnabled ((__bridge CFStringRef)@"com.banshai.LittleLink-Helper", NO)) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"An error ocurred"
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"Couldn't remove LittleLink from \"launch at login\" settings. ¿Are you an Administrator?"];
            [alert runModal];
        }
    }
}




@end
