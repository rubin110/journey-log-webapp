//
//  JourneyLogAppDelegate.h
//  JourneyLog
//
//  Created by Mike Ashmore on 6/11/11.
//  Copyright 2011 Perforce Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainViewController;

@interface JourneyLogAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@property (nonatomic, retain) IBOutlet MainViewController *mainViewController;

@end
