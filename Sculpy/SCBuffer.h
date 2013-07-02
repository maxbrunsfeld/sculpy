#import <Foundation/Foundation.h>

@class SCCommand;

@interface SCBuffer : NSObject

@property (nonatomic, strong) NSTextStorage *textStorage;

- (id)initWithTextStorage:(NSTextStorage *)textStorage;

- (void)runCommand:(SCCommand *)command;
- (void)runCommand:(SCCommand *)command index:(NSNumber *)index;

- (void)moveUp;
- (void)moveDown;
- (void)moveLeft;
- (void)moveRight;
- (void)moveToBeginningOfLine;
- (void)moveToEndOfLine;

- (void)setInsertionPointIndex:(NSNumber *)index;
- (void)addInsertionPointAtIndex:(NSNumber *)index;

- (void)insertCharacter:(NSString *)string;

- (NSString *)string;
- (NSUInteger)length;
- (NSArray *)insertionPointIndices;

@end