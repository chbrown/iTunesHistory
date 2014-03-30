#import <Foundation/Foundation.h>
// #import <ApplicationServices/ApplicationServices.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import "iTunes.h"
#import "iTunesHistory.h"

// Compile like:
// clang iTunesHistory.m -o iTunesHistory -Wall -fobjc-arc -framework Foundation -framework AppKit
// call like: iTunesHistory -file ~/.iTunes_history

@implementation PlayState

@synthesize track;
@synthesize position;

- (id)initWithTrack:(iTunesTrack *)track_ andPosition:(double)position_ {
  self = [super init];
  if (self) {
    track = track_;
    position = position_;
  }
  return self;
}

- (BOOL)isEqualToPlayState:(PlayState *)otherState {
  return [track.artist isEqualToString:otherState.track.artist] &&
    [track.album isEqualToString:otherState.track.album] &&
    [track.name isEqualToString:otherState.track.name];
}

- (NSString *)description {
  return [NSString stringWithFormat:@"PlayState: artist=%@, album=%@, name=%@, position=%f",
    track.artist, track.album, track.name, position];
}

@end


@implementation HistoryUpdater

@synthesize iTunes;
@synthesize filepath;
@synthesize file;
@synthesize previousState;

- (id)initWithiTunes:(iTunesApplication *)iTunes_ andFilepath:(NSString *)filepath_ {
  self = [super init];
  if (self) {
    iTunes = iTunes_;
    // expand `~` into $USER if necessary
    filepath = [filepath_ stringByExpandingTildeInPath];
    // I have to create a file before I can write to it--- awesome!
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filepath]) {
      // create it if it doesn't exist
      bool create_success = [fileManager createFileAtPath:filepath contents:nil attributes:nil];
      if (!create_success) {
        NSLog(@"Could not create file: %@", filepath);
      }
    }
    // okay, now I can open it
    file = [NSFileHandle fileHandleForWritingAtPath:filepath];
    // but I can't open it in "append" mode so I have to seek to the end manually
    [file seekToEndOfFile];
    // NSLog(@"Opened file: %@ -> %@", filepath, file);
    previousState = [[PlayState alloc] initWithTrack:nil andPosition:0.0];
  }
  return self;
}

- (void)poll:(NSTimer *)timer {
  if (iTunes.isRunning) {
    // [iTunesTrack get] returns a copy, rather than whatever the current track is.
    iTunesTrack *currentTrack = [iTunes.currentTrack get];
    PlayState *newState = [[PlayState alloc] initWithTrack:currentTrack andPosition:iTunes.playerPosition];
    NSLog(@"iTunes is running: %d, %d, %@", previousState.track != nil, newState.track != nil, currentTrack);
    if (previousState.track != nil && newState.track != nil && ![previousState isEqualToPlayState:newState]) {
      NSTimeInterval epoch = [[NSDate date] timeIntervalSince1970];

      NSString *complete = previousState.position > (previousState.track.duration / 2.0) ? @"Y" : @"N";

      // format:
      // TIMESTAMP, COMPLETE (Y/N), ELAPSED, ARTIST, ALBUM, TRACK
      // values:
      // * COMPLETE is Y iff ELAPSED > 50% of the song's duration
      NSString *historyLine = [NSString stringWithFormat:@"%d\t%@\t%f\t%@\t%@\t%@\n", (int)epoch, complete,
        previousState.position, previousState.track.artist, previousState.track.album, previousState.track.name];
      NSLog(@"> %@", historyLine);
      [file writeData:[historyLine dataUsingEncoding:NSUTF8StringEncoding]];
    }
    else {
      // NSLog(@"previousState == newState");
    }
    previousState = newState;
  }
  else {
    NSLog(@"iTunes is not running");
  }
}

@end


int main(int argc, const char *argv[]) {
  @autoreleasepool {
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    NSUserDefaults *args = [NSUserDefaults standardUserDefaults];
    NSString *history_filepath = [args stringForKey:@"file"];
    if (!history_filepath) {
      // XXX: DEBUG: @"~/objc.iTunes_history" should be @"~/.iTunes_history"
      history_filepath = @"~/objc.iTunes_history";
    }
    NSLog(@"Writing history to file: %@", history_filepath);
    HistoryUpdater *updater = [[HistoryUpdater alloc] initWithiTunes:iTunes andFilepath:history_filepath];

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
