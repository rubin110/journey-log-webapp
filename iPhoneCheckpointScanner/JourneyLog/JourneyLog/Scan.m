//
//  Scan.m
//  JourneyLog
//
//  Created by Mike Ashmore on 6/11/11.
//  Copyright (c) 2011 Perforce Software. All rights reserved.
//

#import "Scan.h"
#import "ASIHTTPRequest.h"

@implementation Scan
@dynamic timestamp;
@dynamic timeUploaded;
@dynamic location;
@dynamic url;

- (void) awakeFromInsert
{
    [super awakeFromInsert];
    self.timestamp = [NSDate date];
}

#pragma mark - Class constructors
+ (NSArray *) recentScansOfURL:(NSString *)someUrl inContext:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Scan" inManagedObjectContext:moc];
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    [request setEntity:entityDescription];
    
    NSDate *recentPast = [NSDate dateWithTimeIntervalSinceNow:-10];
    // Set example predicate and sort orderings...
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"(url like %@) AND (timestamp > %@)", someUrl, recentPast];
    [request setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"timestamp" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [sortDescriptor release];
    
    NSError *error = nil;
    NSArray *array = [moc executeFetchRequest:request error:&error];
    if (error) {
        NSLog(@"Something blew up trying to retrieve scans of url %@", someUrl);
    }
    return array;
}

+ (Scan *) scanOfURL:(NSString *)someUrl atLocation:(CLLocation *)location inContext:(NSManagedObjectContext *)moc
{
    NSArray *recentScans = [Scan recentScansOfURL:someUrl inContext:moc];
    Scan * theScan =  nil;
    if ([recentScans count]) {
        theScan = [recentScans lastObject];
    } else {
        theScan = [NSEntityDescription insertNewObjectForEntityForName:@"Scan" inManagedObjectContext:moc];
        theScan.url = someUrl;
        theScan.location = location;
    }
    return theScan;
}

#pragma mark - Convenience methods

- (NSArray *) urlPathComponents
{
    NSURL *theUrl = [NSURL URLWithString:self.url];
    return [[theUrl path] componentsSeparatedByString:@"/"];
}

- (NSString *) playerId
{
    if ([self isPlayerCode]) {
        return [self.urlPathComponents lastObject];
    } else {
        NSLog(@"Not returning a playerId because this doesn't seem to be a player code");
        return nil;
    }
}

- (BOOL) isPlayerCode
{
    return ([self.urlPathComponents count] == 2);
}

- (ASIHTTPRequest *) httpRequest
{
    return [ASIHTTPRequest requestWithURL:[NSURL URLWithString:self.url]];
}

@end
