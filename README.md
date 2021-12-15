# wifi-captive-bypass

## How it works

It automatically connect to SNCF public hotspots. At the present time, only working for `_SNCF_WIFI_INOUI` hotspot.<br>
The algorithm has been done thanks to scrapping techniques.

## Usage
`./start.sh`

## Caution
It disable `NetworkManager` service and change your interface settings.
After stopping the script use [clean.sh](./clean.sh])