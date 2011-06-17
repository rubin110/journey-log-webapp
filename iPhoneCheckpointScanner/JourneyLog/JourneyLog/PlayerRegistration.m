//
//  PlayerRegistration.m
//  JourneyLog
//
//  Created by Mike Ashmore on 6/13/11.
//  Copyright (c) 2011 Perforce Software. All rights reserved.
//

#import "PlayerRegistration.h"
#import "ASIFormDataRequest.h"

@implementation PlayerRegistration
@dynamic mugshot;

+ (PlayerRegistration *) playerRegistrationWithMugshot:(UIImage *)aMugshot inContext:(NSManagedObjectContext *)context;
{
    PlayerRegistration * theRegistration =  [NSEntityDescription insertNewObjectForEntityForName:@"PlayerRegistration" inManagedObjectContext:context];
    theRegistration.mugshot = UIImageJPEGRepresentation(aMugshot, 0.9);
    return theRegistration;
}

- (ASIHTTPRequest *) httpRequest
{
    ASIFormDataRequest *req = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:self.url]];
    NSLog(@"Adding mugshot as player_photo and %@ as player_id to this PlayerRegistration", self.playerId);
    [req addData:self.mugshot withFileName:@"RubinsMom.jpg" andContentType:@"image/jpg" forKey:@"player_photo"];
    [req addPostValue:self.playerId forKey:@"runner_id"];
    return req;
}

@end
