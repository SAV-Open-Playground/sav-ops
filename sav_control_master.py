#!/usr/bin/python3
# -*-coding:utf-8 -*-
"""
@File    :   sav_control_master.py
@Time    :   2023/11/30
@Version :   0.1
@Desc    :   The sav_control_master.py is responsible for the management of all hosts(slaves).

"""
import os
from sav_control_common import *
from script_builder import script_builder

if __name__ == "__main__":
    src_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

    savop_dir = os.path.join(src_dir, "savop")
    sav_agent_dir = os.path.join(savop_dir, "sav-agent")
    router_dir = os.path.join(savop_dir, "sav-reference-router")
    topo_json = "3_nodes_v4.json"
    os.chdir(savop_dir)
    base_node_num = script_builder(src_dir, savop_dir,
                                   input_json=topo_json,
                                   out_folder=os.path.join(savop_dir, "this_config"))
    print("config regenerated")
