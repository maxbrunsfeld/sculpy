#import "SCTextView.h"
#import "SCInsertionPoint.h"
#import "SCKeyMap.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SCTextViewSpec)

describe(@"SCTextView", ^{
    __block SCTextView *view;

    beforeEach(^{
        NSRect frame = NSMakeRect(0, 0, 200, 100);
        view = [[SCTextView alloc] initWithFrame:frame];
    });
    
    describe(@"events", ^{
        describe(@"typing a key", ^{
            it(@"notifies the delegate", ^{
                [view keyDown:[NSEvent keyEventWithType:NSKeyDown
                                               location:NSMakePoint(0, 0)
                                          modifierFlags:5
                                              timestamp:0
                                           windowNumber:0
                                                context:view.window.graphicsContext
                                             characters:@"a"
                            charactersIgnoringModifiers:@"a"
                                              isARepeat:NO
                                                keyCode:5]];
            });
        });
        
        describe(@"clicking the mouse", ^{
            it(@"notifies the delegate", ^{
                [view mouseDown:[NSEvent mouseEventWithType:NSLeftMouseDown
                                                   location:NSMakePoint(0, 0)
                                              modifierFlags:0
                                                  timestamp:0
                                               windowNumber:0
                                                    context:view.window.graphicsContext
                                                eventNumber:1 
                                                 clickCount:1
                                                   pressure:1.0]];
            });
        });
    });
});

SPEC_END
