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


def run_cmd(cmd):
    """print output if returncode != 0"""
    ret = subprocess_cmd(cmd)
    if ret.returncode != 0:
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


def extract_mem_and_cpu_stats_from(data):
    print("start")
    cvs_content = ""

    data_content_list = data.split("\n")
    title_list = [i.replace("-", '').replace("usage", "").replace("total", "") for i in data_content_list[0].split(" ")][0:2]
    child_title = [i.strip() for i in data_content_list[1].split("|")][0:2]

    column_list = []
    for index in range(0, len(title_list)):
        child_title_list = [i for i in child_title[index].split(" ") if len(i) != 0]
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
                        value = str(int(float(value[:-1]) * 1024)) + "M"
                        mem_list.append(value)
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


if __name__ == "__main__":
    data = "------memory-usage----- --total-cpu-usage-- -dsk/loop0- -dsk/loop1- -dsk/loop2- -dsk/loop3- -dsk/loop4- -dsk/loop5- -dsk/loop6- -dsk/loop7- -dsk/loop8- --dsk/sda-- --dsk/sdb-- net/br-742b net/docker0 -net/ens1f1 ---paging-- ---system--\n used  free  buff  cach|usr sys idl wai stl| read  writ: read  writ: read  writ: read  writ: read  writ: read  writ: read  writ: read  writ: read  writ: read  writ: read  writ| recv  send: recv  send: recv  send|  in   out | int   csw \n7709M  215G 4461M 21.7G|  2   0  98   0   0|   0     0 :  53b    0 :   0     0 :  25b    0 :  48b    0 :   8b    0 :  21b    0 :   3b    0 :   0     0 :2273b 1105k:6498b  488k|   0     0 :   0     0 :   0     0 | 184B  274B|5364    65k\n7721M  215G 4461M 21.7G|  2   0  98   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    19M:   0     0 |   0     0 :   0     0 :  23k   20k|   0     0 |3652  4990 \n7724M  215G 4461M 21.7G|  2   0  98   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 |   0     0 :   0     0 : 860k  866k|   0     0 |3661  5474 \n7795M  215G 4461M 21.7G|  2   0  98   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    19M:   0  3703k|   0     0 :   0     0 :  26k   22k|   0     0 |4951    26k\n7810M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9896k:   0     0 |   0     0 :   0     0 :  31k 7360b|   0     0 |3909  9590 \n7815M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    10M:   0    66k|   0     0 :   0     0 :  73k  114k|   0     0 |2083  4892 \n7825M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    11M:   0   262k|   0     0 :   0     0 :  88k  195k|   0     0 |2091  5430 \n7834M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9667k:   0     0 |   0     0 :   0     0 :  78k  228k|   0     0 |2920  5779 \n7838M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9470k:   0     0 |   0     0 :   0     0 :  83k  270k|   0     0 |1738  4902 \n7852M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9732k:   0  4686k|   0     0 :   0     0 :  87k  316k|   0     0 |3644  7168 \n7822M  215G 4461M 21.7G|  0   0  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9470k:   0     0 |   0     0 :   0     0 :  65k  347k|   0     0 |3336  8276 \n8353M  215G 4461M 21.7G|  4   5  91   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    22M:   0   129M|   0     0 :   0     0 :  86k  546k|   0     0 |  49k   91k\n8787M  214G 4461M 21.7G|  5   9  86   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    14M:   0     0 |   0     0 :   0     0 : 108k  488k|   0     0 |  29k   39k\n8967M  214G 4461M 21.7G|  4   9  87   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    10M:   0  3670k|   0     0 :   0     0 : 124k  993k|   0     0 |  32k   46k\n8967M  214G 4461M 21.7G|  3  10  88   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9896k:   0     0 |   0     0 :   0     0 :  77k  987k|   0     0 |  31k   45k\n8991M  214G 4461M 21.7G|  3  11  87   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9470k:   0     0 |   0     0 :   0     0 :  76k 1248k|   0     0 |  31k   45k\n8989M  214G 4461M 21.7G|  3  10  87   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9798k:   0    39M|   0     0 :   0     0 :  92k 2089k|   0     0 |  31k   42k\n9027M  214G 4461M 21.7G|  1   2  97   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    19M:   0     0 |   0     0 :   0     0 :  67k 1753k|   0     0 |  15k   22k\n9033M  214G 4461M 21.7G|  1   1  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    10M:   0  1114k|   0     0 :   0     0 : 116k 2051k|   0     0 |  14k   14k\n9043M  214G 4461M 21.7G|  1   1  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    10M:   0     0 |   0     0 :   0     0 : 115k 3248k|   0     0 |  16k   13k\n8822M  214G 4461M 21.7G|  1   2  97   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9830k:   0     0 |   0     0 :   0     0 : 106k 3631k|   0     0 |  16k   17k\n8748M  214G 4461M 21.7G|  1   0  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9634k:   0     0 |   0     0 :   0     0 :  93k 2802k|   0     0 |  16k   13k\n8739M  214G 4461M 21.7G|  1   1  98   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    15M:   0  7045k|   0     0 :   0     0 : 100k 3064k|   0     0 |  18k   20k\n8735M  214G 4461M 21.7G|  1   0  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    43M:   0  3244k|   0     0 :   0     0 : 107k 3335k|   0     0 |  14k   12k\n8729M  214G 4461M 21.7G|  1   1  98   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9765k:   0     0 |   0     0 :   0     0 :  81k 3488k|   0     0 |  16k   16k\n8718M  214G 4461M 21.7G|  1   0  98   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9765k:   0     0 |   0     0 :   0     0 :  65k 2577k|   0     0 |  14k   16k\n8718M  214G 4461M 21.7G|  1   0  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    11M:   0     0 |   0     0 :   0     0 : 104k 4113k|   0     0 |  12k   12k\n8722M  214G 4461M 21.7G|  1   0  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    12M:   0  4194k|   0     0 :   0     0 :  90k 4373k|   0     0 |  13k   15k\n8723M  214G 4461M 21.7G|  1   0  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    16M:   0  3113k|   0     0 :   0     0 :  97k 4639k|   0     0 |  11k   11k\n8726M  214G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9896k:   0    66k|   0     0 :   0     0 :  84k 4896k|   0     0 |6515  9718 \n8732M  214G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    29M:   0     0 |   0     0 :   0     0 : 100k 5158k|   0     0 |4734  8039 \n8736M  214G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    10M:   0     0 |   0     0 :   0     0 :   0     0 |   0     0 |6242    10k\n8746M  214G 4461M 21.7G|  1   1  98   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    11M:   0     0 |   0     0 :   0     0 : 101k 6805k|   0     0 |  20k   36k\n8754M  214G 4461M 21.7G|  1   0  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    13M:   0  3899k|   0     0 :   0     0 : 113k 7120k|   0     0 |  13k   22k\n8756M  214G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    10M:   0     0 |   0     0 :   0     0 :  95k 6072k|   0     0 |4754  8668 \n8737M  214G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9699k:   0     0 |   0     0 :   0     0 :  95k 6331k|   0     0 |5133  9020 \n8696M  214G 4461M 21.7G|  1   0  99   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9601k:   0     0 |   0     0 :   0     0 :  97k 6589k|   0     0 |  19k   11k\n8695M  214G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    10M:   0     0 |   0     0 :   0     0 : 106k 6855k|   0     0 |4777  8700 \n7813M  215G 4461M 21.7G|  1   1  98   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    13M:   0   102M|   0     0 :   0     0 :  62k  508k|   0     0 |  18k   40k\n7809M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    11M:   0     0 |   0     0 :   0     0 :  67k  777k|   0     0 |1796  4836 \n7810M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9470k:   0     0 |   0     0 :   0     0 :  83k 1041k|   0     0 |3487  7240 \n7811M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9503k:   0     0 |   0     0 :   0     0 :  72k 1225k|   0     0 |1582  4296 \n7816M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9404k:   0     0 |   0     0 :   0     0 :  72k 1450k|   0     0 |3347  7316 \n7816M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0    12M:   0  8978k|   0     0 :   0     0 :  93k 1949k|   0     0 |2262  4290 \n7815M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9404k:   0     0 |   0     0 :   0     0 :  80k 1909k|   0     0 |1974  5451 \n7818M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9535k:   0     0 |   0     0 :   0     0 :  72k 2132k|   0     0 |3338  6397 \n7815M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9404k:   0     0 |   0     0 :   0     0 :  72k 2353k|   0     0 |1826  4610 \n7811M  215G 4461M 21.7G|  0   0 100   0   0|   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0     0 :   0  9535k:   0     0 |   0     0 :   0     0 :  79k 2578k|   0     0 |3495  7184 \n"
    print(extract_mem_and_cpu_stats_from(data=data))