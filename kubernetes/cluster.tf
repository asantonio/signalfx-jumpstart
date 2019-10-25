/*
resource "signalfx_detector" "k8s_cluster_cpu_capacity" {
  name         = "[SFx] K8S Cluster CPU Capacity approaching limit"
  description  = "Alerts when Cluster is approaching CPU capacity"
  program_text = <<-EOF
    A = data('container_cpu_percent', filter=filter('kubernetes_cluster', '*') and filter('kubernetes_namespace', '*') and filter('sf_tags', '*', match_missing=True) and filter('deployment', '*', match_missing=True), rollup='rate').sum(by=['kubernetes_cluster']).scale(0.01).publish(label='A')
    B = data('kube_node_status_allocatable_cpu_cores', filter=filter('kubernetes_cluster', '*')).sum(by=['kubernetes_cluster']).publish(label='B')
    C = (A/B).publish(label='K8S Cluster CPU Capacity approaching limit')
  EOF
  rule {
    detect_label = "K8S Cluster CPU Capacity approaching limit"
    severity = "Critical"
    disabled = true
  }
}
*/

resource "signalfx_detector" "k8s_cluster_memory_overcommitted" {
  name         = "[SFx] K8S Cluster Memory Overcommitted"
  description  = "Alerts when cluster has overcommitted memory requests and cannot tolerate node failure."
  program_text = <<-EOF
    A = data('kube_node_status_allocatable_memory_bytes', filter=(not filter('azure_resource_id', '*')) and filter('kubernetes_cluster', '*'), rollup='sum').sum(by=['kubernetes_cluster']).publish(label='A', enable=False)
    B = data('kube_pod_container_resource_requests_memory_bytes', filter=filter('kubernetes_cluster', '*') and filter('kubernetes_namespace', '*'), rollup='sum').sum(by=['kubernetes_cluster', 'kubernetes_namespace']).publish(label='B', enable=False)
    C = data('kube_node_status_allocatable_memory_bytes', filter=(not filter('azure_resource_id', '*')) and filter('kubernetes_cluster', '*'), rollup='count').count(by=['kubernetes_cluster']).publish(label='C', enable=False)
    D = (B/A-(C-1)/C).publish(label='D', enable=False)
    detect(when(D > 0)).publish('K8S Cluster Memory Overcommitted')
  EOF
  rule {
    detect_label = "K8S Cluster Memory Overcommitted"
    severity = "Warning"
  }
}

resource "signalfx_detector" "k8s_daemonset_ready_vs_scheduled" {
  name = "[SFx] K8S Cluster DaemonSet ready vs scheduled"
  description = "Alerts when number of ready and scheduled DaemonSets have diverged"
  program_text = <<-EOF
    A = data('kube_daemonset_status_number_ready', filter=filter('kubernetes_cluster', '*') and filter('daemonset', '*')).sum(by=['kubernetes_cluster', 'daemonset']).publish(label='A', enable=False)
    B = data('kube_daemonset_status_desired_number_scheduled', filter=filter('kubernetes_cluster', '*') and filter('daemonset', '*')).sum(by=['kubernetes_cluster', 'daemonset']).publish(label='B', enable=False)
    C = (A-B).publish(label='C')
    detect((when((C > 0) or (C < 0), lasting='5m', at_least=0.95))).publish('K8S Cluster DaemonSet ready and scheduled have diverged')
  EOF
  rule {
    detect_label = "K8S Cluster DaemonSet ready and scheduled have diverged"
    severity     = "Major"
  }
}
