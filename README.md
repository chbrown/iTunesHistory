# iTunesHistory

Last.fm is an awesome service but their desktop client sucks *so much* that
I can't use it anymore. I need F6, for example. How else am I going to use
the search next function in `htop`?

Mac python is weird sometimes. For best results, edit the following file:

    sudo vim /System/Library/Frameworks/Python.framework/Versions/2.7/Resources/Python.app/Contents/Info.plist

By adding the key-val pair:

    <key>LSUIElement</key>
    <string>1</string>

Which prevents that app from ever having a dock icon.
Who wants to know that python is running? I know I don't.

## Output

Tab separated output is put in: `~/.iTunes_history`

## Usage

Running the app will install it into your login items if it is not already
installed there. If you run it, you always run it.

To uninstall, go to System Preferences -> Users & Groups -> Login Items
  -> select "iTunesHistory" and click "-".

## License

MIT Licensed, 2012
