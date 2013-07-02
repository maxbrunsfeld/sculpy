#import "SCAppDelegate.h"
#import "SCTextView.h"
#import "SCBuffer.h"
#import "SCKeyMap.h"

@implementation SCAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    SCKeyMap *keyMap = [SCKeyMap mapWithDictionary:@{
                        @"ctrl+x": @{ @"command": @"insertStringAtAllInsertionPoints:", @"argument": @"ok" }
                        }];
    self.textView.keyMap = keyMap;
    NSAttributedString *s = [[NSAttributedString alloc]
                             initWithString:@"one two three\nfour five six\nseven eight nine"];
    [self.textView.buffer.textStorage insertAttributedString:s atIndex:0];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.window makeFirstResponder:self.textView];
}

@end
