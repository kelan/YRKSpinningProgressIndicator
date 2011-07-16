//
//  SPIDAppController.m
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import "SPIDAppController.h"

#import "YRKSpinningProgressIndicator.h"

@interface SPIDAppController (PrivateMethods)

- (void)runDeterminateDemoInBackgroundThread;

@end


@implementation SPIDAppController

-(id)init
{
    self = [super init];
    if (self != nil) {
        _nspiIsRunning = NO;
        _yrkpiIsRunning = NO;
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [_foregroundColorWell setColor:[NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
    [_backgroundColorWell setColor:[NSColor whiteColor]];
    [self changeForegroundColor:_foregroundColorWell];
    [self changeBackgroundColor:_backgroundColorWell];

    [_turboFan setDrawsBackground:NO];
    
    [self takeThreadedFrom:_threadedAnimationButton];
}

- (IBAction)toggleProgressIndicator:(id)sender
{
    if(_nspiIsRunning) {
        [_progressIndicator stopAnimation:self];
        [_nspiToggleButton setTitle:@"Start"];
        _nspiIsRunning = NO;
    }
    else {
        [_progressIndicator startAnimation:self];
        [_nspiToggleButton setTitle:@"Stop"];
        _nspiIsRunning = YES;
    }
}

- (IBAction)toggleTurboFan:(id)sender
{
    if(_yrkpiIsRunning) {
        [_turboFan stopAnimation:self];
        [_yrkpiToggleButton setTitle:@"Start"];
        _yrkpiIsRunning = NO;
    }
    else {
        [_turboFan startAnimation:self];
        [_yrkpiToggleButton setTitle:@"Stop"];
        _yrkpiIsRunning = YES;
    }
}

- (IBAction)startDeterminateDemo:(id)sender
{
    [_determinateDemoButton setEnabled:NO];
    
    [_turboFan setIndeterminate:NO];
    [_turboFan setDoubleValue:0];
    
    [NSThread detachNewThreadSelector:@selector(runDeterminateDemoInBackgroundThread) toTarget:self withObject:nil];
}

- (void)runDeterminateDemoInBackgroundThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    double i;
    for (i = 0; i <= 100; i += 0.5) {
        usleep(20000);
        [_turboFan setDoubleValue:i];
    }
    [pool release];
    
    [self performSelectorOnMainThread:@selector(finishDeterminateDemo)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)finishDeterminateDemo
{
    [_turboFan setIndeterminate:YES];
    if(_yrkpiIsRunning) {
        [_turboFan startAnimation:self];
    }
    
    [_determinateDemoButton setEnabled:YES];
}

- (IBAction)changeForegroundColor:(id)sender
{
    [_turboFan setColor:[sender color]];
}


- (IBAction)changeBackgroundColor:(id)sender
{
    [_turboFan setBackgroundColor:[sender color]];
}

- (IBAction)toggleDrawBackground:(id)sender
{
    if([sender state] == NSOnState)
        [_turboFan setDrawsBackground:YES];
    else
        [_turboFan setDrawsBackground:NO];
}

- (IBAction)toggleDisplayWhenStopped:(id)sender
{
	[_turboFan setDisplayedWhenStopped:([sender state] == NSOnState)];
}

- (IBAction)takeThreadedFrom:(id)sender
{
    BOOL useThreaded = (BOOL)[sender intValue];
    [_turboFan setUsesThreadedAnimation:useThreaded];
    [_progressIndicator setUsesThreadedAnimation:useThreaded];
}

@end
