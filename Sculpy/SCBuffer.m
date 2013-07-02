#import <objc/objc-runtime.h>
#import "SCBuffer.h"
#import "SCCommand.h"
#import "SCInsertionPoint.h"

@interface SCBuffer ()
@property (nonatomic, strong) NSMutableArray *insertionPoints;
@property (nonatomic, strong) NSMutableArray *selections;
@end

@implementation SCBuffer

- (id)initWithTextStorage:(NSTextStorage *)textStorage
{
    self = [super init];
    if (self) {
        self.textStorage = textStorage;
        self.insertionPoints = [NSMutableArray new];
        self.selections = [NSMutableArray new];
        [self ensureLineBreakAtEnd];
        [self setInsertionPointIndex:@0];
    }
    return self;
}

- (void)runCommand:(SCCommand *)command
{
    if (command) objc_msgSend(self, command.selector, command.argument);
}

- (void)runCommand:(SCCommand *)command index:(NSNumber *)index
{
    if (command) objc_msgSend(self, command.selector, index, command.argument);
}

# pragma mark - Cursor movement

- (void)moveUp
{
    for (SCInsertionPoint *insertionPoint in self.insertionPoints) {
        NSUInteger lineStart = [self indexOfLineStartBeforeIndex:insertionPoint.index];
        if (lineStart > 0) {
            NSUInteger previousLineStart = [self indexOfLineStartBeforeIndex:(lineStart - 1)];
            insertionPoint.index = [self indexForGoalColumn:insertionPoint.goalColumn
                                                  lineStart:previousLineStart];
        } else {
            insertionPoint.index = 0;
            [self assignGoalColumnToInsertionPoint:insertionPoint];
        }
    }
}

- (void)moveDown
{
    for (SCInsertionPoint *insertionPoint in self.insertionPoints) {
        NSUInteger lineEnd = [self indexOfLineEndAfterIndex:insertionPoint.index];
        if (lineEnd < self.length) {
            insertionPoint.index = [self indexForGoalColumn:insertionPoint.goalColumn
                                                  lineStart:(lineEnd + 1)];
        } else {
            insertionPoint.index = lineEnd;
            [self assignGoalColumnToInsertionPoint:insertionPoint];
        }
    }
}

- (void)moveLeft
{
    for (SCInsertionPoint *insertionPoint in self.insertionPoints) {
        if (insertionPoint.index > 0) {
            [insertionPoint advanceBy:(-1)];
            [self assignGoalColumnToInsertionPoint:insertionPoint];
        }
    }
}

- (void)moveRight
{
    for (SCInsertionPoint *insertionPoint in self.insertionPoints) {
        if (insertionPoint.index < self.length) {
            [insertionPoint advanceBy:1];
            [self assignGoalColumnToInsertionPoint:insertionPoint];
        }
    }
}

- (void)moveToBeginningOfLine
{
    for (SCInsertionPoint *insertionPoint in self.insertionPoints) {
        insertionPoint.index = [self indexOfLineStartBeforeIndex:insertionPoint.index];
        [self assignGoalColumnToInsertionPoint:insertionPoint];
    }
}

- (void)moveToEndOfLine
{
    for (SCInsertionPoint *insertionPoint in self.insertionPoints) {
        insertionPoint.index = [self indexOfLineEndAfterIndex:insertionPoint.index];
        [self assignGoalColumnToInsertionPoint:insertionPoint];
    }
}

- (void)setInsertionPointIndex:(NSNumber *)index
{
    SCInsertionPoint *point = [SCInsertionPoint insertionPointWithIndex:index.integerValue];
    [self.insertionPoints removeAllObjects];
    [self.insertionPoints addObject:point];
    [self assignGoalColumnToInsertionPoint:point];
}

- (void)addInsertionPointAtIndex:(NSNumber *)index
{
    SCInsertionPoint *point = [SCInsertionPoint insertionPointWithIndex:index.integerValue];
    [self.insertionPoints addObject:point];
    [self assignGoalColumnToInsertionPoint:point];
    [self.insertionPoints sortUsingSelector:@selector(compare:)];
}

# pragma mark - Editing

- (void)insertCharacter:(NSString *)string
{
    NSUInteger advancement = 0;
    NSUInteger length = string.length;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string];
    for (SCInsertionPoint *insertionPoint in self.insertionPoints) {
        [insertionPoint advanceBy:advancement];
        [self.textStorage insertAttributedString:attributedString atIndex:insertionPoint.index];
        [insertionPoint advanceBy:length];
        advancement += length;
    }
}

- (void)deleteCharacterForwards
{
    NSUInteger retreat = 0;
    for (SCInsertionPoint *insertionPoint in self.insertionPoints) {
        [insertionPoint advanceBy:(-1 * retreat)];
        NSInteger index = insertionPoint.index;
        if (index < self.length) {
            [self.textStorage replaceCharactersInRange:NSMakeRange(index, 1) withString:@""];
            retreat++;
        }
    }
}

- (void)deleteCharacterBackwards
{
    NSUInteger retreat = 0;
    for (SCInsertionPoint *insertionPoint in self.insertionPoints) {
        [insertionPoint advanceBy:(-1 * retreat)];
        NSInteger index = insertionPoint.index - 1;
        if (index >= 0) {
            [self.textStorage replaceCharactersInRange:NSMakeRange(index, 1) withString:@""];
            [insertionPoint advanceBy:(-1)];
            retreat++;
        }
    }
}

# pragma mark - Querying

- (NSString *)string
{
    NSMutableString *mutableString = self.textStorage.mutableString;
    return [mutableString substringToIndex:(mutableString.length - 1)];
}

- (NSUInteger)length
{
    return (self.textStorage.mutableString.length - 1);
}

- (NSArray *)insertionPointIndices
{
    return [self.insertionPoints valueForKey:@"index"];
}

# pragma mark - Private

- (void)ensureLineBreakAtEnd
{
    NSAttributedString *lineBreak = [[NSAttributedString alloc] initWithString:@"\n"];
    [self.textStorage insertAttributedString:lineBreak
                                     atIndex:self.textStorage.mutableString.length];
}

- (void)assignGoalColumnToInsertionPoint:(SCInsertionPoint *)insertionPoint
{
    NSUInteger lineStart = [self indexOfLineStartBeforeIndex:insertionPoint.index];
    insertionPoint.goalColumn = (insertionPoint.index - lineStart);
}

- (NSUInteger)indexForGoalColumn:(NSUInteger)goalColumn lineStart:(NSUInteger)lineStart
{
    NSString *string = self.string;
    NSUInteger length = self.length;
    NSUInteger result = lineStart;
    while ((result - lineStart < goalColumn) &&
           (result < length) &&
           ([string characterAtIndex:result] != '\n'))
        result++;
    return result;
}

- (NSUInteger)indexOfLineStartBeforeIndex:(NSInteger)index
{
    if (index <= 0) return 0;
    NSInteger result = index - 1;
    while ((result >= 0) && ([self.string characterAtIndex:result] != '\n'))
        result--;
    return result + 1;
}

- (NSUInteger)indexOfLineEndAfterIndex:(NSInteger)index
{
    NSUInteger length = self.length;
    if (index >= length) return length;
    NSInteger result = index;
    while ((result < length) && ([self.string characterAtIndex:result] != '\n'))
        result++;
    return result;
}

@end
