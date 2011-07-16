//
//  YRKSpinningProgressIndicator.m
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import "YRKSpinningProgressIndicator.h"


@interface YRKSpinningProgressIndicator ()

- (void)updateFrame:(NSTimer *)timer;
- (void)animateInBackgroundThread;
- (void)actuallyStartAnimation;
- (void)actuallyStopAnimation;

@end


@implementation YRKSpinningProgressIndicator

@synthesize color = _foreColor;
@synthesize backgroundColor = _backColor;
@synthesize drawsBackground = _drawsBackground;
@synthesize displayedWhenStopped = _displayedWhenStopped;
@synthesize usesThreadedAnimation = _usesThreadedAnimation;
@synthesize indeterminate = _isIndeterminate;
@synthesize doubleValue = _currentValue;
@synthesize maxValue = _maxValue;


#pragma mark Init

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _position = 0;
        _numFins = 12;
        _isAnimating = NO;
        _isFadingOut = NO;
        
        _foreColor = [[NSColor blackColor] copy];
        _backColor = [[NSColor clearColor] copy];
        _drawsBackground = NO;
        
		_displayedWhenStopped = YES;
        _usesThreadedAnimation = NO;
        
        _isIndeterminate = YES;
        _currentValue = 0.0;
        _maxValue = 100.0;
    }
    return self;
}

- (void) dealloc
{
    [_foreColor release];
    [_backColor release];
    if (_isAnimating) [self stopAnimation:self];
    
    [super dealloc];
}

# pragma mark NSView overrides

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];

    if ([self window] == nil) {
        // No window?  View hierarchy may be going away.  Dispose timer to clear circular retain of timer to self to timer.
        [self actuallyStopAnimation];
    }
    else if (_isAnimating) {
        [self actuallyStartAnimation];
    }
}

- (void)drawRect:(NSRect)rect
{
    int i;
    float alpha = 1.0;

    // Determine size based on current bounds
    NSSize size = [self bounds].size;
    CGFloat theMaxSize;
    if(size.width >= size.height)
        theMaxSize = size.height;
    else
        theMaxSize = size.width;

    // fill the background, if set
    if(_drawsBackground) {
        [_backColor set];
        [NSBezierPath fillRect:[self bounds]];
    }

    CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    [NSGraphicsContext saveGraphicsState];

    // Move the CTM so 0,0 is at the center of our bounds
    CGContextTranslateCTM(currentContext,[self bounds].size.width/2,[self bounds].size.height/2);

    if (_isIndeterminate) {
        // do initial rotation to start place
        CGContextRotateCTM(currentContext, 3.14159*2/_numFins * _position);

        NSBezierPath *path = [[NSBezierPath alloc] init];
        CGFloat lineWidth = 0.0859375 * theMaxSize; // should be 2.75 for 32x32
        CGFloat lineStart = 0.234375 * theMaxSize; // should be 7.5 for 32x32
        CGFloat lineEnd = 0.421875 * theMaxSize;  // should be 13.5 for 32x32
        [path setLineWidth:lineWidth];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path moveToPoint:NSMakePoint(0,lineStart)];
        [path lineToPoint:NSMakePoint(0,lineEnd)];

        for(i=0; i<_numFins; i++) {
            if(_isAnimating) {
                [[_foreColor colorWithAlphaComponent:alpha] set];
            }
            else {
                [[_foreColor colorWithAlphaComponent:0.2] set];
            }

            [path stroke];

            // we draw all the fins by rotating the CTM, then just redraw the same segment again
            CGContextRotateCTM(currentContext, 6.282185/_numFins);
            alpha -= 1.0/_numFins;
        }
        [path release];
    }
    else {
        CGFloat lineWidth = 1 + (0.01 * theMaxSize);
        CGFloat circleRadius = (theMaxSize - lineWidth) / 2.1;
        NSPoint circleCenter = NSMakePoint(0, 0);
        [[_foreColor colorWithAlphaComponent:alpha] set];
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path setLineWidth:lineWidth];
        [path appendBezierPathWithOvalInRect:NSMakeRect(-circleRadius, -circleRadius, circleRadius*2, circleRadius*2)];
        [path stroke];
        [path release];
        path = [[NSBezierPath alloc] init];
        [path appendBezierPathWithArcWithCenter:circleCenter radius:circleRadius startAngle:90 endAngle:90-(360*(_currentValue/_maxValue)) clockwise:YES];
        [path lineToPoint:circleCenter] ;
        [path fill];
        [path release];
    }

    [NSGraphicsContext restoreGraphicsState];
}


#pragma mark NSProgressIndicator API

- (void)startAnimation:(id)sender
{
    if (!_isIndeterminate) return;
    if (_isAnimating) return;
    
	if (!_displayedWhenStopped)
		[self setHidden:NO];
	
    [self actuallyStartAnimation];
    _isAnimating = YES;
}

- (void)stopAnimation:(id)sender
{
    [self actuallyStopAnimation];
    _isAnimating = NO;
	
	if (!_displayedWhenStopped)
		[self setHidden:YES];
}

/// Only the spinning style is implemented
- (void)setStyle:(NSProgressIndicatorStyle)style
{
    if (NSProgressIndicatorSpinningStyle != style) {
        NSAssert(NO, @"Non-spinning styles not available.");
    }
}


# pragma mark Custom Accessors

- (void)setColor:(NSColor *)value
{
    if (_foreColor != value) {
        [_foreColor release];
        _foreColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setBackgroundColor:(NSColor *)value
{
    if (_backColor != value) {
        [_backColor release];
        _backColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (void)setDrawsBackground:(BOOL)value
{
    if (_drawsBackground != value) {
        _drawsBackground = value;
    }
    [self setNeedsDisplay:YES];
}

- (void)setIndeterminate:(BOOL)isIndeterminate
{
    _isIndeterminate = isIndeterminate;
    if (!_isIndeterminate && _isAnimating) [self stopAnimation:self];
    [self setNeedsDisplay:YES];
}

- (void)setDoubleValue:(double)doubleValue
{
    // Automatically put it into determinate mode if it's not already.
    if (_isIndeterminate) {
        [self setIndeterminate:NO];
    }
    _currentValue = doubleValue;
    [self setNeedsDisplay:YES];
}

- (void)setMaxValue:(double)maxValue
{
    _maxValue = maxValue;
    [self setNeedsDisplay:YES];
}

- (void)setUsesThreadedAnimation:(BOOL)useThreaded
{
    if (_usesThreadedAnimation != useThreaded) {
        _usesThreadedAnimation = useThreaded;
        
        if (_isAnimating) {
            // restart the timer to use the new mode
            [self stopAnimation:self];
            [self startAnimation:self];
        }
    }
}

- (void)setDisplayedWhenStopped:(BOOL)displayedWhenStopped
{
	_displayedWhenStopped = displayedWhenStopped;
	
	// Show/hide ourself if necessary
	if (!_isAnimating) {
		if (_displayedWhenStopped && [self isHidden]) {
			[self setHidden:NO];
		}
		else if (!_displayedWhenStopped && ![self isHidden]) {
			[self setHidden:YES];
		}
	}
}


#pragma mark Private

- (void)updateFrame:(NSTimer *)timer
{
    if(_position > 0) {
        _position--;
    }
    else {
        _position = _numFins - 1;
    }
    
    if (_usesThreadedAnimation) {
        // draw now instead of waiting for setNeedsDisplay (that's the whole reason
        // we're animating from background thread)
        [self display];
    }
    else {
        [self setNeedsDisplay:YES];
    }
}

- (void)actuallyStartAnimation
{
    // Just to be safe kill any existing timer.
    [self actuallyStopAnimation];
    
    if ([self window]) {
        // Why animate if not visible?  viewDidMoveToWindow will re-call this method when needed.
        if (_usesThreadedAnimation) {
            _animationThread = [[NSThread alloc] initWithTarget:self selector:@selector(animateInBackgroundThread) object:nil];
            [_animationThread start];
        }
        else {
            _animationTimer = [[NSTimer timerWithTimeInterval:(NSTimeInterval)0.05
                                                       target:self
                                                     selector:@selector(updateFrame:)
                                                     userInfo:nil
                                                      repeats:YES] retain];
            
            [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
            [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSDefaultRunLoopMode];
            [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSEventTrackingRunLoopMode];
        }
    }
}

- (void)actuallyStopAnimation
{
    if (_animationThread) {
        // we were using threaded animation
		[_animationThread cancel];
		if (![_animationThread isFinished]) {
			[[NSRunLoop currentRunLoop] runMode:NSModalPanelRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.05]];
		}
		[_animationThread release];
        _animationThread = nil;
	}
    else if (_animationTimer) {
        // we were using timer-based animation
        [_animationTimer invalidate];
        [_animationTimer release];
        _animationTimer = nil;
    }
    [self setNeedsDisplay:YES];
}

- (void)animateInBackgroundThread
{
	NSAutoreleasePool *animationPool = [[NSAutoreleasePool alloc] init];
	
	// Set up the animation speed to subtly change with size > 32.
	// int animationDelay = 38000 + (2000 * ([self bounds].size.height / 32));
    
    // Set the rev per minute here
    int omega = 100; // RPM
    int animationDelay = 60*1000000/omega/_numFins;
	int poolFlushCounter = 0;
    
	do {
		[self updateFrame:nil];
		usleep(animationDelay);
		poolFlushCounter++;
		if (poolFlushCounter > 256) {
			[animationPool drain];
			animationPool = [[NSAutoreleasePool alloc] init];
			poolFlushCounter = 0;
		}
	} while (![[NSThread currentThread] isCancelled]); 
    
	[animationPool release];
}

@end
