//
//  YRKSpinningProgressIndicator.m
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import "YRKSpinningProgressIndicator.h"

@implementation YRKSpinningProgressIndicator

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		_position = 0;
        _numFins = 12;
		_isAnimating = NO;
		_isFadingOut = NO;
		_nextFrameUpdate = [[NSDate date] retain];
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
	int i;
	float alpha = 1.0;
	
	// Determine size based on current bounds
	NSSize size = [self bounds].size;
	float maxSize;
	if(size.width >= size.height)
		maxSize = size.height;
	else
		maxSize = size.width;
	
	// fill the background, if set
	if(_drawBackground) {
		[_backColor set];
		[NSBezierPath fillRect:[self bounds]];
	}
	
	CGContextRef currentContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	[NSGraphicsContext saveGraphicsState];
	
	// Move the CTM so 0,0 is at the center of our bounds
	CGContextTranslateCTM(currentContext,[self bounds].size.width/2,[self bounds].size.height/2);
	
	// do initial rotation to start place
	CGContextRotateCTM(currentContext, 3.14159*2/_numFins * _position);
	
	NSBezierPath *path = [[NSBezierPath alloc] init];
	float lineWidth = 0.0859375 * maxSize; // should be 2.75 for 32x32
	float lineStart = 0.234375 * maxSize; // should be 7.5 for 32x32
	float lineEnd = 0.421875 * maxSize;  // should be 13.5 for 32x32
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
	
	[NSGraphicsContext restoreGraphicsState];
}

# pragma mark -
# pragma mark Subclass

- (void)animate:(id)sender {
    
    if(_position > 0) {
        _position--;
    }
    else {
        _position = _numFins;  
    } 

    [self setNeedsDisplay:YES];
}

- (void)startAnimation:(id)sender {
	_isAnimating = YES;
    _animationTimer = [[NSTimer timerWithTimeInterval:(NSTimeInterval)0.05
                                               target:self
                                             selector:@selector(animate:)
                                             userInfo:nil
                                              repeats:YES] retain];
                                          
    [_animationTimer setFireDate:[NSDate date]];
    [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] addTimer:_animationTimer forMode:NSEventTrackingRunLoopMode];
}

- (void)stopAnimation:(id)sender {
	_isAnimating = NO;
    [_animationTimer invalidate];
    
    [self setNeedsDisplay:YES];
}

# pragma mark Not Implemented

- (void)setStyle:(NSProgressIndicatorStyle)style {
    if (NSProgressIndicatorSpinningStyle != style) {
        NSAssert(NO, @"Non-spinning styles not available.");
    }
}


# pragma mark -
# pragma mark Accessors

- (NSColor *)foreColor {
    return [[_foreColor retain] autorelease];
}

- (void)setForeColor:(NSColor *)value {
    if (_foreColor != value) {
        [_foreColor release];
        _foreColor = [value copy];
		[self setNeedsDisplay:YES];
    }
}

- (NSColor *)backColor {
    return [[_backColor retain] autorelease];
}

- (void)setBackColor:(NSColor *)value {
    if (_backColor != value) {
        [_backColor release];
        _backColor = [value copy];
		[self setNeedsDisplay:YES];
    }
}

- (BOOL)drawBackground {
    return _drawBackground;
}

- (void)setDrawBackground:(BOOL)value {
    if (_drawBackground != value) {
        _drawBackground = value;
    }
	[self setNeedsDisplay:YES];
}

@end
