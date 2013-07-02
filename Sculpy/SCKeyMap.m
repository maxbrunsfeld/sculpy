#import "SCKeyMap.h"
#import "SCCommand.h"
#import "SCBuffer.h"

# pragma mark - SCKeyCombination

@interface SCKeyCombination : NSObject
+ (instancetype)combinationWithCode:(NSNumber *)code modifiers:(NSNumber *)modifiers;
+ (instancetype)clickWithModifiers:(NSNumber *)modifiers;
@property (nonatomic, strong) NSNumber *modifierFlags;
@property (nonatomic, strong) NSNumber *keyCode;
@property (nonatomic, assign) int type;
@end

@implementation SCKeyCombination

+ (instancetype)combinationWithCode:(NSNumber *)code modifiers:(NSNumber *)modifiers
{
    SCKeyCombination *combination = [SCKeyCombination new];
    combination.type = NSKeyDown;
    combination.modifierFlags = modifiers;
    combination.keyCode = code;
    return combination;
}

+ (instancetype)clickWithModifiers:(NSNumber *)modifiers
{
    SCKeyCombination *combination = [SCKeyCombination new];
    combination.type = NSLeftMouseDown;
    combination.modifierFlags = modifiers;
    return combination;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"SCKeyCombination: %@, %@", self.keyCode, self.modifierFlags];
}

@end

# pragma mark - Constants

NSDictionary *modifierMap()
{
    static NSDictionary *result = nil;
    if (!result) {
        result = @{@"cmd": @(NSCommandKeyMask),
                   @"alt": @(NSAlternateKeyMask),
                   @"ctrl": @(NSControlKeyMask),
                   @"shift": @(NSShiftKeyMask)};
    }
    return result;
}

NSDictionary *keyCodeMap()
{
    static NSDictionary *result = nil;
    if (!result) {
        result = @{@"`": @50, @"-": @27, @"+": @24, @"delete": @51,
                   @"1": @18, @"2": @19, @"3": @20, @"4": @21, @"5": @23, @"6": @22, @"7": @26, @"8": @28, @"9": @25, @"0": @29,
                   @"q": @12, @"w": @13, @"e": @14, @"r": @15, @"t": @17, @"y": @16, @"u": @32, @"i": @34, @"o": @31, @"p": @35,
                   @"a": @0,  @"s": @1,  @"d": @2,  @"f": @3,  @"g": @5,  @"h": @4,  @"j": @38, @"k": @40, @"l": @37, @";": @41, 
                   @"z": @6,  @"x": @7,  @"c": @8,  @"v": @9,  @"b": @11, @"n": @45, @"m": @46, @",": @43, @".": @47, @"/": @44,
                   @"up": @126, @"down": @125, @"left": @123, @"right": @124,
                   @"space": @49, @"tab": @48, @"enter": @36,
                   @"backspace": @51
                   };
    }
    return result;
}

NSArray *letters()
{
    static NSMutableArray *result = nil;
    if (!result) {
        result = [NSMutableArray new];
        for (char c = 'a'; c <= 'z'; c++) {
            [result addObject:[NSString stringWithFormat:@"%c", c]];
        }
    }
    return result;
}

NSDictionary *specialChars() {
    static NSDictionary *result = nil;
    if (!result) {
        result = @{@"space": @" ",
                   @"enter": @"\n",
                   @"tab": @"\t"};
    }
    return result;
}

# pragma mark - SCKeyMap

@interface SCKeyMap ()
@property (nonatomic, strong) NSMutableDictionary *keyCommandsByCodeAndModifiers;
@property (nonatomic, strong) NSMutableDictionary *clickCommandsByModifiers;
@end

@implementation SCKeyMap

+ (instancetype)defaultMap
{
    SCKeyMap *map = [[self alloc] init];

    for (NSString *key in letters()) {
        [map addCommandDescription:@{ @"command": @"insertCharacter:", @"argument": key }
               forInputDescription:key];
        [map addCommandDescription:@{ @"command": @"insertCharacter:", @"argument": key.capitalizedString } 
               forInputDescription:[NSString stringWithFormat:@"shift+%@", key]];
    }

    for (NSString *key in specialChars()) {
        [map addCommandDescription:@{ @"command": @"insertCharacter:", @"argument": specialChars()[key] }
               forInputDescription:key];
    }
    
    [map addMappingsFromDictionary:@{
     @"up": @"moveUp",
     @"down": @"moveDown",
     @"left": @"moveLeft",
     @"right": @"moveRight",
     @"cmd+left": @"moveToBeginningOfLine",
     @"cmd+right": @"moveToEndOfLine",
     @"delete": @"deleteCharacterBackwards",
     
     @"ctrl+p": @"moveUp",
     @"ctrl+n": @"moveDown",
     @"ctrl+b": @"moveLeft",
     @"ctrl+f": @"moveRight",
     @"ctrl+a": @"moveToBeginningOfLine",
     @"ctrl+e": @"moveToEndOfLine",
     @"ctrl+d": @"deleteCharacterForwards",
     @"ctrl+h": @"deleteCharacterBackwards",

     @"click": @"setInsertionPointIndex:",
     @"alt+click": @"addInsertionPointAtIndex:"}];

    return map;
}

+ (instancetype)mapWithDictionary:(NSDictionary *)dictionary
{
    SCKeyMap *map = [self defaultMap];
    [map addMappingsFromDictionary:dictionary];
    return map;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.keyCommandsByCodeAndModifiers = [NSMutableDictionary new];
        self.clickCommandsByModifiers = [NSMutableDictionary new];
    }
    return self;
}

- (SCCommand *)commandForKeyCode:(NSUInteger)keyCode modifiers:(NSUInteger)modifiers
{
    return self.keyCommandsByCodeAndModifiers[@(keyCode)][@(modifiers & NSDeviceIndependentModifierFlagsMask)];
}

- (SCCommand *)commandForClickWithModifiers:(NSUInteger)modifiers
{
    return self.clickCommandsByModifiers[@(modifiers & NSDeviceIndependentModifierFlagsMask)];
}

# pragma mark - Private

- (void)addMappingsFromDictionary:(NSDictionary *)dictionary
{
    for (NSString *key in dictionary) {
        [self addCommandDescription:dictionary[key] forInputDescription:key];
    }
}

- (void)addCommandDescription:(id)commandDescription forInputDescription:(NSString *)keyDescription
{
    SCKeyCombination *combination = [self parseKeyDescription:keyDescription];
    SCCommand *command = [self parseCommandDescription:commandDescription];
    [self addCommand:command forInput:combination];
}

- (void)addCommand:(SCCommand *)command forInput:(SCKeyCombination *)keyCombination
{
    NSNumber *code = keyCombination.keyCode;
    NSNumber *modifiers = keyCombination.modifierFlags;

    switch (keyCombination.type) {
        case NSLeftMouseDown:
            self.clickCommandsByModifiers[modifiers] = command;
            break;
        case NSKeyDown:
            if (!self.keyCommandsByCodeAndModifiers[code]) {
                self.keyCommandsByCodeAndModifiers[code] = [NSMutableDictionary new];
            }
            self.keyCommandsByCodeAndModifiers[code][modifiers] = command;
            break;
    }
}

- (SCKeyCombination *)parseKeyDescription:(NSString *)description
{
    NSArray *parts = [description componentsSeparatedByString:@"+"];
    NSArray *modifierNames = [parts subarrayWithRange:NSMakeRange(0, parts.count - 1)];
    NSString *keyName = parts.lastObject;
    
    int modifierFlags = 0;
    for (NSString *modifierName in modifierNames) {
        NSNumber *modifierMask = modifierMap()[modifierName];
        if (modifierMask) modifierFlags |= modifierMask.integerValue;
    }

    if ([@[@"up", @"down", @"left", @"right"] containsObject:keyName]) {
        modifierFlags |= (NSNumericPadKeyMask | NSFunctionKeyMask);
    }
    
    if ([keyName isEqualToString:@"click"]) {
        return [SCKeyCombination clickWithModifiers:@(modifierFlags)];
    } else {
        return [SCKeyCombination combinationWithCode:keyCodeMap()[keyName]
                                           modifiers:@(modifierFlags)];
    }
}

- (SCCommand *)parseCommandDescription:(id)description
{
    if ([description isKindOfClass:[NSString class]]) {
        return [SCCommand commandWithMethodName:description argument:nil];
    } else {
        return [SCCommand commandWithMethodName:description[@"command"] 
                                       argument:description[@"argument"]];
    }
}

@end