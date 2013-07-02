#import "SCInsertionPoint.h"

@implementation SCInsertionPoint

+ (instancetype)insertionPointWithIndex:(NSUInteger)index
{
    return [[self alloc] initWithCharIndex:index];
}

- (instancetype)initWithCharIndex:(NSUInteger)index
{
    self = [super init];
    if (self) {
        self.index = index;
        self.goalColumn = 0;
}
    return self;
}

- (void)advanceBy:(NSInteger)offset
{
    self.index += offset;
}

- (NSComparisonResult)compare:(SCInsertionPoint *)other
{
    return [@(self.index) compare:@(other.index)];
}


@end
