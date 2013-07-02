#import "SCCommand.h"

@implementation SCCommand

+ (instancetype)commandWithSelector:(SEL)selector argument:(id)argument
{
    SCCommand *command = [[self alloc] init];
    command.selector = selector;
    command.argument = argument;
    return command;
}

+ (instancetype)commandWithMethodName:(NSString *)methodName argument:(id)argument
{
    return [self commandWithSelector:NSSelectorFromString(methodName) argument:argument];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Command: %@, %@", NSStringFromSelector(self.selector), self.argument];
}

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[SCCommand class]] &&
    ([object selector] == self.selector) &&
    [[object argument] isEqual:self.argument];
}

@end