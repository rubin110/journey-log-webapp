//
//  MainViewController.m
//  JourneyLog
//
//  Created by Mike Ashmore on 6/11/11.
//  Copyright 2011 Perforce Software. All rights reserved.
//

#import "MainViewController.h"
#import "Scan.h"
#import "PlayerRegistration.h"
#import "CameraOverlayViewController.h"
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@implementation MainViewController

@synthesize managedObjectContext=_managedObjectContext;
@synthesize locationManager=_locationManager;
@synthesize playerRegistrationInProgress=_playerRegistrationInProgress;
@synthesize overlayViewController;
@synthesize textView;
@synthesize soundFileURLRef;
@synthesize soundFileObject;
@synthesize networkQueue = _networkQueue;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.text = @"View loaded!";
    //[self.textView setNeedsDisplay];
    NSURL *tapSound   = [[NSBundle mainBundle] URLForResource: @"tap"
                                                withExtension: @"aif"];
    
    // Store the URL as a CFURLRef instance
    self.soundFileURLRef = (CFURLRef) [tapSound retain];
    
    // Create a system sound object representing the sound file.
    AudioServicesCreateSystemSoundID (                                      
                                      soundFileURLRef,
                                      &soundFileObject
                                      );
    
    [[self locationManager] startMonitoringSignificantLocationChanges];
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    // Silly user, this text field is for display purposes only
    return NO;
}

#pragma mark - CLLocationManager methods
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    //self.textView.text = [NSString stringWithFormat:@"Location manager reported location: %@", newLocation];

}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    self.textView.text = @"Location manager reported a failure";
}

- (CLLocationManager *)locationManager {
    
    if (_locationManager != nil) {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.distanceFilter = 500;
    _locationManager.delegate = self;
    
    return _locationManager;
}

#pragma mark - Network Queue management
- (ASINetworkQueue *)networkQueue
{
    if (_networkQueue != nil) {
        return _networkQueue;
    }
    
    _networkQueue = [[ASINetworkQueue queue] retain];
    [_networkQueue setShouldCancelAllRequestsOnFailure:NO];
    return _networkQueue;
}

- (IBAction)showRegistration:(id)sender
{
    NSLog(@"Now preparing to show registration camera");
    self.playerRegistrationInProgress = nil;
    UIImagePickerController *imagePickerController = [UIImagePickerController new];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeCamera];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    } else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [imagePickerController setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    }
    [imagePickerController setCameraOverlayView:self.overlayViewController.view];
    imagePickerController.allowsEditing = YES;
    [self.overlayViewController showInstructions: @"Please to be taking a mugshot now"];
    [imagePickerController setDelegate:self];
    NSLog(@"Now presenting registration camera");
    [self presentModalViewController:imagePickerController animated:YES];
    [imagePickerController release];
}

- (IBAction)showScanner:(id)sender
{
    NSLog(@"Now preparing to show scanner");
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    
    [reader.scanner setSymbology: 0
                          config: ZBAR_CFG_ENABLE
                              to: 0];
    
    [reader.scanner setSymbology: ZBAR_QRCODE
                          config: ZBAR_CFG_ENABLE
                              to: 1];
    
    [reader.scanner setSymbology:0 config:ZBAR_CFG_X_DENSITY to:1];
    [reader.scanner setSymbology:0 config:ZBAR_CFG_Y_DENSITY to:1];
    
    reader.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    reader.cameraOverlayView = self.overlayViewController.view;
    [self.overlayViewController showInstructions:@"Now let's scan a QR code!"];
    NSLog(@"Now presenting the scanner");
    [self presentModalViewController:reader animated:YES];
    [reader release];    
}

- (void) zBarReaderViewController: (ZBarReaderViewController *) picker
didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    NSLog(@"Scanned a QR code");
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    NSMutableArray *scannedURLs = [NSMutableArray array];
    if (results) {
        AudioServicesPlayAlertSound (soundFileObject);
        ZBarSymbol *symbol = nil;
        for(symbol in results) {
            NSString *symbolData = symbol.data;
            [scannedURLs addObject:symbolData];
        }
    }
    CLLocation *loc = self.locationManager.location;
    Scan *newScan = nil;
    if (self.playerRegistrationInProgress) {
        if ([scannedURLs count] > 1) {
            NSLog(@"Problem: we seem to have scanned more than just the one QR code. But we're supposed to be registering a single individual");
            [self.overlayViewController showInstructions:@"Please only scan one QR code at a time when we're registering a new user"];
        } else {
            newScan = self.playerRegistrationInProgress;
            newScan.url = [scannedURLs lastObject];
            newScan.location = loc;
            NSLog(@"Attaching scan data to the registration already in progress: %@", newScan);
            [self.overlayViewController showInstructions: [NSString stringWithFormat:@"New user registered, player ID is %@", [newScan playerId]]];
            [picker dismissModalViewControllerAnimated:YES];
        }
    } else {
        for (NSString *symbolData in scannedURLs) {
            newScan = [Scan scanOfURL:symbolData atLocation:loc inContext:self.managedObjectContext];
            if (![newScan isPlayerCode]) {
                // handle server request for things that aren't player checkins 
            }
            [self.overlayViewController showInstructions: [NSString stringWithFormat:@"Player %@ identified", [newScan playerId]]];
            NSLog(@"Checkpoint scan data received: %@", newScan);
        }
    }
    NSError *err;
    if (![self.managedObjectContext save:&err]) {
        NSLog(@"Failed to save object context: %@", err);
    }
    self.playerRegistrationInProgress = nil;
    ASIHTTPRequest *newRequest = [newScan httpRequest];
    [newRequest setCompletionBlock:^{
        newScan.timeUploaded = [NSDate date];
        for (NSString *cookie in newRequest.responseCookies) {
            NSLog(@"Response cookie! %@", cookie);
        }
        NSError *err;
        if (![self.managedObjectContext save:&err]) {
            NSLog(@"Failed to save object context: %@", err);
        } else {
            NSLog(@"w00t! uploaded %@ ; got %@", newScan.url, newRequest.responseString);
        }
    }];
    [self.networkQueue addOperation:newRequest];
    if ([self.networkQueue isSuspended]) {
        [self.networkQueue go];
    }
}
- (void) imagePickerController: (UIImagePickerController*) picker
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    if ([[[picker class] description] isEqualToString:@"ZBarReaderViewController"]) {
        [self zBarReaderViewController:(ZBarReaderViewController *)picker didFinishPickingMediaWithInfo:info];
    } else {
        NSLog(@"Took a picture");
        UIImage *mugshot = [info valueForKey:UIImagePickerControllerOriginalImage];
        CGSize resizeSize = CGSizeMake(600.0, 600.0);
        UIGraphicsBeginImageContext(resizeSize);
        [mugshot drawInRect:CGRectMake(0,0,resizeSize.width,resizeSize.height)];
        UIImage *compactMugshot = UIGraphicsGetImageFromCurrentImageContext();
        self.playerRegistrationInProgress = [PlayerRegistration playerRegistrationWithMugshot:compactMugshot inContext:self.managedObjectContext];
        [self dismissModalViewControllerAnimated:NO];
        NSLog(@"... now entering scan mode");
        [self showScanner:self];
    }
}

- (void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.locationManager = nil;
}

- (void)dealloc
{
    AudioServicesDisposeSystemSoundID (soundFileObject);
    CFRelease (soundFileURLRef);
    self.networkQueue = nil;
    [_managedObjectContext release];
    [super dealloc];
}

@end
