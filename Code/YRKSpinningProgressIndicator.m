//
//  YRKSpinningProgressIndicator.m
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import "YRKSpinningProgressIndicator.h"


@interface YRKSpinningProgressIndicator (YRKSpinningProgressIndicatorPrivate)

- (void)updateFrame:(NSTimer *)timer;
- (void)animateInBackgroundThread;
- (void)actuallyStartAnimation;
- (void)actuallyStopAnimation;

@end


@implementation YRKSpinningProgressIndicator

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _position = 0;
        _numFins = 12;
        _isAnimating = NO;
        _isFadingOut = NO;
        _isIndeterminate = YES;
        _currentValue = 0.0;
        _maxValue = 100.0;
        _foreColor = [[NSColor blackColor] copy];
		_displayWhenStopped = YES;
    }
    return self;
}

- (void) dealloc {
    [_foreColor release];
    [_backColor release];
    if (_isAnimating) [self stopAnimation:self];
    
    [super dealloc];
}

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
    float theMaxSize;
    if(size.width >= size.height)
        theMaxSize = size.height;
    else
        theMaxSize = size.width;

    // fill the background, if set
    if(_drawBackground) {
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
        float lineWidth = 0.0859375 * theMaxSize; // should be 2.75 for 32x32
        float lineStart = 0.234375 * theMaxSize; // should be 7.5 for 32x32
        float lineEnd = 0.421875 * theMaxSize;  // should be 13.5 for 32x32
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
        float lineWidth = 1 + (0.01 * theMaxSize);
        float circleRadius = (theMaxSize - lineWidth) / 2.1;
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

# pragma mark -
# pragma mark Subclass

- (void)updateFrame:(NSTimer *)timer;
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

- (void)startAnimation:(id)sender
{
    if (!_isIndeterminate) return;
    if (_isAnimating) return;
    
	if (!_displayWhenStopped)
		[self setHidden:NO];
	
    [self actuallyStartAnimation];
    _isAnimating = YES;
}

- (void)stopAnimation:(id)sender
{
    [self actuallyStopAnimation];
    _isAnimating = NO;
	
	if (!_displayWhenStopped)
		[self setHidden:YES];
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

# pragma mark Not Implemented

- (void)setStyle:(NSProgressIndicatorStyle)style
{
    if (NSProgressIndicatorSpinningStyle != style) {
        NSAssert(NO, @"Non-spinning styles not available.");
    }
}


# pragma mark -
# pragma mark Accessors

- (NSColor *)color
{
    return [[_foreColor retain] autorelease];
}

- (void)setColor:(NSColor *)value
{
    if (_foreColor != value) {
        [_foreColor release];
        _foreColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (NSColor *)backgroundColor
{
    return [[_backColor retain] autorelease];
}

- (void)setBackgroundColor:(NSColor *)value
{
    if (_backColor != value) {
        [_backColor release];
        _backColor = [value copy];
        [self setNeedsDisplay:YES];
    }
}

- (BOOL)drawsBackground
{
    return _drawBackground;
}

- (void)setDrawsBackground:(BOOL)value
{
    if (_drawBackground != value) {
        _drawBackground = value;
    }
    [self setNeedsDisplay:YES];
}

- (BOOL)isIndeterminate
{
    return _isIndeterminate;
}

- (void)setIndeterminate:(BOOL)isIndeterminate
{
    _isIndeterminate = isIndeterminate;
    if (!_isIndeterminate && _isAnimating) [self stopAnimation:self];
    [self setNeedsDisplay:YES];
}

- (double)doubleValue
{
    return _currentValue;
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

- (double)maxValue
{
    return _maxValue;
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

- (BOOL)usesThreadedAnimation
{
    return _usesThreadedAnimation;
}

- (void)setDisplayedWhenStopped:(BOOL)displayWhenStopped
{
	_displayWhenStopped = displayWhenStopped;
	
	// Show/hide ourself if necessary
	if (!_isAnimating) {
		if (_displayWhenStopped && [self isHidden]) {
			[self setHidden:NO];
		}
		else if (!_displayWhenStopped && ![self isHidden]) {
			[self setHidden:YES];
		}
	}
}
- (BOOL)displayWhenStopped
{
	return _displayWhenStopped;
}

@end
