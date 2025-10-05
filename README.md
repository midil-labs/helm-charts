## Usage

To use these Helm charts, ensure you have [Helm](https://helm.sh) installed. If you need help installing Helm, see the [official documentation](https://helm.sh/docs/).

### Add the Helm Repository

`helm repo add midil-labs https://midil-labs.github.io/helm-charts`

### Validate The Helm

`helm template checkin midil-labs/midil -n default -f onekg-overrides.yaml`