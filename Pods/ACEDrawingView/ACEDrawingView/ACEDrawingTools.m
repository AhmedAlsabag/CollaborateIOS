/*
 * ACEDrawingView: https://github.com/acerbetti/ACEDrawingView
 *
 * Copyright (c) 2013 Stefano Acerbetti
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "ACEDrawingTools.h"
#if (TARGET_OS_EMBEDDED || TARGET_OS_IPHONE)
#import <CoreText/CoreText.h>
#else
#import <AppKit/AppKit.h>
#endif

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

#pragma mark - ACEDrawingPenTool

@implementation ACEDrawingPenTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize isCompleted = _isCompleted;
@synthesize identifier = _identifier;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.lineCapStyle = kCGLineCapRound;
        path = CGPathCreateMutable();
    }
    return self;
}

- (void)setInitialPoint:(CGPoint)firstPoint
{
    //[self moveToPoint:firstPoint];
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    //[self addQuadCurveToPoint:midPoint(endPoint, startPoint) controlPoint:startPoint];
}

- (CGRect)addPathPreviousPreviousPoint:(CGPoint)p2Point withPreviousPoint:(CGPoint)p1Point withCurrentPoint:(CGPoint)cpoint {
    
    CGPoint mid1 = midPoint(p1Point, p2Point);
    CGPoint mid2 = midPoint(cpoint, p1Point);
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL, p1Point.x, p1Point.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(subpath);
    
    CGPathAddPath(path, NULL, subpath);
    CGPathRelease(subpath);
    
    return bounds;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextAddPath(context, path);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGContextSetAlpha(context, self.lineAlpha);
    CGContextStrokePath(context);
}

- (CGMutablePathRef)getPath
{
    return path;
}

- (void)setPath:(CGMutablePathRef)newPath
{
    path = newPath;
}

- (void)dealloc
{
    CGPathRelease(path);
    self.lineColor = nil;
    #if !ACE_HAS_ARC
    [super dealloc];
    #endif
}

- (void)deserializePath:(NSString *)name withInfo:(NSDictionary *)info
{

    NSDictionary *rgb = [info objectForKey:@"color"];
    CGFloat red = [[rgb objectForKey:@"red"] floatValue];
    CGFloat green = [[rgb objectForKey:@"green"] floatValue];
    CGFloat blue = [[rgb objectForKey:@"blue"] floatValue];
    CGFloat alpha = [[rgb objectForKey:@"alpha"] floatValue];
    
    NSArray *points = [info objectForKey:@"points"];
    CGMutablePathRef currPath = CGPathCreateMutable();
    for (NSString *currentPathElement in points) {
        
        NSArray *elements = [currentPathElement componentsSeparatedByString:@" "];
        if ([elements[0] isEqualToString:@"MoveTo"]) {
            CGPathMoveToPoint(currPath, NULL, [elements[1] floatValue], [elements[2] floatValue]);
        } else if ([elements[0] isEqualToString:@"LineTo"]) {
            CGPathAddLineToPoint(currPath, NULL, [elements[1] floatValue], [elements[2] floatValue]);
        } else if ([elements[0] isEqualToString:@"QuadCurveTo"]) {
            CGPathAddQuadCurveToPoint(currPath, NULL, [elements[1] floatValue], [elements[2] floatValue], [elements[3] floatValue], [elements[4] floatValue]);
        } else if ([elements[0] isEqualToString:@"CurveTo"]) {
            CGPathAddCurveToPoint(currPath, NULL, [elements[1] floatValue], [elements[2] floatValue], [elements[3] floatValue], [elements[4] floatValue], [elements[5] floatValue], [elements[6] floatValue]);
        } else {
            NSLog(@"Error: Core Graphics Path Identifier.");
        }
    }
    
    CGFloat width = [[info objectForKey:@"width"] floatValue];
    
    self.lineColor = [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
    self.lineAlpha = alpha;
    self.lineWidth = width;
    self.isCompleted = YES;
    self.identifier = name;
    
    [self setPath:currPath];
    
}

- (NSDictionary *)serialize
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    
    //Points
    NSMutableArray *points = [[NSMutableArray alloc]init];
    CGPathApply(path, (__bridge void *)(points), processPathElement);
    [dict setObject:points forKey:@"points"];
    
    //Line Color
    NSMutableDictionary *rgb = [self getRGBComponents:self.lineColor];
    [rgb setObject:[NSNumber numberWithFloat:self.lineAlpha] forKey:@"alpha"];
    [dict setObject:rgb forKey:@"color"];
    
    //Line Width
    [dict setObject:[NSNumber numberWithFloat:self.lineWidth] forKey:@"width"];
    
    //Type
    [dict setObject:@"Pen" forKey:@"toolType"];
    
    return dict;
}

- (NSMutableDictionary *)getRGBComponents:(UIColor *)color {
    NSMutableDictionary *components = [[NSMutableDictionary alloc]init];
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    [components setObject:[NSNumber numberWithFloat:resultingPixel[0] / 255.0f] forKey:@"red"];
    [components setObject:[NSNumber numberWithFloat:resultingPixel[1] / 255.0f] forKey:@"green"];
    [components setObject:[NSNumber numberWithFloat:resultingPixel[2] / 255.0f] forKey:@"blue"];
    
    return components;
}

void processPathElement(void* info, const CGPathElement* element) {
    NSMutableArray *points = (__bridge NSMutableArray *)info;
    
    switch (element->type) {
        case kCGPathElementMoveToPoint: {
            CGPoint point = element ->points[0];
            [points addObject:[NSString stringWithFormat:@"%s %f %f\n", "MoveTo", point.x, point.y]];
            break;
        }
        case kCGPathElementAddLineToPoint: {
            CGPoint point = element ->points[0];
            [points addObject:[NSString stringWithFormat:@"%s %f %f\n", "LineTo", point.x, point.y]];
            break;
        }
        case kCGPathElementAddQuadCurveToPoint: {
            CGPoint point1 = element->points[0];
            CGPoint point2 = element->points[1];
            [points addObject:[NSString stringWithFormat:@"%s %f %f %f %f\n", "QuadCurveTo", point1.x, point1.y, point2.x, point2.y]];
            break;
        }
        case kCGPathElementAddCurveToPoint: {
            CGPoint point1 = element->points[0];
            CGPoint point2 = element->points[1];
            CGPoint point3 = element->points[2];
            [points addObject:[NSString stringWithFormat:@"%s %f %f %f %f %f %f\n", "CurveTo", point1.x, point1.y, point2.x, point2.y, point3.x, point3.y]];
            break;
        }
        case kCGPathElementCloseSubpath: {
            [points addObject:@"ClosePath"];
            break;
        }
    }
    
}

@end


#pragma mark - ACEDrawingEraserTool

@implementation ACEDrawingEraserTool

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);

	CGContextAddPath(context, path);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end


#pragma mark - ACEDrawingLineTool

@interface ACEDrawingLineTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingLineTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;
@synthesize isCompleted = _isCompleted;
@synthesize identifier = _identifier;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the line properties
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the line
    CGContextMoveToPoint(context, self.firstPoint.x, self.firstPoint.y);
    CGContextAddLineToPoint(context, self.lastPoint.x, self.lastPoint.y);
    CGContextStrokePath(context);
}

- (void)dealloc
{
    self.lineColor = nil;
#if !ACE_HAS_ARC
    [super dealloc];
#endif
}

@end

#pragma mark - ACEDrawingTextTool

@interface ACEDrawingTextTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingTextTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;
@synthesize isCompleted = _isCompleted;
@synthesize identifier = _identifier;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the text
    CGRect viewBounds = CGRectMake(MIN(self.firstPoint.x, self.lastPoint.x),
                                   MIN(self.firstPoint.y, self.lastPoint.y),
                                   fabs(self.firstPoint.x - self.lastPoint.x),
                                   fabs(self.firstPoint.y - self.lastPoint.y)
                                   );
    
    // Flip the context coordinates, in iOS only.
    CGContextTranslateCTM(context, 0, viewBounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // Set the text matrix.
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    // Create a path which bounds the area where you will be drawing text.
    // The path need not be rectangular.
    CGMutablePathRef path = CGPathCreateMutable();
    
    // In this simple example, initialize a rectangular path.
    CGRect bounds = CGRectMake(viewBounds.origin.x, -viewBounds.origin.y, viewBounds.size.width, viewBounds.size.height);
    CGPathAddRect(path, NULL, bounds );
    
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge_retained CFAttributedStringRef)self.attributedText);
    
    // Create a frame.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
    // Draw the specified frame in the given context.
    CTFrameDraw(frame, context);
    
    // Release the objects we used.
    CFRelease(frame);
    CFRelease(framesetter);
    CFRelease(path);
    CGContextRestoreGState(context);
}

- (void)dealloc
{
    self.lineColor = nil;
    self.attributedText = nil;
#if !ACE_HAS_ARC
    [super dealloc];
#endif
}

@end


#pragma mark - ACEDrawingRectangleTool

@interface ACEDrawingRectangleTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingRectangleTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;
@synthesize isCompleted = _isCompleted;
@synthesize identifier = _identifier;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the rectangle
    CGRect rectToFill = CGRectMake(self.firstPoint.x, self.firstPoint.y, self.lastPoint.x - self.firstPoint.x, self.lastPoint.y - self.firstPoint.y);
    if (self.fill) {
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
        CGContextFillRect(UIGraphicsGetCurrentContext(), rectToFill);
        
    } else {
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextStrokeRect(UIGraphicsGetCurrentContext(), rectToFill);
    }
}

- (void)dealloc
{
    self.lineColor = nil;
#if !ACE_HAS_ARC
    [super dealloc];
#endif
}

@end


#pragma mark - ACEDrawingEllipseTool

@interface ACEDrawingEllipseTool ()
@property (nonatomic, assign) CGPoint firstPoint;
@property (nonatomic, assign) CGPoint lastPoint;
@end

#pragma mark -

@implementation ACEDrawingEllipseTool

@synthesize lineColor = _lineColor;
@synthesize lineAlpha = _lineAlpha;
@synthesize lineWidth = _lineWidth;
@synthesize isCompleted = _isCompleted;
@synthesize identifier = _identifier;

- (void)setInitialPoint:(CGPoint)firstPoint
{
    self.firstPoint = firstPoint;
}

- (void)moveFromPoint:(CGPoint)startPoint toPoint:(CGPoint)endPoint
{
    self.lastPoint = endPoint;
}

- (void)draw
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the properties
    CGContextSetAlpha(context, self.lineAlpha);
    
    // draw the ellipse
    CGRect rectToFill = CGRectMake(self.firstPoint.x, self.firstPoint.y, self.lastPoint.x - self.firstPoint.x, self.lastPoint.y - self.firstPoint.y);
    if (self.fill) {
        CGContextSetFillColorWithColor(context, self.lineColor.CGColor);
        CGContextFillEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
        
    } else {
        CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
        CGContextSetLineWidth(context, self.lineWidth);
        CGContextStrokeEllipseInRect(UIGraphicsGetCurrentContext(), rectToFill);
    }
}

- (void)dealloc
{
    self.lineColor = nil;
#if !ACE_HAS_ARC
    [super dealloc];
#endif
}

@end
