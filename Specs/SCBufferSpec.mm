#import "SCBuffer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SCBufferSpec)

describe(@"SCBuffer", ^{
    __block SCBuffer *buffer;
    __block NSTextStorage *textStorage;
    __block NSString *line1;
    __block NSString *line2;
    __block NSString *string;

    beforeEach(^{
        line1 = @"one two three";
        line2 = @"four five six";
        string = [@[line1, line2] componentsJoinedByString:@"\n"];
        
        textStorage = [[NSTextStorage alloc] init];
        buffer = [[SCBuffer alloc] initWithTextStorage:textStorage];
        [textStorage.mutableString insertString:string atIndex:0];
    });
    
    describe(@"with multiple cursors set up", ^{
        beforeEach(^{
            [buffer setInsertionPointIndex:@(@"one".length)];
            [buffer addInsertionPointAtIndex:@(@"one two".length)];
            [buffer addInsertionPointAtIndex:@(@"one two three".length)];
        });
        
        it(@"can insert a string at every insertion point", ^{
            [buffer insertCharacter:@"..."];
            buffer.string should equal(@"one... two... three...\nfour five six");
        });
        
        it(@"can move all of its insertion points left and right", ^{
            [buffer moveLeft];
            buffer.insertionPointIndices should equal(@[@(@"on".length),
                                                      @(@"one tw".length),
                                                      @(@"one two thre".length)]);
            
            [buffer moveRight];
            buffer.insertionPointIndices should equal(@[@(@"one".length),
                                                      @(@"one two".length),
                                                      @(@"one two three".length)]);
        });
        
        it(@"does not let the insertion point move beyond the bounds of the text", ^{
            [buffer setInsertionPointIndex:0];
            [buffer moveLeft];
            buffer.insertionPointIndices should equal(@[@0]);
            
            [buffer setInsertionPointIndex:@(string.length)];
            [buffer moveRight];
            buffer.insertionPointIndices should equal(@[@(string.length)]);
        });
        
        describe(@"moving the cursors down", ^{
            beforeEach(^{
                [buffer moveDown];
            });
            
            it(@"keeps them in the same column", ^{
                buffer.insertionPointIndices should equal(@[@(line1.length + 1 + @"one".length),
                                                          @(line1.length + 1 + @"one two".length),
                                                          @(2 * line1.length + 1)]);
            });
            
            it(@"moves them to the end of the line when they're on the last line", ^{
                [buffer moveDown];
                buffer.insertionPointIndices should equal(@[@(string.length),
                                                          @(string.length),
                                                          @(string.length)]);
            });
            
            describe(@"moving them back up", ^{
                beforeEach(^{
                    [buffer moveUp];
                });

                it(@"can move them back up", ^{
                    buffer.insertionPointIndices should equal(@[@(@"one".length),
                                                              @(@"one two".length),
                                                              @(@"one two three".length)]);
                });
                
                it(@"moves them to the beginning of the line when they're at ", ^{
                    [buffer setInsertionPointIndex:@(@"one".length)];
                    [buffer moveUp];
                    buffer.insertionPointIndices should equal(@[@0]);
                });
            });
        });
        
        describe(@"moving the cursor to the beginning and end of lines", ^{
            it(@"works on the first line", ^{
                [buffer setInsertionPointIndex:@(@"one".length)];
                [buffer moveToBeginningOfLine];
                buffer.insertionPointIndices should equal(@[@0]);
                
                [buffer setInsertionPointIndex:@(@"one".length)];
                [buffer moveToEndOfLine];
                buffer.insertionPointIndices should equal(@[@(@"one two three".length)]);
            });
            
            it(@"works on a line in the middle of the text", ^{
                [buffer setInsertionPointIndex:@(line1.length + 5)];
                [buffer moveToEndOfLine];
                buffer.insertionPointIndices should equal(@[@(string.length)]);
                
                [buffer setInsertionPointIndex:@(line1.length + 5)];
                [buffer moveToBeginningOfLine];
                buffer.insertionPointIndices should equal(@[@(line1.length + 1)]);
            });
        });
    });
});

SPEC_END
