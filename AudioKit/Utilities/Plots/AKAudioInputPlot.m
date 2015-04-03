//
//  AKAudioInputPlot.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/6/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
#import "CsoundObj.h"
#import "AKAudioInputPlot.h"
#import "AKFoundation.h"

@interface AKAudioInputPlot() <CsoundBinding>
{
    NSData *inSamples;
    MYFLT *samples;
    int sampleSize;
    CsoundObj *cs;
}

@end

@implementation AKAudioInputPlot

- (void) defaultValues
{
    _lineWidth = 4.0f;
    _lineColor = [AKColor yellowColor];
}


- (void)drawWithColor:(AKColor *)color lineWidth:(CGFloat)width
{
    // Draw waveform
#if TARGET_OS_IPHONE
    UIBezierPath *waveformPath = [UIBezierPath bezierPath];
#elif TARGET_OS_MAC
    NSBezierPath *waveformPath = [NSBezierPath bezierPath];
#endif
    
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    for (int i = 0; i < sampleSize/2; i++) {
        y = AK_CLAMP(samples[i*2], -1.0f, 1.0f);
        y = self.bounds.size.height * (y + 1.0) / 2.0;
        
        if (i == 0) {
            [waveformPath moveToPoint:CGPointMake(x, y)];
        } else {
#if TARGET_OS_IPHONE
            [waveformPath addLineToPoint:CGPointMake(x, y)];
#elif TARGET_OS_MAC
            [waveformPath lineToPoint:CGPointMake(x, y)];
#endif
            
        }
        x += (self.frame.size.width / (sampleSize/2));
    };
    
    [waveformPath setLineWidth:width];
    [color setStroke];
    [waveformPath stroke];
}

- (void)drawRect:(CGRect)rect {
    [self drawWithColor:self.lineColor lineWidth:self.lineWidth];
}

// -----------------------------------------------------------------------------
# pragma mark - CsoundBinding
// -----------------------------------------------------------------------------

- (void)setup:(CsoundObj *)csoundObj
{
    cs = csoundObj;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"AudioKit" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    int samplesPerControlPeriod = [dict[@"Samples Per Control Period"] intValue];
    int numberOfChannels = [dict[@"Number Of Channels"] intValue];
    
    sampleSize = numberOfChannels * samplesPerControlPeriod;
    samples = (MYFLT *)malloc(sampleSize * sizeof(MYFLT));
}

- (void)updateValuesFromCsound
{
    inSamples = [cs getInSamples];
    samples = (MYFLT *)[inSamples bytes];
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
    
}

- (void)updateUI {
#if TARGET_OS_IPHONE
    [self setNeedsDisplay];
#elif TARGET_OS_MAC
    [self setNeedsDisplay:YES];
#endif
}

@end
