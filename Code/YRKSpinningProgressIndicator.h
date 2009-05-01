//
//  YRKSpinningProgressIndicator.h
//
//  Copyright 2009 Kelan Champagne. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YRKSpinningProgressIndicator : NSView {
    int _position;
    NSDate *_nextFrameUpdate;
    int _numFins;

    BOOL _isAnimating;
    NSTimer *_animationTimer;

    NSColor *_foreColor;
    NSColor *_backColor;
    BOOL _drawBackground;

    NSTimer *_fadeOutAnimationTimer;
    BOOL _isFadingOut;
}
- (void)animate:(id)sender;
- (void)stopAnimation:(id)sender;
- (void)startAnimation:(id)sender;

- (NSColor *)foreColor;
- (void)setForeColor:(NSColor *)value;

- (NSColor *)backColor;
- (void)setBackColor:(NSColor *)value;

- (BOOL)drawBackground;
- (void)setDrawBackground:(BOOL)value;

@end
