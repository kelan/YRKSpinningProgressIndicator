//
//  SPIDAppController.h
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//


@class YRKSpinningProgressIndicator;


@interface SPIDAppController : NSObject {
    NSViewAnimation *viewAnimation;

    IBOutlet NSProgressIndicator *_progressIndicator;
    IBOutlet YRKSpinningProgressIndicator *_turboFan;
    IBOutlet NSButton *_nspiToggleButton;
    IBOutlet NSButton *_yrkpiToggleButton;
    IBOutlet NSButton *_threadedAnimationButton;
    IBOutlet NSButton *_displayWhenStoppedButton;

    IBOutlet NSColorWell *_foregroundColorWell;
    IBOutlet NSColorWell *_backgroundColorWell;
    BOOL _yrkpiIsRunning, _nspiIsRunning;
    
    IBOutlet NSButton *_determinateDemoButton;
}

- (IBAction)toggleProgressIndicator:(id)sender;
- (IBAction)toggleTurboFan:(id)sender;

- (IBAction)startDeterminateDemo:(id)sender;
- (void)finishDeterminateDemo;

- (IBAction)changeForegroundColor:(id)sender;
- (IBAction)changeBackgroundColor:(id)sender;
- (IBAction)toggleDrawBackground:(id)sender;

- (IBAction)toggleDisplayWhenStopped:(id)sender;

- (IBAction)takeThreadedFrom:(id)sender;

@end
