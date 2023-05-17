import time
import click
import os
from subprocess import run, PIPE, Popen

@click.command()
@click.option('-k', '--kubeconfig', required=True)
def teardown(kubeconfig):
    if os.path.exists(kubeconfig) == False:
        raise Exception("Kubeconfig file doesn't exist")
    
    get_clusters_cmd=f'kubectl --kubeconfig {kubeconfig} get Clusters --no-headers -o=custom-columns=":metadata.name"'
    proc = Popen(get_clusters_cmd, shell=True, stdout=PIPE, stderr=PIPE)
    outs, errs = proc.communicate(None)
    if len(errs) != 0:
        raise Exception("error getting clusters")
    for line in outs.splitlines():
        name=line.decode('utf-8')
        delete_cluster_cmd=f'kubectl --kubeconfig {kubeconfig} delete Cluster {name}'
        proc = Popen(delete_cluster_cmd, shell=True, stdout=PIPE, stderr=PIPE)
        outs, errs = proc.communicate(None)
        if len(errs) != 0:
            raise Exception(f'error deleting cluster {name}: {errs}')

    click.echo("Finished")


if __name__=='__main__':
    teardown()