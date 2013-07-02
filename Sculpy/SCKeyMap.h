@class SCCommand;

@interface SCKeyMap : NSObject

+ (instancetype)defaultMap;
+ (instancetype)mapWithDictionary:(NSDictionary *)dictionary;
- (SCCommand *)commandForKeyCode:(NSUInteger)keyCode modifiers:(NSUInteger)modifiers;
- (SCCommand *)commandForClickWithModifiers:(NSUInteger)modifiers;

@end