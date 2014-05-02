//
//  STTwitterAPI+DirectMessages.h
//  STTwitterDemoIOS
//
//  Created by Jerôme Morissard on 02/05/14.
//  Copyright (c) 2014 Nicolas Seriot. All rights reserved.
//

#import "STTwitterAPI.h"

@interface STTwitterAPI (DirectMessages)

#pragma mark Direct Messages

/*
 GET	direct_messages
 
 Returns the 20 most recent direct messages sent to the authenticating user. Includes detailed information about the sender and recipient user. You can request up to 200 direct messages per call, up to a maximum of 800 incoming DMs.
 */

- (void)getDirectMessagesSinceID:(NSString *)sinceID
                           maxID:(NSString *)maxID
                           count:(NSString *)count
                 includeEntities:(NSNumber *)includeEntities
                      skipStatus:(NSNumber *)skipStatus
                    successBlock:(void(^)(NSArray *messages))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;
// convenience
- (void)getDirectMessagesSinceID:(NSString *)sinceID
						   count:(NSUInteger)count
					successBlock:(void(^)(NSArray *messages))successBlock
					  errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    direct_messages/sent
 
 Returns the 20 most recent direct messages sent by the authenticating user. Includes detailed information about the sender and recipient user. You can request up to 200 direct messages per call, up to a maximum of 800 outgoing DMs.
 */

- (void)getDirectMessagesSinceID:(NSString *)sinceID
                           maxID:(NSString *)maxID
                           count:(NSString *)count
                            page:(NSString *)page
                 includeEntities:(NSNumber *)includeEntities
                    successBlock:(void(^)(NSArray *messages))successBlock
                      errorBlock:(void(^)(NSError *error))errorBlock;

/*
 GET    direct_messages/show
 
 Returns a single direct message, specified by an id parameter. Like the /1.1/direct_messages.format request, this method will include the user objects of the sender and recipient.
 */

- (void)getDirectMessagesShowWithID:(NSString *)messageID
                       successBlock:(void(^)(NSArray *statuses))successBlock
                         errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	direct_messages/destroy
 
 Destroys the direct message specified in the required ID parameter. The authenticating user must be the recipient of the specified direct message.
 */

- (void)postDestroyDirectMessageWithID:(NSString *)messageID
                       includeEntities:(NSNumber *)includeEntities
						  successBlock:(void(^)(NSDictionary *message))successBlock
							errorBlock:(void(^)(NSError *error))errorBlock;

/*
 POST	direct_messages/new
 
 Sends a new direct message to the specified user from the authenticating user. Requires both the user and text parameters and must be a POST. Returns the sent message in the requested format if successful.
 */

- (void)postDirectMessage:(NSString *)status
					   to:(NSString *)screenName
             successBlock:(void(^)(NSDictionary *message))successBlock
               errorBlock:(void(^)(NSError *error))errorBlock;

@end
