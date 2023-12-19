#!/usr/bin/python3
# -*-coding:utf-8 -*-
"""
@File    :   sav_control_common.py
@Time    :   2023/11/30
@Version :   0.1
@Desc    :   The sav_control_common.py contains some common functions.
"""
import json
import subprocess


def json_r(path, encoding='utf-8'):
    with open(path, 'r', encoding=encoding) as f:
        return json.load(f)


def json_w(path, data, encoding='utf-8', mode='w'):
    with open(path, mode, encoding=encoding) as f:
        return json.dump(data, f, indent=2, sort_keys=True)


def subprocess_cmd(cmd):
    out = subprocess.run(cmd, shell=True, capture_output=True, encoding='utf-8')
    return out


def whoami():
    """
    we use ip as the id of the node
    """
    result = subprocess_cmd("ip -j -4 address")
    # print(result)
    results = json.loads(result.stdout)
    for i in results:
        if i["ifname"] in ["lo", "docker0"]:
            continue
        return i["addr_info"][-1]["local"]


def run_cmd(cmd,expected_returncode=0):
    """print output if returncode != 0"""
    ret = subprocess_cmd(cmd)
    if ret.returncode != expected_returncode:
        print(ret)
    return ret.returncode, ret.stdout, ret.stderr


def remove_bird_links(bird_cfg, nodes):
    """remove unused links in bird config"""
    temp = []
    for i in range(len(bird_cfg)):
        line = bird_cfg[i]
        if "savbgp" in line:
            # this is a bgo title
            asns = line.split(" ")[2].split("_")[1:]
            asns = list(map(int, asns))
            if (not asns[0] in nodes) or (not asns[1] in nodes):
                temp += bird_cfg[i+9:]
                return temp, True
        temp.append(line)
    return temp, False


def ensure_no_trailing_slash(path):
    if path.endswith('/'):
        path = path.rstrip('/')
    return path
