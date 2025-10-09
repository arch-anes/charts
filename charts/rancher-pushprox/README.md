# rancher-pushprox

This chart has been copied from https://github.com/rancher/charts/tree/dev-v2.12/charts/rancher-monitoring/107.2.0%2Bup69.8.2-rancher.20/charts/k3sServer.

## Configuration

The following tables list the configurable parameters of the rancher-pushprox chart and their default values.

### General

#### Required
| Parameter | Description | Example |
| ----- | ----------- | ------ |
| `component` | The component that is being monitored | `kube-etcd`
| `metricsPort` | The port on the host that contains the metrics you want to scrape (e.g. `http://<HOST_IP>:<metricsPort>/metrics`) | `2379` |
| `namespaceOverride` | The namespace to install the chart | `""`

#### Optional
| Parameter | Description | Default |
| ----- | ----------- | ------ |
| `serviceMonitor.enabled` | Deploys a [Prometheus Operator](https://github.com/coreos/prometheus-operator/blob/master/Documentation/api.md#servicemonitor) ServiceMonitor CR that is configured to scrape metrics on the hosts that the clients are deployed on via the proxy. Also deploys a Service that points to all pods with the expected client name that exposes the `metricsPort` selected | `true` |
| `serviceMonitor.endpoints` | A list of endpoints that will be added to the ServiceMonitor based on the [Endpoint spec](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#endpoint) | `[{port: metrics}]` |
| `service.selector` | The selector that is used to populate the Service's Endpoints object. The chart will error out on rendering templating if `.Values.clients.enabled` is set alongside this field, since it is expected that this service should point to the PushProx Clients Daemonset / Deployment | `{}` |
| `clients.enabled` | Deploys a DaemonSet of clients that are each capable of scraping endpoints on the hostNetwork it is deployed on | `true` |
| `clients.port` |  The port where the client will publish PushProx client-specific metrics. If deploying multiple clients onto the same node, the clients should not have conflicting ports | `9369` |
| `clients.proxyUrl` | Overrides the default proxyUrl setting of `http://pushprox-{{ .Values.component }}-proxy.{{ . Release.Namespace }}.svc.cluster.local:{{ .Values.proxy.port }}"` with the `proxyUrl` specified | `""` |
| `clients.useLocalhost` | Sets a flag on each client deployment to redirect scrapes directed to `HOST_IP` to `127.0.0.1` | `false` |
| `clients.https.enabled` | Enables scraping metrics via HTTPS using the provided TLS certs that exist on each host | `false` |
| `clients.https.forceHTTPSScheme` | Forces scraping metrics via HTTPS using the provided TLS certs that exist on each host | `false` |
| `clients.https.useServiceAccountCredentials` | If set to true, the client will create a service account with permissions to scrape `/metrics` endpoint of Kubernetes components. The client will use the service account token provided to make authorized scrape requests to the Kubernetes API | `false` |
| `clients.https.authenticationMethod.bearerTokenFile.enabled` | If set to true, the client will use service account credentials mounted at the configured path `clients.https.authenticationMethod.bearerTokenFile.bearerTokenFilePath`. This requires permissions to scrape `/metrics` endpoint of Kubernetes components. This method is deprecated by the prometheus operator and may be removed in a future release | `false` |
| `clients.https.authenticationMethod.bearerTokenFile.bearerTokenFilePath` | This is a volume mount on the pod with permissions to scrape `/metrics` endpoint of Kubernetes components | `"/var/run/secrets/kubernetes.io/serviceaccount/token"` |
| `clients.https.authenticationMethod.bearerTokenSecret.enabled` | If set to true, the client will use service account credentials to scrape `/metrics` endpoint of Kubernetes components. This method is deprecated by the prometheus operator and may be removed in a future release | `false` |
| `clients.https.authenticationMethod.authorization.enabled` | If set to true, the client will use service account credentials to scrape `/metrics` endpoint of Kubernetes components | `false` |
| `clients.https.authenticationMethod.authorization.type` | If set, the client will use this type of authorization in its client requests for metrics | `"bearer"` |
| `clients.https.authenticationMethod.authorization.credentials.key` | If set, the client will use this key in the secret created by `clients.https.useServiceAccountCredentials` for authorization in its client requests for metrics | `"token"` |
| `clients.https.authenticationMethod.authorization.credentials.optional` | If set to false, the client will fail if the key in the secret created by `clients.https.useServiceAccountCredentials` does not exist | `false` |
| `clients.https.insecureSkipVerify` | If set to true, the client will disable SSL security checks | `false` |
| `clients.https.certDir` | A `hostPath` where TLS certs can be found. This path is mounted as a volume on an `initContainer` which copies only the necessary files over to an EmptyDir volume used by each client. Required and only used if `clients.https.enabled` is set | `""` |
| `clients.https.certFile` | The path to the TLS cert file located within `clients.https.certDir`. Required and only used if `clients.https.enabled` is set | `""` |
| `clients.https.keyFile` | The path to the TLS key file located within `clients.https.certDir`. Required and only used if `clients.https.enabled` is set | `""` |
| `clients.https.caCertFile` | The path to the TLS cacert file located within `clients.https.certDir`. Required and only used if `clients.https.enabled` is set | `""` |
| `clients.https.seLinuxOptions` | seLinuxOptions to be passed into the container that copies certs. Should define a container with permissions to read the files in the certDir provided on the host. Required and only used if `clients.https.enabled` is set and `clients.https.certDir` is provided. | `""` |
| `clients.metrics.enabled` | Whether the client should publish PushProx client-specific metrics. | `false` |
| `clients.rbac.additionalRules` | Additional permissions to provide to the ServiceAccount bound to the client. This can be used to provide additional permissions for the client to scrape metrics from the k8s API. Only enabled if clients.https.enabled and clients.https.useServiceAccountCredentials are true | `[]` |
| `clients.deployment.enabled` | Deploys the client as a Deployment (generally used if the underlying hostNetwork Pod that is being scraped is managed by a Deployment) | `false` |
| `clients.deployment.replicas` | The number of pods the Deployment has, it should match the number of pod the hostNetwork Deployment has. Required and only used if `client.deployment.enable` is set | `0` |
| `clients.deployment.affinity` | The affinity rules that allocate the pod to the node in which the hostNetwork Deployment's pods run. Required and only used if `client.deployment.enable` is set | `{}` |
| `clients.resources` | Set resource limits and requests for the client container | `{}` |
| `clients.nodeSelector` | Select which nodes to deploy the clients on | `{}` |
| `clients.tolerations` | Specify tolerations for clients | `[]` |
| `proxy.enabled` | Deploys the proxy that each client will register with | `true` |
| `proxy.port` | The port exposed by the proxy that each client will register with to allow metrics to be scraped from the host | `8080` |
| `proxy.resources` | Set resource limits and requests for the proxy container | `{}` |
| `proxy.nodeSelector` | Select which nodes the proxy can be deployed on | `{}` |
| `proxy.tolerations` | Specify tolerations (if necessary) to allow the proxy to be deployed on the selected node | `[]` |
| `kubeVersionOverrides` | A list of Semver constraint strings (defined by https://github.com/Masterminds/semver) and values.yaml overrides. For each key in kubeVersionOverrides, this chart will check to see if the current Kubernetes cluster's version matches any of the semver constraints provided as keys on the map. On seeing a match, the default value for each values.yaml field overridden will be updated with the new value. If multiple matches are encountered (due to overlapping semver ranges), the matches will be applied in order. | `[]`

*Tip: The filepaths set in `clients.https.<cert|key|caCert>File` can include wildcard characters*. 

See [rancher-monitoring](https://github.com/rancher/charts/tree/gh-pages/packages/rancher-monitoring) for examples of how this chart can be used.
