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
import logging
import os
import time
from logging.handlers import RotatingFileHandler
import sys
SAV_OP_DIR = os.path.dirname(os.path.abspath(__file__))
SAV_ROOT_DIR = os.path.dirname(SAV_OP_DIR)
SAV_AGENT_DIR = os.path.join(SAV_ROOT_DIR, "sav_agent")
SAV_OP_DIR = os.path.dirname(os.path.abspath(__file__))
sys.path.append(SAV_AGENT_DIR)
from common import *
#print(sys.path)
#print(TIMEIT_THRESHOLD)
SAV_ROUTER_DIR = os.path.join(SAV_ROOT_DIR, "sav_router")
OUT_DIR = os.path.join(SAV_OP_DIR, "this_config")
SAV_REF_IMG_TAG = "savop_bird_base"
DEVICE_COMPOSE_FILE = "devices.yml"
CA_COMPOSE_FILE = "ca.yml"
CA_IP4 = "10.10.0.2"
CA_HTTP_PORT = 3000
RUN_DIR = "savop_run"

RPDP_ID = "rpdp"
def json_r(path, encoding='utf-8'):
    with open(path, 'r', encoding=encoding) as f:
        return json.load(f)


def json_w(path, data, encoding='utf-8', mode='w'):
    with open(path, mode, encoding=encoding) as f:
        return json.dump(data, f, indent=2, sort_keys=True)


def subprocess_cmd(cmd, timeout, capture_output=False):
    out = subprocess.run(cmd, shell=True, capture_output=capture_output, encoding='utf-8', timeout=timeout)
    return out


def whoami():
    """
    we use ip as the id of the node
    """
    result = subprocess_cmd("ip -j -4 address", 30, capture_output=True)
    # print(result)
    results = json.loads(result.stdout)
    for i in results:
        if i["ifname"] in ["lo", "docker0"]:
            continue
        return i["addr_info"][-1]["local"]


def run_cmd(cmd, expected_return_code=0, capture_output=False, timeout=None):
    """print output if return code is not expected
    return returncode, stdout, stderr"""
    ret = subprocess_cmd(cmd, timeout, capture_output=capture_output)
    if ret.returncode != expected_return_code and capture_output is False:
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
                temp += bird_cfg[i + 9:]
                return temp, True
        temp.append(line)
    return temp, False


def ensure_no_trailing_slash(path):
    if path.endswith('/'):
        path = path.rstrip('/')
    return path


def get_logger(_id_="", level=logging.INFO):
    """
    get logger function for all modules
    """
    maxsize = 1024*1024*500
    backup_num = 5
    level = logging.WARN
    level = logging.DEBUG
    logger = logging.getLogger(__name__)
    logger.setLevel(level)
    path = os.path.dirname(os.path.abspath(__file__))+f"/{_id_}_{__name__}.log"
    with open(path, "w") as f:
        pass
    handler = RotatingFileHandler(
        path, maxBytes=maxsize, backupCount=backup_num)
    handler.setLevel(level)
    formatter = logging.Formatter(
        "[%(asctime)s] [%(filename)s:%(lineno)s-%(funcName)s] [%(levelname)s] %(message)s")
    formatter.converter = time.gmtime
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logging.StreamHandler(stream=None)
    # sh = logging.StreamHandler(stream=sys.stdout)
    # sh.setFormatter(formatter)
    # logger.addHandler(sh)
    return logger


def extract_mem_and_cpu_stats_from_dstat(data_content_list):
    cvs_content = ""
    data_content_list = data_content_list.split("\n")
    data_content_list
    title_list = [i.replace("-", '').replace("usage", "").replace("total", "")
                  for i in data_content_list[0].split(" ")][0:2]
    child_title = [i.strip() for i in data_content_list[1].split("|")][0:2]

    column_list = []
    for index in range(0, len(title_list)):
        child_title_list = [
            i for i in child_title[index].split(" ") if len(i) != 0]
        for k in child_title_list:
            column_list.append(f"{title_list[index]}_{k}")
    for column in column_list:
        cvs_content += column + ","
    cvs_content = cvs_content[:-1] + "\n"

    for data in data_content_list[2:]:
        data_list = [i.strip() for i in data.split("|")][0:2]
        for index in range(0, len(data_list)):
            child_data_list = [i for i in data_list[index].split(" ") if len(i) != 0]
            if index == 0:
                mem_list = []
                for value in child_data_list:
                    if value[-1] == "G":
                        try:
                            value = str(int(float(value[:-1]) * 1024)) + "M"
                            mem_list.append(value)
                        except Exception as e:
                            mem_list.append("NaN")
                    else:
                        mem_list.append(value)
                for value in mem_list:
                    cvs_content += value + ","
            if index == 1:
                cpu_list = []
                for value in child_data_list:
                    cpu_list.append(value)
                for value in cpu_list:
                    cvs_content += value + ","
                cvs_content = cvs_content[:-1] + "\n"
    return cvs_content


def get_container_node_num(root_dir, capture_output=True):
    cmd = f'grep "container_name" {root_dir}/{DEVICE_COMPOSE_FILE} |wc -l'
    returncode, stdout, stderr = run_cmd(cmd, capture_output=capture_output)
    if returncode != 0:
        raise Exception(f"get_container_node_num failed, {stderr}")
    return int(stdout)

def sys_init():
    """
    ensure the system is ready to run the emulation
    """
    cmd = "sysctl -w "
    # remove rp_filter
    cmds = ["net.ipv4.conf.all.rp_filter=0",
            "net.ipv4.conf.default.rp_filter=0"]
    # set ip forward
    cmds += ["net.ipv4.ip_forward=1", "net.ipv6.conf.all.forwarding=1"]
    # fast closing tcp connection
    cmds += ["net.ipv4.tcp_fin_timeout=1", "net.ipv4.tcp_tw_reuse=1"]
    # increase max open files
    cmds += ["fs.file-max=1000000"]
    # increase max tcp connection
    cmds += ["net.ipv4.tcp_max_syn_backlog=1000000",
             "net.core.somaxconn=1000000",
             "net.ipv4.tcp_max_tw_buckets=1000000",
             "net.ipv4.tcp_max_orphans=1000000"
             "net.ipv4.tcp_syncookies=1"
             ]
    for c in cmds:
        try:
            run_cmd(cmd+c, 0)
        except Exception as e:
            print(e)
            pass