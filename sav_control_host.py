#!/usr/bin/python3
# -*-coding:utf-8 -*-
"""
@File    :   sav_control_host.py
@Time    :   2023/11/30
@Version :   0.1
@Desc    :   The sav_control_host.py is responsible for the management of current host(slave).
"""
from sav_control_common import *
import argparse
import threading
HOST_METRIC_PATH = "./host_metric.txt"
CONTAINER_METRIC_PATH = "./containers_metric.json"
def monitor_host(stat_out_file = HOST_METRIC_PATH):
    """
    monitor resource usage of the host
    the default interval is one second
    """
    if os.path.exists(stat_out_file):
        os.unlink(stat_out_file)
    cmd = f"dstat -f -m -a --bits --nocolor>{stat_out_file}"
    run_cmd(cmd,1)
def monitor_containers(stat_out_file = CONTAINER_METRIC_PATH):
    if os.path.exists(stat_out_file):
        os.unlink(stat_out_file)
    cmd = f"docker stats -a --format json>{stat_out_file}"
    run_cmd(cmd)
def parse_dstat_file(file_path):
    """
    parse dstat file
    """
    # raise NotImplementedError
    with open(file_path) as f:
        lines = f.readlines()
    headers = lines[0].strip().split("|")
    print(headers)
    lines = lines[3:]
    ret = []
    for line in lines:
        line = line.strip()
        if not line:
            continue
        line = line.split("|")
        line = list(map(lambda x: x.strip(), line))
        line = list(filter(lambda x: x, line))
        ret.append(line)
    return 


class RunEmulation():
    def __init__(self, root_dir, host_signal_path=r"./active_signal.json", base_compose="./docker_compose_50.yml",
                 base_topo="./savop/topology/topo_50.sh", base_node_num=50):
        self._id = whoami()
        if not self._id:
            raise ValueError("get id error")
        self.logger = get_logger(self._id)
        self.root_dir = root_dir
        self.host_signal_path = host_signal_path
        self.base_compose_path = base_compose
        self.base_topo = base_topo
        self.base_node_num = base_node_num
        self.active_app = None


    def if_base_started(self):
        """
        tell if base started
        """
        s_cmd = subprocess_cmd("docker ps")
        out = s_cmd.stdout.split("\n")
        bird_count = 0
        krill_count = 0
        routinator_count = 0
        self.active_containers = set()
        for line in out:
            if "savop_bird_base" in line:
                self.active_containers.add(line.split()[-1])
                bird_count += 1
            elif "routinator" in line:
                routinator_count += 1
            elif "krill" in line:
                krill_count += 1
        if bird_count != self.base_node_num:
            self.logger.info(f"bird count error, should be {self.base_node_num}, but {bird_count}")
            return False
        rpki = False
        if rpki:
            return routinator_count == 1 and krill_count == 1
        else:
            return True

    def send_stop_signal(self):
        """stop sav-agent and bird on all nodes"""
        data = json_r(self.host_signal_path)
        data["command"] = "stop"
        json_w(self.host_signal_path, data)
        self.logger.info("stop signal sent")
    def send_start_signal(self):
        """start sav-agent and bird on all nodes"""
        data = json_r(self.host_signal_path)
        data["command"] = "start"
        json_w(self.host_signal_path, data)
        self.logger.info("start signal sent")
    def clear_logs(self):
        """
        clear log folders, should be called in start base function
        """
        cur_dir = os.path.dirname(os.path.abspath(__file__))
        self.logger.debug(cur_dir)
        path = r'./logs'
        if not os.path.exists(path):
            os.mkdir(path)
        folders = os.listdir(path)
        folders = [i for i in folders if os.path.isdir(os.path.join(path, i))]
        for folder in folders:
            folder_path = os.path.join(path, folder)
            files = os.listdir(folder_path)
            for file in files:
                file_path = os.path.join(folder_path, file)
                if os.path.isdir(file_path):
                    os.system("rm -rf " + file_path)
                else:
                    os.remove(file_path)

    def ready_base(self, force_restart=False):
        """
        start base ,starting  containers and links
        """
        if self.if_base_started() and not force_restart:
            self.logger.info("base already started")
            return
        self.logger.info(f"init base with {self.base_compose_path}")
        t = time.time()
        subprocess_cmd(f"docker compose -f {self.base_compose_path} down")
        self.logger.info("container stopped")
        cmd = f"docker build --build-arg root_dir=./ -f {self.root_dir}/savop/dockerfiles/reference_router {self.root_dir} -t savop_bird_base"
        run_cmd(cmd)
        self.clear_logs()
        self.logger.debug(f"docker compose -f {self.base_compose_path} up -d")
        run_cmd(f"docker compose -f {self.base_compose_path} up -d")
        self.logger.info("container started")
        run_cmd(f"bash {self.base_topo}")
        self.logger.info("link added")
        t = time.time()-t
        self.logger.info(f"base start finished in {t:.4f} seconds")
        if self.if_base_started():
            self.logger.info("base ready")
        else:
            self.logger.error("base start failed")
            sys.exit(1)

    def update_configs(self, nodes, proto):
        """
        update the bird and sav-agent configs
        """
        valid_protos = ["grpc", "quic", "dsav", "non-rpdp"]
        if not proto in valid_protos:
            raise ValueError(f"proto should be {valid_protos} ,not {proto}")
        for n in nodes:
            # update bird config
            with open(f"{self.src_cfg_path}/{n}.conf", "r") as f:
                bird_cfg = f.readlines()
            if proto != "dsav":
                bird_cfg = list(map(lambda x: x.replace(
                    "from sav_inter{", "from basic{"), bird_cfg))
            # remove unused links
            # bird config
            not_changed = True
            while not_changed:
                bird_cfg, not_changed = remove_bird_links(bird_cfg, nodes)
            # sa config
            # remove tailing spaces
            temp = []
            for l in bird_cfg:
                while l.endswith(" \n"):
                    l = l[:-2]+"\n"
                temp.append(l)
            bird_cfg = temp
            # update start delay in bird
            for i in range(len(bird_cfg)):
                count = 0
                if "connect delay time" in bird_cfg[i]:
                    bird_cfg[i] = f"\tconnect delay time {count};\n"
                    # count += 1

            with open(f"{self.dst_cfg_path}/{n}.conf", "w") as f:
                f.writelines(bird_cfg)
            for l in bird_cfg:
                if l.endswith(" \n"):
                    input(l)
            # update sav-agent config
            sa_cfg = json_r(f"{self.src_cfg_path}/{n}.json")
            if proto in ["grpc", "quic"]:
                temp = {}
                for k, v in sa_cfg["link_map"].items():
                    asns = k.split("_")[1:]
                    asns = list(map(int, asns))
                    if (asns[0] in nodes) and (asns[1] in nodes):
                        v["link_type"] = proto
                        temp[k] = v
                sa_cfg["link_map"] = temp
            else:
                sa_cfg["link_map"] = {}
            sa_cfg["enabled_sav_app"] = self.active_app
            sa_cfg["apps"] = [self.active_app]
            json_w(f"{self.dst_cfg_path}/{n}.json", sa_cfg)
            # self.logger.info(f"active_app:{self.active_app} config updated")
        # waits the configs to be updated in containers
        time.sleep(len(nodes)/30)

    def _log_to_cmd_file(self, msg, result_path, log_level='info'):
        if not log_level in ['info', 'error', 'warn']:
            raise ValueError(f"log_level should be info, error or warn: {log_level}")
        match log_level:
            case 'info':
                self.logger.info(msg)
            case 'error':
                self.logger.error(msg)
            case 'warn':
                self.logger.warning(msg)
        with open(result_path, "a+") as f:
            f.write("\n"+msg)

    def _update_scope(self, percentage, mode):
        signal_base_path = f'./signal_templates/signal_{percentage}_full.txt'
        signal = json_r(signal_base_path)
        del signal["command_timestamp"]
        signal["command"] = "start"
        signal["source"] = self.active_app
        signal["command_scope"] = list(
            map(int, signal["command_scope"].split(",")))
        signal["command_scope"].sort()
        # signal["stable_threshold"] = int((len(signal['command_scope'])/3)**2)*1.5
        if mode == "dsav":
            signal["stable_threshold"] = len(signal['command_scope'])*3
        elif mode == "grpc":
            signal["stable_threshold"] = len(signal['command_scope'])
        elif mode in ["passport"]:
            signal["stable_threshold"] = 10
        self.logger.info(
            f"active nodes: {signal['command_scope']}\n stable_threshold: {signal['stable_threshold']}")
        return signal

    def _ready_env(self, result_path, percentage, mode):
        # self.ready_base(True)
        # self.send_stop_signal()
        # time.sleep(5)
        msg = f"active_app: {self.active_app}, "
        msg += f"percentage: {percentage}, base_size:{self.base_node_num}"
        self._log_to_cmd_file(msg, result_path)
        return self._update_scope(percentage, mode)

    def get_valid_nodes(self, nodes):
        results = []
        for node in nodes:
            node_roles = {}
            bird_cfg = open(
                f"{self.dst_cfg_path}/{node}.conf", "r").readlines()
            for l in bird_cfg:
                if l.startswith("\tlocal role"):
                    node_roles[l.split()[-1][:-1]] = None
            if "provider" in node_roles:
                results.append(node)
            elif "peer" in node_roles:
                results.append(node)
        return results
    
    def _start_metric_monitor(self):
        """
        clear metric history and start metric monitor (a thread)
        """
        self.host_monitor_thread= threading.Thread(target=monitor_host)
        self.container_monitor_thread= threading.Thread(target=monitor_containers)
        self.container_monitor_thread.daemon = True
        self.host_monitor_thread.daemon = True
        self.container_monitor_thread_start_dt = time.time()
        self.container_monitor_thread.start()
        self.host_monitor_thread_start_dt = time.time()
        self.host_monitor_thread.start()
        self.logger.debug("monitor started")
    def _stop_metric_monitor(self):
        """our cmd will quit but new monitor thread will be created,
        we need to kill the monitor thread"""
        cmd = f"ps -aux|grep dstat|awk '{{print $2}}'|xargs kill -9"
        self.host_monitor_thread_stop_dt = time.time()
        run_cmd(cmd)
        cmd = f"ps -aux|grep 'docker stats'|awk '{{print $2}}'|xargs kill -9"
        self.container_monitor_thread_stop_dt = time.time()
        run_cmd(cmd)
        self.logger.debug("monitor stopped")
    def _get_result(self):
        """parse the file generated by dstat and docker stats"""
        ret = {"host_metric":{"start_dt":self.host_monitor_thread_start_dt,"stop_dt":self.host_monitor_thread_stop_dt}}
        ret["container_metric"] = {"start_dt":self.container_monitor_thread_start_dt,"stop_dt":self.container_monitor_thread_stop_dt}
        with open(HOST_METRIC_PATH) as f:
            ret["host_metric"]["data"] = f.read()
        with open(CONTAINER_METRIC_PATH) as f:
            ret["container_metric"]["data"] = f.read()
        return ret
    def _wait_for_all_fib_stable(self,check_interval=5):
        """
        will block until all nodes's fib is stable
        collect metric output and return a dict of results
        """
        is_all_fib_stable = False
        ret = {}
        while not is_all_fib_stable:
            is_all_fib_stable = True
            for container_id in self.active_containers:
                cmd = f"docker exec -it {container_id} curl http://localhost:8888/metric/"
                _,out,_ = run_cmd(cmd)
                try:
                    out = json.loads(out)
                    if not out["agent"]["initial_fib_stable"]:
                        is_all_fib_stable = False
                        break
                    else:
                        ret[container_id] = out
                except Exception as e:
                    is_all_fib_stable = False
                    break
            time.sleep(check_interval)
        return ret
    def _get_kernel_fib(self):
        """
        using route command(route -n -F -4) to get the kernel fib
        """
        ret = {}
        for container_id in self.active_containers:
            ret[container_id] = {}
            for v in [4,6]:
                cmd = f"docker exec -it {container_id} route -{v} -n -F"
                _,out,_ = run_cmd(cmd)
                ret[container_id][v] = out
        return ret
    def start(self,monitor_overlap_sec=10):
        """
        will monitor the host and containers during the exp
        
        """
        # for dev, stop history monitors
        self._stop_metric_monitor()
        self._start_metric_monitor()
        time.sleep(monitor_overlap_sec)
        self.ready_base(force_restart=True)
        start_dt = time.time()
        self.send_start_signal()
        agents_out = self.wait_for_all_fib_stable()
        # TODO add logic to tell when to stop
        self.send_stop_signal()
        subprocess_cmd(f"docker compose -f {self.base_compose_path} down")
        time.sleep(monitor_overlap_sec)
        self._stop_metric_monitor()
        ret = self._get_result()
        # ret["agents_metric"] = agents_out
        ret["start_signal_dt"] = start_dt
        return ret
    
    def start_dons(self,monitor_overlap_sec=10):
        """
        will monitor the host and containers during the exp
        1. wait for all fib stable
        2. randomly remove 10 links
        3. wait for all fib stable  
        """
        # for dev, stop history monitors
        self._stop_metric_monitor()
        self._start_metric_monitor()
        time.sleep(monitor_overlap_sec)
        self.ready_base(force_restart=True)
        start_dt = time.time()
        self.send_start_signal()
        agents_out = self._wait_for_all_fib_stable()
        ret["first_fib_table"] = self._get_kernel_fib()
        self.send_stop_signal()
        subprocess_cmd(f"docker compose -f {self.base_compose_path} down")
        time.sleep(monitor_overlap_sec)
        self._stop_metric_monitor()
        ret = self._get_result()
        ret["agents_metric"] = agents_out
        ret["start_signal_dt"] = start_dt
        return ret
        


class DevicePerformance():
    __cpucommand = "dstat -c --nocolor 1 2 --nocolor| sed -e '1,3d'"
    __memorycommand = "dstat -m --nocolor 1 2 --nocolor| sed -e '1,3d'"
    __diskcommand = "dstat -d --nocolor 1 2 --nocolor| sed -e '1,3d'"
    __networkcommand = "dstat -n --nocolor 1 2 --nocolor| sed -e '1,3d'"
    __hostCommand = "dstat -c -m -d -n --nocolor 1 2 --nocolor | sed -e '1,3d'"
    __dockerStatscommand = "docker stats --no-stream --format json"

    def get_cpu_performance(self):
        ret = subprocess_cmd(cmd=self.__cpucommand)
        return ret.returncode, ret.stderr, ret.stdout

    def get_memory_performace(self):
        ret = subprocess_cmd(cmd=self.__memorycommand)
        return ret.returncode, ret.stderr, ret.stdout

    def get_disk_performance(self):
        ret = subprocess_cmd(cmd=self.__diskcommand)
        return ret.returncode, ret.stderr, ret.stdout

    def get_network_performance(self):
        ret = subprocess_cmd(cmd=self.__networkcommand)
        return ret.returncode, ret.stderr, ret.stdout

    def get_host_performance(self):
        ret = subprocess_cmd(cmd=self.__hostCommand)
        return ret.returncode, ret.stderr, ret.stdout

    def get_docker_container_performance(self):
        ret = subprocess_cmd(cmd=self.__dockerStatscommand)
        return ret.returncode, ret.stderr, ret.stdout


class Monitor:
    performance = DevicePerformance()
    @staticmethod
    def host_performance():
        performance = DevicePerformance()
        performance_dict = {"CPU": {}, "memory": {}, "disk": {}, "network": {}}
        returncode, stderr, stdout = performance.get_host_performance()
        std_list = stdout.split("|")
        # CPU
        cpu_performance = std_list[0].replace("  ", " ").strip().split()
        performance_dict["CPU"] = {"usr": cpu_performance[0], "sys": cpu_performance[1], "usage": f"{100-int(cpu_performance[2])}",
                              "wai": cpu_performance[3], "stl": cpu_performance[4]}
        # memory
        memory_performance = std_list[1].strip().split()
        performance_dict["memory"] = {"used": memory_performance[0], "free": memory_performance[1], "buff": memory_performance[2], "cache": memory_performance[3]}
        # disk
        disk_performance = std_list[2].strip().split()
        performance_dict["disk"] = {"read": disk_performance[0], "writ": disk_performance[1]}
        # network
        network_performance = std_list[3].replace("\n", "").strip().split()
        performance_dict["network"] = {"recv": network_performance[0], "send": network_performance[1]}
        return performance_dict

    @staticmethod
    def container_performance():
        performance = DevicePerformance()
        performance_dict = []
        returncode, stderr, stdout = performance.get_docker_container_performance()
        for item in stdout.strip().split("\n"):
            performance_dict.append(json.loads(item))
        return performance_dict


def run(args):
    action = args.action
    performance = args.performance
    result = ""
    if action is not None:

        host_root_dir = os.path.join(args.dir)
        cfg_root_dir = os.path.join(host_root_dir, "savop_run")
        host_signal_path = os.path.join(cfg_root_dir, "active_signal.json")
        base_compose = os.path.join(cfg_root_dir, "docker-compose.yml")
        base_topo = os.path.join(cfg_root_dir,"topo.sh")
        run_emulation = RunEmulation(root_dir=host_root_dir, 
                                     host_signal_path=host_signal_path,
                                     base_compose=base_compose, 
                                     base_topo=base_topo,
                                     base_node_num=args.node_num)
        
        match action:
            case 'start':
                result = json.dumps(run_emulation.start(),indent=2)
            case 'stop':
                result = "SAVOP stop"
            case 'restart':
                result = "SAVOP restart"
            case 'start_dons':
                result = json.dumps(run_emulation.start_dons())

    if performance is not None:
        match performance:
            case 'host':
                result = Monitor.host_performance()
            case 'container':
                result = Monitor.container_performance()
            case 'all':
                result_ = {"host_performance": "", "container_performance": ""}
                result_["host_performance"] = Monitor.host_performance()
                result_["container_performance"] = Monitor.container_performance()
                result = {int(time.time()): result_}
        return json.dumps(result, indent=4)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="this scripts control SAVOP")
    operate_group = parser.add_argument_group("operate", "control the operation of SAVOP")
    operate_group.add_argument("-a", "--action", choices=["start", "stop", "restart", "start_dons"],
                        help="control SAVOP execution, only support three values: start, stop, restart and start_dons")
    operate_group.add_argument("-d", "--dir", help="directory that contains the config files")
    operate_group.add_argument("-n", "--node_num", type=int, help="the count of the running container on the slave")
    monitor_group = parser.add_argument_group("monitor", "Monitor the operational status of SAVOP")
    monitor_group.add_argument("-p", "--performance", choices=["host", "container", "all"],
                               help="monitor the performance of machines or containers")
    args = parser.parse_args()
    print(run(args=args))
