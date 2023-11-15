"""
1. recompile bird
2. rebuild docker images
3. regenerate config files
4. regenerate keys
5. regenerate compose.yml and topo.sh for the given node and links
"""


import os
import sys
import subprocess
import json
import netaddr
import copy


class IPGenerator():
    def __init__(self, ip="fec::1:1"):
        self.set_ip(ip)

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


def recompile_bird(path=r'/root/savop-dev/sav-reference-router'):
    os.chdir(path)
    run_cmd("make")


def rebuild_img(path=r'/root/savop-dev', file="docker_file_update_bird_bin", tag="savop_bird_base"):
    """
    build docker image
    rebuild docker image without any tag
    """
    os.chdir(path)
    cmd = f"docker build -f {file} . -t {tag} --no-cache"
    run_cmd(cmd)
    cmd = "docker images| grep 'none' | awk '{print $3}' | xargs docker rmi"
    run_cmd(cmd)


def gen_bird_conf(node, delay, mode, base):
    """
    add everything but actual bgp links
    """
    # raise ValueError(base)
    ip_version = base["ip_version"]
    all_nodes = base["devices"]
    dev_id = node["device_id"]
    dev_as = node["as"]
    router_id = base["as_scope"][dev_as][dev_id]["router_id"]
    enable_rpki = base["enable_rpki"]
    bird_conf_str = f"router id {str(netaddr.IPAddress(router_id))};\n"
    if enable_rpki:
        bird_conf_str += f"roa{ip_version} table r{ip_version}" + "{"
        bird_conf_str += \
            """
	sorted 1;
};
protocol rpki rpki1
{
    debug all;"""
        bird_conf_str += f"    roa{ip_version}" + \
            "{ table r" + f"{ip_version};" + "};"
        bird_conf_str += \
            """
    remote 10.10.0.3 port 3323;
    retry 1;
}
"""
    bird_conf_str += f"ipv{ip_version} table master{ip_version}" + "{"
    bird_conf_str += \
        """
	sorted 1;
};

protocol device {
	scan time 60;
	interface "eth_*";
};
protocol kernel {
	scan time 60;
"""
    bird_conf_str += f"    ipv{ip_version} " + "{"
    bird_conf_str += \
        """
		export all;
		import all;
	};
	learn;
};
protocol direct {
"""
    bird_conf_str += f"    ipv{ip_version}; "
    bird_conf_str += \
        """
	interface "eth_*";
};

protocol static {
"""
    bird_conf_str += f"    ipv{ip_version} " + "{"
    bird_conf_str += \
        """
		export all;
		import all;
	};
"""
    for prefix in node["prefixes"]:
        bird_conf_str += f"\troute {prefix} {mode};\r"
    bird_conf_str += \
        """};
template bgp basic{
"""
    bird_conf_str += f"\tlocal as {node['as']};"
    bird_conf_str += \
        """
	long lived graceful restart on;
	debug all;
	enable extended messages;
"""
    bird_conf_str += f"    ipv{ip_version} " + "{"
    bird_conf_str += \
        """
        export all;
        import all;
        import table on;
    };
};
template bgp sav_inter from basic{
"""
    bird_conf_str += f"    rpdp{ip_version} " + "{"
    bird_conf_str += \
        """
		import none;
		export none;
	};
};
"""
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
            bird_conf_str += f"protocol bgp savbgp_{dev_id}_{peer_id} from sav_inter\r"
        else:
            bird_conf_str += f"protocol bgp savbgp_{dev_id}_{peer_id} from basic\r"

        bird_conf_str += "{\r"
        bird_conf_str += f"\tdescription \"modified BGP between {dev_id} and {peer_id}\";\r"
        if dev_as != peer_as:
            input("external, need to code role")
            raise NotImplementedError
            # local role peer;
        # get ip
        bird_conf_str += f"\tsource address {my_ip};\r"

        bird_conf_str += f"\tneighbor {peer_ip} as {peer_as};\r"
        # interface "eth_3356";
        bird_conf_str += f"\tconnect delay time {int(delay)};\r"
        delay += 0.1
        bird_conf_str += "\tdirect;\r};\r"
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


def gen_sa_config(ip_version, node, link_map, as_scope, apps=["rpdp_app"], active_app="rpdp_app", fib_threshold=1):
    as_scope = as_scope[node["as"]]
    sa_config = {
        "apps": apps,
        "enabled_sav_app": active_app,
        "fib_stable_threshold": fib_threshold,
        "ca_host": "10.10.0.2",
        "ca_port": 3000,
        "grpc_config": {
            "server_addr": "0.0.0.0:5000",
            "server_enabled": True
        },
        "ip_version": ip_version,
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


def ready_input_json(input_json, selected_nodes):
    with open(input_json, 'r') as f:
        base = json.load(f)
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


def assign_ip(base, ip_version):
    """
    assign ip to each link (device)
    """
    a = IPGenerator()
    as_scope = {}
    if ip_version == 4:
        raise NotImplementedError
    elif ip_version == 6:
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
    else:
        raise NotImplementedError


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


def regenerate_config(input_json, out_folder=r'/root/savop-dev/savop/this_config/', selected_nodes=None):
    if os.path.exists(out_folder):
        run_cmd(f"rm -r {out_folder}")
    os.makedirs(out_folder)
    base = ready_input_json(input_json, selected_nodes)
    base = assign_ip(base, ip_version=6)
    delay = 0
    # compose
    run_cmd("cp /root/savop-dev/savop/base_configs/docker-compose.yml /root/savop-dev/savop/this_config/docker-compose.yml")
    run_cmd(
        f"cp /root/savop-dev/savop/base_configs/sign_key.sh {os.path.join(out_folder,'sign_keys.sh')}")
    run_cmd("cp /root/savop-dev/savop/base_configs/topo.sh /root/savop-dev/savop/this_config/topo.sh")
    refresh_folder("/root/savop-dev/savop/base_configs/ca",
                   os.path.join(out_folder, "ca"))
    # refresh_folder("/root/savop-dev/sav-agent",os.path.join(out_folder,"sav-agent"))
    # build docker compose
    compose_f = open(os.path.join(
        out_folder, "docker-compose.yml"), 'a', newline='\r')
    key_f = open(os.path.join(out_folder, 'sign_keys.sh'), 'a', newline='\r')
    if base["enable_rpki"]:
        compose_f.write(
            """
networks:
  build_ca_net:
    external: true
    ipam:
      driver: default
      config:
        - subnet: "10.10.0.0/16\""""
        )
    compose_f.write("\rservices:")
    ca_ip = netaddr.IPAddress("::ffff:10.10.0.3")
    for node in base["devices"]:
        temp = base["devices"][node]
        temp["device_id"] = node
        delay, bird_config_str, link_map = gen_bird_conf(
            temp, delay, "blackhole", base)
        node_folder = os.path.join(out_folder, node)
        if not os.path.exists(node_folder):
            os.makedirs(node_folder)
        with open(os.path.join(node_folder, "bird.conf"), 'w', newline='\r') as f:
            f.write(bird_config_str)
        sa_config = gen_sa_config(
            base["ip_version"], temp, link_map, base["as_scope"])
        with open(os.path.join(node_folder, "sa.json"), 'w', newline='\r') as f:
            json.dump(sa_config, f, indent=4)
        # resign keys
        # if base["enable_rpki"]:
        resign_keys(out_folder, node, key_f)
        tag = f"r{node}"
        compose_f.write(
            f"""
  "{tag}": 
    sysctls:
      - net.ipv6.conf.all.disable_ipv6=0
    image: savop_bird_base 
    init: true 
    container_name: "{tag}"
    cap_add: 
      - NET_ADMIN 
    deploy:
      resources:
        limits:
          cpus: '0.3'
          memory: 512M
    volumes:
      - /root/savop-dev/savop/reference_and_agent/router_kill_and_start.sh:/root/savop/router_kill_and_start.sh
      - type: bind
        source: /root/savop-dev/sav-agent/
        target: /root/savop/sav-agent/
      - type: bind
        source:  /root/savop-dev/savop/this_config/{node}/bird.conf
        target: /usr/local/etc/bird.conf 
      - type: bind
        source: /root/savop-dev/savop/this_config/{node}/sa.json
        target: /root/savop/SavAgent_config.json 
      - /root/savop-dev/savop/this_config/{node}/log/:/root/savop/logs/ 
      - /root/savop-dev/savop/this_config/{node}/log/data:/root/savop/sav-agent/data/ 
      - type: bind
        source: /root/savop-dev/savop/this_config/active_signal.json
        target: /root/savop/signal.json
      - /etc/localtime:/etc/localtime 
      - /root/savop-dev/savop/this_config/{node}/cert.pem:/root/savop/cert.pem 
      - /root/savop-dev/savop/this_config/{node}/key.pem:/root/savop/key.pem 
      - /root/savop-dev/savop/this_config/ca/cert.pem:/root/savop/ca_cert.pem 
    command: 
        python3 /root/savop/sav-agent/unisav_bot.py  
    privileged: true""")
        if base["enable_rpki"]:
            compose_f.write(
                f"""
    networks: 
      savop-dev_ca_net: 
        ipv4_address: {str(ca_ip)} 

""")
        else:
            compose_f.write("\r    network_mode: none")

    compose_f.close()
    key_f.close()
    active_signal = {
        "command": "stop",
        "source": "rpdp_app",
        "command_scope": list(base["devices"].keys()),
        "stable_threshold": 5
    }
    with open(os.path.join(out_folder, "active_signal.json"), 'w') as f:
        json.dump(active_signal, f, indent=4)

    topo_f = open(os.path.join(out_folder, "topo.sh"), 'a', newline='\r')
    for src, dst, link_type, src_ip, dst_ip in base["links"]:
        topo_f.write(f'\recho "adding edge r{src}-r{dst}"')
        if not src_ip.version == dst_ip.version:
            raise NotImplementedError
        topo_f.write(
            f"\rfunCreateV{src_ip.version} 'r{src}' 'r{dst}' '{src_ip}/124' '{dst_ip}/124'")
    topo_f.close()
    os.chdir("/root/savop-dev/")
    run_cmd("python3 change_eol.py")
    os.chdir(out_folder)
    run_cmd("bash sign_keys.sh")
    return len(base["devices"])


def resign_keys(out_folder, node, key_f):
    run_cmd(
        f"cp /root/savop-dev/savop/base_configs/req.conf {os.path.join(out_folder,node)}")
    with open(os.path.join(out_folder, node, "sign.ext"), 'w') as f:
        f.write(
            f"""authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = DNS:{node}, DNS:localhost""")
    key_f.write(f"\rfunCGenPrivateKeyAndSign ./{node} ./ca")


def refresh_intra(input_json=r'/root/savop-dev/savop/base_configs/classic_3.json', out_folder=r'/root/savop-dev/savop/this_config/'):
    # recompile_bird()
    # rebuild_img()
    return regenerate_config(input_json, out_folder)


def refresh_inter(input_json=r'/root/savop-dev/savop/base_configs/classic_3.json', out_folder=r'/root/savop-dev/savop/this_config/'):
    return regenerate_config(input_json, out_folder)


if __name__ == "__main__":
    refresh_intra()
