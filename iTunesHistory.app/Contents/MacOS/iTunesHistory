#!/usr/bin/env python
import os
import subprocess
import re
import time
from ScriptingBridge import SBApplication
iTunes = SBApplication.applicationWithBundleIdentifier_("com.apple.iTunes")

# first, install if needed:
app_path = re.search('^.+iTunesHistory.app', os.path.abspath(__file__)).group(0)
login_items = subprocess.check_output(['osascript', '-e', 'tell application "System Events" to get the name of every login item'])
if 'iTunesHistory' not in login_items:
    # command from http://hints.macworld.com/article.php?story=20111226075701552
    command = """osascript -e 'tell application "System Events" to make login item at end with properties {path:"%s", hidden:false}'""" % app_path
    install_result = subprocess.check_output(command, shell=True)
    print install_result


# format:
# TIMESTAMP, COMPLETE (Y/N), ELAPSED, ARTIST, ALBUM, TRACK
# COMPLETE is Y iff ELAPSED > 50% of the song's duration

class PlayState(object):
    def __init__(self, track, position):
        self.artist = track.artist()
        self.album = track.album()
        self.track = track.name()
        self.duration = track.duration()

        self.position = position

    def __eq__(self, other):
        return self and other and \
            self.artist == other.artist and self.album == other.album and self.track == other.track

    def __ne__(self, other):
        return not self == other

def update(fp, last_state, new_state):
    if last_state and last_state != new_state:
        # track changed
        cols = [int(time.time()),
            'Y' if last_state.position > (last_state.duration / 2.0) else 'N', last_state.position,
            last_state.artist, last_state.album, last_state.track]

        line = u'\t'.join(map(unicode, cols))
        fp.write('%s\n' % line.encode('utf-8'))
        fp.flush()
    return new_state

last_state = None
new_state = None
log_path = os.path.join(os.environ['HOME'], '.iTunes_history')
with open(log_path, 'a') as fp:
    while True:
        if iTunes.isRunning():
            new_state = PlayState(iTunes.currentTrack(), iTunes.playerPosition())
        else:
            new_state = None

        last_state = update(fp, last_state, new_state)

        time.sleep(5)
