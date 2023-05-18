import json
import click
import os
import datetime
from subprocess import run, PIPE, Popen

@click.command()
@click.option('-k', '--kubeconfig', required=True)
def teardown(kubeconfig):
    if os.path.exists(kubeconfig) == False:
        raise Exception("Kubeconfig file doesn't exist")
    
    get_clusters_cmd=f'kubectl --kubeconfig {kubeconfig} get Clusters -A --no-headers -o=custom-columns=":metadata.name,:metadata.namespace"'
    proc = Popen(get_clusters_cmd, shell=True, stdout=PIPE, stderr=PIPE)
    outs, errs = proc.communicate(None)
    if len(errs) != 0:
        raise Exception("error getting clusters")
    print('cluster,cpinitdelta,readydelat,createtime,inittime,readytime')
    for line in outs.splitlines():
        line_decoded=line.decode('utf-8')
        items = line_decoded.split()
        name = items[0]
        namespace = items[1]
        get_cluster_cmd=f'kubectl --kubeconfig {kubeconfig} --namespace {namespace} get Cluster {name} -o json'
        proc = Popen(get_cluster_cmd, shell=True, stdout=PIPE, stderr=PIPE)
        outs, errs = proc.communicate(None)
        if len(errs) != 0:
            raise Exception(f'error getting cluster {name}: {errs}')
        cluster_json = outs.decode('utf-8')
        cluster = json.loads(cluster_json)
        creation_time_str = cluster['metadata']['creationTimestamp']
        creation_time = datetime.datetime.strptime(creation_time_str, '%Y-%m-%dT%H:%M:%SZ')
        conditions = cluster['status']['conditions']
        cond_init_str = getConditionTimeStamp(conditions, 'ControlPlaneReady')
        cond_init = datetime.datetime.strptime(cond_init_str, '%Y-%m-%dT%H:%M:%SZ')
        cond_ready_str = getConditionTimeStamp(conditions, 'Ready')
        cond_ready = datetime.datetime.strptime(cond_ready_str, '%Y-%m-%dT%H:%M:%SZ')

        init_delta = cond_init - creation_time
        ready_delta = cond_ready - creation_time
        print(f'{name},{init_delta.total_seconds()},{ready_delta.total_seconds()},{creation_time_str},{cond_init_str},{cond_ready_str}')


def getConditionTimeStamp(conditions, condition_type):
    for cond in conditions:
        if cond['type'] == condition_type and cond['status'] == "True":
            return cond['lastTransitionTime']
    return None

if __name__=='__main__':
    teardown()