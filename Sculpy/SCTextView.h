#import <Cocoa/Cocoa.h>

@class SCBuffer, SCKeyMap;

@interface SCTextView : NSView

@property (nonatomic, strong) SCBuffer *buffer;
@property (nonatomic, strong) SCKeyMap *keyMap;
@property (nonatomic, strong) NSTextContainer *textContainer;

- (id)initWithFrame:(NSRect)frame;
- (id)initWithFrame:(NSRect)frame textContainer:(NSTextContainer *)textContainer;

@end
