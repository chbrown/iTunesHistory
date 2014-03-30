#import <ScriptingBridge/ScriptingBridge.h>
#import "iTunes.h"


@interface PlayState : NSObject

- (id)initWithTrack:(iTunesTrack *)track_ andPosition:(double)position_;
- (BOOL)isEqualToPlayState:(PlayState *)otherState;

@property(strong) iTunesTrack *track;
@property double position;
// @property(strong) NSString *artist;
// @property(strong) NSString *album;
// @property(strong) NSString *track;
// @property double duration;

@end


@interface HistoryUpdater : NSObject

- (id)initWithiTunes:(iTunesApplication *)iTunes_ andFilepath:(NSString *)filepath_;
- (void)poll:(NSTimer *)timer;

@property(strong) iTunesApplication *iTunes;
@property(strong) NSString *filepath;
@property(strong) NSFileHandle *file;
@property(strong) PlayState *previousState;

@end
