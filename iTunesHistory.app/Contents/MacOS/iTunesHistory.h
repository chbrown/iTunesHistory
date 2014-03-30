#import <ScriptingBridge/ScriptingBridge.h>
#import "iTunes.h"


@interface TrackState : NSObject

- (id)initFromTrack:(iTunesTrack *)track_ andPosition:(double)position_;
- (BOOL)equalTo:(TrackState *)other;

// we have to store the artist, album, track as native values
// because when iTunes closes it unref's all of them and we're left with a bunch of nils
@property(strong) NSString *artist;
@property(strong) NSString *album;
@property(strong) NSString *name;
@property double duration;
@property double position;

@end


@interface HistoryUpdater : NSObject

- (id)initWithiTunes:(iTunesApplication *)iTunes_ andFilepath:(NSString *)filepath_;
- (void)poll:(NSTimer *)timer;
- (void)write:(NSString *)line;

@property(strong) iTunesApplication *iTunes;
@property(strong) NSFileHandle *file;
@property(strong) TrackState *previousTrackState;

@end
