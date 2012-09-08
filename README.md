# iTunesHistory

Last.fm is an awesome service but their desktop client sucks *so much* that
I can't use it anymore. I need F6, for example. How else am I going to use
the search next in `htop`?

## Output

Tab separated output is put in: `~/.iTunes_history`

## Usage

Running the app will install it into your login items if it is not already
installed there. If you run it, you always run it.

To uninstall, go to System Preferences -> Users & Groups -> Login Items
  -> select "LessWatch" and click "-".

## License

MIT Licensed, 2012

## Code snippet that I am going to delete after I commit it.

# t = iTunes.currentTrack()
# keys = dir(t)
# for key in keys:
#     val = 'Not calling'
#     if key not in ['allowsWeakReference', 'dealloc', 'delete', 'finalize', 'retainWeakReference']:
#         try:
#             val = getattr(t, key)()
#         except Exception:
#             val = 'Failed'
#     print '%60s %s' % (key, val)
#     # print '  ', val
