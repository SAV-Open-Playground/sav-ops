#!/usr/bin/python3
# -*-coding:utf-8 -*-
"""
@File    :   sav_control_master.py
@Time    :   2023/11/30
@Version :   0.1
@Desc    :   The sav_control_master.py is responsible for the management of all hosts(hosts). 
             excepted file structure:
             sav-root-dir
                -sav-agent
                    - sav_control_container.py
                -sav-reference-router
                -savop
                    - base_configs
                        - base_config.json
                    - sav_control_master.py
                    - sav_control_host.py
                    - sav_control_master_config.json
"""
from sav_control_common import *
from script_builder import script_builder
from fabric2 import Connection
import argparse
from threading import Thread
import shutil
import os

# change the dirs here

SELF_HOST_ID = "localhost"

os.chdir(SAV_OP_DIR)


class MasterController:
    def __init__(self, master_config_file, logger=None):
        master_config_file = os.path.join(SAV_OP_DIR, master_config_file)
        self.config = json_r(master_config_file)
        self.host_node = self.config["host_node"]
        if logger is None:
            self.logger = get_logger("master_controller")
        else:
            self.logger = logger

    def _self_host(self, input_json):
        ret = {}
        host_node = self.host_node[SELF_HOST_ID]
        path2json = os.path.join(SAV_OP_DIR, "base_configs", input_json)
        json_content = json_r(path2json)
        generated_config_dir = os.path.join(OUT_DIR, SELF_HOST_ID)

        ret[SELF_HOST_ID] = script_builder(host_node["root_dir"], SAV_OP_DIR, json_content,
                                           out_dir=generated_config_dir,
                                           logger=self.logger, skip_bird=True, skip_rebuild=True)
        self.host_node[SELF_HOST_ID]["cfg_src_dir"] = generated_config_dir
        return ret

    def _not_self_host(self, input_json, skip_compile=True):
        ret = {}
        for host_id in list(self.host_node.keys()):
            host_node = self.host_node[host_id]
            path2json = os.path.join(SAV_OP_DIR, f"base_configs", input_json)
            json_content = json_r(path2json)
            generated_config_dir = os.path.join(OUT_DIR, host_id)
            ret[host_id] = script_builder(
                host_node["root_dir"], SAV_OP_DIR, json_content, out_dir=generated_config_dir, logger=self.logger)
            self.host_node[host_id]["cfg_src_dir"] = generated_config_dir
        return ret

    def config_file_generate(self, input_json, skip_compile=True):
        """
        add load balancing here
        Currently, we just put all containers on the first node.
        """
        shutil.rmtree(OUT_DIR)
        os.mkdir(OUT_DIR)
        if len(list(self.host_node.keys())) and list(self.host_node.keys())[0] == "localhost":
            ret = self._self_host(input_json)
        else:
            ret = self._not_self_host(
                input_json=input_json, skip_compile=skip_compile)
        self.distribution_d = ret
        return ret

    def _remote_run(self, node_id, node, cmd):
        ret = {}
        if node_id == "localhost":
            ret["cmd_start_dt"] = time.time()
            returncode, stdout, stderr = run_cmd(cmd)
            ret["cmd_result"] = {"returncode": returncode,
                                 "stdout": stdout, "stderr": stderr, "cmd": cmd}
            ret["cmd_end_dt"] = time.time()
        else:
            with Connection(host=node_id, user=node["user"], connect_kwargs={"password": node["password"]}) as conn:
                ret["cmd_start_dt"] = time.time()
                ret["cmd_result"] = conn.run(command=cmd)
                ret["cmd_end_dt"] = time.time()
        return ret

    def config_file_distribute(self, skip_compile=False):
        for node_id, node in self.host_node.items():
            # use my self as a host
            cfg_src_dir = node["cfg_src_dir"]
            if node_id == "localhost":
                cfg_dst_dir = os.path.join(node["root_dir"], "savop_run")
                if os.path.exists(cfg_dst_dir):
                    shutil.rmtree(cfg_dst_dir)
                shutil.copytree(cfg_src_dir, cfg_dst_dir)
                self.logger.info(f"config file copied to: {cfg_dst_dir}")
                continue
            with Connection(host=node_id, user=node["user"], connect_kwargs={"password": node["password"]}) as conn:
                clear_config = conn.run(
                    command=f"rm -rf {node['root_dir']}/savop_run/*")
                if clear_config.return_code == 0:
                    print("clear old config successfully.")
                else:
                    print("clear old config fail!")
                compress_config = run_cmd(
                    cmd=f"tar -czf this_config/{node_id}.tar.gz this_config/{node_id}")
                if compress_config[0] == 0:
                    print("compress config files successfully.")
                else:
                    print("compress config files fail!")
                result = conn.put(
                    local=f"{SAV_OP_DIR}/this_config/{node_id}.tar.gz", remote=f"{node['root_dir']}/savop_run/")
                if not skip_compile:
                    result = conn.put(
                        local=f"{SAV_ROUTER_DIR}/bird", remote=f"{node['root_dir']}/sav-reference-router/")
                    result = conn.put(
                        local=f"{SAV_ROUTER_DIR}/birdc", remote=f"{node['root_dir']}/sav-reference-router/")
                    result = conn.put(
                        local=f"{SAV_ROUTER_DIR}/birdcl", remote=f"{node['root_dir']}/sav-reference-router/")
                transfer_config = conn.run(
                    command=f"ls -al {node['root_dir']}/savop_run/{node_id}.tar.gz")
                if transfer_config.return_code == 0:
                    print("transfer config files successfully.")
                else:
                    print("transfer config files fail!")
                uncompress_config = conn.run(
                    command=f"cd {node['root_dir']}/savop_run; tar -xzf {node['root_dir']}/savop_run/{node_id}.tar.gz")
                mv_config = conn.run(command=f"mv {node['root_dir']}/savop_run/this_config/{node_id}/*  {node['root_dir']}/savop_run"
                                             f" && rm -rf {node['root_dir']}/savop_run/this_config")

    def mode_performance(self):
        for node_id in list(self.host_node.keys()):
            node = self.host_node[node_id]
            root_dir = node["root_dir"][:-
                                        1] if node["root_dir"].endswith("/") else node["root_dir"]
            cmd = f'python3 {root_dir}/savop/sav_control_host.py -p all'
            run_result = self._remote_run(node_id=node_id, node=node, cmd=cmd)
        return run_result["cmd_result"]

    def mode_start(self):
        result = {}
        # TODO we should calculate the container number on each node,but here we just use a fixed number
        for node_id, node_num in self.config["host_node"].items():
            node = self.host_node[node_id]
            path2hostpy = os.path.join(
                node["root_dir"], "savop", "sav_control_host.py")
            cmd = f"python3 {path2hostpy} -a start"
            self.logger.debug(cmd)
            node_result = self._remote_run(node_id, node, cmd)
            self.logger.debug(node_result)
            if node_id in result:
                self.logger.error("keys conflict")
            # if node_result["cmd_result"].return_code == 0:
                # node_result["cmd_result"] = "ok"
            result[node_id] = node_result
        return result

    def dev_test(self):
        for node_id, node_num in self.config["host_node"].items():
            node = self.host_node[node_id]
            path2hostpy = os.path.join(
                node["root_dir"], "savop", "sav_control_host.py")
            cmd = f"python3 {path2hostpy} -a dev_test"
            node_result = self._remote_run(node_id, node, cmd)
            self.logger.debug(node_result)
        return
    def sav_exp_start(self):
        """
        sav experiment start
        """
        result = {}
        # TODO we should calculate the container number on each node,but here we just use a fixed number
        for node_id, _ in self.config["host_node"].items():
            node = self.host_node[node_id]
            path2hostpy = os.path.join(
                node["root_dir"], "savop", "sav_control_host.py")
            cmd = f"python3 {path2hostpy} -a start"
            node_result = self._remote_run(node_id, node, cmd)
            self.logger.debug(node_result)
            if node_id in result:
                self.logger.error("keys conflict")
            result[node_id] = node_result
        return result

    def original_bird_test(self):
        """
        using original bird to test error, for debugging
        """
        result = {}
        for node_id, node_num in self.distribution_d.items():
            node = self.host_node[node_id]
            host_py_path = os.path.join(
                node["root_dir"], "savop", "sav_control_host.py")
            cmd = f"python3 {host_py_path} -a start_original_bird"
            node_result = self._remote_run(node_id, node, cmd)
            if node_id in result:
                self.logger.error("keys conflict")
            result[node_id] = node_result
        return result

    def fib_stable_test(self):
        """
        using sav_agent to test fib stable time
        """
        result = {}
        for node_id, node_num in self.distribution_d.items():
            node = self.host_node[node_id]
            host_py_path = os.path.join(
                node["root_dir"], "savop", "sav_control_host.py")
            cmd = f"python3 {host_py_path} -a start_original_bird"
            node_result = self._remote_run(node_id, node, cmd)
            if node_id in result:
                self.logger.error("keys conflict")
            result[node_id] = node_result
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
    logger = get_logger("SAVExp")
    controller = MasterController("sav_control_master_config.json", logger)


    def experiment_testing_v6_inter(self):
        self.controller.config_file_generate(
            input_json="testing_v6_inter.json")
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


    def _bgp_exp_result_parser(self, result):
        """
        parse bgp experiment result,return a json object
        """
        std_out = result.split("CompletedProcess")
        while "" in std_out:
            std_out.remove("")
        temp = []
        for i in std_out:
            if i.endswith("No such process\\n\')\n"):
                continue
            if i.endswith("savop-dev/src/savop\n"):
                continue
            if i.startswith("(args='dstat -f "):
                continue
            if i.startswith("(args='docker stats -a"):
                continue
            else:
                temp.append(i)
        std_out = temp[0]
        std_out = std_out.split("\n")[1:]
        json_str = "\n".join(std_out)
        result = json.loads(json_str)
        result["host_metric"]["data"] = extract_mem_and_cpu_stats_from_dstat(
            result["host_metric"]["data"])
        return result

        # currently we just need the host data
    def general_exp(self, base_cfg_name, skip_compile=True):
        # 1. generate config files
        self.controller.config_file_generate(
            input_json=base_cfg_name, skip_compile=skip_compile)
        # 2. distribute config files
        self.controller.config_file_distribute(skip_compile=skip_compile)
        self.controller.sav_exp_start()

    def dev_test(self, base_cfg_name):
        """
        for development
        """
        self.controller.config_file_generate(
            input_json=base_cfg_name)
        # 2. distribute config files
        self.controller.config_file_distribute()
        self.controller.dev_test()
    def original_bird(self):
        """
        test the time consumption for bgp to stable
        """
        full_list = [
            '246_100_50_50_246_nodes_inter_v4_original_bird.json'
        ]
        for topo in full_list:
            self.logger.debug(f"starting {topo}")
            # add original bird key here
            self.controller.config_file_generate(topo)
            self.controller.config_file_distribute()
            ret = self.controller.original_bird_test()
            for node, result in ret.items():
                std_out = result["cmd_result"]["stdout"]
                std_err = result["cmd_result"]["stderr"]
                ret_code = result["cmd_result"]["returncode"]
                if ret_code == 0:
                    time_usage = result["cmd_end_dt"] - result["cmd_start_dt"]
                    self.logger.debug(f"{node} finished in {time_usage}")
                    raw_result = std_out
                    raw_result_file_name = topo.replace(
                        ".json", "_raw_result.txt")
                    with open(raw_result_file_name, "w") as f:
                        f.write(raw_result)
                    print(f"raw_result saved to {raw_result_file_name}")

    def fib_stable(self):
        """
        using sav_agent to monitor the fib stable time
        """
        configs = [
            '246_20_50_50_49_nodes_inter_v4.json', '246_40_50_50_98_nodes_inter_v4.json',
            '246_60_50_50_147_nodes_inter_v4.json', '246_80_50_50_196_nodes_inter_v4.json',
            '246_100_50_50_246_nodes_inter_v4.json']
        for config in configs:
            self.logger.debug(f"starting {config}")
            # add original bird key here
            self.controller.config_file_generate(config)
            self.controller.config_file_distribute()
            ret = self.controller.fib_stable_test()
            input(ret)
            for node, result in ret.items():
                std_out = result["cmd_result"]["stdout"]
                std_err = result["cmd_result"]["stderr"]
                ret_code = result["cmd_result"]["returncode"]
                if ret_code == 0:
                    time_usage = result["cmd_end_dt"] - result["cmd_start_dt"]
                    self.logger.debug(f"{node} finished in {time_usage}")
                    raw_result = std_out
                    raw_result_file_name = config.replace(
                        ".json", "_raw_result.txt")
                    with open(raw_result_file_name, "w") as f:
                        f.write(raw_result)
                    self.logger.debug(
                        f"raw_result saved to {raw_result_file_name}")
def run(args):
    topo_json = args.topo_json
    config = args.config
    distribute = args.distribute
    action = args.action
    performance = args.performance
    experiment = args.experiment
    skip_compile= args.skip_compile
    if experiment is not None:
        sav_exp = SavExperiment()
        match experiment:
            case "fib_stable":
                return sav_exp.fib_stable()
            case "original_bird":
                return sav_exp.original_bird()
            case "dev_test":
                return sav_exp.dev_test("testing_v4_inter.json")
            case _:
                return sav_exp.general_exp(experiment+'.json',skip_compile=skip_compile)
    # generate config files
    if config is not None and topo_json is not None:
        master_controller = MasterController("sav_control_master_config.json")
        match config:
            case "refresh":
                base_node_num = master_controller.config_file_generate(
                    input_json=topo_json)
    # distribute config file
    if distribute:
        master_controller = MasterController("sav_control_master_config.json")
        match distribute:
            case "all":
                master_controller.config_file_distribute()
    # start, stop, restart the savop in every host
    if action:
        master_controller = MasterController("sav_control_master_config.json")
        match action:
            case "start":
                master_controller.mode_start()
            case "stop":
                pass
            case "restart":
                pass
    # the performance of machines and containers
    if performance:
        master_controller = MasterController("sav_control_master_config.json")
        match performance:
            case "all":
                performance_content = master_controller.mode_performance()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="1 Control the generation and distribution of SAVOP configuration files. "
                    "2 control the operation of SAVOP."
                    "3 Monitor the operational status of SAVOP. ")
    parser.add_argument("-t", "--topo_json",
                        help="Json file for arbitrary topology.")
    config_group = parser.add_argument_group("config", "Control the generation and distribution of SAVOP "
                                                       "configuration files.")
    config_group.add_argument(
        "-c", "--config", choices=["refresh"], help="generate the configuration files")
    config_group.add_argument(
        "-d", "--distribute", choices=["all"], help="distribute the configuration files")
    parser.add_argument("-s", "--skip_compile", action="store_true",
                        help="skip compile bird, default value is false")
    operate_group = parser.add_argument_group(
        "operate", "control the operation of SAVOP.")
    operate_group.add_argument("-a", "--action", choices=["start", "stop", "restart"],
                               help="control SAVOP execution, only support three values: start, stop and restart")

    monitor_group = parser.add_argument_group(
        "monitor", "Monitor the operational status of SAVOP.")
    monitor_group.add_argument("-p", "--performance", choices=["all"],
                               help="monitor the performance of machines and containers")

    experiment_group = parser.add_argument_group("experiment", "refresh the SAVOP coniguration files, "
                                                               "restart the simulation and record experimental process "
                                                               "data.")
    experiment_group.add_argument(
        "-e", "--experiment", help="initiate a new experiment cycle, add then json file name here (without extension or dir), it should exist in base_configs dir.")
    args = parser.parse_args()
    result = run(args=args)
    print(f"run over, show: \n{result}")
