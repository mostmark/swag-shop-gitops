# swag-shop-gitops

Kubernetes manifests that deploy the [Swag Shop](https://github.com/mostmark/swag-shop) Quarkus demo application,
a conference swag web shop built as seven services and monitored by Cryostat, on OpenShift.

## Contents

| Path | Description |
|---|---|
| `manifests/` | One file per resource |
| `swag-shop.yaml` | All manifests from `manifests/` in a single file |
| `update-combined.sh` | Regenerates `swag-shop.yaml` from `manifests/` |

Resources:

- **Services**: a `Deployment` (`quay.io/mostmark/swag-shop-<service>:latest`) and a `Service` (port 8080) for
  each of `catalog`, `search`, `pricing`, `inventory`, `order`, `frontend` and `load-generator`
- **Route**: an edge-terminated `Route` to the frontend (HTTP redirects to HTTPS); the other services are only
  reachable inside the namespace

Every resource carries the label `app.kubernetes.io/part-of=swag-shop-demo`, which also groups the services in the
OpenShift console Topology view.

No resource sets a namespace, so everything is created in the current project.

## Requirements

- The Cryostat Operator and a Cryostat instance whose target namespaces include the project. The pods carry the
  labels `cryostat.io/name: cryostat-sample` and `cryostat.io/namespace: cryostat`, so the operator injects the
  Cryostat Agent into them; change both labels in the deployments if your Cryostat instance has another name or
  namespace. The operator only injects the Agent when a pod is created, so add the project to the target
  namespaces before you deploy (or sync with Argo CD). Pods created before that do not show up in Cryostat until
  they are restarted:
  `oc rollout restart deployment -l app.kubernetes.io/part-of=swag-shop-demo`.
- The images are public on quay.io, so no pull secret is needed.

## Deploy

From the command line:

```shell
oc new-project swag-shop
oc apply -f swag-shop.yaml
```

or apply the individual files with `oc apply -f manifests/`.

From the OpenShift console, select the project, click **+** (Import YAML) and paste the contents of `swag-shop.yaml`.

With Argo CD, create an Application with this repository as its source, `manifests` as its path and the project
as its destination namespace.

Then open the shop and the demo control page:

```shell
echo "https://$(oc get route swag-shop-frontend -o jsonpath='{.spec.host}')"
echo "https://$(oc get route swag-shop-frontend -o jsonpath='{.spec.host}')/demo.html"
```

## Updating

When a file in `manifests/` changes, regenerate `swag-shop.yaml` so the two stay in sync:

```shell
./update-combined.sh
```
