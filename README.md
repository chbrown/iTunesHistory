# iTunesHistory

Last.fm is an awesome service but their desktop client sucks *so much* that
I can't use it anymore. I need F6, for example. How else am I going to use
the search next function in `htop`?


## Installation

Running `make -B` will re-build the main binary, `iTunesHistory`. The committed binary was built on Mac OS X Mavericks (10.9.5).

Running `make install` will:

1. Re-build `iTunesHistory` if needed
2. Copy `iTunesHistory` to `/usr/local/bin/iTunesHistory`
3. Copy the local `github.chbrown.iTunesHistory.plist` file to `~/Library/LaunchAgents/`
4. Call `launchctl` to load `github.chbrown.iTunesHistory.plist` via `launchd`

Running `make distclean` will:

1. Stop the `launchd` job named `github.chbrown.iTunesHistory`
2. Remove `/usr/local/bin/iTunesHistory`
3. Remove `~/Library/LaunchAgents/github.chbrown.iTunesHistory.plist`


## Output

Tab separated output is put in: `~/.iTunes_history`. There is no header, but the columns are:

1. Integer seconds since the unix epoch when track ended
2. `Y` / `N` if the song was played past the halfway point
3. Floating-point seconds into the song when the track ended
4. Artist name
5. Album name
6. Track name


## License

Copyright (c) 2012–2020 Christopher Brown.
[MIT Licensed](https://chbrown.github.io/licenses/MIT/#2012-2020).
