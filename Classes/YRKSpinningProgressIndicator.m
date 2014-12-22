//
//  YRKSpinningProgressIndicator.m
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import "YRKSpinningProgressIndicator.h"

// Some constants to control the animation
const CGFloat kAlphaWhenStopped = 0.15;
const CGFloat kFadeMultiplier = 0.85l;
const NSUInteger kNumberOfFins = 12;
const NSTimeInterval kFadeOutTime = 0.5;  // seconds


// Helper functions
static NSTimeInterval timeIntervalFromCVTimeStamp(const CVTimeStamp *timestamp);


@interface YRKSpinningProgressIndicator ()
@end


@implementation YRKSpinningProgressIndicator {
    NSUInteger _currentPosition;
    NSArray *_finColors;
    BOOL _isAnimating;

    CVDisplayLinkRef _displayLink;
    NSTimeInterval _animationStartTime;

    NSTimeInterval _fadeOutStartTime;
    CGFloat _fadeAmount;  // 1.0 = no fade, 0.0 = full fade
    BOOL _isFadingOut;
}

#pragma mark - Init

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _currentPosition = 0;
        _finColors = @[];

        _isAnimating = NO;
        _isFadingOut = NO;

        // user setter, to generate all fin colors
        self.color = [NSColor blackColor];
        _backgroundColor = [NSColor clearColor];
        _drawsBackground = NO;
        
        _displayedWhenStopped = YES;

        _indeterminate = YES;
        _currentValue = 0.0;
        _maxValue = 100.0;
    }
    return self;
}


#pragma mark - NSView overrides

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    
    if ([self window] == nil) {
        // No window? View hierarchy may be going away. Dispose timer to clear circular retain of timer to self to timer.
        [self actuallyStopAnimation];
    }
    else if (_isAnimating) {
        [self actuallyStartAnimation];
    }
}

- (void)drawRect:(NSRect)rect
{
    const CGSize size = self.bounds.size;
    const CGFloat length = MIN(size.height, size.width);

    // fill the background, if set
    if (_drawsBackground) {
        [_backgroundColor set];
        [NSBezierPath fillRect:[self bounds]];
    }
    
    CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];

    // Move the CTM so 0,0 is at the center of our bounds
    CGContextTranslateCTM(ctx, size.width/2, size.height/2);
    
    if (_indeterminate) {
        NSBezierPath *path = [[NSBezierPath alloc] init];
        // magic constants determined empirically, to make it look like the NS version.
        const CGFloat lineWidth = 0.0859375 * length; // should be 2.75 for 32x32
        const CGFloat lineStart = 0.234375 * length; // should be 7.5 for 32x32
        const CGFloat lineEnd = 0.421875 * length; // should be 13.5 for 32x32
        [path setLineWidth:lineWidth];
        [path setLineCapStyle:NSRoundLineCapStyle];
        [path moveToPoint:NSMakePoint(0, lineStart)];
        [path lineToPoint:NSMakePoint(0, lineEnd)];

        // Draw all the fins by rotating the CTM, then just redraw the same path again.
        for (NSUInteger i = 0; i < kNumberOfFins; i++) {
            NSColor *c = _isAnimating ? _finColors[(i + _currentPosition) % kNumberOfFins] : [_color colorWithAlphaComponent:kAlphaWhenStopped];
            if (_isFadingOut) {
                const CGFloat minAlpha = _displayedWhenStopped ? kAlphaWhenStopped : 0.0;
                c = [c colorWithAlphaComponent:MAX(c.alphaComponent * _fadeAmount, minAlpha)];
            }
            [c set];
            [path stroke];

            CGContextRotateCTM(ctx, 2 * M_PI/kNumberOfFins);
        }
    }
    else {
        CGFloat lineWidth = 1 + (0.01 * length);
        CGFloat circleRadius = (length - lineWidth) / 2.1;
        NSPoint circleCenter = NSMakePoint(0, 0);
        [_color set];
        NSBezierPath *path = [[NSBezierPath alloc] init];
        [path setLineWidth:lineWidth];
        [path appendBezierPathWithOvalInRect:NSMakeRect(-circleRadius,
                                                        -circleRadius,
                                                        circleRadius * 2,
                                                        circleRadius * 2)];
        [path stroke];
        path = [[NSBezierPath alloc] init];
        [path appendBezierPathWithArcWithCenter:circleCenter radius:circleRadius startAngle:90 endAngle:90-(360*(_currentValue/_maxValue)) clockwise:YES];
        [path lineToPoint:circleCenter] ;
        [path fill];
    }
}

- (BOOL)isOpaque
{
    return _drawsBackground;
}

#pragma mark - NSProgressIndicator API

- (void)startAnimation:(id)sender
{
    if (!_indeterminate || (_isAnimating && !_isFadingOut)) {
        return;
    }

    [self actuallyStartAnimation];
}

- (void)stopAnimation:(id)sender
{
    // Don't stop immediately; continue animation to fade out to stopped state.
    _isFadingOut = YES;
    _fadeOutStartTime = -1;  // signal to set it on next displayLink callback
}


#pragma mark - Custom Accessors

- (void)setColor:(NSColor *)value
{
    if (_color != value) {
        _color = [value copy];

        NSTimeInterval elapsedTime = 0.0;
        // elapsedTime is only needed when fading out
        if (_isFadingOut) {
            CVTimeStamp now;
            if (CVDisplayLinkGetCurrentTime(_displayLink, &now) == kCVReturnSuccess) {
                elapsedTime = timeIntervalFromCVTimeStamp(&now);
            }
            else {
                NSLog(@"error getting current time");
            }
        }
        // Set all the fin colors, with decreasing alpha.
        NSMutableArray *mutableColors = [NSMutableArray arrayWithCapacity:kNumberOfFins];
        for (NSUInteger i = 0; i < kNumberOfFins; i++) {
            CGFloat alphaValue = pow(kFadeMultiplier, i);
            mutableColors[i] = [_color colorWithAlphaComponent:alphaValue];
        }
        _finColors = mutableColors;

        [self setNeedsDisplay:YES];
    }
}

- (void)setBackgroundColor:(NSColor *)value
{
    if (_backgroundColor != value) {
        _backgroundColor = [value copy];
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

- (void)setIsIndeterminate:(BOOL)isIndeterminate
{
    _indeterminate = isIndeterminate;
    if (!_indeterminate && _isAnimating) {
        [self stopAnimation:self];
    }
    [self setNeedsDisplay:YES];
}

- (void)setCurrentValue:(CGFloat)currentValue
{
    // Automatically put it into determinate mode if it's not already.
    if (_indeterminate) {
        self.indeterminate = NO;
    }
    _currentValue = currentValue;
    [self setNeedsDisplay:YES];
}

- (void)setMaxValue:(CGFloat)maxValue
{
    _maxValue = maxValue;
    [self setNeedsDisplay:YES];
}

- (void)setDisplayedWhenStopped:(BOOL)displayedWhenStopped
{
    _displayedWhenStopped = displayedWhenStopped;
    
    // Show/hide ourself if necessary
    if (!_isAnimating) {
        self.hidden = !_displayedWhenStopped;
    }
}


#pragma mark - Private

- (void)actuallyStartAnimation
{
    NSAssert([NSThread isMainThread], @"must be called on main thread");

    // Just to be safe kill any existing timer.
    [self actuallyStopAnimation];
    
    _isAnimating = YES;
    _isFadingOut = NO;
    
    // always start from the top
    _currentPosition = 0;
    
    if (!_displayedWhenStopped) {
        [self setHidden:NO];
    }

    // Don't animate if not visible. viewDidMoveToWindow will re-call this method when needed.
    if (self.window) {
        CGDirectDisplayID displayID = CGMainDisplayID();
        CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink);
        CVDisplayLinkSetCurrentCGDisplay(_displayLink, ((CGDirectDisplayID)[[[NSScreen mainScreen].deviceDescription objectForKey:@"NSScreenNumber"]intValue]));
        CVReturn error = CVDisplayLinkCreateWithCGDisplay(displayID, &_displayLink);
        if (error != kCVReturnSuccess) {
            NSLog(@"CVDisplayLinkCreateWithCGDisplay() returned error=%d", error);
            _displayLink = NULL;
        }
        else {
            CVDisplayLinkSetOutputCallback(_displayLink,
                                           displayLinkCallback,
                                           (__bridge void *)self);
            CVDisplayLinkStart(_displayLink);
            _animationStartTime = -1;  // signal to set it on next displayLink callback
        }
    }
}


/// A C function that serves as the CVDisplayLink callback, but just calls to the Spinner to do the actual work.
CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *now,
                             const CVTimeStamp *outputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext)
{
    YRKSpinningProgressIndicator *spinner = (__bridge YRKSpinningProgressIndicator *)displayLinkContext;
    return spinner ? [spinner updateStateAndDrawForOutputTime:outputTime] : kCVReturnError;
}

/// This updates the state, and then draws (from a background thread).
/// The state info used by -drawRect: is _currentPosition and _fadeAmount.
- (CVReturn)updateStateAndDrawForOutputTime:(const CVTimeStamp *)outputTime
{
    if (!(outputTime->flags & kCVTimeStampVideoTimeValid)) {
        NSLog(@"videoTime not valid");
        return kCVReturnError;
    }

    NSTimeInterval now = timeIntervalFromCVTimeStamp(outputTime);

    // Check if we need to set the start times
    if (_animationStartTime < 0.0) {
        _animationStartTime = now;
    }
    if (_fadeOutStartTime < 0.0) {
        _fadeOutStartTime = now;
    }

    NSTimeInterval elapsedTime = now - _animationStartTime;

    if (!_isFadingOut) {
        // deterime new currentPosition
        const CGFloat rpm = 100.0;
        const NSTimeInterval desiredSecsPerFinIncrement = (NSTimeInterval)60 / rpm / kNumberOfFins;

        NSUInteger newPosition = (NSUInteger)floorf((elapsedTime / desiredSecsPerFinIncrement)) % kNumberOfFins;
        if (_currentPosition != newPosition) {
            _currentPosition = newPosition;
            dispatch_async(dispatch_get_main_queue(), ^{
                // use -display instead of -setNeedsDisplay:YES, otherwise it seems to get blocked
                // by certain run loop moodes (for example, resizing the window in the demo app.
                [self display];
            });
        }
    }
    else {
        // During fade-out, don't change _currentPosition, but do update _fadeAmount
        NSTimeInterval timeSinceStop = now - _fadeOutStartTime;
        _fadeAmount = kFadeOutTime - timeSinceStop;

        dispatch_async(dispatch_get_main_queue(), ^{
            [self display];

            // check if the fadeout is  done
            if (timeSinceStop > kFadeOutTime) {
                [self actuallyStopAnimation];
            }
        });
    }

    return kCVReturnSuccess;
}

- (void)actuallyStopAnimation
{
    NSAssert([NSThread isMainThread], @"must be called on main thread");

    _isAnimating = NO;
    _isFadingOut = NO;
    
    if (!_displayedWhenStopped) {
        [self setHidden:YES];
    }

    // clean up the displayLink
    CVDisplayLinkStop(_displayLink);
    CVDisplayLinkRelease(_displayLink);
    _displayLink = nil;

    [self setNeedsDisplay:YES];
}

@end


#pragma mark - Helper functions

static NSTimeInterval timeIntervalFromCVTimeStamp(const CVTimeStamp *timestamp)
{
    return ((NSTimeInterval)timestamp->videoTime) / timestamp->videoTimeScale;
}
