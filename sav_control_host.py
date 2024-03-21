#!/usr/bin/python3
# -*-coding:utf-8 -*-
"""
@File    :   sav_control_host.py
@Time    :   2023/11/30
@Version :   0.1
@Desc    :   The sav_control_host.py is responsible for the management of current host(slave).
"""
import json

from sav_control_common import *
import argparse
import threading
import os


SAV_OP_DIR = os.path.dirname(os.path.abspath(__file__))
SAV_ROOT_DIR = os.path.dirname(SAV_OP_DIR)
SAV_RUN_DIR = os.path.join(SAV_ROOT_DIR, "savop_run")
HOST_METRIC_PATH = "./host_metric.txt"
CONTAINER_METRIC_PATH = "./containers_metric.json"


def monitor_host(stat_out_file=HOST_METRIC_PATH) -> None:
    """
    monitor resource usage of the host
    the default interval is one second
    """
    if os.path.exists(stat_out_file):
        os.unlink(stat_out_file)
    cmd = f"dstat -f -m -a --bits --nocolor>{stat_out_file}"
    run_cmd(cmd, 1)


def monitor_containers(stat_out_file=CONTAINER_METRIC_PATH) -> None:
    if os.path.exists(stat_out_file):
        os.unlink(stat_out_file)
    cmd = f"docker stats -a --format json>{stat_out_file}"
    run_cmd(cmd)


def parse_dstat_file(file_path) -> None:
    """
    parse dstat file
    """
    # raise NotImplementedError
    with open(file_path) as f:
        lines = f.readlines()
    headers = lines[0].strip().split("|")
    # print(headers)
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
                 base_topo="./savop/topology/topo_50.sh", base_node_num=50) -> None:
        self._id = whoami()
        if not self._id:
            raise ValueError("get id error")
        self.logger = get_logger(self._id)
        self.root_dir = root_dir
        self.host_signal_path = host_signal_path
        self.base_compose_path = base_compose
        self.ca_compose_path = os.path.dirname(self.base_compose_path)
        self.ca_compose_path = os.path.join(
            self.ca_compose_path, CA_COMPOSE_FILE)
        self.base_topo = base_topo
        self.base_node_num = base_node_num
        self.active_app = None
        self.docker_client = docker.DockerClient.from_env()
        self._system_check()

    def _system_check(self) -> None:
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
                self.logger.exception(e)
                pass

    def _run_cmd_in_container(self, container_id, cmd, timeout=60):
        container = self.docker_client.containers.get(container_id)
        return container.exec_run(cmd, timeout=timeout)

    def if_base_started(self):
        """
        tell if base started
        """
        dev_count = 0
        krill_count = 0
        self.active_containers = set()
        self.device_containers = []
        containers = self.docker_client.containers.list()

        for container in containers:
            tag = container.image.tags
            if not len(tag) == 1:
                continue
            tag = tag[0]
            if "savop_bird_base" in tag:
                dev_count += 1
                self.active_containers.add(container.name)
                self.device_containers.append(container)
                continue
            if "krill" in tag:
                krill_count += 1
                self.active_containers.add(container.name)
        if dev_count != self.base_node_num:
            self.logger.info(
                f"node count error, should be {self.base_node_num}, but {dev_count}")
            return False
        rpki = False
        if rpki:
            return krill_count == 1
        else:
            return True

    def send_stop_signal(self) -> None:
        """stop sav-agent and bird on all nodes"""
        data = json_r(self.host_signal_path)
        data["command"] = "stop"
        json_w(self.host_signal_path, data)
        self.logger.info("stop signal sent")

    def send_start_signal(self) -> None:
        """start sav-agent and bird on all nodes"""
        data = json_r(self.host_signal_path)
        data["command"] = "start"
        json_w(self.host_signal_path, data)
        self.logger.info("start signal sent")

    def clear_logs(self):
        """
        clear log folders, should be called in start base function
        """
        path = SAV_RUN_DIR
        if not os.path.exists(SAV_RUN_DIR):
            os.mkdir(SAV_RUN_DIR)
        folders = os.listdir(SAV_RUN_DIR)
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

    def _stop_base(self) -> None:
        """
        stop and remove all containers
        """
        t0 = time.time()
        # stop all containers' image is savop_bird_base
        count = 0
        for container in self.docker_client.containers.list():
            tag = container.image.tags
            if not len(tag) == 1:
                continue
            tag = tag[0]
            container.remove(force=True)
            count += 1
        t1 = time.time()
        self.logger.info(
            f"{count} containers removed in {t1-t0:.4f} seconds")

    def _start_base(self) -> None:
        """
        start the base (node compose and rpki compose)
        """
        t0 = time.time()
        if os.path.exists(self.ca_compose_path):
            run_cmd(f"docker compose -f {self.ca_compose_path} up -d")
            ca_ready = False
            while not ca_ready:
                time.sleep(1)
                try:
                    ret_code, std, err = run_cmd(
                        f"docker exec -it ca cat /root/still_adding", 0, capture_output=True)
                    if "done" in std:
                        ca_ready = True
                except Exception as e:
                    time.sleep(1)
            t1 = time.time()
            self.logger.info(f"rpki started in {t1-t0:.4f} seconds")
        t1 = time.time()
        subprocess_cmd(
            f"docker compose -f {self.base_compose_path} up -d", None)
        t2 = time.time()
        self.logger.info(
            f"{self.base_compose_path} started in {t2-t1:.4f} seconds")

    def _ready_base(self, force_restart=False, build_image=False) -> None:
        """
        1. stop containers
        2. rebuild/recompile if needed
        3. start containers
        4. add links
        """
        if self.if_base_started() and not force_restart:
            self.logger.info("base already started")
            return
        self.logger.info(f"init base with {self.base_compose_path}")
        t = time.time()
        self._stop_base()

        # if build_image:
        # # TODO not working
        #     self.logger.debug("build image")
        #     tag = SAV_REF_IMG_TAG
        #     for img in self.docker_client.images.list():
        #         if tag in img.tags:
        #             self.docker_client.images.remove(img.id, force=True)
        #     docker_file_path = f"{self.root_dir}/savop/dockerfiles/reference_router"
        #     try:
        #         os.chdir(SAV_ROOT_DIR)
        #         cmd = f"docker build -f {docker_file_path} . -t {tag} --no-cache"
        #         self.logger.debug
        #         run_cmd(cmd)
        #         # img, build_log = self.docker_client.images.build(path={self.root_dir},
        #                 # fileobj=open(docker_file_path, "r"), tag=tag, nocache=True, buildargs={"root_dir": self.root_dir})

        #     except Exception as e:
        #         self.logger.exception(e)
        #         sys.exit(1)
        self._start_base()
        t1 = time.time()
        run_cmd(f"bash {self.base_topo}")
        t2 = time.time()
        log_str = f"link started in {t2-t1:.4f} seconds"
        self.logger.info(log_str)

        t = time.time() - t
        self.logger.info(f"base start finished in {t:.4f} seconds")
        if self.if_base_started():
            self.logger.info("base ready")
        else:
            self.logger.error("base start failed")
            sys.exit(1)

    def update_configs(self, nodes, proto) -> None:
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
            self.logger.debug(self.dst_cfg_path)
            json_w(f"{self.dst_cfg_path}/{n}.json", sa_cfg)
            # self.logger.info(f"active_app:{self.active_app} config updated")
        # waits the configs to be updated in containers
        time.sleep(len(nodes)/30)

    def _log_to_cmd_file(self, msg, result_path, log_level='info'):
        if not log_level in ['info', 'error', 'warn']:
            raise ValueError(
                f"log_level should be info, error or warn: {log_level}")
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
        elif mode in ["Passport"]:
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
        self.host_monitor_thread = threading.Thread(target=monitor_host)
        self.container_monitor_thread = threading.Thread(
            target=monitor_containers)
        self.container_monitor_thread.daemon = True
        self.host_monitor_thread.daemon = True
        self.container_monitor_thread_start_dt = time.time()
        self.container_monitor_thread.start()
        self.host_monitor_thread_start_dt = time.time()
        self.host_monitor_thread.start()
        self.logger.info("monitor started")
        return

    def _stop_metric_monitor(self):
        """our cmd will quit but new monitor thread will be created,
        we need to kill the monitor thread"""
        cmd = f"ps -aux|grep dstat|awk '{{print $2}}'|xargs kill -9"
        self.host_monitor_thread_stop_dt = time.time()
        run_cmd(cmd)
        cmd = f"ps -aux|grep 'docker stats'|awk '{{print $2}}'|xargs kill -9"
        self.container_monitor_thread_stop_dt = time.time()
        run_cmd(cmd)
        self.logger.info("monitor stopped")

    def _get_result(self):
        """parse the file generated by dstat and docker stats"""
        # ret = {"host_metric": {"start_dt": self.host_monitor_thread_start_dt,
        #                        "stop_dt": self.host_monitor_thread_stop_dt}}
        # ret["container_metric"] = {
        #     "start_dt": self.container_monitor_thread_start_dt, "stop_dt": self.container_monitor_thread_stop_dt}
        # with open(HOST_METRIC_PATH) as f:
        #     ret["host_metric"]["data"] = f.read()
        # with open(CONTAINER_METRIC_PATH) as f:
        #     ret["container_metric"]["data"] = f.read()
        ret = {}
        ret["errors"] = self._count_errors_in_log()
        return ret

    def _wait_for_initial_fib_stable(self, check_interval=5, containers_to_go=None):
        """
        will block until all nodes's fib is stable
        collect metric output and return a dict of results
        """
        ret = {}
        t0 = time.time()

        if containers_to_go is None:
            containers_to_go = list(self.active_containers)
        while len(containers_to_go) > 0:
            time.sleep(check_interval)
            self.logger.debug(
                f"{len(containers_to_go)} containers to go: {containers_to_go}")
            new_containers_to_go = []
            for container_id in containers_to_go:
                out = self._get_container_metric(
                    container_id, f"{containers_to_go.index(container_id)}/{len(containers_to_go)}", timeout=10)
                if out is None:
                    new_containers_to_go.append(container_id)
                    continue
                if out["initial_fib_stable"]:
                    ret[container_id] = out["initial_fib_stable_dt"] - t0
                else:
                    new_containers_to_go.append(container_id)
            containers_to_go = new_containers_to_go

        return ret

    def _get_container_metric2(self, container_id):
        exec_result = json_r(f"{SAV_RUN_DIR}/{container_id}/exec_result.json")
        if exec_result["status"] == "error":
            return None

    def _container_curl(self, container, url_path, connect_timeout=2, transfer_timeout=5, raw=False):
        """
        execute f"docker exec -it {container.id} curl http://localhost:8888/{url_path} 
        --connect-timeout {connect_timeout} -m {transfer_timeout}"
        and return the json response
        """
        default = {}
        if raw:
            default = "{}"
        if container.status != "running":
            self.logger.warning(f"{container.id} not running")
            return default
        cmd = f"docker exec -it {container.id} "
        cmd += f"curl http://localhost:8888/{url_path} "
        cmd += f"--connect-timeout {connect_timeout} -m {transfer_timeout}"
        ret_code, ret_str, ret_err = run_cmd(cmd, capture_output=True)
        try:
            if raw:
                return ret_str
            return json.loads(ret_str)
        except Exception as e:
            # self.logger.debug(cmd)
            # self.logger.debug(ret_code)
            # self.logger.debug(ret_str)
            # self.logger.debug(ret_err)
            # self.logger.exception(e)
            return default

    def _get_container_metric(self, container_id, extra_str, timeout=10):
        """
        return None if error
        return agent of metric if success
        """
        cmd = "curl http://localhost:8888/metric/ --connect-timeout 2 -m 5"
        try:
            cmd = f"docker exec -it {container_id} {cmd}"
            _, response, _ = run_cmd(cmd, timeout=timeout)
            # container = self.docker_client.containers.get(container_id)
            # response = container.exec_run(cmd).output
            # response = response[response.index("{"):]
            # self.logger.debug(response)
            return json.loads(response)["agent"]
        except Exception as e:
            # self.logger.exception(e)
            # self.logger.debug(f"{cmd}  {extra_str}")
            return None

    def _wait_for_fib_stable(self, initial_wait, check_interval=5, containers_to_go=None):
        ret = {}
        t0 = time.time()
        time.sleep(initial_wait)
        if containers_to_go is None:
            containers_to_go = list(self.active_containers)
        while len(containers_to_go) > 0:
            self.logger.debug(
                f"{len(containers_to_go)} containers to go: {containers_to_go}")
            new_containers_to_go = []
            for container_id in containers_to_go:
                out = self._get_container_metric(
                    container_id, f"{containers_to_go.index(container_id)}/{len(containers_to_go)}", timeout=10)
                if out is None:
                    new_containers_to_go.append(container_id)
                    continue
                if out["is_fib_stable"]:
                    if out["initial_fib_stable_dt"] != out["last_fib_stable_dt"]:
                        ret[container_id] = out["last_fib_stable_dt"] - t0
                else:
                    new_containers_to_go.append(container_id)
            containers_to_go = new_containers_to_go
            time.sleep(check_interval)
        return ret

    def _get_kernel_fib(self):
        """
        using route command(route -n -F -4) to get the kernel fib
        """
        ret = {}
        for container_id in self.active_containers:
            ret[container_id] = {}
            for v in [4, 6]:
                cmd = f"docker exec -it {container_id} route -{v} -n -F"
                _, out, _ = run_cmd(cmd)
                ret[container_id][v] = out
        return ret

    def start(self, monitor_overlap_sec=10):
        """
        start the containers

        """
        self._ready_base(force_restart=True, build_image=True)
        self.send_start_signal()

    def _remove_top_n_links(self, n):
        """
        remove "top" n links from current running containers
        return  a dict of removed links
        """
        removed_links = {}
        count = 0
        for container_id in self.active_containers:
            cmd = f"docker exec -it {container_id} ifconfig | grep 'eth_' | awk '{{print $1}}'"
            _, eths, _ = run_cmd(cmd)
            eths = eths.split()
            eths = sorted(eths)
            for eth in eths:
                eth = eth[:-1]  # tailing :
                try:
                    removed_links[container_id][eth]
                    continue
                except KeyError:
                    peer_container_id = 'r'+eth.split("_")[1]
                    peer_eth = f"eth_{container_id[1:]}"
                    cmd = f"docker exec -it {container_id} ifconfig {eth} down"
                    run_cmd(cmd)
                    cmd = f"docker exec -it {peer_container_id} ifconfig {peer_eth} down"
                    run_cmd(cmd)
                    if not container_id in removed_links:
                        removed_links[container_id] = {}
                    if not peer_container_id in removed_links:
                        removed_links[peer_container_id] = {}
                    removed_links[container_id][eth] = None
                    removed_links[peer_container_id][peer_eth] = None
                    count += 1
                    if count == n:
                        return removed_links

    def _count_errors_in_log(self):
        """
        count the graceful restart error from log files
        """
        items = os.listdir(SAV_RUN_DIR)
        items = [i for i in items if os.path.isdir(
            os.path.join(SAV_RUN_DIR, i))]
        items = [i for i in items if i.isdigit()]
        results = {}
        count = 0
        for router_folder in items:
            bird_log = os.path.join(
                SAV_RUN_DIR, router_folder, "log", "bird.log")
            if not os.path.exists(bird_log):
                bird_log = bird_log.replace("bird.log", "bird-original.log")
            with open(bird_log, "r") as f:
                d = f.read()
                results[router_folder] = d.count("graceful restart detected")
                count += results[router_folder]
        if count/self.base_node_num > 3:
            self.logger.warning(
                f"too many graceful restart detected: {count}/{self.base_node_num} \
                consider increace the graceful restart shreshold")
        return count

    def original_bird_error(self, keep_time=60):
        """
        keep the containers for keep_time and check the errors
        """
        self._stop_metric_monitor()
        self._ready_base(force_restart=True)
        start_dt = time.time()
        self.send_start_signal()
        time.sleep(keep_time)
        self._stop_base()
        ret = self._get_result()
        ret['keep_time'] = keep_time
        ret["start_signal_dt"] = start_dt
        return ret

    def restart_agent_in_container(self, container_id=None):
        """
        restart agent in container
        if container_id is None, restart agent in all containers
        """
        if container_id is None:
            containers_to_go = self.docker_client.containers.list()
        else:
            containers_to_go = [
                self.docker_client.containers.get(container_id)]
        for container in containers_to_go:
            if container.status != "running":
                self.logger.warning(f"{container_id} not running")
                continue
            t1 = time.time()
            self.logger.debug(f" restarting {container}")
            cmd = f"bash /root/savop/router_kill_and_start.sh start"
            container.exec_run(cmd)
            t2 = time.time()
            self.logger.debug(f"{container} started in {t2-t1:.4f} seconds")
            self.logger.debug(f"{container} restarted")

    def _wait_valid_sav_table(self, check_interval=5):
        containers_to_go = self.device_containers
        time.sleep(10)
        while len(containers_to_go) > 0:
            temp = []
            for c in containers_to_go:
                if c.status != "running":
                    continue
                ret = self._container_curl(c, "sav_table/",raw = True)
                if not (ret.startswith("{") and ret.endswith("}") and len(ret) > 3):
                    temp.append(c)
                else:
                    # self.logger.debug(f"{c.name} sav table ready! {ret}")
                    self.logger.debug(f"{c.name} sav table ready!")
            containers_to_go = temp
            time.sleep(check_interval)
        for c in self.device_containers:
            self._container_curl(c, "save_sav_table/", raw=True)
            self.logger.debug(f"{c.name} sav table saved")

    def _remove_prefix_in_container(self, container_name, prefix_index) -> None:
        """
        1. modify the bird config
        2. restart bird
        """
        # modify the bird config
        container_dir = f"{SAV_RUN_DIR}/{container_name.replace('r', '')}"
        bird_cfg_path = f"{container_dir}/bird.conf"
        data = open(bird_cfg_path, "r").readlines()
        with open(bird_cfg_path, "w") as f:
            index = 0
            for line in data:
                if line.startswith(f"  route"):
                    if index == prefix_index:
                        continue
                    index += 1
                f.write(line+'\n')
        if index < prefix_index:
            raise ValueError(f"prefix_index {prefix_index} is too large")
        self.logger.debug("reconfiguring")
        run_cmd(f"docker exec -it {container_name} birdc configure")

    def dev_test(self) -> None:
        """
        dev test
        """
        self.logger.debug("dev test")
        self._ready_base(force_restart=True, build_image=True)
        self.send_start_signal()
        self._wait_valid_sav_table()
        t = 1
        self.logger.info(f"will del prefixes in {t} seconds")
        time.sleep(t)
        self._remove_prefix_in_container('r1', 0)
        time.sleep(600)
        self._stop_base()

    def fib_stable(self, monitor_overlap_sec=10, if_monitor=False):
        """
        will monitor the host and containers during the exp if if_monitor is True
        1. wait for all fib stable
        3. wait for all fib stable  
        """
        # for dev, stop history monitors
        # self.logger.debug(self.base_topo)

        self._stop_metric_monitor()
        if if_monitor:
            self._start_metric_monitor()
            time.sleep(monitor_overlap_sec)
        self._ready_base(force_restart=True)
        start_dt = time.time()
        self.send_start_signal()
        # wait for all fib stable
        check_interval = 30
        initial_fib_stable = self._wait_for_initial_fib_stable(check_interval)
        # randomly remove 10 links
        # self._remove_top_n_links(10)
        # fib_stable = self._wait_for_fib_stable(check_interval)
        # fib_table_data = self._get_kernel_fib()
        self.send_stop_signal()
        subprocess_cmd(
            f"docker compose -f {self.base_compose_path} down", None)
        if if_monitor:
            time.sleep(monitor_overlap_sec)
            self._stop_metric_monitor()

        ret = self._get_result()
        ret["start_signal_dt"] = start_dt
        ret["initial_fib_stable"] = initial_fib_stable
        ret['max_initial_fib_stable'] = max(initial_fib_stable.values())
        return ret


class DevicePerformance():
    __cpucommand = "dstat -c --nocolor 1 2 --nocolor| sed -e '1,3d'"
    __memorycommand = "dstat -m --nocolor 1 2 --nocolor| sed -e '1,3d'"
    __diskcommand = "dstat -d --nocolor 1 2 --nocolor| sed -e '1,3d'"
    __networkcommand = "dstat -n --nocolor 1 2 --nocolor| sed -e '1,3d'"
    __hostCommand = "dstat -c -m -d -n --nocolor 1 2 --nocolor | sed -e '1,3d'"
    __dockerStatscommand = "docker stats --no-stream --format json"

    def get_cpu_performance(self):
        ret = subprocess_cmd(cmd=self.__cpucommand,
                             timeout=None, capture_output=True)
        return ret.returncode, ret.stderr, ret.stdout

    def get_memory_performace(self):
        ret = subprocess_cmd(cmd=self.__memorycommand,
                             timeout=None, capture_output=True)
        return ret.returncode, ret.stderr, ret.stdout

    def get_disk_performance(self):
        ret = subprocess_cmd(cmd=self.__diskcommand,
                             timeout=None, capture_output=True)
        return ret.returncode, ret.stderr, ret.stdout

    def get_network_performance(self):
        ret = subprocess_cmd(cmd=self.__networkcommand,
                             timeout=None, capture_output=True)
        return ret.returncode, ret.stderr, ret.stdout

    def get_host_performance(self):
        ret = subprocess_cmd(cmd=self.__hostCommand,
                             timeout=None, capture_output=True)
        return ret.returncode, ret.stderr, ret.stdout

    def get_docker_container_performance(self):
        ret = subprocess_cmd(cmd=self.__dockerStatscommand,
                             timeout=None, capture_output=True)
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
        performance_dict["memory"] = {"used": memory_performance[0], "free": memory_performance[1],
                                      "buff": memory_performance[2], "cache": memory_performance[3]}
        # disk
        disk_performance = std_list[2].strip().split()
        performance_dict["disk"] = {
            "read": disk_performance[0], "writ": disk_performance[1]}
        # network
        network_performance = std_list[3].replace("\n", "").strip().split()
        performance_dict["network"] = {
            "recv": network_performance[0], "send": network_performance[1]}
        return performance_dict

    @staticmethod
    def container_performance():
        performance = DevicePerformance()
        performance_dict = []
        returncode, stderr, stdout = performance.get_docker_container_performance()
        if len(stdout) == 0:
            return performance_dict
        for item in stdout.strip().split("\n"):
            performance_dict.append(json.loads(item))
        return performance_dict

    @staticmethod
    def protocol_step():
        step = {}
        folders = [f for f in os.listdir(SAV_RUN_DIR) if os.path.isdir(
            os.path.join(SAV_RUN_DIR, f))]
        for f in folders:
            step.update({f: []})
            f_log_path = os.path.join(f, "log")
            cmd = f"grep LOG_FOR_FRONT {SAV_RUN_DIR}/{f_log_path}/sav-agent.log |awk -F\"LOG_FOR_FRONT\" '{{print $2}}'|grep SPA|grep -E \"'msg_cause': 'receive'|'msg_cause': 'relay'\""
            returncode, stdout, stderr = run_cmd(cmd=cmd, capture_output=True)
            for i in stdout.replace("\'", "\"").split("\n"):
                if len(i) < 10:
                    continue
                step[f].append(json.loads(i))
            cmd = f"grep LOG_FOR_FRONT {SAV_RUN_DIR}/{f_log_path}/sav-agent.log |awk -F\"LOG_FOR_FRONT\" '{{print $2}}'|grep SPD| sed \"s/'/\\\"/g\"|grep -E '\"msg_cause\": \"origin\"|\"msg_cause\": \"relay\"'| jq -s 'unique_by(.src_ip, .dst_ip, .msg_cause, .link_name)'"
            returncode, stdout, stderr = run_cmd(cmd=cmd, capture_output=True)
            step[f].extend(json.loads(stdout))
        return json.dumps(step)

    @staticmethod
    def protocol_metric():
        metric = []
        cmd = "docker ps |grep -v NAMES|awk '{ print $NF }'"
        returncode, stdout, stderr = run_cmd(cmd=cmd, capture_output=True)
        for container_name in stdout.split("\n")[:-1]:
            cmd = f"docker exec -i {container_name} curl http://localhost:8888/metric/"
            returncode, stdout, stderr = run_cmd(cmd=cmd, capture_output=True)
            metric.append({container_name: json.loads(stdout)})
        return json.dumps(metric)

    @staticmethod
    def protocol_table():
        table = []
        cmd = "docker ps |grep -v NAMES|awk '{ print $NF }'"
        returncode, stdout, stderr = run_cmd(cmd=cmd, capture_output=True)
        for container_name in stdout.split("\n")[:-1]:
            cmd = f"docker exec -i {container_name} curl http://localhost:8888/sav_table/"
            returncode, stdout, stderr = run_cmd(cmd=cmd, capture_output=True)
            table.append({container_name: json.loads(stdout.replace("IPNetwork(", "").replace(
                ")", "").replace("\'", "\"").replace("True", "\"True\"").replace("False", "\"False\"").replace("IPAddress(", ""))})
        return json.dumps(table)

    @staticmethod
    def enable_sav_table(protocol_name, router):
        result = []
        cmd = "docker ps |grep -v NAMES|awk '{ print $NF }'"
        returncode, stdout, stderr = run_cmd(cmd=cmd, capture_output=True)
        router_scope = router.split(",")
        for container_name in stdout.split("\n")[:-1]:
            if container_name not in router_scope:
                continue
            cmd = f"docker exec -i {container_name} curl http://localhost:8888/refresh_proto/{protocol_name}/"
            returncode, stdout, stderr = run_cmd(cmd=cmd, capture_output=True)
            result.append({container_name:json.loads(stdout)})
        return json.dumps(result)


def run(args):
    action = args.action
    performance = args.performance
    step = args.step
    metric = args.metric
    table = args.table
    enable = args.enable
    router = args.router
    node_num = get_container_node_num(SAV_RUN_DIR)
    result = ""
    if action is not None:
        host_root_dir = os.path.join(SAV_ROOT_DIR)
        cfg_root_dir = os.path.join(host_root_dir, "savop_run")
        host_signal_path = os.path.join(cfg_root_dir, "active_signal.json")
        base_compose = os.path.join(cfg_root_dir, DEVICE_COMPOSE_FILE)

        base_topo = os.path.join(cfg_root_dir, "topo.sh")
        run_emulation = RunEmulation(root_dir=host_root_dir,
                                     host_signal_path=host_signal_path,
                                     base_compose=base_compose,
                                     base_topo=base_topo,
                                     base_node_num=node_num)
        match action:
            case 'start':
                run_emulation.start()
            case 'stop':
                result = "SAVOP stop"
            case 'restart':
                run_emulation.restart_agent_in_container()
                result = "SAVOP restart"
            case 'fib_stable':
                result = json.dumps(run_emulation.fib_stable())
            case 'start_original_bird':
                result = json.dumps(run_emulation.original_bird_error())
            case 'dev_test':
                result = json.dumps(run_emulation.dev_test())

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
        return json.dumps(result)

    if step is not None:
        result = Monitor.protocol_step()

    if metric is not None:
        result = Monitor.protocol_metric()

    if table is not None:
        result = Monitor.protocol_table()

    if enable is not None:
        if router is None:
            return {"error": "the router name cannot be empty"}
        result = Monitor.enable_sav_table(protocol_name=enable, router=router)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="this scripts control SAVOP")
    operate_group = parser.add_argument_group("operate control the operation of SAVOP",
                                              "control SAVOP execution, only support three values: start, stop and restart")
    operate_group.add_argument("-a", "--action", choices=["start", "stop", "restart", "start_original_bird", "fib_stable", "dev_test"],
                               help="control SAVOP execution, only support three values: start, stop, restart ,fib_stable and start_original_bird")
    monitor_group = parser.add_argument_group("monitor", "Monitor the operational status of SAVOP")
    monitor_group.add_argument("-p", "--performance", choices=["host", "container", "all"],
                               help="monitor the performance of machines or containers")
    monitor_group.add_argument("--step", help="the protocol process of sending packets")
    monitor_group.add_argument("--metric", help="the protocol performance metrics")
    monitor_group.add_argument("--table", help="the protocol table")
    data_plane_control_group = parser.add_argument_group("data_plane_control",
                                                         "Enable data plane control for the sav_table rule")
    data_plane_control_group.add_argument("--enable",
                                          choices=["strict_urpf", "rpdp", "loose_urpf", "efp_urpf_a", "efp_urpf_b","fp_urpf"],
                                          help="enable sav_table rule")
    data_plane_control_group.add_argument("--router", help="the enable scope")
    args = parser.parse_args()
    print(run(args=args))
