//
//  MainViewController.h
//  JourneyLog
//
//  Created by Mike Ashmore on 6/11/11.
//  Copyright 2011 Perforce Software. All rights reserved.
//

#import "CameraOverlayViewController.h"
#import "ZBarSDK.h"

#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#include <AudioToolbox/AudioToolbox.h>

@class PlayerRegistration;
@class ASINetworkQueue;

@interface MainViewController : UIViewController <ZBarReaderDelegate, UINavigationControllerDelegate, UITextViewDelegate, CLLocationManagerDelegate> {
	CFURLRef		soundFileURLRef;
	SystemSoundID	soundFileObject;
    CLLocationManager *_locationManager;
    PlayerRegistration *_playerRegistrationInProgress;
    CameraOverlayViewController *overlayViewController;
    UITextView *textView;
    ASINetworkQueue *_networkQueue;

}

- (IBAction)showScanner:(id)sender;
- (IBAction)showRegistration:(id)sender;

#pragma mark -
#pragma mark UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) PlayerRegistration *playerRegistrationInProgress;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet CameraOverlayViewController *overlayViewController;
@property (nonatomic, retain) ASINetworkQueue *networkQueue;
@property (readwrite)	CFURLRef		soundFileURLRef;
@property (readonly)	SystemSoundID	soundFileObject;

@end
