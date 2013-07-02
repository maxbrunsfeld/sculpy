#import "SCKeyMap.h"
#import "SCCommand.h"
#import "SCBuffer.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(SCKeyMapSpec)

describe(@"SCKeyMap", ^{
    __block SCKeyMap *manager;

    beforeEach(^{
        manager = [SCKeyMap defaultMap];
    });
    
    describe(@"actions for printable characters", ^{
        it(@"inserts the characters by default", ^{
            SCCommand *command = [manager commandForKeyCode:0 modifiers:0];
            command should equal([SCCommand commandWithSelector:@selector(insertCharacter:) argument:@"a"]);
        });
        
        it(@"works with capital letters", ^{
            SCCommand *command = [manager commandForKeyCode:0 modifiers:NSShiftKeyMask];
            command should equal([SCCommand commandWithSelector:@selector(insertCharacter:) argument:@"A"]);
        });
        
        it(@"ignores hardware-dependent fields in the modifier flags bitmask", ^{
            NSUInteger noModifiers = (260 | 4);
            SCCommand *command = [manager commandForKeyCode:0 modifiers:noModifiers];
            command should equal([SCCommand commandWithSelector:@selector(insertCharacter:) argument:@"a"]);
        });
    });
});

SPEC_END
