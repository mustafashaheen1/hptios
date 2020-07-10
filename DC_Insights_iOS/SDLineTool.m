//
//  SDLineTool.m
//  SimpleDrawing
//
//  Created by Nathanial Woolls on 10/17/12.
//

// This code is distributed under the terms and conditions of the MIT license.

// Copyright (c) 2012 Nathanial Woolls
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "SDLineTool.h"


@implementation SDLineTool

- (void)touchMoved:(UITouch*)touch {
    
    [super touchMoved:touch];
    
    CGPoint currentPoint = [touch locationInView:self.drawingImageView];
    [self drawEllipseFromPoint:self.firstPoint toPoint:currentPoint];
    
}

- (void)drawEllipseFromPoint:(CGPoint)from toPoint:(CGPoint)to {
    
    [self setupImageContextForDrawing];\
    
    /* Draw arrow head with lines */
    
    
    /*float deltaX;
    float deltaY;
    float frac = (float) 0.1;
    float point_x_1;
    float point_y_1;
    float point_x_2;
    float point_y_2;
    float point_x_3;
    float point_y_3;
    deltaX = toPoint.x - fromPoint.x;
    deltaY = toPoint.y - fromPoint.y;
    frac = (float) 0.1;
    point_x_1 = fromPoint.x + (float) ((1 - frac) * deltaX + frac * deltaY);
    point_y_1 = fromPoint.y + (float) ((1 - frac) * deltaY - frac * deltaX);
    point_x_2 = toPoint.x;
    point_y_2 = toPoint.y;
    point_x_3 = fromPoint.x + (float) ((1 - frac) * deltaX - frac * deltaY);
    point_y_3 = fromPoint.y + (float) ((1 - frac) * deltaY + frac * deltaX);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapSquare);
    CGContextBeginPath(UIGraphicsGetCurrentContext());
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), toPoint.x, toPoint.y);
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), point_x_1, point_y_1);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point_x_2, point_y_2);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point_x_3, point_y_3);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), point_x_1, point_y_1);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext());*/
    
    /* Draw filled arrowhead */
    
    double slopy, cosy, siny;
    // Arrow size
    double length = 10.0;
    double width = 15.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    slopy = atan2((from.y - to.y), (from.x - to.x));
    cosy = cos(slopy);
    siny = sin(slopy);
    
    //draw a line between the 2 endpoint
    CGContextMoveToPoint(context, from.x - length * cosy, from.y - length * siny );
    CGContextAddLineToPoint(context, to.x + length * cosy, to.y + length * siny);
    //paints a line along the current path
    CGContextStrokePath(context);
    
    /*CGContextMoveToPoint(context, from.x, from.y);
    CGContextAddLineToPoint(context,
                            from.x + ( - length * cosy - ( width / 2.0 * siny )),
                            from.y + ( - length * siny + ( width / 2.0 * cosy )));
    CGContextAddLineToPoint(context,
                            from.x + (- length * cosy + ( width / 2.0 * siny )),
                            from.y - (width / 2.0 * cosy + length * siny ) );
    CGContextClosePath(context);
    CGContextStrokePath(context);*/
    
    /*/-------------similarly the the other end-------------/*/
    CGContextMoveToPoint(context, to.x, to.y);
    CGContextAddLineToPoint(context,
                            to.x +  (length * cosy - ( width / 2.0 * siny )),
                            to.y +  (length * siny + ( width / 2.0 * cosy )) );
    CGContextAddLineToPoint(context,
                            to.x +  (length * cosy + width / 2.0 * siny),
                            to.y -  (width / 2.0 * cosy - length * siny) );
    CGContextClosePath(context);
    CGContextStrokePath(context);
    
    self.drawingImageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
}

@end
