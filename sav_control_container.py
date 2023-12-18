#!/usr/bin/python3
# -*-coding:utf-8 -*-
"""
@File    :   unisav_bot.py
@Time    :   2023/09/14
@Version :   0.1
@Desc    :   The unisav_bot.py is responsible for the container 
status and metric report during the emulation process. it should be run as main process inside the container.
"""

import time
import os
import json
import subprocess
from datetime import datetime
import sqlite3
import requests
from sav_common import get_logger


class Bot():
    def __init__(self):
        self.data_path = r"/root/savop"
        self.signal_path = f"{self.data_path}/signal.json"
        self.sa_config_path = f"{self.data_path}/SavAgent_config.json"
        self.exec_results_path = f"{self.data_path}/logs/exec_results.json"
        self.last_signal = {}
        self.logger = get_logger("unisav_bot")
        self.is_monitor = False
        self.monitor_results = {}
        self.exec_result = {}
        self.stable_threshold = 30
        self.last_check_dt = 0

    def _run_cmd(self, cmd, timeout=60):
        try:
            result = subprocess.run(cmd, shell=True,
                                    capture_output=True, encoding='utf-8', timeout=timeout)
        except subprocess.TimeoutExpired:
            return 255
        return result.returncode

    def _http_request_executor(self, url_str, log=True):
        url = f"http://localhost:8888{url_str}"
        if log:
            self.logger.debug(url)
        rep = requests.get(url, timeout=30)
        if rep.status_code != 200:
            self.logger.error(f"request {url} failed")
            return rep
        return rep.text

    def _get_current_datetime_str(self):
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    def _get_max_update_timestamp(self, source):
        conn = sqlite3.connect('/root/savop/sav-agent/data/sib.sqlite')
        cursor = conn.cursor()
        source = "bar_app" if source == "BAR" else source
        query = f'SELECT strftime("%s", MAX(updatetime)) AS max_updatetime FROM STB WHERE source="{source}"'
        cursor.execute(query)
        results = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        return results

    def _get_sav_rule_number(self, source):
        conn = sqlite3.connect('/root/savop/sav-agent/data/sib.sqlite')
        cursor = conn.cursor()
        query = f'SELECT COUNT(*) FROM STB WHERE source="{source}"'
        cursor.execute(query)
        results = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        return results
    def check_signal_file(self):
        # 根据signal.json, sav_agent_config判断下一步路由器的执行动作
        # 执行动作有：start, stop, keep

        signal = self._read_json(self.signal_path)
        self.stable_threshold = signal["stable_threshold"]
        if signal == {}:
            # initial state ,stop
            return "stop"
        if signal == self.last_signal:
            return "keep"
        local_as = self._read_json(self.sa_config_path)["local_as"]
        command = signal["command"]
        if not command in ["start", "stop"]:
            raise ValueError("unknown command")
        # self.is_monitor = (local_as in signal["command_scope"])
        self.is_monitor = True
        if not self.is_monitor:
            return "keep"

        last_cmd = self.last_signal.get("command", "")
        self.logger.debug(f"last_cmd:{last_cmd} => command:{command}")
        self.last_signal = signal
        return command

    def modify_sav_config_file(self):
        """预留函数，防止将来测试不同的机制的sav协议，此时修改配置文件"""
        pass

    def monitor_sav_convergence(self):
        """功能：监控sav-agent与bird的状态，并计算sav_rule的收敛时间
        根据monitor_node字段判断是否为监控结点，非监控结点不需要打开监控功能
        根据字段action, execute_result来判断sav协议机制已经开始
        根据last_rule_num, this_rule_num, stable_number来判断sav是否收敛
        根据stable_down_count==0和stable_time确定已经收敛无效继续监控"""
        # self.logger.debug("monitor_sav_convergence")
        t0 = time.time()
        signal = self._read_json(self.signal_path)
        source = signal["source"]
        if not self.is_monitor:
            self.monitor_results = {}
            return
        exec_result = self.exec_result
        if ("judge_stable_time" in exec_result):
            # sav已经稳定，不需要继续监控
            return
        if exec_result["action"] != "start":
            return
        if exec_result["execute_result"] != "ok":
            return
        if t0-self.last_check_dt < 5:
            return  # reduce db read
        self.last_check_dt = t0
        
        last_rule_num = exec_result.get("last_rule_num", 0)
        exec_result["rule_num_check_dt"] = t0
        exec_result.update(
                    {"agent_metric": json.loads(self._http_request_executor("/metric/",False))})
        # self.logger.debug(f"agent_metric:{exec_result['agent_metric']}")
        temp = exec_result['agent_metric']["agent"].get("sav_rule_nums",{source:{"sav_rule_num":0,"update_dt":time.time()}})[source]
        new_rule_num = temp["sav_rule_num"]
        exec_result["last_rule_num"] = new_rule_num
        if new_rule_num != last_rule_num:
            exec_result.update({"rule_num_update_dt": temp["update_dt"]})
            self.logger.debug(f"new_rule_num for {source}: {new_rule_num}")
            self.exec_result = exec_result
            return
        if new_rule_num == 0:
            return
        time_diff = exec_result["rule_num_check_dt"] - \
            exec_result["rule_num_update_dt"]
        if time_diff > self.stable_threshold:
            exec_result["judge_stable_time"] = self._get_current_datetime_str()
            exec_result["convergence_duration"] = exec_result[
                "rule_num_update_dt"] - exec_result["cmd_exe_dt"]
            exec_result["stable_threshold"] = self.stable_threshold
            sav_start_time = exec_result["cmd_exe_dt"]
            with open(f"{self.data_path}/logs/server.log", "r") as f:
                lines = f.readlines()
                for line in lines:
                    if "FIB STABILIZED" in line:
                        fib_stable_dt = float(line.split("at ")[-1])
                        break
            if not fib_stable_dt:
                self.logger.warning("fib not stabled")
            exec_result["fib_stable_time"] = fib_stable_dt - sav_start_time
            
            # try:
            #     self._http_request_executor(
            #         url_str=f"/refresh_proto/{source}/")
            # except Exception as e:
            #     self.logger.exception(e)
            exec_result["sav_last_update_dt"] = self._get_max_update_timestamp(
                source)
            with open(f"{self.data_path}/logs/sav_table.json", "w") as f:
                f.write(self._http_request_executor(url_str="/sav_table/"))
            self._write_json(self.exec_results_path, exec_result)
            
        else:
            exec_result.update({"stable_down_count": 10})
            exec_result.update({"source": source})
            exec_result.update(
                {"monitor_cycle_start_dt": time.time()})

    def _write_json(self, file_path, data):
        json.dump(data, open(file_path, "w", encoding="utf-8"), indent=2)

    def _read_json(self, file_path):
        if not os.path.exists(file_path):
            self.logger.warning(
                f"{file_path} not exists, return default value")
            return {}
        return json.load(open(file_path, "r", encoding="utf-8"))

    def stop_server(self, action):
        signal = self._read_json(self.signal_path)
        exec_result = self.exec_result
        exec_result.update({"command": f'{signal["command"]}_{time.time()}',
                            "execute_start_time": f"{self._get_current_datetime_str()}",
                            "cmd_exe_dt": time.time(),
                            "action": action})
        result = self._run_cmd("iptables -F SAVAGENT")
        result = self._run_cmd(
            "bash /root/savop/router_kill_and_start.sh stop")
        if result == 0:
            exec_result.update({"execute_end_time": f"{self._get_current_datetime_str()}",
                                "execute_result": "ok"})
        else:
            exec_result.update({"execute_end_time": f"{self._get_current_datetime_str()}",
                                "execute_result": "fail"})
        self.exec_result = exec_result
        self._write_json(self.exec_results_path, exec_result)

    def start_server(self, action):
        signal = self._read_json(self.signal_path)

        # exec_result = self._read_json(self.exec_results_path)\
        exec_result = {}
        # 动态更改sav-agent的配置文件

        sav_agent_config = self._read_json(self.sa_config_path)
        source = signal["source"]
        if source in ["rpdp_app"]:
            sav_agent_config["apps"] = [source]
        elif source == "fpurpf_app":
            sav_agent_config["apps"] = ["rpdp_app", "FP-uRPF"]
        elif source == "strict_urpf_app":
            sav_agent_config["apps"] = ["strict-uRPF"]
        elif source == "loose_urpf_app":
            sav_agent_config["apps"] = ["loose-uRPF"]
        elif source == "EFP-uRPF-Algorithm-A_app":
            sav_agent_config["apps"] = ["rpdp_app", "EFP-uRPF-A"]
        elif source == "EFP-uRPF-Algorithm-B_app":
            sav_agent_config["apps"] = ["rpdp_app", "EFP-uRPF-B"]
        elif source == "passport":
            sav_agent_config["apps"] = ["passport"]
        elif source == "bar_app":
            sav_agent_config["apps"] = ["bar_app"]
        else:
            self.logger.error(f"unknown source {source}")
            raise ValueError("unknown source")
        self._write_json(self.sa_config_path, sav_agent_config)
        exec_result.update({"command": f'{signal["command"]}_{time.time()}',
                            "execute_start_time": f"{self._get_current_datetime_str()}",
                            "cmd_exe_dt": time.time(),
                            "action": action})
        result = os.system(
            "bash /root/savop/router_kill_and_start.sh start")
        if result == 0:
            exec_result.update({"execute_end_time": f"{self._get_current_datetime_str()}",
                                "execute_result": "ok",
                                "stable_down_count": 10
                                })
        else:
            exec_result.update({"execute_end_time": f"{self._get_current_datetime_str()}",
                                "execute_result": "fail"})
        self.exec_result = exec_result
        self._write_json(self.exec_results_path, exec_result)

    def run(self):
        # 循环，监控配置文件与sav数据库的转态
        # self.logger.debug("unisav_bot start")
        while True:
            time.sleep(0.1)
            try:
                action = self.check_signal_file()
                if action == "start":
                    self.start_server(action=action)
                elif action == "stop":
                    self.stop_server(action=action)
                elif action == "keep":
                    if self.is_monitor:
                        self.monitor_sav_convergence()
                else:
                    self.logger.error(f"unknown action {action}")
            except Exception as e:
                continue


if __name__ == "__main__":
    a = Bot()
    a.run()
