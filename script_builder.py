#!/usr/bin/python3
# -*- coding: utf-8 -*-
"""
1. recompile bird
2. rebuild docker images
3. regenerate config files
4. regenerate keys
5. regenerate compose.yml and topo.sh for the given node and links
"""
from http.client import INTERNAL_SERVER_ERROR
import os
import time
import subprocess
import json
import netaddr
import copy
import platform
from sav_control_common import *
from script_consts import *


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


def recompile_bird(path=r'{host_dir}/sav_router', logger=None):
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


def add_bird_basic(router_id, ip_version, my_as):
    router_id_ip = netaddr.IPAddress(router_id)
    bird_conf_str = f"router id {str(router_id_ip)};"
    bird_conf_str += BIRD_BASIC.replace(REP_KEY_IP_VERSION,
                                        str(ip_version)).replace(REP_KEY_MY_AS, str(my_as))
    return bird_conf_str


def gen_bird_conf(node, delay, mode, base, roa_json, aspa_json):
    """
    add everything but actual bgp links
    """
    # raise ValueError(base)
    dev_id = node["device_id"]
    dev_as = node["as"]
    router_id = base["as_scope"][dev_as][dev_id]["router_id"]
    enable_rpki = base["enable_rpki"]
    try:
        v = tell_prefix_version(list(node["prefixes"].keys())[0])
    except IndexError:
        v = 4
        print(f"forcing version to {v}")
    bird_conf_str = add_bird_basic(router_id, v, dev_as)
    if mode == "blackhole":
        for prefix in node["prefixes"]:
            bird_conf_str += f"  route {prefix} {mode};\n"
            roa_item = {"asn": int(dev_as), "prefix": prefix,
                        "max_length": int(prefix.split("/")[1])}
            roa_json["add"].append(roa_item)
    aspa_item = {"customer": int(dev_as), "providers": []}
    if enable_rpki:
        aspa_json["add"].append(aspa_item)
    # calculate the no_export map
    if not "no_export_map" in base:
        no_export_map = {}
    else:
        no_export_map = base["no_export_map"]
    for prefix, p_data in node["prefixes"].items():
        if not "no_export" in p_data:
            continue
        for dst_dev_id in p_data["no_export"]:
            if not dev_id in no_export_map:
                no_export_map[dev_id] = {}
            if not dst_dev_id in no_export_map[dev_id]:
                no_export_map[dev_id][dst_dev_id] = []
            no_export_map[dev_id][dst_dev_id].append(prefix)
    base["no_export_map"] = no_export_map
    return delay, bird_conf_str, node, no_export_map


def find_links(all_links, dev_id) -> list:
    result = []
    for src_id, dst_id, link_type, src_ip, dst_ip in all_links:
        if not dev_id in [src_id, dst_id]:
            continue
        if dev_id == src_id:
            peer_id = dst_id
            my_ip = src_ip
            peer_ip = dst_ip
        else:
            peer_id = src_id
            my_ip = dst_ip
            peer_ip = src_ip
        result.append((peer_id, peer_ip, my_ip, dev_id, link_type))
    return result


def add_bird_link(bird_conf_str, peer_id, peer_ip, peer_as, dev_ip, dev_id, link_type, no_exp_map, phy_links, is_inter):
    no_exp_data = None
    if link_type in [LINK_NATIVE_BGP, LINK_BGP_WITH_RPDP]:
        if dev_id in no_exp_map:
            # input(dev_id)
            # input(no_exp_map)
            if peer_id in no_exp_map[dev_id]:
                no_exp_data = no_exp_map[dev_id][peer_id]
                bird_conf_str += f"filter noexport_{peer_id} "
                bird_conf_str += "{\n"
                for prefix in no_exp_data:
                    bird_conf_str += f"  if net = {prefix} then bgp_community.add((0xFFFF, 0xFF01));\n"
                bird_conf_str += "  accept;\n};\n"
    bird_conf_str += f"protocol bgp {link_type}_{dev_id}_{peer_id} from"
    if no_exp_data:
        bird_conf_str += " basic {\n"
    else:
        if link_type == LINK_NATIVE_BGP:
            bird_conf_str += f" {REP_KEY_BGPONLY}"
            bird_conf_str += " {\n"
        elif link_type == LINK_BGP_WITH_RPDP:
            bird_conf_str += f" {REP_KEY_BGPRPDP}"
            bird_conf_str += " {\n"
        elif link_type == LINK_RPDP_BGP:
            bird_conf_str += f" {REP_KEY_SAV}"
            bird_conf_str += " sav46 {\n"
    if link_type == LINK_NATIVE_BGP:
        bird_conf_str += f"  description \"LINK_NATIVE_BGP between {dev_id} and {peer_id}\";\n"
    elif link_type == LINK_BGP_WITH_RPDP:
        bird_conf_str += f"  description \"LINK_BGP_WITH_RPDP between {dev_id} and {peer_id}\";\n"
    elif link_type == LINK_RPDP_BGP:
        bird_conf_str += f"  description \"RPDP OVER BGP (no BGP data) between {dev_id} and {peer_id}\";\n"
    if not is_inter:
        bird_conf_str += "  rr client;\n"
    if no_exp_data:
        bird_conf_str += NO_EXPORT_STR.replace(REP_KEY_PEER_ID, peer_id)
    ip1, ip2 = find_link([dev_id, peer_id], phy_links)
    bird_conf_str += f"  source address {dev_ip};\n"
    bird_conf_str += f"  neighbor {peer_ip} as {peer_as};\n"
    if ip1:
        bird_conf_str += "  direct;\n"
    else:
        bird_conf_str += "  multihop;\n"
    return bird_conf_str


def find_as_relation(my_as, peer_as, relations, aspa_json, enable_rpki):
    remote_role = "peer"
    local_role = "peer"
    for rel in relations:
        if my_as in rel and peer_as in rel:
            if my_as == rel[0]:
                local_role = "provider"
                remote_role = "customer"
            elif my_as == rel[1]:
                local_role = "customer"
                remote_role = "provider"
            if enable_rpki:
                aspa_json["add"]["providers"].append(
                    f"AS{peer_as}(v4)")
            return local_role, remote_role, aspa_json
    if enable_rpki:
        raise NotImplementedError
    return local_role, remote_role, aspa_json 

def add_links(base, dev_id, bird_conf_str, aspa_json, delay, dev_as, roa_json, sa_config, no_exp_map, phy_links):
    all_nodes = base["devices"]
    links = find_links(base["links"], dev_id)
    link_map = {}
    has_inter_rpdp = False
    has_inter_bgp = False
    sa_config["device_id"] = dev_id
    enable_rpki = base["enable_rpki"]
    for peer_id, peer_ip, dev_ip, dev_id, link_type in links:
        # print(peer_id, peer_ip, dev_ip, dev_id, link_type)
        if link_type == LINK_PHYSICAL:
            continue
        v = dev_ip.version
        peer_node = all_nodes[peer_id]
        peer_as = peer_node["as"]
        is_inter = dev_as != peer_as
        add_a_bird_proto = link_type in [
            LINK_NATIVE_BGP, LINK_BGP_WITH_RPDP, LINK_RPDP_BGP]
        link_map_value = {
                "link_type": link_type,
                "remote_ip": str(peer_ip),
                "remote_id": str(peer_id),
                "remote_as": peer_as,
                "local_ip": str(dev_ip),
                "local_role": None,
                "remote_role": None
            }
        if is_inter:
            link_map_value["local_role"] = None
            link_map_value["remote_role"] = None
            # some cases, we don't have a direct relation
            try:
                local_role, remote_role, aspa_json = find_as_relation(
                        dev_as, peer_as, base["as_relations"]["provider-customer"], aspa_json, enable_rpki)
                link_map_value["local_role"] = local_role
                link_map_value["remote_role"] = remote_role
            except:
                pass
        link_map_name = "_".join([link_type, dev_id, peer_id])
        link_map[link_map_name] = link_map_value
        if add_a_bird_proto:
            bird_conf_str = add_bird_link(
                bird_conf_str, peer_id, peer_ip, peer_as, dev_ip, dev_id, link_type, no_exp_map, phy_links,is_inter)
            if is_inter and link_type in [LINK_NATIVE_BGP, LINK_BGP_WITH_RPDP]:
                has_inter_bgp = True
            if is_inter and link_type in [LINK_RPDP_HTTP, LINK_BGP_WITH_RPDP, LINK_RPDP_BGP]:
                has_inter_rpdp = True
            if is_inter:
                local_role, remote_role, aspa_json = find_as_relation(
                    dev_as, peer_as, base["as_relations"]["provider-customer"], aspa_json, enable_rpki)
                bird_conf_str += f"  local role {local_role};\n"
                
                

            # if base["rpdp_full_link"]:
            # continue
            bird_conf_str += f"  connect delay time {int(delay)};\n"
            delay += 0.1
            bird_conf_str += "};\n"
        elif link_type == LINK_RPDP_HTTP:
            pass
        else:
            raise NotImplementedError(f"{link_type} not implemented")
    if base["rpdp_full_link"]:
        raise NotImplementedError
    sa_config["link_map"] = link_map
    if has_inter_bgp:
        if has_inter_rpdp:
            sa_config["location"] = RT_EDGE_REP
        sa_config["location"] = RT_EDGE
    else:
        sa_config["location"] = RT_CORE
    return bird_conf_str, sa_config


def get_node_config(node, config_json) -> dict:
    d = config_json["sav_app_map"][0]
    for x in config_json["sav_app_map"]:
        if node in x["devices"]:
            return x
    return d


def gen_sa_config(config_json, node):
    auto_ip_version = config_json["auto_ip_version"]
    enable_rpki = config_json["enable_rpki"]
    node_config = get_node_config(node["device_id"], config_json)
    as_scope = config_json["as_scope"]
    as_scope = as_scope[node["as"]]
    sa_config = {
        "apps": node_config["sav_apps"],
        "enabled_sav_app": node_config["active_app"],
        "fib_stable_threshold": node_config["fib_threshold"],
        "ca_host": None,
        "ca_port": None,
        "grpc_config": {
            "server_addr": "0.0.0.0:5000",
            "server_enabled": True
        },
        "auto_ip_version": auto_ip_version,
        "ignore_nets": config_json['ignore_nets'],
        "use_ignore_nets": node_config["ignore_irrelevant_nets"],
        "quic_config": {
            "server_enabled": True
        },
        "local_as": node["as"],
        "prefixes": node["prefixes"],
        "router_id": as_scope[node["device_id"]]["router_id"],
        "as_scope": as_scope,
        "enable_rpki": enable_rpki,
        "ignore_private": node_config["ignore_private"],
        "prefix_method": config_json["prefix_method"],
    }
    if enable_rpki:
        if auto_ip_version in [4, 6]:
            sa_config["ca_host"] = CA_IP4
            sa_config["ca_port"] = CA_HTTP_PORT
        # elif auto_ip_version == 6:
            # raise NotImplementedError
    return sa_config


def refresh_folder(src, dst):
    if os.path.exists(dst):
        run_cmd(f"rm -r {dst}")
    run_cmd(f"cp -r {src} {dst}")


def add_default_values(base):
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
    return base


def find_link(target_link, physical_links):
    # find ip from physical_links
    for link in physical_links:
        if link[0] == target_link[0] and link[1] == target_link[1]:
            return link[3], link[4]
        if link[0] == target_link[1] and link[1] == target_link[0]:
            return link[4], link[3]
    return None, None

def order_links(links):
    """
    order links by device id
    """
    temp = []
    for link in links:
        id_0 = int(link[0])
        id_1 = int(link[1])
        if id_0 > id_1:
            temp.append([link[1], link[0], link[2]])
        else:
            temp.append([link[0], link[1], link[2]])
    temp = sorted(temp, key=lambda x: x[0])
    return temp
        
def assign_ip(base):
    """
    assign ip to each link (device)
    """
    
    as_scope = {}
    a = None
    # assign new ips for bgp links
    if base["auto_ip_version"] == 4:
        a = IPGenerator("1.1.1.1")

    elif base["auto_ip_version"] == 6:
        a = IPGenerator("FEC::1:1")
    else:
        raise NotImplementedError
    # extend physical links
    temp = []
    base["links"] = order_links(base["links"])
    for link in base["links"]:
        if link[2] == LINK_NATIVE_BGP:
            new_link = copy.deepcopy(link)
            new_link[2] = LINK_PHYSICAL
            temp.append(new_link)
    base["links"] += temp
    phy_links = [x for x in base["links"] if x[2] == LINK_PHYSICAL]
    ip_map = {}
    for link in phy_links:
        src_ip, dst_ip = a.get_new_ip_pair()
        link.append(src_ip)
        link.append(dst_ip)
        for idx in [0, 1]:
            if link[idx] not in ip_map:
                ip_map[link[idx]] = []
            ip_map[link[idx]].append(link[idx+3])
    for link in base["links"]:
        if link[2] != LINK_PHYSICAL:
            src_ip, dst_ip = find_link(link, phy_links)
            if src_ip:
                link.append(src_ip)
                link.append(dst_ip)
            else:
                link.append(ip_map[link[0]][-1])
                link.append(ip_map[link[1]][-1])
        as_scope = build_as_scope(as_scope, link, base["devices"])
    bgps = []
    dsavs = []
    bgp_rpdp_links = []
    links_to_del = []
    for link in base["links"]:
        if link[2] == LINK_NATIVE_BGP:
            bgps.append(link)
        elif link[2] == LINK_RPDP_BGP:
            dsavs.append(link)
    for bgp_link in bgps:
        for dsav_link in dsavs:
            if bgp_link[0] == dsav_link[0] and bgp_link[1] == dsav_link[1]:
                new_link = copy.deepcopy(bgp_link)
                new_link[2] = LINK_BGP_WITH_RPDP
                links_to_del.append(bgp_link)
                links_to_del.append(dsav_link)
                bgp_rpdp_links.append(new_link)
            elif bgp_link[0] == dsav_link[1] and bgp_link[1] == dsav_link[0]:
                new_link = copy.deepcopy(bgp_link)
                new_link[2] = LINK_BGP_WITH_RPDP
                links_to_del.append(bgp_link)
                links_to_del.append(dsav_link)
                bgp_rpdp_links.append(new_link)
    for link in links_to_del:
        base["links"].remove(link)
    base["links"].extend(bgp_rpdp_links)
    for asn, asn_data in as_scope.items():
        new_asn_data = {}
        # ips must be sorted
        for dev_id, ips in asn_data.items():
            router_id = ips[-1]
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
    if link[2] in [LINK_NATIVE_BGP,LINK_BGP_WITH_RPDP]:
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
    if base["auto_ip_version"] in [4, 6]:
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
    s += "    networks:\n"
    s += "      ca_net:\n"
    if base["auto_ip_version"] == [4, 6]:
        s += f"        ipv4_address: {CA_IP4}\n"
    # else:
        # raise NotImplementedError
    s += "    command: >\n"
    s += "      bash /var/krill/start.sh\n"
    ca_compose_path = os.path.join(out_dir, CA_COMPOSE_FILE)
    with open(ca_compose_path, 'w') as f:
        f.write(s)


def add_rpki_1(compose_f, savop_dir, out_dir, ca_dir, run_dir) -> None:
    cp_cmd = f"cp {os.path.join(savop_dir,'rpki','sign_key.sh')} {os.path.join(out_dir,'sign_key.sh')}"
    run_cmd(cp_cmd)
    refresh_folder(os.path.join(savop_dir, "rpki", "ca"),
                   os.path.join(out_dir, "ca"))
    key_f = open(os.path.join(out_dir, 'sign_key.sh'), 'a')
    os.mkdir(os.path.join(ca_dir, "log"))
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
    run_cmd(f"cp {os.path.join(savop_dir,'rpki','ca','cert.pem')} \
        {os.path.join(ca_dir, 'web_cert.pem')}")
    run_cmd(f"cp {os.path.join(savop_dir,'rpki','ca','key.pem')} \
        {os.path.join(ca_dir, 'web_key.pem')}")
    docker_network_content = "networks:\n" \
                             f"  {run_dir}_ca_net:\n" \
                             "    external: true\n" \
                             "    ipam:\n" \
                             "      driver: default\n" \
                             "      config:\n" \
                             "        - subnet: \"10.10.0.0/16\"\n"
    compose_f.write(docker_network_content)
    return key_f


def write_compose_str(node, base, host_dir, run_dir, tag, compose_f, cpu_id, ca_ip):
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
        f"      - {host_dir}/sav_agent/:/root/savop/sav-agent/\n"\
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
    return cpu_id


def ready_out_dir(out_dir) -> None:
    if os.path.exists(out_dir):
        run_cmd(f"rm -r {out_dir}")
    os.makedirs(out_dir)


def prepare_base(input_json):
    ret = add_default_values(input_json)
    ret = assign_ip(ret)
    # add ignore_nets
    i_n = []
    ca_ip = None
    if ret["enable_rpki"]:
        if ret["auto_ip_version"] in [4, 6]:
            ca_ip = netaddr.IPAddress(CA_IP4)
            i_n.append("10.10.0.0/16")
        # TODO: use proper ipv6 address
            # raise NotImplementedError("ca_ip6 not ready")
            # ca_ip = netaddr.IPAddress("::ffff:10.10.0.3")
            # ignore_nets.append("10.10.0.0/16")
    i_n.append(ret["ip_range"])
    ret['ignore_nets'] = i_n
    # assign router_location

    # input(ret.keys())
    # input(ret['links'])
    return ret, ca_ip
def regenerate_config(
        savop_dir,
        host_dir,
        input_json,
        out_dir):
    ready_out_dir(out_dir)
    print("step: generate sav-agent, bird, docker_compose, sign_key files")
    base, ca_ip = prepare_base(input_json)
    ca_dir = os.path.join(out_dir, "ca")
    run_dir = "savop_run"
    cp_cmd = f"cp {os.path.join(savop_dir,'topo.sh')} {os.path.join(out_dir,'topo.sh')}"
    run_cmd(cp_cmd)
    
    # build docker compose
    compose_f = open(os.path.join(out_dir, DEVICE_COMPOSE_FILE), 'a')
    compose_f.write("version: \"2\"\n")

    if base["enable_rpki"]:
        key_f = add_rpki_1(compose_f, savop_dir, out_dir, ca_dir, run_dir)
    compose_f.write("\nservices:\n")
    cpu_id = 0
    roa_json = {"ip": "localhost", "port": CA_HTTP_PORT,
                "token": "krill", "add": []}
    aspa_json = {"ip": "localhost", "port": CA_HTTP_PORT,
                 "token": "krill", "add": []}

    # print(f"ignore_nets: {ignore_nets}")
    for node_id in base["devices"]:
        cur_delay = 0
        nodes = base["devices"][node_id]
        nodes["device_id"] = node_id
        node_dir = os.path.join(out_dir, node_id)
        os.makedirs(node_dir)
        # generate bird conf
        cur_delay, bird_config_str, base["devices"][node_id], no_exp_map = gen_bird_conf(
            nodes, cur_delay, base["prefix_method"], base,
            roa_json, aspa_json)
        sa_config = gen_sa_config(
            base,
            nodes)
        phy_links = [x for x in base["links"] if x[2] == LINK_PHYSICAL]
        bird_config_str, sa_config = add_links(base, node_id, bird_config_str,
                                               aspa_json, cur_delay, nodes["as"],
                                               roa_json, sa_config, no_exp_map, phy_links)
        base["devices"][node_id]["bird_cfg_str"] = bird_config_str
        base["devices"][node_id]["sa_cfg"] = sa_config
        # resign keys
        if base["enable_rpki"]:
            resign_keys(out_dir, node_id, key_f,
                        os.path.join(savop_dir, 'rpki'))
        tag = f"{node_id}"
        while host_dir.endswith("/"):
            host_dir = host_dir[:-1]
        cpu_id = write_compose_str(
            node_id, base, host_dir, run_dir, tag, compose_f, cpu_id, ca_ip)
    compose_f.close()
    active_signal = {
        "command": "stop",
        "command_scope": list(base["devices"].keys())
    }
    for node_id in base["devices"]:
        link_map = base["devices"][node_id]["sa_cfg"]["link_map"]
        for link_id, link_data in link_map.items():
            if link_data["link_type"] in RPDP_LINK_TYPES:
                remote_id = link_data["remote_id"]
                base["devices"][node_id]["sa_cfg"]["link_map"][link_id]["remote_location"] = base["devices"][remote_id]["sa_cfg"]["location"]
    for node_id in base["devices"]:
        sa_config = base["devices"][node_id]["sa_cfg"]
        node_dir = os.path.join(out_dir, node_id)
        with open(os.path.join(node_dir, "bird.conf"), 'w') as f:
            f.write(base["devices"][node_id]["bird_cfg_str"])
        run_cmd(f"chmod 666 {node_dir}/bird.conf")
        with open(os.path.join(node_dir, "sa.json"), 'w') as f:
            json.dump(base["devices"][node_id]["sa_cfg"], f, indent=4)
        run_cmd(f"chmod 666 {node_dir}/sa.json")
    with open(os.path.join(out_dir, "active_signal.json"), 'w') as f:
        json.dump(active_signal, f, indent=4)
    ret = run_cmd(f"chmod 666 {out_dir}/active_signal.json")

    topo_f = open(os.path.join(out_dir, "topo.sh"), 'a')
    for src, dst, link_type, src_ip, dst_ip in base["links"]:
        if not link_type == LINK_PHYSICAL:
            continue
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


def resign_keys(out_dir, node, key_f, base_cfg_folder) -> None:
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
                SAV_ROOT_DIR, "sav_router"), logger)
        if not skip_rebuild:
           rebuild_img(
               f"{host_dir}/", file=f"{SAV_OP_DIR}/dockerfiles/reference_router", tag="savop_bird_base", logger=logger)
        container_num = regenerate_config(
            savop_dir,
            host_dir,
            json_content,
            out_dir)
        t = time.time() - t0
        logger.info(
            f"script_builder finished, container_num: {container_num} in {t:.4f} seconds")
        return container_num
    except Exception as e:
        logger.exception(f"script_builder failed: {e}")
        raise
