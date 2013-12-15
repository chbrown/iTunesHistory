CFLAGS=-Wall -fobjc-arc -framework Foundation -framework AppKit -framework ScriptingBridge

all: iTunesHistory.app/Contents/MacOS/iTunesHistory

clean:
	rm -f iTunesHistory
