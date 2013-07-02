#import <Cocoa/Cocoa.h>

@class SCTextView;

@interface SCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet SCTextView *textView;

@end
