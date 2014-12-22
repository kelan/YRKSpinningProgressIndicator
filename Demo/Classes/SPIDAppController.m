//
//  SPIDAppController.m
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import "SPIDAppController.h"

#import "YRKSpinningProgressIndicator.h"


@interface SPIDAppController () <NSApplicationDelegate>
@property (nonatomic) IBOutlet NSWindow *window;
@property (nonatomic) IBOutlet NSProgressIndicator *progressIndicator;
@property (nonatomic) IBOutlet YRKSpinningProgressIndicator *turboFan;
@property (nonatomic) IBOutlet NSButton *nspiToggleButton;
@property (nonatomic) IBOutlet NSButton *yrkpiToggleButton;
@property (nonatomic) IBOutlet NSButton *displayWhenStoppedButton;
@property (nonatomic) IBOutlet NSColorWell *foregroundColorWell;
@property (nonatomic) IBOutlet NSColorWell *backgroundColorWell;
@property (nonatomic) IBOutlet NSButton *determinateDemoButton;
@end


@implementation SPIDAppController {
    BOOL _yrkpiIsRunning;
    BOOL _nspiIsRunning;
}


#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    _foregroundColorWell.color = [NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    _backgroundColorWell.color = [NSColor whiteColor];
    [self changeForegroundColor:_foregroundColorWell];
    [self changeBackgroundColor:_backgroundColorWell];

    _turboFan.drawsBackground = NO;
}


#pragma mark - IBActions

- (IBAction)toggleProgressIndicator:(id)sender
{
    if (_nspiIsRunning) {
        [_progressIndicator stopAnimation:self];
        _nspiToggleButton.title = @"Start";
        _nspiIsRunning = NO;
    }
    else {
        [_progressIndicator startAnimation:self];
        _nspiToggleButton.title = @"Stop";
        _nspiIsRunning = YES;
    }
}

- (IBAction)toggleTurboFan:(id)sender
{
    if (_yrkpiIsRunning) {
        [_turboFan stopAnimation:self];
        _yrkpiToggleButton.title = @"Start";
        _yrkpiIsRunning = NO;
    }
    else {
        [_turboFan startAnimation:self];
        _yrkpiToggleButton.title = @"Stop";
        _yrkpiIsRunning = YES;
    }
}

- (IBAction)startDeterminateDemo:(NSButton *)sender
{
    [_determinateDemoButton setEnabled:NO];
    
    _turboFan.indeterminate = NO;
    _turboFan.currentValue = 0.0;
    _turboFan.maxValue = 100.0;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (CGFloat value = 0.0; value <= 100.0; value += 0.5) {
            usleep(20000);
            dispatch_async(dispatch_get_main_queue(), ^{
                _turboFan.currentValue = value;
            });
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            [_turboFan setIndeterminate:YES];
            if (_yrkpiIsRunning) {
                [_turboFan startAnimation:self];
            }

            [_determinateDemoButton setEnabled:YES];
        });
    });
}

- (IBAction)changeForegroundColor:(NSColorWell *)sender
{
    _turboFan.color = [sender color];
}


- (IBAction)changeBackgroundColor:(NSColorWell *)sender
{
    _turboFan.backgroundColor = [sender color];
}


- (IBAction)toggleDrawBackground:(NSButton *)sender
{
    _turboFan.drawsBackground = ([sender state] == NSOnState);
}

- (IBAction)toggleDisplayWhenStopped:(NSButton *)sender
{
    _turboFan.displayedWhenStopped = ([sender state] == NSOnState);
}

- (IBAction)blockThread:(id)sender
{
    // do a few noticably long operations on the main thread
    for (NSUInteger i = 0; i < 5; i++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            usleep(100000);
        });
    }
}

@end
