//
//  PlayerRegistration.h
//  JourneyLog
//
//  Created by Mike Ashmore on 6/13/11.
//  Copyright (c) 2011 Perforce Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Scan.h"


@interface PlayerRegistration : Scan {
@private
}
@property (nonatomic, retain) NSData * mugshot;

+ (PlayerRegistration *) playerRegistrationWithMugshot:(UIImage *)aMugshot inContext:(NSManagedObjectContext *)context;
@end
