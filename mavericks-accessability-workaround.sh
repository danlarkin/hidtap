TCC_DB="/Library/Application Support/com.apple.TCC/TCC.db"

sudo sqlite3 "$TCC_DB" 'insert or ignore into access values("kTCCServiceAccessibility", "/usr/local/bin/hidtap", 1, 1, 0, null)'
sudo sqlite3 "$TCC_DB" 'select * from access'
