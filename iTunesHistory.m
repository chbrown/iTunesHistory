#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import "iTunes.h"
#import "iTunesHistory.h"

// Compile like:
// clang iTunesHistory.m -o iTunesHistory -Wall -fobjc-arc -framework Foundation -framework AppKit
// call like: iTunesHistory -file ~/.iTunes_history

@implementation TrackState

@synthesize artist;
@synthesize album;
@synthesize name;
@synthesize duration;
@synthesize position;

- (id)initFromTrack:(iTunesTrack *)track_ andPosition:(double)position_ {
  self = [super init];
  if (self) {
    artist = track_.artist;
    album = track_.album;
    name = track_.name;
    duration = track_.duration;
    position = position_;
  }
  return self;
}

- (BOOL)equalTo:(TrackState *)other {
  // returns TRUE if both tracks are nil, or if both tracks have identical artists, albums, and names
  // nil == nil is TRUE, right?
  return self == other || (
    [self.artist isEqualToString:other.artist] &&
    [self.album isEqualToString:other.album] &&
    [self.name isEqualToString:other.name]
  );
}

@end


@implementation HistoryUpdater

@synthesize iTunes;
@synthesize file;
@synthesize previousTrackState;

- (id)initWithApplication:(iTunesApplication *)iTunes_ andFilepath:(NSString *)filepath {
  self = [super init];
  if (self) {
    iTunes = iTunes_;
    // I have to create a file before I can open it--- awesome!
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filepath]) {
      // create it if it doesn't exist
      bool create_success = [fileManager createFileAtPath:filepath contents:nil attributes:nil];
      if (create_success) {
        NSLog(@"Created file: %@", filepath);
      }
      else {
        NSLog(@"Could not create file: %@", filepath);
      }
    }
    // okay, now I can open it
    file = [NSFileHandle fileHandleForWritingAtPath:filepath];
    // but I can't open it in "append" mode so I have to seek to the end manually
    [file seekToEndOfFile];
    previousTrackState = nil;
  }
  return self;
}

- (void)poll:(NSTimer *)timer {
  TrackState *currentTrackState = nil;
  if (iTunes.isRunning && iTunes.currentTrack && iTunes.currentTrack.name) {
    // [iTunesTrack get] returns a copy, rather than whatever the current track is.
    currentTrackState = [[TrackState alloc] initFromTrack:iTunes.currentTrack andPosition:iTunes.playerPosition];
  }

  if (previousTrackState) {
    // just ignore cases where the previousTrackState was nil
    if (![previousTrackState equalTo:currentTrackState]) {
      // format:
      // TIMESTAMP, COMPLETE (Y/N), ELAPSED, ARTIST, ALBUM, TRACK
      // values:
      // * COMPLETE is Y iff ELAPSED > 50% of the song's duration
      NSTimeInterval epoch = [[NSDate date] timeIntervalSince1970];
      NSString *complete = previousTrackState.position > (previousTrackState.duration / 2.0) ? @"Y" : @"N";
      NSString *historyLine = [NSString stringWithFormat:@"%d\t%@\t%.3f\t%@\t%@\t%@\n",
        (int)epoch, complete, previousTrackState.position, previousTrackState.artist, previousTrackState.album, previousTrackState.name];
      [self write:historyLine];
    }
  }

  // how to release the previousTrackState before overwriting it?
  previousTrackState = currentTrackState;
}

- (void)write:(NSString *)line {
  NSLog(@"> %@", line);
  [file writeData:[line dataUsingEncoding:NSUTF8StringEncoding]];
}

@end


int main(int argc, const char *argv[]) {
  @autoreleasepool {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    NSString *history_file = [args stringForKey:@"file"];
    if (!history_file) {
      history_file = @"~/.iTunes_history";
    }
    // expand `~` into $USER if necessary
    NSString *history_filepath = [history_file stringByExpandingTildeInPath];
    NSLog(@"Writing history to file: %@", history_filepath);
    HistoryUpdater *updater = [[HistoryUpdater alloc] initWithApplication:iTunes andFilepath:history_filepath];

    // start
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2.0
      target:updater selector:@selector(poll:)
      userInfo:nil repeats:YES];

    // loop and wait
    NSRunLoop *runLoop = [NSRunLoop mainRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
    [runLoop run];
  }

  return 0;
}
