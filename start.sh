#!/bin/bash

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

