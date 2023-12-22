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
                -sav-reference-router
                -savop
                    - base_configs
                        - base_config.json
                    - sav_control_master.py
                    - sav_control_master_config.json
"""


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
SELF_HOST_ID = "localhost"

os.chdir(SAV_OP_DIR)


class MasterController:
    def __init__(self, master_config_file, logger=None):
        master_config_file = os.path.join(SAV_OP_DIR, master_config_file)
        self.config = json_r(master_config_file)
        self.host_node = self.config["host_node"]
        if logger is None:
            self.logger = get_logger("master_controller")
    def _self_host(self,input_json):
        ret = {}
        host_node = self.host_node[SELF_HOST_ID]
        path2json = os.path.join(SAV_OP_DIR, "base_configs", input_json)
        json_content = json_r(path2json)
        generated_config_dir = os.path.join(OUT_DIR, SELF_HOST_ID)
        ret[SELF_HOST_ID] = script_builder(host_node["root_dir"], SAV_OP_DIR, json_content, out_folder=generated_config_dir)
        self.host_node[SELF_HOST_ID]["cfg_src_dir"] = generated_config_dir
        return ret
    def config_file_generate(self, input_json):
        """
        add load balancing here
        Currently, we just put all containers on the first node.
        """
        shutil.rmtree(OUT_DIR)
        os.mkdir(OUT_DIR)
        ret = self._self_host(input_json=input_json)
        self.distribution_d = ret
        return ret
    def _remote_run(self, node_id,node, cmd):
        ret = {}
        if node_id == "localhost":
            ret["cmd_start_dt"] = time.time()
            returncode, stdout, stderr = run_cmd(cmd)
            ret["cmd_result"] = {"returncode": returncode, "stdout": stdout, "stderr": stderr,"cmd":cmd}
            ret["cmd_end_dt"] = time.time()
        else:
            with Connection(host=node_id, user=node["user"], connect_kwargs={"password": node["password"]}) as conn:
                ret["cmd_start_dt"] = time.time()
                ret["cmd_result"] = conn.run(command=cmd)
                ret["cmd_end_dt"] = time.time()
        return ret
    def config_file_distribute(self):
        for node_id,node in self.host_node.items():
            # use my self as a host
            cfg_src_dir = node["cfg_src_dir"]
            if node_id == "localhost":
                cfg_dst_dir = os.path.join(node["root_dir"],"savop_run")

                if os.path.exists(cfg_dst_dir):
                    shutil.rmtree(cfg_dst_dir)
                shutil.copytree(cfg_src_dir, cfg_dst_dir)
                print(f"config file copied to: {cfg_dst_dir}")
                continue
            with Connection(host=node_id, user=node["user"], connect_kwargs={"password": node["password"]}) as conn:
                clear_config = conn.run(
                    command=f"rm -rf {self.host_root_dir}/savop_run/*")
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
                    local=f"{SAV_OP_DIR}/this_config.tar.gz", remote=f"{self.host_root_dir}/savop_run/")
                transfer_config = conn.run(
                    command=f"ls -al {self.host_root_dir}/savop_run/this_config.tar.gz")
                if transfer_config.return_code == 0:
                    print("transfer config files successfully.")
                else:
                    print("transfer config files fail!")
                uncompress_config = conn.run(
                    command=f"cd {self.host_root_dir}/savop_run; tar -xzf {self.host_root_dir}/savop_run/this_config.tar.gz")

    def mode_start(self):
        result = {}
        # TODO we should calculate the container number on each node,but here we just use a fixed number
        for node_id, node_num in self.distribution_d.items():
            node = self.host_node[node_id]
            path2hostpy = os.path.join(node["root_dir"], "savop", "sav_control_host.py")
            cmd = f"python3 {path2hostpy} -a start -d {node['root_dir']} -n {node_num}"
            node_result = self._remote_run(node_id, node, cmd)
            if node_id in result:
                self.logger.error("duplic keys")
            result[node_id] = node_result
        return result
    def mode_dons(self):
        result = {}
        # TODO we should calculate the container number on each node,but here we just use a fixed number
        for node_id, node_num in self.distribution_d.items():
            node = self.host_node[node_id]
            path2hostpy = os.path.join(node["root_dir"], "savop", "sav_control_host.py")
            cmd = f"python3 {path2hostpy} -a start_dons -d {node['root_dir']} -n {node_num}"
            node_result = self._remote_run(node_id, node, cmd)
            if node_id in result:
                self.logger.error("duplic keys")
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

    def _bgp_exp_result_parser(self, result):
        """
        parse bgp experiment result,return a json object
        """
        std_out = result.split("CompletedProcess")
        while "" in std_out:
            std_out.remove("")
        temp = []
        for i in std_out:
            i = i.strip()
            if i.startswith("(") and i.endswith(")"):
                continue
            else:
                temp.append(i)
        if len(temp) != 1:
            for i in temp:
                input([i])
        std_out = temp[0].split("\n")[1:]
        csv_str = "\n".join(std_out)
        result = json.loads(csv_str)
        input(result.keys())
        del result["container_metric"]
        for node, node_data in result["agents_metric"].items():
            self.logger.debug(f"{node} {node_data}")
            result["agents_metric"][node] = node_data["agent"]["fib_stable_dt"] - \
                node_data["agent"]["first_dt"]
        result["router_fib_stable_time_sec_detail"] = result["agents_metric"]
        result["router_fib_stable_time_sec_max"] = max(list(result["router_fib_stable_time_sec_detail"].values()))
        
        del result["agents_metric"]
        result["host_metric"]["data"] = extract_mem_and_cpu_stats_from_dstat(
            result["host_metric"]["data"])
        return result

        # currently we just need the host data

    def bgp_performance(self):
        """
        test the time consumption for bgp to stable
        """
        full_list = ['246_5_50_50_12_nodes_inter_v4.json',  '246_10_50_50_24_nodes_inter_v4.json', '246_15_50_50_36_nodes_inter_v4.json',
                     '246_15_50_50_36_nodes_inter_v4.json', '246_20_50_50_49_nodes_inter_v4.json', '246_25_50_50_61_nodes_inter_v4.json',
                     '246_30_50_50_73_nodes_inter_v4.json', '246_35_50_50_86_nodes_inter_v4.json', '246_40_50_50_98_nodes_inter_v4.json',
                     '246_45_50_50_110_nodes_inter_v4.json','246_50_50_50_123_nodes_inter_v4.json','246_55_50_50_135_nodes_inter_v4.json',
                     '246_60_50_50_147_nodes_inter_v4.json','246_65_50_50_159_nodes_inter_v4.json','246_70_50_50_172_nodes_inter_v4.json',
                     '246_75_50_50_184_nodes_inter_v4.json','246_80_50_50_196_nodes_inter_v4.json','246_85_50_50_209_nodes_inter_v4.json',
                     '246_90_50_50_221_nodes_inter_v4.json','246_95_50_50_233_nodes_inter_v4.json','246_100_50_50_246_nodes_inter_v4.json']
        # full_list = full_list[:1]
        for topo in full_list:
            self.controller.config_file_generate(input_json=topo)
            self.controller.config_file_distribute()
            ret = self.controller.mode_dons()
            for node, result in ret.items():
                std_out = result["cmd_result"]["stdout"]
                std_err = result["cmd_result"]["stderr"]
                ret_code = result["cmd_result"]["returncode"]
                if ret_code != 0:
                    input(std_err)
                time_usage = result["cmd_end_dt"] - result["cmd_start_dt"]
                self.logger.debug(f"{node} finished in {time_usage}")
                result = self._bgp_exp_result_parser(std_out)
                result_file_name = topo.replace(".json", "_result.json")
                json_w(result_file_name, result)
                print(f"result saved to {result_file_name}")
                input()

def run(args):
    # topo_json = args.topo_json

    config = args.config
    distribute = args.distribute
    action = args.action
    performance = args.performance
    experiment = args.experiment

    # master_controller = MasterController("sav_control_master_config.json")
    # # generate config files
    # if config:
    #     match config:
    #         case "refresh:":
    #             base_node_num = script_builder(
    #                 SAV_ROOT_DIR, SAV_OP_DIR, input_json=topo_json, out_folder=OUT_DIR)
    # # distribute config file
    # if distribute:
    #     match distribute:
    #         case "all":
    #             master_controller.config_file_distribute()
    # # start, stop, restart the savop in every host
    # if action:
    #     match action:
    #         case "start":
    #             master_controller.mode_start()
    #         case "stop":
    #             pass
    #         case "restart":
    #             pass
    # # the performance of machines and containers
    # if performance:
    #     match performance:
    #         case "all":
    #             performance_content = master_controller.mode_performance()
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