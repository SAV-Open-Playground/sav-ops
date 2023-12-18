#!/usr/bin/python3
# -*-coding:utf-8 -*-
"""
@File    :   sav_control_master.py
@Time    :   2023/11/30
@Version :   0.1
@Desc    :   The sav_control_master.py is responsible for the management of all hosts(slaves).

"""
import json
import os
import time
from sav_control_common import *
from script_builder import script_builder
from fabric2 import Connection
import argparse
from threading import Thread

SAV_ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
savop_dir = os.path.dirname(os.path.abspath(__file__))
sav_agent_dir = os.path.join(SAV_ROOT_DIR, "sav-agent")
router_dir = os.path.join(SAV_ROOT_DIR, "sav-reference-router")
os.chdir(savop_dir)
out_folder = os.path.join(savop_dir, "this_config")


class MasterController:
    with open(f"{savop_dir}/master_config.json", "r") as f:
        conf_content = json.load(f)
    slave_node = conf_content["slave_node"]
    slave_root_dir = ensure_no_trailing_slash(conf_content["slave_root_dir"])

    def config_file_generate(self, input_json):
        return script_builder(self.slave_root_dir, savop_dir, input_json=input_json, out_folder=out_folder)

    def config_file_distribute(self):
        for node in self.slave_node:
            with Connection(host=node["ip"], user=node["user"], connect_kwargs={"password": node["password"]}) as conn:
                clear_config = conn.run(command=f"rm -rf {self.slave_root_dir}/savop_run/this_config*")
                if clear_config.return_code == 0:
                    print("clear old config successfully.")
                else:
                    print("clear old config fail!")
                compress_config = run_cmd(cmd="tar -czf this_config.tar.gz this_config")
                if compress_config[0] == 0:
                    print("compress config files successfully.")
                else:
                    print("compress config files fail!")
                result = conn.put(local=f"{savop_dir}/this_config.tar.gz", remote=f"{self.slave_root_dir}/savop_run/")
                transfer_config = conn.run(command=f"ls -al {self.slave_root_dir}/savop_run/this_config.tar.gz")
                if transfer_config.return_code == 0:
                    print("transfer config files successfully.")
                else:
                    print("transfer config files fail!")
                uncompress_config = conn.run(
                    command=f"cd {self.slave_root_dir}/savop_run; tar -xzf {self.slave_root_dir}/savop_run/this_config.tar.gz")

    def mode_start(self):
        result = {}
        for node in self.slave_node:
            with Connection(host=node["ip"], user=node["user"], connect_kwargs={"password": node["password"]}) as conn:
                run_result = conn.run(command=f"python3 {self.slave_root_dir}/savop/sav_control_host.py -a start -d {self.slave_root_dir} -n 3")
                result.update({node["ip"]: run_result.stdout})
        return result

    def mode_performance(self):
        for node in self.slave_node:
            with Connection(host=node["ip"], user=node["user"], connect_kwargs={"password": node["password"]}) as conn:
                run_result = conn.run(command=f"python3 {self.slave_root_dir}/savop/sav_control_host.py -p all")
        return run_result


class ThreadWithReturnValue(Thread):
    def __init__(self, target, args=()):
        super(ThreadWithReturnValue, self).__init__()
        self._target = target
        self._args = args
        self._return = None

    def run(self):
        try:
            if self._target is not None:
                self._return = self._target(*self._args)
        finally:
            # Avoid a refcycle if the thread is running a function with
            # an argument that has a member that points to the thread.
            del self._target, self._args

    def join(self):
        super().join()
        return self._return


class SavExperiment:
    controller = MasterController()

    def experiment_3_nodes_v4(self, ):
        self.controller.config_file_generate(input_json="3_nodes_v4.json")
        self.controller.config_file_distribute()
        timestamp_1 = int(time.time())
        before_performance = self.controller.mode_performance().stdout
        timestamp_2 = int(time.time())
        t1 = ThreadWithReturnValue(target=self.controller.mode_start)
        t2 = ThreadWithReturnValue(target=self.controller.mode_performance)
        timestamp_3 = int(time.time())
        t1.start()
        t2.start()
        run_status = t1.join()
        timestamp_4 = int(time.time())
        run_performance_obj = t2.join()
        timestamp_5 = int(time.time())
        run_performance = run_performance_obj.stdout
        after_performance = self.controller.mode_performance().stdout
        timestamp_6 = int(time.time())
        result = {
                "before_run": json.loads(before_performance),
                "during_run": {"start_time": timestamp_3,
                               "container": run_status,
                               "host": json.loads(run_performance),
                               "end_time": timestamp_4},
                "after_run": json.loads(after_performance)}
        return result


def run(args):
    topo_json = args.topo_json

    config = args.config
    distribute = args.distribute
    action = args.action
    performance = args.performance
    experiment = args.experiment

    master_controller = MasterController()
    result = None
    # generate config files
    if config is not None:
        match config:
            case "refresh:":
                base_node_num = script_builder(SAV_ROOT_DIR, savop_dir, input_json=topo_json, out_folder=out_folder)
    # distribute config file
    if distribute is not None:
        match distribute:
            case "all":
                master_controller.config_file_distribute()
    # start, stop, restart the savop in every slave
    if action is not None:
        match action:
            case "start":
                master_controller.mode_start()
            case "stop":
                pass
            case "restart":
                pass
    # the performance of machines and containers
    if performance is not None:
        match performance:
            case "all":
                performance_content = master_controller.mode_performance()
    if experiment is not None:
        sav_exp = SavExperiment()
        match experiment:
            case "3_nodes_v4":
                result = sav_exp.experiment_3_nodes_v4()
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="1 Control the generation and distribution of SAVOP configuration files. "
                    "2 control the operation of SAVOP."
                    "3 Monitor the operational status of SAVOP. ")
    parser.add_argument("-t", "--topo_json", help="JSon file for descripting arbitrary topology.")
    config_group = parser.add_argument_group("config", "Control the generation and distribution of SAVOP "
                                                       "configuration files.")
    config_group.add_argument("-c", "--config", choices=["refresh"], help="generate the configuration files")
    config_group.add_argument("-d", "--distribute", choices=["all"], help="distribute the configuration files")

    operate_group = parser.add_argument_group("operate", "control the operation of SAVOP.")
    operate_group.add_argument("-a", "--action", choices=["start", "stop", "restart"],
                               help="control SAVOP execution, only support three values: start, stop and restart")

    monitor_group = parser.add_argument_group("monitor", "Monitor the operational status of SAVOP.")
    monitor_group.add_argument("-p", "--performance", choices=["all"],
                               help="monitor the performance of machines and containers")

    experiment_group = parser.add_argument_group("experiment", "refresh the SAVOP coniguration files, "
                                                               "restart the simulation and record experimental process "
                                                               "data.")
    monitor_group.add_argument("-e", "--experiment", choices=["3_nodes_v4"], help="initiate a new experiment cycle")
    args = parser.parse_args()
    result = run(args=args)
    print(f"run over, show: \n{result}")

    # topo_json = "3_nodes_v4.json"
    # os.chdir(savop_dir)
    # out_folder = os.path.join(savop_dir, "this_config")
    # base_node_num = refresh(SAV_ROOT_DIR, savop_dir, input_json=topo_json, out_folder=out_folder)
    # master_controller = MasterController()
    # base_node_num = master_controller.config_file_generate()
    # master_controller.config_file_distribute()
    # master_controller.mode_start()
    # print("config regenerated")
