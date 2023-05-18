from string import Template
import time
import click
import os
from subprocess import run, PIPE, Popen
from datetime import datetime

@click.command()
@click.option("-d", "--docker-hosts", required=True, type=click.File('r'), help="A path to a file containing the docker hosts to use")
@click.option("-t", "--template", required=True, type=click.File('r'))
@click.option("-n", "--num", default=1, type=int)
@click.option("-s", "--step", default=1, type=int)
@click.option('-k', '--kubeconfig', required=True)
@click.option('--start', default=0, type=int)
@click.option('--multi-ns', is_flag=True, show_default=True, default=False, help="If true will create a namespace per cluster")
def generate(docker_hosts, template, num, step, kubeconfig, start, multi_ns):
    startTime =  datetime.now()
    hostips=[]
    for line in docker_hosts:
        ip = line.strip()
        if len(ip) > 0:
            hostips.append(ip)

    if len(hostips)==0:
        raise Exception("No host ips")
    
    if os.path.exists(kubeconfig) == False:
        raise Exception("Kubeconfig file doesn't exist")
    
    template_contents = template.read()
    current_ip_index=0
    for cluster_num in range(start, num):
        namespace='default'
        if multi_ns:
            namespace=f'ns{cluster_num}'
            create_namespace(namespace, kubeconfig)
        host_ip=hostips[current_ip_index]
        tokens = dict(cluster_num=cluster_num,host=host_ip,worker_machine_count=1,control_plane_machine_count=1, namespace=namespace)
        src = Template(template_contents)
        result = src.substitute(tokens)
        

        kubectl_command=['kubectl', '--kubeconfig', kubeconfig, '-n', namespace, 'apply', '-f', '-'] #, '--dry-run=server']
        p = run(kubectl_command, input=result, encoding='ascii')
        if p.returncode != 0:
            raise Exception(f'No zero return code from kubectl command: {p.returncode}')

        if cluster_num % step == 0:
            while True:
                kubectl_command_get=f'kubectl --kubeconfig {kubeconfig} get Machines -A -o custom-columns="POD-NAME":.metadata.name,"PHASE":.status.phase | grep -v POD-NAME | grep -v Running | wc -l'
                proc = Popen(kubectl_command_get, shell=True, stdout=PIPE, stderr=PIPE)
                outs, errs = proc.communicate(None)
                if len(errs) != 0:
                    raise Exception("error getting machines")
                not_running = int(outs)
                if not_running == 0:
                    break
                print("waiting for all machines to be running")
                time.sleep(5) # sleep 5 seconds


        current_ip_index+=1
        if current_ip_index == len(hostips):
            current_ip_index=0

    endTime = datetime.now()
    delta = endTime - startTime
    click.echo(f'Finished in {delta.total_seconds()}')

def create_namespace(name, kubeconfig):
    kubectl_command=['kubectl', '--kubeconfig', kubeconfig, 'create', 'namespace', name] #, '--dry-run=server']
    p = run(kubectl_command)
    if p.returncode != 0:
        raise Exception(f'No zero return code from kubectl command to create namespace: {p.returncode}')


if __name__=='__main__':
    generate()