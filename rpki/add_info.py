import sys
import time

import json
import requests
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


def read_json(path_to_json):
    with open(path_to_json, "r", encoding="utf-8") as json_file:
        return json.loads(json_file.read())


def send(url, data, headers):
    while True:
        try:
            response = requests.post(url=url, json=data,
                                     verify=False, headers=headers, timeout=1)
            if response.status_code == 200:
                print("finished")
                return
            if response.status_code == 400:
                # 400 usually is roa rejected due to already existing
                print(response.json())
                print("finished")
                return
            print(response.status_code)
            print()
        except Exception as err:
            print(err)
            print(time.time())
            time.sleep(3)


def add_info(input_file):
    file_json = read_json(input_file)
    headers = {
        'Authorization': 'Bearer ' + file_json.get("token"),
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
    data = {"added": [], "removed": []}
    url = f"https://{file_json.get('ip')}:{file_json.get('port')}/api/v1/cas/testbed/"
    if "roas" in input_file:
        url += "routes"
        print(url)
        data["added"] = file_json.get("add")
        send(url, data, headers)
    elif "aspas" in input_file:
        url += "aspas"
        data = {"add_or_replace": file_json.get("add"), "remove": []}
        send(url, data, headers)
    else:
        print(f"unkown file: {input_file}")


if __name__ == '__main__':
    add_info(sys.argv[1])
    add_info(sys.argv[2])
