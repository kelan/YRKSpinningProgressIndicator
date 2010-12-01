//
//  YRKSpinningProgressIndicator.h
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YRKSpinningProgressIndicator : NSView {
    int _position;
    int _numFins;
    
    BOOL _isAnimating;
    NSTimer *_animationTimer;
	NSThread *_animationThread;
    
    NSColor *_foreColor;
    NSColor *_backColor;
    BOOL _drawBackground;
    
    NSTimer *_fadeOutAnimationTimer;
    BOOL _isFadingOut;
	
	BOOL _displayWhenStopped;
    
    // For determinate mode
    BOOL _isIndeterminate;
    double _currentValue;
    double _maxValue;
    
    BOOL _usesThreadedAnimation;
}

- (void)stopAnimation:(id)sender;
- (void)startAnimation:(id)sender;


// Accessors

- (NSColor *)color;
- (void)setColor:(NSColor *)value;
- (NSColor *)backgroundColor;
- (void)setBackgroundColor:(NSColor *)value;
- (BOOL)drawsBackground;
- (void)setDrawsBackground:(BOOL)value;

- (BOOL)isIndeterminate;
- (void)setIndeterminate:(BOOL)isIndeterminate;
- (double)doubleValue;
- (void)setDoubleValue:(double)doubleValue;
- (double)maxValue;
- (void)setMaxValue:(double)maxValue;

- (void)setUsesThreadedAnimation:(BOOL)useThreaded;
- (BOOL)usesThreadedAnimation;

- (void)setDisplayedWhenStopped:(BOOL)displayWhenStopped;
- (BOOL)displayWhenStopped;

@end
