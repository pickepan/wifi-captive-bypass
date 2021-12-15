wpa_pid=$(pgrep wpa_supplicant | tail -n 1)
kill -9 $wpa_pid 2>/dev/null
wpa_pid=$(pgrep wpa_supplicant | tail -n 1)
kill -9 $wpa_pid 2>/dev/null
service NetworkManager start
ifconfig wlan0 default