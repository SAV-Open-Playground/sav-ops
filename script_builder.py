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
import subprocess
import json
import netaddr
import copy
import platform


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

    def get_new_ip_pair(self):
        src = copy.deepcopy(self.ip)
        dst = src + 1
        if self.ip.version == 4:
            self.ip += 256
        elif self.ip.version == 6:
            self.ip += 65536
        return src, dst

    def set_ip(self, ip):
        self.ip = netaddr.IPAddress(ip)


def subprocess_cmd(command):
    process = subprocess.run(
        command, shell=True, capture_output=True, encoding='utf-8')
    return process


def run_cmd(command):
    process = subprocess_cmd(command)
    if not process.returncode == 0:
        print(f"run command {command} failed")
        print(process.stderr.encode("utf-8"))
    return process.stdout.encode("utf-8")


def recompile_bird(path=r'{host_dir}/sav-reference-router'):
    os.chdir(path)
    run_cmd("autoreconf")
    run_cmd("./configure")
    run_cmd("make")


def rebuild_img(path=r'{host_dir}', file="docker_file_update_bird_bin", tag="savop_bird_base"):
    """
    build docker image
    rebuild docker image without any tag
    """
    os.chdir(path)
    cmd = f"docker build -f {file} . -t {tag} --no-cache"
    run_cmd(cmd)
    cmd = "docker images| grep 'none' | awk '{print $3}' | xargs docker rmi"
    run_cmd(cmd)


def get_bird_cfg_relation_str(my_as, peer_as, as_relations):
    for provider, customer in as_relations["provider-customer"]:
        if not my_as in [provider, customer]:
            continue
        if not peer_as in [provider, customer]:
            continue
        if my_as == provider:
            return f"\tlocal role provider;\n"
        if my_as == customer:
            return f"\tlocal role customer;\n"
    return f"\tlocal role peer;\n"
    return ""


def gen_bird_conf(node, delay, mode, base, enable_rpdp=True):
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
    if enable_rpki:
        # "\tdebug all;\n" \
        bird_conf_str += "\nroa4 table r4 {	sorted 1; };\n"\
                         "roa6 table r6 { sorted 1; };\n" \
                         "protocol rpki rpki1\n"\
                         "{\n" \
                         "\troa4 {\n" \
                         "\t\ttable r4;\n" \
                         "\t\t};\n" \
                         "\troa6 {\n" \
                         "\t\ttable r6;\n" \
                         "\t\t};\n" \
                         "\tremote 10.10.0.3 port 3323;\n" \
                         "\tretry 1;\n" \
                         "}\n"
    bird_conf_str += "\nipv4 table master4 {sorted 1;};\n" \
                     "ipv6 table master6 {sorted 1;};\n" \
                     "protocol device {\n" \
                     "\tscan time 60;\n" \
                     "\tinterface \"eth_*\";\n" \
                     "};\n" \
                     "protocol kernel {\n" \
                     "\tscan time 60;\n" \
                     "\tipv4 {\n" \
                     "\t\texport all;\n" \
                     "\t\timport all;\n" \
                     "\t};\n" \
                     "\tlearn;\n" \
                     "};\n" \
                     "protocol kernel {\n" \
                     "\tscan time 60;\n" \
                     "\tipv6 {\n" \
                     "\t\texport all;\n" \
                     "\t\timport all;\n" \
                     "\t};\n" \
                     "\tlearn;\n" \
                     "};\n" \
                     "protocol direct {\n" \
                     "\tipv4;\n" \
                     "\tipv6;\n" \
                     "\tinterface \"eth_*\";\n" \
                     "};\n"
    try:
        v = tell_prefix_version(list(node["prefixes"].keys())[0])
    except IndexError:
        v = 4
        # self.logger.warning(f"forcing version to {v}")
    bird_conf_str += "protocol static {\n"
    bird_conf_str += f"\tipv{v} {{\n" \
                     "\t\texport all;\n" \
                     "\t\timport all;\n" \
                     "\t};\n"
    for prefix in node["prefixes"]:
        bird_conf_str += f"\troute {prefix} {mode};\n"
    bird_conf_str += "};\n"
#  "\tdebug all;\n" \
    bird_conf_str += "template bgp basic {\n"
    bird_conf_str += f"\tlocal as {node['as']};\n"
    bird_conf_str += "\tlong lived graceful restart on;\n" \
                     "\tenable extended messages;\n" \
                     "};\n" \
                     "template bgp basic4 from basic {\n" \
                     "\tipv4 {\n" \
                     "\t\texport all;\n" \
                     "\t\timport all;\n" \
                     "\t\timport table on;\n" \
                     "\t};\n" \
                     "};\n" \
                     "template bgp basic6 from basic {\n" \
                     "\tipv6 {\n" \
                     "\t\texport all;\n" \
                     "\t\timport all;\n" \
                     "\t\timport table on;\n" \
                     "\t};\n" \
                     "};\n"
    bird_conf_str += f"template bgp sav_inter from basic{v} "
    bird_conf_str += "{\n"
    if enable_rpdp:
        bird_conf_str += f"\trpdp{v} "
        bird_conf_str += "{\n" \
            "\timport all;\n" \
            "\texport all;\n" \
            "\t};\n"
    bird_conf_str += "};\n"
    link_map = {}
    for src_id, dst_id, link_type, src_ip, dst_ip in base["links"]:
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
        peer_node = all_nodes[peer_id]
        peer_as = peer_node["as"]
        link_map_value = {"link_type": link_type}
        if link_type == "dsav":
            bird_conf_str += f"protocol bgp savbgp_{dev_id}_{peer_id} from sav_inter\n"
        else:
            bird_conf_str += f"protocol bgp savbgp_{dev_id}_{peer_id} from basic\n"

        bird_conf_str += "{\n"
        bird_conf_str += f"\tdescription \"modified BGP between {dev_id} and {peer_id}\";\n"
        if dev_as != peer_as:
            bird_conf_str += get_bird_cfg_relation_str(
                dev_as, peer_as, base["as_relations"])
            # local role peer;
        # get ip
        bird_conf_str += f"\tsource address {my_ip};\n"

        bird_conf_str += f"\tneighbor {peer_ip} as {peer_as};\n"
        # interface "eth_3356";
        bird_conf_str += f"\tconnect delay time {int(delay)};\n"
        delay += 0.1
        bird_conf_str += "\tdirect;\n};\n"
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

    return delay, bird_conf_str, link_map


def gen_sa_config(auto_ip_version, node, link_map, as_scope, app_list, active_app, fib_threshold=5):
    as_scope = as_scope[node["as"]]
    sa_config = {
        "apps": app_list,
        "enabled_sav_app": active_app,
        "fib_stable_threshold": fib_threshold,
        "ca_host": "10.10.0.2",
        "ca_port": 3000,
        "grpc_config": {
            "server_addr": "0.0.0.0:5000",
            "server_enabled": True
        },
        "auto_ip_version": auto_ip_version,
        "link_map": link_map,
        "quic_config": {
            "server_enabled": True
        },
        "local_as": node["as"],
        "prefixes": node["prefixes"],
        "router_id": as_scope[node["device_id"]]["router_id"],
        "location": "edge_full",
        "as_scope": as_scope,
    }
    return sa_config


def refresh_folder(src, dst):
    if os.path.exists(dst):
        run_cmd(f"rm -r {dst}")
    run_cmd(f"cp -r {src} {dst}")


def ready_input_json(json_content, selected_nodes):
    base = json_content
    if not "fib_threshold" in base:
        print("fib_threshold not found, using default value 60")
        base["fib_threshold"] = 300
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
        if not dev_as in as_scope:
            as_scope[dev_as] = {dev_id: [dev_ip]}
        else:
            if not dev_id in as_scope[dev_as]:
                as_scope[dev_as][dev_id] = [dev_ip]
            else:
                as_scope[dev_as][dev_id].append(dev_ip)

    return as_scope


def regenerate_config(savop_dir, host_dir, input_json, base_config_dir, selected_nodes,  out_folder):
    if os.path.exists(out_folder):
        run_cmd(f"rm -r {out_folder}")
    os.makedirs(out_folder)
    base = ready_input_json(input_json, selected_nodes)
    base = assign_ip(base)

    # compose
    for f in ["sign_key.sh", "topo.sh"]:
        cp_cmd = f"cp {os.path.join(base_config_dir, f)} {os.path.join(out_folder, f)}"
        run_cmd(cp_cmd)
    refresh_folder(os.path.join(base_config_dir, "ca"),
                   os.path.join(out_folder, "ca"))
    # build docker compose
    compose_f = open(os.path.join(out_folder, "docker-compose.yml"), 'a')
    compose_f.write("version: \"2\"\n")
    key_f = open(os.path.join(out_folder, 'sign_key.sh'), 'a')
    if base["enable_rpki"]:
        docker_network_content = "networks:\n" \
                                 "  build_ca_net:\n" \
                                 "    external: true\n" \
                                 "    ipam:\n" \
                                 "      driver: default\n" \
                                 "      config:\n" \
                                 "        - subnet: \"10.10.0.0/16\"\n"
        compose_f.write(docker_network_content)
    compose_f.write("\nservices:\n")
    ca_ip = netaddr.IPAddress("::ffff:10.10.0.3")

    for node in base["devices"]:
        cur_delay = 0
        nodes = base["devices"][node]
        nodes["device_id"] = node
        rpdp_enable = "rpdp_app" in base["sav_apps"]
        # generate bird conf
        cur_delay, bird_config_str, link_map = gen_bird_conf(
            nodes, cur_delay, "blackhole", base, rpdp_enable)
        node_folder = os.path.join(out_folder, node)
        if not os.path.exists(node_folder):
            os.makedirs(node_folder)
        with open(os.path.join(node_folder, "bird.conf"), 'w') as f:
            f.write(bird_config_str)
        ret = run_cmd(command=f"chmod 666 {node_folder}/bird.conf")

        sa_config = gen_sa_config(base["auto_ip_version"],
                                  nodes, link_map, base["as_scope"], base["sav_apps"],
                                  base["active_sav_app"], fib_threshold=base["fib_threshold"])
        with open(os.path.join(node_folder, "sa.json"), 'w') as f:
            json.dump(sa_config, f, indent=4)
        # resign keys
        if base["enable_rpki"]:
            resign_keys(out_folder, node, key_f, base_config_dir)
        tag = f"{node}"
        while host_dir.endswith("/"):
            host_dir = host_dir[:-1]
        # TODO resource limit
        resource_limit = False

        docker_compose_content = f"  r{tag}:\n" \
            f"    sysctls:\n" \
            f"      - net.ipv6.conf.all.disable_ipv6=0\n" \
            f"    image: savop_bird_base\n" \
            f"    init: true\n" \
            f"    container_name: \"r{tag}\"\n" \
            f"    cap_add:\n" \
            f"      - NET_ADMIN\n" \
            f"    deploy:\n"
        if resource_limit:
            docker_compose_content += f"      resources:\n" \
                f"        limits:\n" \
                f"          cpus: '0.3'\n" \
                f"          memory: 512M\n"
        docker_compose_content += f"    volumes:\n" \
            f"      - type: bind\n" \
            f"        source: {host_dir}/savop_run/{node}/bird.conf\n" \
            f"        target: /usr/local/etc/bird.conf\n" \
            f"      - type: bind\n" \
            f"        source: {host_dir}/savop_run/{node}/sa.json\n" \
            f"        target: /root/savop/SavAgent_config.json\n" \
            f"      - {host_dir}/savop_run/{node}/log/:/root/savop/logs/\n" \
            f"      - {host_dir}/savop_run/{node}/log/data:/root/savop/sav-agent/data/\n" \
            f"      - type: bind\n" \
            f"        source: {host_dir}/savop_run/active_signal.json\n" \
            f"        target: /root/savop/signal.json\n" \
            f"      - /etc/localtime:/etc/localtime\n"
        if base["enable_rpki"]:
            docker_compose_content += f"      - {host_dir}/savop_run/{node}/cert.pem:/root/savop/cert.pem\n"
            docker_compose_content += f"      - {host_dir}/savop_run/{node}/key.pem:/root/savop/key.pem\n"
            docker_compose_content += f"      - {host_dir}/savop_run/ca/cert.pem:/root/savop/ca_cert.pem\n"
        docker_compose_content += f"    command:\n" \
            f"        python3 /root/savop/sav-agent/sav_control_container.py\n" \
            f"    privileged: true\n"
        compose_f.write(docker_compose_content)
        if base["enable_rpki"]:
            docker_compose_content = "    networks:\n" \
                                     "      savop-dev_ca_net:\n" \
                                     "        ipv4_address: {str(ca_ip)}\n"
            compose_f.write(docker_compose_content)
        else:
            compose_f.write("    network_mode: none\n")

    compose_f.close()
    key_f.close()
    active_signal = {
        "command": "stop",
        "source": base["active_sav_app"],
        "command_scope": list(base["devices"].keys()),
        "stable_threshold": base["fib_threshold"]
    }
    with open(os.path.join(out_folder, "active_signal.json"), 'w') as f:
        json.dump(active_signal, f, indent=4)
    ret = run_cmd(command=f"chmod 666 {out_folder}/active_signal.json")

    topo_f = open(os.path.join(out_folder, "topo.sh"), 'a')
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
    # os.chdir(out_folder)
    # run_cmd("bash sign_key.sh")
    return len(base["devices"])


def resign_keys(out_folder, node, key_f, base_cfg_folder):
    run_cmd(
        f"cp {os.path.join(base_cfg_folder, 'req.conf')} {os.path.join(out_folder, node)}")
    with open(os.path.join(out_folder, node, "sign.ext"), 'w') as f:
        sign_content = "authorityKeyIdentifier=keyid,issuer\n" \
                       "basicConstraints=CA:FALSE\n" \
                       "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment\n" \
                       f"subjectAltName = DNS:{node}, DNS:localhost"
        f.write(sign_content)
    key_f.write(f"\rfunCGenPrivateKeyAndSign ./{node} ./ca")


def script_builder(host_dir, savop_dir, json_content, out_folder, skip_bird=False, skip_img=False):
    if skip_bird:
        recompile_bird(os.path.join(host_dir, "sav-reference-router"))
    if skip_img:
        rebuild_img(host_dir)
    base_cfg_folder = os.path.join(savop_dir, "base_configs")
    selected_nodes = None
    device_number = regenerate_config(
        savop_dir, host_dir, json_content, base_cfg_folder, selected_nodes, out_folder)
    return device_number
