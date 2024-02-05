#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
1. recompile bird
2. rebuild docker images
3. regenerate config files
4. regenerate keys
5. regenerate compose.yml and topo.sh for the given node and links
"""
import os
import time
import subprocess
import json
import netaddr
import copy
import platform
from sav_control_common import *


def tell_prefix_version(prefix):
    """
    use . and : to tell if prefix is ipv4 or ipv6
    """
    if "." in prefix:
        return 4
    if ":" in prefix:
        return 6
    raise ValueError(f"invalid prefix :prefix")


class IPGenerator():
    def __init__(self, base_ip):
        self.set_ip(base_ip)
        self.first_ip = copy.deepcopy(self.ip)
        self.last_ip = self.ip

    def get_new_ip_pair(self):
        src = copy.deepcopy(self.ip)
        dst = src + 1
        if self.ip.version == 4:
            self.ip += 256
            self.last_ip = self.ip
        elif self.ip.version == 6:
            self.ip += 65536
            self.last_ip = self.ip
        return src, dst

    def set_ip(self, ip):
        self.ip = netaddr.IPAddress(ip)
        self.last_ip = self.ip

    def get_range(self):
        ip_version = self.ip.version
        if ip_version == 4:
            prefix_len = 32
        elif ip_version == 6:
            prefix_len = 128
        ip_network = netaddr.IPNetwork(f"{self.first_ip}/{prefix_len}")
    # Expand the IPNetwork to cover the last IP address
        while not self.last_ip in ip_network:
            prefix_len -= 1
            ip_network = netaddr.IPNetwork(f"{self.first_ip}/{prefix_len}")
        return ip_network


def recompile_bird(path=r'{host_dir}/sav-reference-router', logger=None):
    # return
    print("step: recompile bird")
    os.chdir(path)
    run_cmd("autoreconf")
    run_cmd("./configure")
    run_cmd("make")
    if logger:
        logger.info("recompile bird")
    else:
        print("recompile bird")


def rebuild_img(
        path=r'{host_dir}',
        file="docker_file_update_bird_bin",
        tag="savop_bird_base",
        logger=None):
    """
    build docker image
    rebuild docker image without any tag
    """
    if logger:
        logger.info("rebuild docker image")
    else:
        print("rebuild docker image")
    os.chdir(path)
    cmd = f"docker build -f {file} . -t {tag} --no-cache"
    run_cmd(cmd)
    cmd = "docker images| grep 'none' | awk '{print $3}' | xargs docker rmi"
    run_cmd(cmd)


def gen_bird_conf(node, delay, mode, base,
                  enable_rpdp, roa_json, aspa_json):
    """
    add everything but actual bgp links
    """
    # raise ValueError(base)

    auto_ip_version = base["auto_ip_version"]
    all_nodes = base["devices"]
    dev_id = node["device_id"]
    dev_as = node["as"]
    router_id = base["as_scope"][dev_as][dev_id]["router_id"]
    enable_rpki = base["enable_rpki"]
    bird_conf_str = f"router id {str(netaddr.IPAddress(router_id))};"
    bird_conf_str += "\nipv4 table master4 {sorted 1;};\n" \
                     "ipv6 table master6 {sorted 1;};\n" \
                     "protocol device {\n" \
                     "  scan time 60;\n" \
                     "  interface \"eth_*\";\n" \
                     "};\n" \
                     "protocol kernel {\n" \
                     "  scan time 60;\n" \
                     "  ipv4 {\n" \
                     "    export all;\n" \
                     "    import all;\n" \
                     "  };\n" \
                     "  learn;\n" \
                     "};\n" \
                     "protocol kernel {\n" \
                     "  scan time 60;\n" \
                     "  ipv6 {\n" \
                     "    export all;\n" \
                     "    import all;\n" \
                     "  };\n" \
                     "  learn;\n" \
                     "};\n" \
                     "protocol direct {\n" \
                     "  ipv4;\n" \
                     "  ipv6;\n" \
                     "  interface \"eth_*\";\n" \
                     "};\n"
    try:
        v = tell_prefix_version(list(node["prefixes"].keys())[0])
    except IndexError:
        v = 4
        print(f"forcing version to {v}")
    bird_conf_str += "protocol static {\n"
    bird_conf_str += f"  ipv{v} {{\n" \
        "    export all;\n" \
        "    import all;\n" \
        "  };\n"
    for prefix in node["prefixes"]:
        bird_conf_str += f"  route {prefix} {mode};\n"
        roa_item = {"asn": int(dev_as), "prefix": prefix,
                    "max_length": int(prefix.split("/")[1])}
        roa_json["add"].append(roa_item)
    bird_conf_str += "};\n"
    bird_conf_str += "template bgp basic {\n"
    bird_conf_str += f"  local as {node['as']};\n"
    bird_conf_str += "  long lived graceful restart on;\n"
    bird_conf_str += "  debug all;\n"
    bird_conf_str += "  enable extended messages;\n" \
                     "};\n" \
                     "template bgp basic4 from basic {\n" \
                     "  ipv4 {\n" \
                     "    export all;\n" \
                     "    import all;\n" \
                     "    import table on;\n" \
                     "  };\n" \
                     "};\n" \
                     "template bgp basic6 from basic {\n" \
                     "  ipv6 {\n" \
                     "    export all;\n" \
                     "    import all;\n" \
                     "    import table on;\n" \
                     "  };\n" \
                     "};\n"
    bird_conf_str += f"template bgp sav_inter from basic{v} "
    bird_conf_str += "{\n"
    if enable_rpdp:
        bird_conf_str += f"  rpdp{v} "
        bird_conf_str += "{\n" \
            "  import all;\n" \
            "  export all;\n" \
            "  };\n"
    bird_conf_str += "};\n"
    link_map = {}
    aspa_item = {"customer": int(dev_as), "providers": []}
    for src_id, dst_id, link_type, src_ip, dst_ip in base["links"]:
        if dev_id not in [src_id, dst_id]:
            continue
        if dev_id == src_id:
            peer_id = dst_id
            my_ip = src_ip
            peer_ip = dst_ip
        else:
            peer_id = src_id
            my_ip = dst_ip
            peer_ip = src_ip
        peer_node = all_nodes[peer_id]
        peer_as = peer_node["as"]
        link_map_value = {"link_type": link_type}
        if link_type == "dsav":
            bird_conf_str += f"protocol bgp savbgp_{dev_id}_{peer_id} from sav_inter\n"
        else:
            bird_conf_str += f"protocol bgp savbgp_{dev_id}_{peer_id} from basic\n"

        bird_conf_str += "{\n"
        bird_conf_str += f"  description \"modified BGP between {dev_id} and {peer_id}\";\n"

        if dev_as != peer_as:
            found = False
            for provider, customer in base["as_relations"]["provider-customer"]:
                if dev_as not in [provider, customer]:
                    continue
                if peer_as not in [provider, customer]:
                    continue
                if dev_as == provider:
                    bird_conf_str += f"  local role provider;\n"
                    found = True
                elif dev_as == customer:
                    bird_conf_str += f"  local role customer;\n"
                    aspa_item["providers"].append(f"AS{peer_as}(v4)")
                    found = True
            if not found:
                bird_conf_str += f"  local role peer;\n"
        # get ip
        bird_conf_str += f"  source address {my_ip};\n"

        bird_conf_str += f"  neighbor {peer_ip} as {peer_as};\n"
        # bird_conf_str += f"  interface \"eth_{dst_id}\";\n"
        # interface "eth_3356";
        bird_conf_str += f"  connect delay time {int(delay)};\n"
        delay += 0.1
        bird_conf_str += "  direct;\n};\n"
        link_map_value["link_data"] = {
            "peer_ip": {peer_ip},
            "peer_id": peer_id
        }
        match link_type:
            case "dsav":
                pass
            case "grpc":
                link_map_value["link_data"]["peer_port"] = 5000
                link_map[f"savbgp_{dev_id}_{peer_id}"] = link_map_value
            case "quic":
                link_map_value["link_data"]["peer_port"] = 7777
                link_map[f"savbgp_{dev_id}_{peer_id}"] = link_map_value
            case _:
                raise NotImplementedError
    if enable_rpki:
        aspa_json["add"].append(aspa_item)

    return delay, bird_conf_str, link_map


def gen_sa_config(
        auto_ip_version,
        auto_nets,
        use_ignore_nets,
        node,
        link_map,
        as_scope,
        app_list,
        active_app,
        enable_rpki,
        fib_threshold=5,
        ignore_private=True):
    as_scope = as_scope[node["as"]]
    sa_config = {
        "apps": app_list,
        "enabled_sav_app": active_app,
        "fib_stable_threshold": fib_threshold,
        "ca_host": None,
        "ca_port": None,
        "grpc_config": {
            "server_addr": "0.0.0.0:5000",
            "server_enabled": True
        },
        "auto_ip_version": auto_ip_version,
        "ignore_nets": auto_nets,
        "use_ignore_nets": use_ignore_nets,
        "link_map": link_map,
        "quic_config": {
            "server_enabled": True
        },
        "local_as": node["as"],
        "prefixes": node["prefixes"],
        "router_id": as_scope[node["device_id"]]["router_id"],
        "location": "edge_full",
        "as_scope": as_scope,
        "enable_rpki": enable_rpki,
        "ignore_private": ignore_private
    }
    if enable_rpki:
        if auto_ip_version in [4,6]:
            sa_config["ca_host"] = CA_IP4
            sa_config["ca_port"] = CA_HTTP_PORT
        # elif auto_ip_version == 6:
            # raise NotImplementedError
    return sa_config


def refresh_folder(src, dst):
    if os.path.exists(dst):
        run_cmd(f"rm -r {dst}")
    run_cmd(f"cp -r {src} {dst}")


def ready_input_json(json_content, selected_nodes):
    DEFAULT_FIB_THRESHOLD = 300
    DEFAULT_ORIGINAL_BIRD = False
    base = json_content
    if "fib_threshold" not in base:
        print(
            f"fib_threshold not found, using default value {DEFAULT_FIB_THRESHOLD}")
        base["fib_threshold"] = DEFAULT_FIB_THRESHOLD
    if "original_bird" not in base:
        print(
            f"original_bird not found, using default value {DEFAULT_ORIGINAL_BIRD}")
        base["original_bird"] = DEFAULT_ORIGINAL_BIRD
    if base["original_bird"]:
        print("original_bird is enabled")
        if not "keep_time" in base:
            base["keep_time"] = 600
            print(
                f"keep_time not found, using default value {base['keep_time']}")
    if selected_nodes:
        temp_node = {}
        temp_links = []
        for node in selected_nodes:
            temp_node[node] = base["devices"][node]
        for link in base["links"]:
            if (link[0] in selected_nodes and link[1] in selected_nodes):
                temp_links.append(link)
        base["links"] = temp_links
        base["devices"] = temp_node
    return base


def assign_ip(base):
    """
    assign ip to each link (device)
    """
    as_scope = {}
    a = None
    if base["auto_ip_version"] == 4:
        a = IPGenerator("1.1.1.1")

    elif base["auto_ip_version"] == 6:
        a = IPGenerator("FEC::1:1")
    else:
        raise NotImplementedError
    temp = []
    for link in base["links"]:
        src_ip, dst_ip = a.get_new_ip_pair()
        link.append(src_ip)
        link.append(dst_ip)
        temp.append(link)
        as_scope = build_as_scope(as_scope, link, base["devices"])
    base["links"] = temp
    for asn, asn_data in as_scope.items():
        new_asn_data = {}
        for dev_id, ips in asn_data.items():
            router_id = max(ips)
            if router_id.version == 4:
                router_id = str(router_id)
            elif router_id.version == 6:
                router_id = router_id.packed[-4:]
                router_id = int.from_bytes(router_id, byteorder='big')
                router_id = str(netaddr.IPAddress(router_id))
            new_asn_data[dev_id] = {
                "router_id": router_id,
                "ips": list(map(str, ips))
            }
        as_scope[asn] = new_asn_data
    base["as_scope"] = as_scope
    base["ip_range"] = str(a.get_range())
    return base


def build_as_scope(as_scope, link, base_device):
    """
    return a dict of as_scope
    first level key: as
    second level key: dev_id
    second level value: list of ip
    """
    src_dev_id, dst_dev_id, link_type, src_ip, dst_ip = link
    for dev_id in [src_dev_id, dst_dev_id]:
        dev_ip = src_ip if dev_id == src_dev_id else dst_ip
        dev_as = base_device[dev_id]["as"]
        if dev_as not in as_scope:
            as_scope[dev_as] = {dev_id: [dev_ip]}
        else:
            if dev_id not in as_scope[dev_as]:
                as_scope[dev_as][dev_id] = [dev_ip]
            else:
                as_scope[dev_as][dev_id].append(dev_ip)

    return as_scope


def get_cpu_id(cur_id, max_id=103):
    new_id = cur_id+1
    if new_id > max_id:
        new_id = 0
    return new_id


def build_rpki(base, out_dir):
    """
    build rpki compose 
    """
    krill_dev_id = "ca"
    s = "version: \"2\"\n"
    s += "networks:\n"
    s += "  ca_net:\n"
    s += "    external: false\n"
    s += "    ipam:\n"
    s += "      driver: default\n"
    s += "      config:\n"
    if base["auto_ip_version"] in [4,6]:
        s += "        - subnet: \"10.10.0.0/16\"\n\n"
    # else:
        # raise NotImplementedError
    s += "services:\n"
    s += "  savopkrill.com:\n"
    s += "    image: krill\n"
    s += "    container_name: ca\n"
    if base["auto_ip_version"] == 6:
        s += "    sysctls:\n"
        s += "      - net.ipv6.conf.all.disable_ipv6=0\n"
    s += "    cap_add:\n"
    s += "      - NET_ADMIN\n"
    s += "    environment:\n"
    s += "      - KRILL_LOG_LEVEL=debug\n"
    s += "      - RUST_BACKTRACE=1\n"
    s += "    volumes:\n"
    s += f"      - ./{krill_dev_id}/add_info.py:/var/krill/add_info.py\n"
    s += f"      - ./{krill_dev_id}/log/krill.log:/var/krill/logs/krill.log\n"
    s += f"      - ./{krill_dev_id}/log/rsync.log:/var/krill/logs/rsync.log\n"
    s += f"      - ./{krill_dev_id}/krill.sh:/var/krill/start.sh\n"
    s += f"      - ./{krill_dev_id}/krill.conf:/var/krill/data/krill.conf\n"
    s += f"      - ./{krill_dev_id}/rsyncd.conf:/etc/rsyncd.conf\n"
    s += f"      - ./{krill_dev_id}/roas.json:/var/krill/roas.json\n"
    s += f"      - ./{krill_dev_id}/aspas.json:/var/krill/aspas.json\n"
    s += f"      - ./{krill_dev_id}/web_cert.pem:/var/krill/data/ssl/cert.pem\n"
    s += f"      - ./{krill_dev_id}/web_key.pem:/var/krill/data/ssl/key.pem\n"
    s += f"      - ./{krill_dev_id}/cert.pem:/usr/local/share/ca-certificates/extra/ca.crt\n"
    s += f"      - ./{krill_dev_id}/roa/:/var/krill/data/roa\n"
    s += "    networks:\n"
    s += "      ca_net:\n"
    if base["auto_ip_version"] == [4,6]:
        s += f"        ipv4_address: {CA_IP4}\n"
    # else:
        # raise NotImplementedError
    s += "    command: >\n"
    s += "      bash /var/krill/start.sh\n"
    ca_compose_path = os.path.join(out_dir, CA_COMPOSE_FILE)
    with open(ca_compose_path, 'w') as f:
        f.write(s)


def regenerate_config(
        savop_dir,
        host_dir,
        input_json,
        base_config_dir,
        selected_nodes,
        out_dir):
    if os.path.exists(out_dir):
        run_cmd(f"rm -r {out_dir}")
    print("step: genetate sav-agent, bird, docker_compose, sign_key files")
    os.makedirs(out_dir)
    base = ready_input_json(input_json, selected_nodes)
    base = assign_ip(base)
    ca_dir = os.path.join(out_dir, "ca")
    roa_dir = os.path.join(out_dir, "roa")
    run_dir = "savop_run"
    cp_cmd = f"cp {os.path.join(base_config_dir,'topo.sh')} {os.path.join(out_dir,'topo.sh')}"
    run_cmd(cp_cmd)

    # build docker compose
    compose_f = open(os.path.join(out_dir, DEVICE_COMPOSE_FILE), 'a')
    compose_f.write("version: \"2\"\n")

    if base["enable_rpki"]:
        refresh_folder(os.path.join(base_config_dir, "ca"),
                       os.path.join(ca_dir))
        key_f = open(os.path.join(out_dir, 'sign_key.sh'), 'a')
        os.mkdir(os.path.join(ca_dir, "log"))
        os.makedirs(os.path.join(roa_dir, "log"))
        # touch log files
        for f in [
            os.path.join(ca_dir, "log", "krill.log"), os.path.join(
                ca_dir, "log", "rsync.log")
        ]:
            with open(f, 'w') as f:
                pass
        # copy key generation files
        for f in [
            "sign_key.sh"
        ]:
            cmd = f"cp {os.path.join(savop_dir,'rpki',f)} {os.path.join(out_dir, f)}"
            run_cmd(cmd)
        # copy ca files
        for f in [
            "add_info.py", "krill.sh", "krill.conf", "rsyncd.conf"
        ]:
            cmd = f"cp {os.path.join(savop_dir,'rpki',f)} {os.path.join(ca_dir, f)}"
            run_cmd(cmd)
        run_cmd(f"cp {os.path.join(savop_dir,'rpki','web','cert.pem')} \
            {os.path.join(ca_dir, 'web_cert.pem')}")
        run_cmd(f"cp {os.path.join(savop_dir,'rpki','web','key.pem')} \
            {os.path.join(ca_dir, 'web_key.pem')}")
        docker_network_content = "networks:\n" \
                                 f"  {run_dir}_ca_net:\n" \
                                 "    external: true\n" \
                                 "    ipam:\n" \
                                 "      driver: default\n" \
                                 "      config:\n" \
                                 "        - subnet: \"10.10.0.0/16\"\n"
        compose_f.write(docker_network_content)
    compose_f.write("\nservices:\n")
    ignore_nets = []
    if base["enable_rpki"]:
        if base["auto_ip_version"] in [4, 6]:
            ca_ip = netaddr.IPAddress(CA_IP4)
            ignore_nets.append("10.10.0.0/16")
        # TODO: use proper ipv6 address
            # raise NotImplementedError("ca_ip6 not ready")
            # ca_ip = netaddr.IPAddress("::ffff:10.10.0.3")
            # ignore_nets.append("10.10.0.0/16")
    cpu_id = 0
    roa_json = {"ip": "localhost", "port": CA_HTTP_PORT,
                "token": "krill", "add": []}
    aspa_json = {"ip": "localhost", "port": CA_HTTP_PORT,
                 "token": "krill", "add": []}
    ignore_nets.append(base["ip_range"])
    for node in base["devices"]:

        cur_delay = 0
        nodes = base["devices"][node]
        nodes["device_id"] = node
        rpdp_enable = RPDP_ID in base["sav_apps"]
        node_dir = os.path.join(out_dir, node)
        os.makedirs(node_dir)
        # generate bird conf
        cur_delay, bird_config_str, link_map = gen_bird_conf(
            nodes, cur_delay, "blackhole", base, rpdp_enable,
            roa_json, aspa_json)

        with open(os.path.join(node_dir, "bird.conf"), 'w') as f:
            f.write(bird_config_str)
        run_cmd(f"chmod 666 {node_dir}/bird.conf")
        sa_config = gen_sa_config(
            base["auto_ip_version"],
            ignore_nets,
            base["ignore_irrelevant_nets"],
            nodes,
            link_map,
            base["as_scope"],
            base["sav_apps"],
            base["active_sav_app"],
            base["enable_rpki"],
            fib_threshold=base["fib_threshold"],
            ignore_private=base["ignore_private"])
        with open(os.path.join(node_dir, "sa.json"), 'w') as f:
            json.dump(sa_config, f, indent=4)
        # resign keys
        if base["enable_rpki"]:
            resign_keys(out_dir, node, key_f, base_config_dir)
        tag = f"{node}"
        while host_dir.endswith("/"):
            host_dir = host_dir[:-1]

        compose_str = f"  r{tag}:\n"
        if base["auto_ip_version"] == 6:
            compose_str += f"    sysctls:\n"
            compose_str += f"      - net.ipv6.conf.all.disable_ipv6=0\n"
        compose_str += f"    image: savop_bird_base\n" \
            f"    init: true\n" \
            f"    container_name: \"r{tag}\"\n" \
            f"    cap_add:\n" \
            f"      - NET_ADMIN\n" \
            f"    deploy:\n"
        # TODO resource limit
        compose_str += f"      resources:\n"
        resource_limit = False
        if resource_limit:
            compose_str += f"        limits:\n" \
                f"          cpus: '0.3'\n" \
                f"          memory: 512M\n"
        compose_str += f"        reservations:\n"
        compose_str += f"          cpus: '{cpu_id}'\n"
        cpu_id = get_cpu_id(cpu_id)
        compose_str += f"    volumes:\n" \
            f"      - type: bind\n" \
            f"        source: {host_dir}/{run_dir}/{node}/bird.conf\n" \
            f"        target: /usr/local/etc/bird.conf\n" \
            f"      - type: bind\n" \
            f"        source: {host_dir}/{run_dir}/{node}/sa.json\n" \
            f"        target: /root/savop/SavAgent_config.json\n" \
            f"      - {host_dir}/{run_dir}/{node}/log/:/root/savop/logs/\n" \
            f"      - {host_dir}/sav-agent/:/root/savop/sav-agent/\n"\
            f"      - {host_dir}/savop/reference_and_agent/router_kill_and_start.sh:"\
            "/root/savop/router_kill_and_start.sh\n"\
            f"      - {host_dir}/{run_dir}/bird:/usr/local/sbin/bird\n"\
            f"      - {host_dir}/{run_dir}/birdc:/usr/local/sbin/birdc\n"\
            f"      - {host_dir}/{run_dir}/birdcl:/usr/local/sbin/birdcl\n"
        compose_str += f"      - type: bind\n" \
            f"        source: {host_dir}/{run_dir}/active_signal.json\n" \
            f"        target: /root/savop/signal.json\n" \
            f"      - /etc/localtime:/etc/localtime\n"

        if base["enable_rpki"]:
            compose_str += f"      - {host_dir}/{run_dir}/{node}/cert.pem:/root/savop/cert.pem\n"
            compose_str += f"      - {host_dir}/{run_dir}/{node}/key.pem:/root/savop/key.pem\n"
            compose_str += f"      - {host_dir}/{run_dir}/ca/cert.pem:/root/savop/ca_cert.pem\n"
        compose_str += f"    command:\n"
        if base["original_bird"]:
            compose_str += "        bird-original -D /root/savop/logs/bird-original.log -f\n"
        else:
            compose_str += f"        python3 /root/savop/sav-agent/sav_control_container.py\n"
        compose_str += f"    privileged: true\n"
        compose_f.write(compose_str)
        if base["enable_rpki"]:
            ca_ip += 1
            compose_str = "    networks:\n" \
                f"      {run_dir}_ca_net:\n" \
                f"        ipv4_address: {str(ca_ip)}\n"
            compose_f.write(compose_str)
        else:
            compose_f.write("    network_mode: none\n")

    compose_f.close()
    active_signal = {
        "command": "stop",
        "source": base["active_sav_app"],
        "command_scope": list(base["devices"].keys()),
        "stable_threshold": base["fib_threshold"]
    }
    with open(os.path.join(out_dir, "active_signal.json"), 'w') as f:
        json.dump(active_signal, f, indent=4)
    run_cmd(f"chmod 666 {out_dir}/active_signal.json")

    topo_f = open(os.path.join(out_dir, "topo.sh"), 'a')
    for src, dst, link_type, src_ip, dst_ip in base["links"]:
        topo_f.write(f'\necho "adding edge r{src}-r{dst}"')
        if not src_ip.version == dst_ip.version:
            raise NotImplementedError
        if src_ip.version == 6:
            topo_f.write(
                f"\nfunCreateV{src_ip.version} 'r{src}' 'r{dst}' '{src_ip}/124' '{dst_ip}/124'")
        elif src_ip.version == 4:
            topo_f.write(
                f"\nfunCreateV{src_ip.version} 'r{src}' 'r{dst}' '{src_ip}/24' '{dst_ip}/24'")

    topo_f.close()

    os.chdir(f"{savop_dir}/")
    if platform.system() == "Windows":
        run_cmd("python3 change_eol.py")
    if base["enable_rpki"]:
        json_w(os.path.join(ca_dir, "roas.json"), roa_json)
        json_w(os.path.join(ca_dir, "aspas.json"), aspa_json)
        build_rpki(base, out_dir)
        cur_dir = os.getcwd()
        os.chdir(out_dir)
        key_f.close()
        run_cmd("bash ./sign_key.sh")
        os.chdir(cur_dir)

    return len(base["devices"])


def resign_keys(out_dir, node, key_f, base_cfg_folder):
    run_cmd(
        f"cp {os.path.join(base_cfg_folder,'req.conf')} {os.path.join(out_dir, node)}")
    with open(os.path.join(out_dir, node, "sign.ext"), 'w') as f:
        sign_content = "authorityKeyIdentifier=keyid,issuer\n" \
                       "basicConstraints=CA:FALSE\n" \
                       "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n" \
                       f"subjectAltName = DNS:{node}, DNS:localhost"
        f.write(sign_content)
    key_f.write(f"\nfunCGenPrivateKeyAndSign ./{node} ./ca")


def script_builder(host_dir, savop_dir, json_content, out_dir, logger, skip_bird=False, skip_rebuild=False):
    """
    build config for birds, rpki, sav-agent and recompile bird if needed
    """
    try:
        t0 = time.time()
        if not "original_bird" in json_content:
            json_content["original_bird"] = False
        if json_content["original_bird"]:
            skip_bird = True
            skip_rebuild = True
        if not skip_bird:
            recompile_bird(os.path.join(
                SAV_ROOT_DIR, "sav-reference-router"), logger)
        base_cfg_folder = os.path.join(savop_dir, "base_configs")
        selected_nodes = None
        container_num = regenerate_config(
            savop_dir,
            host_dir,
            json_content,
            base_cfg_folder,
            selected_nodes,
            out_dir)
        t = time.time() - t0
        logger.info(
            f"script_builder finished, container_num: {container_num} in {t:.4f} seconds")
        return container_num
    except Exception as e:
        logger.exception(f"script_builder failed: {e}")
        raise
