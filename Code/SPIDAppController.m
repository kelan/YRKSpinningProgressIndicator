//
//  SPIDAppController.m
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import "SPIDAppController.h"

@class YRKSpinningProgressIndicator;


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

- (IBAction)doDetermineDemo:(id)sender
{
    [turboFan setIndeterminate:NO];
    [turboFan setDoubleValue:0];
    [NSThread detachNewThreadSelector:@selector(doDetermineDemoAsNewThread) toTarget:self withObject:nil];
}

- (void)doDetermineDemoAsNewThread
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    float i;
    for (i = 0; i <= 100; i += 0.5) {
        usleep(20000);
        [turboFan setDoubleValue:i];
    }
    [turboFan setIndeterminate:YES];
    if(tfIsRunning) {
        [turboFan startAnimation:self];
    }
    
    [pool release];
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

@end
