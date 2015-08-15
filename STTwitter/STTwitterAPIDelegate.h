//
//  STTwitterAPIDelegate.h
//  STTwitterDemoOSX
//
//  Created by Tomohiro Kumagai on H27/08/15.
//  Copyright © 平成27年 Nicolas Seriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STTwitterAPI.h"

@class STTwitterAPI;
@class STTwitterOS;
@class ACAccountStore;

@protocol STTwitterAPIDelegate <NSObject>

@optional

/// This method called when received ACAccountStoreDidChangeNotification using authentication supplied by OS.
/// You return whether the current oauth shuld be disable.
/// If you don't implement the delegate method, It is assumed that it returns YES.
- (BOOL)twitterAPI:(STTwitterAPI*)api shouldDisableCurrentOAuth:(STTwitterOS*)oauth accountStore:(ACAccountStore*)accountStore;

@end