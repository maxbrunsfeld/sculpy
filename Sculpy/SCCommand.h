@interface SCCommand : NSObject

+ (instancetype)commandWithMethodName:(NSString *)methodName argument:(id)argument;
+ (instancetype)commandWithSelector:(SEL)selector argument:(id)argument;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) id argument;

@end