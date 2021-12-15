import requests
import json
import subprocess
import time
import sys

SLEEPING_TIME = 40
WAITING_TIME_INTERFACES = 5

def check_network():
  bashCmd = ["iwgetid", "-r"]
  process = subprocess.Popen(bashCmd, stdout=subprocess.PIPE)
  output, error = process.communicate()
  if output.decode("utf-8") != "_SNCF_WIFI_INOUI\n":
    return 1
  return 0


def change_mac():
  bashCmd = ["ifconfig", "wlan0", "down"]
  process = subprocess.Popen(bashCmd, stdout=subprocess.PIPE)
  output, error = process.communicate()
  print(output.decode("utf-8"))
  time.sleep(WAITING_TIME_INTERFACES)


  bashCmd = ["macchanger", "-r", "wlan0"]
  process = subprocess.Popen(bashCmd, stdout=subprocess.PIPE)
  output, error = process.communicate()
  print(output.decode("utf-8"))
  time.sleep(WAITING_TIME_INTERFACES)



  ashCmd = ["ifconfig", "wlan0", "up"]
  process = subprocess.Popen(bashCmd, stdout=subprocess.PIPE)
  output, error = process.communicate()
  time.sleep(WAITING_TIME_INTERFACES)
  print(output.decode("utf-8"))

  print("Waiting " + str(SLEEPING_TIME) + " seconds for reconnection to hotspot.")
  print("Make sure reconnection is enabled")
  time.sleep(SLEEPING_TIME)

  return_code = check_network()
  if return_code == 1:
    print("Reconnection failed... Please reconnect manually to the target network")
    exit(1)




def connection_status():
  jason_object = ""
  try:
    url = "https://wifi.sncf/router/api/connection/status"

    payload={}
    headers = {
      'Cookie': 'x-iob-grant-id=82%3A6d%3Adb%3A6a%3Acf%3A27; x-vsc-correlation-id=eb07c296-1b02-4742-82cf-17bac998dcc4'
    }

    response = requests.request("GET", url, headers=headers, data=payload)

    jason = response.text

    jason_object = json.loads(jason)

    remaining_data = jason_object["remaining_data"]
    consumed_data = jason_object["consumed_data"]
    total_granted = remaining_data + consumed_data
    lasting_percentage = (remaining_data / total_granted) * 100

    print("Internet connection remaining: " + str(lasting_percentage).split(".")[0] +  "%")

    if lasting_percentage > 80:
      exit(2)
    exit(28)


  except KeyError:
    try:
      status_code = jason_object["status_code"]
      if status_code != 404: #if 404, it s fine, else exit
        exit(10)
      else:
        print("Connecting to the network...")
    except KeyError:
      exit(10)



def connect():
  url = "https://wifi.sncf/router/api/connection/activate/auto"

  payload = json.dumps({
    "without21NetConnection": False
  })
  headers = {
    'Accept': 'application/json',
    'Accept-Language': 'en-US,en;q=0.9,fr-FR;q=0.8,fr;q=0.7,es-ES;q=0.6,es;q=0.5,he-IL;q=0.4,he;q=0.3',
    'Content-Length': '32',
    'Host': 'wifi.sncf',
    'Origin': 'https://wifi.sncf',
    'Referer': 'https://wifi.sncf/en/internet/bot',
    'sec-ch-ua': '" Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-plateform': '"Linux"',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-origin',
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.93 Safari/537.36',
    'Content-Type': 'application/json',
    'Cookie': 'x-iob-grant-id=82%3A6d%3Adb%3A6a%3Acf%3A27; x-vsc-correlation-id=eb07c296-1b02-4742-82cf-17bac998dcc4'
  }


  response = requests.request("POST", url, headers=headers, data=payload)
  jason = response.text

  jason_object = json.loads(jason)

  status = jason_object["travel"]["status"]["active"]
  if status == True:
    print("Connection succesfully established")
  else:
    print("An unexpected error happened during connection")


if __name__ == '__main__':
  print(sys.argv)
  if sys.argv[1] == '_SNCF_WIFI_INOUI':
    return_code = check_network()
    if return_code == 1:
      exit(1)
    connection_status()
    connect()