#import <Foundation/Foundation.h>

@interface SCInsertionPoint : NSObject

+ (instancetype)insertionPointWithIndex:(NSUInteger)index;

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger goalColumn;

- (void)advanceBy:(NSInteger)offset;

@end
