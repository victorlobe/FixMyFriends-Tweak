#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Helper function to check if string contains substring
static BOOL stringContains(NSString *string, NSString *substring) {
    if (!string || !substring) return NO;
    return [string rangeOfString:substring].location != NSNotFound;
}

// modify iOS 6 requests to iOS 7 format
%hook NSMutableURLRequest

- (void)setHTTPBody:(NSData *)body {
    // Check if this is an fmf request
    NSURL *url = [self URL];
    if (url && stringContains([[url absoluteString] lowercaseString], @"fmipservice/friends") && body) {
        NSString *bodyString = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        
        // Only modify 5 and 6 for missing fmfAppRefresh
        BOOL isOldIOS = (stringContains(bodyString, @"\"osVersion\":\"5.") || stringContains(bodyString, @"\"osVersion\":\"6."));
        if (bodyString && isOldIOS && !stringContains(bodyString, @"fmfAppRefresh")) {
            NSError *jsonError = nil;
            NSMutableDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:body options:NSJSONReadingMutableContainers error:&jsonError];
            
            if (jsonDict && !jsonError) {
                NSMutableDictionary *clientContext = [jsonDict objectForKey:@"clientContext"];
                if (clientContext && ![clientContext objectForKey:@"fmfAppRefresh"]) {
                    // modify to iOS 7 format
                    [clientContext setObject:@2 forKey:@"fmfAppRefresh"];
                    [clientContext setObject:@"3.0" forKey:@"appVersion"];
                    [clientContext setObject:@"372" forKey:@"buildVersion"];
                    [clientContext setObject:@"7.0.6" forKey:@"osVersion"];
                    
                    NSData *modifiedData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:&jsonError];
                    if (modifiedData && !jsonError) {
                        %orig(modifiedData);
                        return;
                    }
                }
            }
        }
    }
    
    %orig;
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    // Modify User agent and X-MMe-Client-Info headers for fmf requests
    NSURL *url = [self URL];
    if (url && stringContains([[url absoluteString] lowercaseString], @"fmipservice/friends")) {
        if ([field isEqualToString:@"User-Agent"]) {
            // Fix old User-Agents
            if (stringContains(value, @"FindMyFriends/2.1.1") || stringContains(value, @"FindMyFriends/1.")) {
                value = @"FindMyFriends/3.0(3A77) iPhone5,2/7.0.6(11B651)";
            }
        } else if ([field isEqualToString:@"X-MMe-Client-Info"]) {
            // fix old X-MMe Client Info headers
            value = [value stringByReplacingOccurrencesOfString:@"iPhone OS;5." withString:@"iPhone OS;7.0.6"];
            value = [value stringByReplacingOccurrencesOfString:@"iPhone OS;6." withString:@"iPhone OS;7.0.6"];
            value = [value stringByReplacingOccurrencesOfString:@"10B146" withString:@"11B651"];
            value = [value stringByReplacingOccurrencesOfString:@"com.apple.mobileme.fmf/2." withString:@"com.apple.mobileme.fmf/3.000372"];
            value = [value stringByReplacingOccurrencesOfString:@"com.apple.mobileme.fmf/1." withString:@"com.apple.mobileme.fmf/3.000372"];
        }
    }
    
    %orig(value, field);
}

%end

// Messy workaround to block "sign in required" alerts (will be fixed)
%hook UIAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    if (title && (stringContains(title, @"Sign In Required") || stringContains(title, @"sign in required"))) {
        return nil; 
    }
    
    return %orig;
}

- (void)show {
    if ([self title] && (stringContains([self title], @"Sign In Required") || stringContains([self title], @"sign in required"))) {
        return; 
    }
    
    %orig;
}

%end

%ctor {
    NSLog(@"[FixMyFriends] Loaded - Converting old iOS (5/6) to iOS 7 requests.");
}