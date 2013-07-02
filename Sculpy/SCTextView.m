#import "SCTextView.h"
#import "SCKeyMap.h"
#import "SCBuffer.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreGraphics/CGContext.h>

@implementation SCTextView

- (id)initWithFrame:(NSRect)frame
{
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize:frame.size];
    [layoutManager addTextContainer:textContainer];
    return [self initWithFrame:frame textContainer:textContainer];
}

- (id)initWithFrame:(NSRect)frame textContainer:(NSTextContainer *)container
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textContainer = container;
        self.buffer = [[SCBuffer alloc] initWithTextStorage:[NSTextStorage new]];
        [self.buffer.textStorage addLayoutManager:container.layoutManager];
    }
    return self;
}

# pragma mark - Configuration

- (BOOL)canBecomeKeyView
{
    return YES;
}

- (BOOL)isFlipped
{
    return YES;
}

# pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    [self drawBackgroundInRect:dirtyRect];
    [self drawSelectionsInRect:dirtyRect];
    [self drawTextInRect:dirtyRect];
    [self drawInsertionPointsInRect:dirtyRect];
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    [[NSColor whiteColor] set];
    NSRectFill(dirtyRect);
}

- (void)drawSelectionsInRect:(NSRect)dirtyRect
{
    
}

- (void)drawTextInRect:(NSRect)rect
{
    NSRange glyphRange = [self.layoutManager glyphRangeForBoundingRect:rect inTextContainer:self.textContainer];
    [self.layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:rect.origin];
}

- (void)drawInsertionPointsInRect:(NSRect)rect
{
    [[NSColor blackColor] set];
    for (NSNumber *index in self.buffer.insertionPointIndices) {
        NSRect rect = [self rectForInsertionPointIndex:[index integerValue]];
        NSRectFill(rect);
    }
}

# pragma mark - Events

- (void)keyDown:(NSEvent *)event
{
    SCCommand *command = [self.keyMap commandForKeyCode:event.keyCode modifiers:event.modifierFlags];
    [self.buffer runCommand:command];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint location = [self convertPoint:event.locationInWindow fromView:nil];
    NSUInteger index = [self.layoutManager characterIndexForPoint:location
                                                  inTextContainer:self.textContainer
                         fractionOfDistanceBetweenInsertionPoints:nil];
    SCCommand *command = [self.keyMap commandForClickWithModifiers:event.modifierFlags];
    [self.buffer runCommand:command index:@(index)];
    [self setNeedsDisplay:YES];
}

# pragma mark - Private

- (NSLayoutManager *)layoutManager
{
    return self.textContainer.layoutManager;
}

- (NSRect)rectForInsertionPointIndex:(NSUInteger)index
{
    NSUInteger characterIndex = index;
    NSUInteger rectCount = 0;
    NSRectArray rects = [self.layoutManager 
                         rectArrayForCharacterRange:NSMakeRange(characterIndex, 1)
                         withinSelectedCharacterRange:NSMakeRange(0, 0)
                         inTextContainer:self.textContainer
                         rectCount:&rectCount];
    if (rectCount == 0) {
        return NSZeroRect;
    } else {
        NSRect result = rects[0];
        result.size.width = 1;
        return result;
    }
}

@end
