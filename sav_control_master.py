#!/usr/bin/python3
# -*-coding:utf-8 -*-
"""
@File    :   sav_control_master.py
@Time    :   2023/11/30
@Version :   0.1
@Desc    :   The sav_control_master.py is responsible for the management of all hosts(slaves). 
             excepted file structure:
             sav-root-dir
                -sav-agent
                -sav-reference-router
                -savop
                    - sav_control_master.py
                    - sav_control_master_config.json

"""
import os
import time
from sav_control_common import *
from script_builder import script_builder
from fabric2 import Connection
import argparse
from threading import Thread
import shutil

# change the dirs here
SAV_OP_DIR = os.path.dirname(os.path.abspath(__file__))
SAV_ROOT_DIR = os.path.dirname(SAV_OP_DIR)
SAV_AGENT_DIR = os.path.join(SAV_ROOT_DIR, "sav-agent")
ROUTER_DIR = os.path.join(SAV_ROOT_DIR, "sav-reference-router")
OUT_DIR = os.path.join(SAV_OP_DIR, "this_config")

os.chdir(SAV_OP_DIR)


class MasterController:
    def __init__(self, master_config_file="sav_control_master_config.json"):
        master_config_file = os.path.join(SAV_OP_DIR, master_config_file)
        self.config = json_r(master_config_file)
        self.slave_node = self.config["slave_node"]
        self.slave_root_dir = ensure_no_trailing_slash(
            self.config["slave_root_dir"])

    def config_file_generate(self, input_json):
        shutil.rmtree(OUT_DIR)
        os.mkdir(OUT_DIR)
        ret = script_builder(self.slave_root_dir, SAV_OP_DIR, input_json=input_json, out_folder=OUT_DIR)
        print(f"config file generated in: {OUT_DIR}")
        return ret
    def _remote_run(self, node, cmd):
        ret = {}
        if node["ip"] == "localhost":
            ret["cmd_start_dt"] = time.time()
            returncode, stdout, stderr = run_cmd(cmd)
            ret["cmd_result"] = {"returncode": returncode, "stdout": stdout, "stderr": stderr,"cmd":cmd}
            ret["cmd_end_dt"] = time.time()
        else:
            with Connection(host=node["ip"], user=node["user"], connect_kwargs={"password": node["password"]}) as conn:
                ret["cmd_start_dt"] = time.time()
                ret["cmd_result"] = conn.run(command=cmd)
                ret["cmd_end_dt"] = time.time()
        return ret
    def config_file_distribute(self):
        for node in self.slave_node:
            # use my self as a slave
            if node["ip"] == "localhost":
                dst_dir = os.path.join(self.slave_root_dir, "savop_run","this_config")
                if os.path.exists(dst_dir):
                    shutil.rmtree(dst_dir)
                shutil.copytree(OUT_DIR, dst_dir)
                print(f"config file copied to: {dst_dir}")
                continue
            with Connection(host=node["ip"], user=node["user"], connect_kwargs={"password": node["password"]}) as conn:
                clear_config = conn.run(
                    command=f"rm -rf {self.slave_root_dir}/savop_run/this_config*")
                if clear_config.return_code == 0:
                    print("clear old config successfully.")
                else:
                    print("clear old config fail!")
                compress_config = run_cmd(
                    cmd="tar -czf this_config.tar.gz this_config")
                if compress_config[0] == 0:
                    print("compress config files successfully.")
                else:
                    print("compress config files fail!")
                result = conn.put(
                    local=f"{SAV_OP_DIR}/this_config.tar.gz", remote=f"{self.slave_root_dir}/savop_run/")
                transfer_config = conn.run(
                    command=f"ls -al {self.slave_root_dir}/savop_run/this_config.tar.gz")
                if transfer_config.return_code == 0:
                    print("transfer config files successfully.")
                else:
                    print("transfer config files fail!")
                uncompress_config = conn.run(
                    command=f"cd {self.slave_root_dir}/savop_run; tar -xzf {self.slave_root_dir}/savop_run/this_config.tar.gz")

    def mode_start(self):
        result = {}
        node_num = len(self.slave_node)
        cmd = f"python3 {self.slave_root_dir}/savop/sav_control_host.py -a start -d {self.slave_root_dir} -n {node_num}"
        for node in self.slave_node:
            if node["ip"] == "localhost":
                cmd = cmd.replace(f"{self.slave_root_dir}/savop/", "./")
                result.update({node["ip"]: self._remote_run(node,cmd)})
                continue
            result.update({node["ip"]: self._remote_run(node,cmd)})
        return result


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
            # Avoid a ref cycle if the thread is running a function with
            # an argument that has a member that points to the thread.
            del self._target, self._args

    def join(self):
        super().join()
        return self._return


class SavExperiment:
    """
    here, we provide some basic experiment cases.
    """
    controller = MasterController()

    def experiment_3_nodes_v4(self):
        self.controller.config_file_generate(input_json="3_nodes_v4.json")
        self.controller.config_file_distribute()
        before_performance = self.controller.mode_performance().stdout
        t1 = ThreadWithReturnValue(target=self.controller.mode_start)
        t2 = ThreadWithReturnValue(target=self.controller.mode_performance)
        t1.start()
        t2.start()
        run_status = t1.join()
        run_performance_obj = t2.join()
        run_performance = run_performance_obj.stdout
        after_performance = self.controller.mode_performance().stdout
        return {"before_run": json.loads(before_performance), "during_run": {"container": run_status, "host": json.loads(run_performance)},
                "after_run": json.loads(after_performance)}
    def bgp_performance(self,testing_topo="3_nodes_v4.json"):
        self.controller.config_file_generate(input_json=testing_topo)
        self.controller.config_file_distribute()
        self.controller.mode_start()

def run(args):
    topo_json = args.topo_json

    config = args.config
    distribute = args.distribute
    action = args.action
    performance = args.performance
    experiment = args.experiment

    master_controller = MasterController()
    # generate config files
    if config is not None:
        match config:
            case "refresh:":
                base_node_num = script_builder(
                    SAV_ROOT_DIR, SAV_OP_DIR, input_json=topo_json, out_folder=OUT_DIR)
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
                return sav_exp.experiment_3_nodes_v4()
            case "dons":
                return sav_exp.bgp_performance()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="1 Control the generation and distribution of SAVOP configuration files. "
                    "2 control the operation of SAVOP."
                    "3 Monitor the operational status of SAVOP. ")
    parser.add_argument("-t", "--topo_json",
                        help="Json file for arbitrary topology.")
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
    monitor_group.add_argument("-e", "--experiment", choices=["3_nodes_v4","dons"], help="initiate a new experiment cycle")
    args = parser.parse_args()
    result = run(args=args)
    print(f"run over, show: \n{result}")

    # topo_json = "3_nodes_v4.json"
    # os.chdir(SAV_OP_DIR)
    # out_folder = os.path.join(SAV_OP_DIR, "this_config")
    # base_node_num = refresh(SAV_ROOT_DIR, SAV_OP_DIR, input_json=topo_json, out_folder=out_folder)
    # master_controller = MasterController()
    # base_node_num = master_controller.config_file_generate()
    # master_controller.config_file_distribute()
    # master_controller.mode_start()
    # print("config regenerated")
