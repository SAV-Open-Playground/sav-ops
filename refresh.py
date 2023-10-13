"""
1. recompile bird
2. rebuild docker images
3. regenerate config files
4. regenerate keys
5. regenerate compose.yml and topo.sh for the given node and links
"""


import os,sys
import subprocess
import json
import netaddr

def subprocess_cmd(command):
    process =  subprocess.run(command, shell=True, capture_output=True, encoding='utf-8')
    return process
def run_cmd(command):
    process = subprocess_cmd(command)
    if not process.returncode==0:
        print(f"run command {command} failed")
        print(process.stderr.encode("utf-8"))
    return process.stdout.encode("utf-8")
def recompile_bird(path=r'/root/savop-dev/sav-reference-router'):
    os.chdir(path)
    run_cmd("make")
def rebuild_img(path=r'/root/savop-dev',file="docker_file_update_bird_bin",tag = "savop_bird_base"):
    """
    build docker image
    rebuild docker image without any tag
    """
    os.chdir(path)
    cmd = f"docker build -f {file} . -t {tag} --no-cache"
    run_cmd(cmd)
    cmd = "docker images| grep 'none' | awk '{print $3}' | xargs docker rmi"
    run_cmd(cmd)
def gen_bird_conf(node,all_nodes,enable_rpki,possible_ip,delay,mode="blackhole"):
    bird_conf_str = f"router id {node['router_id']};"
    if enable_rpki:
        bird_conf_str += \
"""
roa4 table r4{
	sorted 1;
};
protocol rpki rpki1
{
	debug all;
	roa4 { table r4; };
	remote 10.10.0.3 port 3323;
	retry 1;
}
"""
    bird_conf_str += \
"""
ipv4 table master4{
	sorted 1;
};

protocol device {
	scan time 60;
	interface "eth_*";
};
protocol kernel {
	scan time 60;
	ipv4 {
		export all;
		import all;
	};
	learn;
};
protocol direct {
	ipv4;
	interface "eth_*";
};

protocol static {
	ipv4 {
		export all;
		import all;
	};
"""
    for prefix in node["prefixes"]:
        bird_conf_str += f"\troute {prefix} {mode};\n"
    bird_conf_str += \
"""};
template bgp basic{
"""
    bird_conf_str += f"\tlocal as {node['as']};\n"
	long lived graceful restart on;
	debug all;
	enable extended messages;
	ipv4{
		export all;
		import all;
		import table on;
	};
};
template bgp sav_inter from basic{
	rpdp4{
		import none;
		export none;
	};
};
"""
    link_map = {}
    for link in node["links"]:
        if len(link) == 2:
            peer_id,link_type = link
            my_ip = possible_ip
            possible_ip += 1
        elif len(link) == 3:
            peer_id,link_type,my_ip = link
            input(link)
        my_id = node["router_id"]
        my_as = node["as"]
        peer_node = all_nodes[peer_id]
        peer_as = peer_node["as"]
        if link_type == "dsav":
            bird_conf_str += f"protocol bgp savbgp_{my_id}_{peer_id} from sav_inter\n"
        else:
            bird_conf_str += f"protocol bgp savbgp_{my_id}_{peer_id} from basic\n"
            link_map_value = {"link_type":link_type}
        
        bird_conf_str += "{\n"
        bird_conf_str += f"\tdescription \"modified BGP between {my_id} and {peer_id}\";\n"
        if my_as != peer_as:
            input("external, need to code role")
            # local role peer;
        # get ip
        bird_conf_str += f"\tsource address {my_ip};\n"
        for temp_link in peer_node["links"]:
            if len(temp_link) == 2:
                temp_peer_id = temp_link[0]
                if temp_peer_id == my_id:
                    peer_ip = possible_ip
                    possible_ip += 1
                    break
            elif len(temp_link) == 3:
                temp_peer_id = temp_link[0]
                if temp_peer_id == my_id:
                    peer_ip = temp_link[2]
                    break
                
        bird_conf_str += f"\tneighbor {peer_ip} as {peer_as};\n"
        # interface "eth_3356";
        bird_conf_str += f"\tconnect delay time {delay};\n"
        delay += 0.1
        bird_conf_str += "\tdirect;\n};\n"
        link_map_value["link_data"]= {
        "peer_ip": {peer_ip},
        "peer_id": peer_id
      }
        match link_type:
            case "dsav":
                pass
            case "grpc":
                link_map_value["link_data"]["peer_port"] = 5000
                link_map[f"savbgp_{my_id}_{peer_id}"] = link_map_value
            case "quic":
                link_map_value["link_data"]["peer_port"] = 7777
                link_map[f"savbgp_{my_id}_{peer_id}"] = link_map_value
            case _:
                raise NotImplementedError
        
        
    return possible_ip,delay,bird_conf_str,link_map
def gen_sa_config(node,link_map,apps =["rpdp_app"],active_app="rpdp_app",fib_threshold=5):
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
                "link_map": link_map,
                "quic_config": {
                "server_enabled": True
                },
                "local_as": node["as"],
  "rpdp_id": "10.0.6.2",
  "location": "edge_full"
}
    print(node)
def regenerate_config(input_json,out_folder = r'/root/savop-dev/savop/this_config/',selected_nodes= None):
    with open(input_json, 'r') as f:
        base = json.load(f)
    # print(base)
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
    for src,dst,link_type in base["links"]:
        if not "links" in base["devices"][src]:
            base["devices"][src]["links"] = []
        if not "links" in base["devices"][dst]:
            base["devices"][dst]["links"] = []
        base["devices"][src]["links"].append([dst,link_type])
        base["devices"][dst]["links"].append([src,link_type])
    possible_ip = netaddr.IPAddress("::ffff:10.0.1.1")
    delay = 0
    for node in base["devices"]:
        temp = base["devices"][node]
        temp["router_id"] = node
        possible_ip,delay,bird_config_str,link_map = gen_bird_conf(temp,base["devices"],base["enable_rpki"],possible_ip,delay)
        node_folder = os.path.join(out_folder,node)
        if not os.path.exists(node_folder):
            os.makedirs(node_folder)
        with open(os.path.join(node_folder,"bird.conf"),'w') as f:
            f.write(bird_config_str)
        sa_config = gen_sa_config(temp,link_map)
        input("press any key to continue")
    
    # os.chdir(path)
    # items = os.listdir()
    # print(items)
    # cmd = f"rm -r {out_folder}"
    # run_cmd(cmd)
    # cmd = f"cp -r {path} {out_folder}"
    # run_cmd(cmd)
    # # cmd = "python3 sav_config_generator.py"
    # # run_cmd(cmd)
def resign_keys():
    raise NotImplementedError
def refresh_intra():
    # recompile_bird()
    # rebuild_img()
    regenerate_config(input_json=r'/root/savop-dev/savop/base_configs/classic_3.json',out_folder = r'/root/savop-dev/savop/this_config/')
if __name__ == "__main__":
    refresh_intra()