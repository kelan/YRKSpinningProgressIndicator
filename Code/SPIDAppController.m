//
//  SPIDAppController.m
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import "SPIDAppController.h"

@class YRKSpinningProgressIndicator;

@interface SPIDAppController (PrivateMethods)

- (void)runDeterminateDemoInBackgroundThread;

@end


@implementation SPIDAppController

-(id)init
{
    self = [super init];
    if (self != nil) {
        piIsRunning = NO;
        tfIsRunning = NO;
    }
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [ftForegroundColor setColor:[NSColor grayColor]];
    [ftBackgroundColor setColor:[NSColor whiteColor]];
    [self changeForegroundColor:ftForegroundColor];
    [self changeBackgroundColor:ftBackgroundColor];

    [turboFan setDrawBackground:NO];
    
    [self takeThreadedFrom:threadedAnimationButton];
}

- (IBAction)toggleProgressIndicator:(id)sender
{
    if(piIsRunning) {
        [progressIndicator stopAnimation:self];
        piIsRunning = NO;
    }
    else {
        [progressIndicator startAnimation:self];
        piIsRunning = YES;
    }
}

- (IBAction)toggleTurboFan:(id)sender
{
    if(tfIsRunning) {
        [turboFan stopAnimation:self];
        tfIsRunning = NO;
    }
    else {
        [turboFan startAnimation:self];
        tfIsRunning = YES;
    }
}

- (IBAction)startDeterminateDemo:(id)sender
{
    [determinateDemoButton setEnabled:NO];
    
    [turboFan setIndeterminate:NO];
    [turboFan setDoubleValue:0];
    
    [NSThread detachNewThreadSelector:@selector(runDeterminateDemoInBackgroundThread) toTarget:self withObject:nil];
}

- (void)runDeterminateDemoInBackgroundThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    double i;
    for (i = 0; i <= 100; i += 0.5) {
        usleep(20000);
        [turboFan setDoubleValue:i];
    }
    [pool release];
    
    [self performSelectorOnMainThread:@selector(finishDeterminateDemo)
                           withObject:nil
                        waitUntilDone:NO];
}

- (void)finishDeterminateDemo
{
    [turboFan setIndeterminate:YES];
    if(tfIsRunning) {
        [turboFan startAnimation:self];
    }
    
    [determinateDemoButton setEnabled:YES];
}

- (IBAction)changeForegroundColor:(id)sender
{
    [turboFan setForeColor:[sender color]];
}


- (IBAction)changeBackgroundColor:(id)sender
{
    [turboFan setBackColor:[sender color]];
}

- (IBAction)toggleDrawBackground:(id)sender
{
    if([sender state] == NSOnState)
        [turboFan setDrawBackground:YES];
    else
        [turboFan setDrawBackground:NO];
}

- (IBAction)takeThreadedFrom:(id)sender
{
    BOOL useThreaded = (BOOL)[sender intValue];
    [turboFan setUsesThreadedAnimation:useThreaded];
    [progressIndicator setUsesThreadedAnimation:useThreaded];
}

@end
