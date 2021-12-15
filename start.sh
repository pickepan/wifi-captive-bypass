#!/bin/bash

find_wifi (){
	echo "Scanning wifi networks..."
	WIFI_WORKING=("_SNCF gare-gratuit" "_SNCF_WIFI_INOUI")
	len_WIFI_WORKING="${#WIFI_WORKING[@]}"
	wifi_network=$(nmcli -t --fields ssid dev wifi | sort | uniq | grep -v '^[[:space:]]*$' > a)

	state=false #target hotspot found

	while read line; do 
		for (( i = 0; i < $len_WIFI_WORKING; i++ )); do
			if [[ $line == "${WIFI_WORKING[i]}" ]]; then
				state=true
				echo "Hotspot" $line "has been detected";
				break
			fi
		done
		if [[ $state  ]]; then
			break
		fi
	done < a

	rm a
	if [[ !$state ]]; then
		echo "No target hotspot found"
		exit 12
	fi
};

find_wifi
exit 0

python3 main.py

return_code=$?


if [[ $return_code -eq 28 ]]; then
	echo "Turning off NetworkManager"
	service NetworkManager stop

	sleep 2

	echo "Killing wpa_supplicant remaining sessions"
	wpa_pid=$(pgrep wpa_supplicant | tail -n 1)
	kill -9 $wpa_pid 2>/dev/null
	wpa_pid=$(pgrep wpa_supplicant | tail -n 1)
	kill -9 $wpa_pid 2>/dev/null

	sudo ifconfig wlan0 down
	sudo macchanger -r wlan0 > /dev/null 2>&1
	sudo ifconfig wlan0 up

	echo "Connection to Wifi hotspot..."
	wpa_supplicant -iwlan0 -cwpa.conf > /dev/null 2>&1 &

	echo "Getting an IP address"
	sudo dhclient wlan0

	python3 main.py
elif [[ $return_code -eq 1 ]]; then
	echo "You are not connected to an open network, connecting"
	echo "Turning off NetworkManager"
	service NetworkManager stop

	sleep 2

	echo "Killing wpa_supplicant remaining sessions"
	wpa_pid=$(pgrep wpa_supplicant | tail -n 1)
	kill -9 $wpa_pid 2>/dev/null
	wpa_pid=$(pgrep wpa_supplicant | tail -n 1)
	kill -9 $wpa_pid 2>/dev/null

	sudo ifconfig wlan0 down
	sudo macchanger -r wlan0 2>/dev/null
	sudo ifconfig wlan0 up

	echo "Connection to Wifi hotspot..."
	wpa_supplicant -iwlan0 -cwpa.conf 2>/dev/null &

	echo "Getting an IP address"
	sudo dhclient wlan0

	python3 main.py

else
	:
fi

