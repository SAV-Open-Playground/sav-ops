#!/usr/bin/python3
# -*-coding:utf-8 -*-
"""
@File    :   sav_controll_common.py
@Time    :   2023/11/30
@Version :   0.1
@Desc    :   The sav_controll_common.py contains some common functions.
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
    out = subprocess.run(
        cmd, shell=True, capture_output=True, encoding='utf-8')
    return out


def whoami():
    """
    we use ip as the id of the node
    """
    result = subprocess_cmd("ifconfig")
    # print(result)
    results = result.stdout.split("\n")
    for i in results:
        if "10.10.254." in i:
            i = i.strip().split(" ")
            return i[1].split('.')[-1]


def run_cmd(cmd):
    """print output if returncode != 0"""
    ret = subprocess_cmd(cmd)
    if ret.returncode != 0:
        print(ret)
    return ret.stdout


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
