iTunesHistory: iTunesHistory.swift
	xcrun -sdk macosx swiftc $< -O -o $@

install: iTunesHistory
	cp $< /usr/local/bin/
	cp github.chbrown.iTunesHistory.plist ~/Library/LaunchAgents/
	launchctl load ~/Library/LaunchAgents/github.chbrown.iTunesHistory.plist

test:
	swiftformat --lint *.swift
	swiftlint lint *.swift

clean:
	rm -f iTunesHistory

distclean:
	launchctl remove github.chbrown.iTunesHistory
	rm ~/Library/LaunchAgents/github.chbrown.iTunesHistory.plist
	rm /usr/local/bin/iTunesHistory
