//
//  YRKSpinningProgressIndicator.h
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//


@interface YRKSpinningProgressIndicator : NSView {
    int _position;
    int _numFins;
    
    BOOL _isAnimating;
    NSTimer *_animationTimer;
	NSThread *_animationThread;
    
    NSColor *_foreColor;
    NSColor *_backColor;
    
    NSTimer *_fadeOutAnimationTimer;
    BOOL _isFadingOut;
    BOOL _drawsBackground;
    
    BOOL _displayedWhenStopped;
    BOOL _usesThreadedAnimation;
	
    // For determinate mode
    BOOL _isIndeterminate;
    double _currentValue;
    double _maxValue;
}

@property (nonatomic, copy) NSColor *color;
@property (nonatomic, copy) NSColor *backgroundColor;
@property (nonatomic, assign) BOOL drawsBackground;

@property (nonatomic, assign, getter=isDisplayedWhenStopped) BOOL displayedWhenStopped;
@property (nonatomic, assign) BOOL usesThreadedAnimation;

@property (nonatomic, assign, getter=isIndeterminate) BOOL indeterminate;
@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) double maxValue;

- (void)stopAnimation:(id)sender;
- (void)startAnimation:(id)sender;

@end
