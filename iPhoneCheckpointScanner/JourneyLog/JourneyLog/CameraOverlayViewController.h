//
//  FlipsideViewController.h
//  JourneyLog
//
//  Created by Mike Ashmore on 6/11/11.
//  Copyright 2011 Perforce Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraOverlayViewController : UIViewController {
    UITextView *instructions;
}

@property (nonatomic, retain) IBOutlet UITextView *instructions;

- (void) showInstructions:(NSString *)someInstruction;

@end

