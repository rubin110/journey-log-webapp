//
//  Scan.h
//  JourneyLog
//
//  Created by Mike Ashmore on 6/11/11.
//  Copyright (c) 2011 Perforce Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class ASIHTTPRequest;

@interface Scan : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSDate * timeUploaded;
@property (nonatomic, retain) CLLocation * location;
@property (nonatomic, retain) NSString * url;

+ (Scan *) scanOfURL:(NSString *)someUrl atLocation:(CLLocation *)location inContext:(NSManagedObjectContext *)moc;
+ (NSArray *) recentScansOfURL:(NSString *)someUrl inContext:(NSManagedObjectContext *)moc;

- (NSString *) playerId;
- (BOOL) isPlayerCode;
- (ASIHTTPRequest *) httpRequest;

@end
