CFLAGS=-Wall -fobjc-arc -framework Foundation -framework AppKit -framework ScriptingBridge -O3

all: iTunesHistory

install: iTunesHistory
	cp $< /usr/local/bin/
	cp github.chbrown.iTunesHistory.plist ~/Library/LaunchAgents/
	launchctl load ~/Library/LaunchAgents/github.chbrown.iTunesHistory.plist

clean:
	rm -f iTunesHistory

distclean:
	launchctl remove github.chbrown.iTunesHistory
	rm ~/Library/LaunchAgents/github.chbrown.iTunesHistory.plist
	rm /usr/local/bin/iTunesHistory
