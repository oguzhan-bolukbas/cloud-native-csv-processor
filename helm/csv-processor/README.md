# CSV Processor Helm Chart

This Helm chart deploys the CSV Processor application in a Kubernetes cluster.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- AWS Secrets Store CSI Driver (if using AWS Secrets Manager integration)

## Installing the Chart

To install the chart with the release name `csv-processor`:

```bash
helm install csv-processor ./helm/csv-processor
```

## Configuration

The following table lists the configurable parameters of the CSV Processor chart and their default values:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `csv-processor` |
| `image.tag` | Image tag | `latest` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `ClusterIP` |
| `service.port` | Service port | `3000` |
| `env.PORT` | Application port | `3000` |
| `env.NODE_ENV` | Node environment | `production` |
| `env.AWS_REGION` | AWS region | `us-east-1` |
| `env.AWS_S3_BUCKET` | S3 bucket name | `csv-processor-bucket` |
| `secrets.AWS_ACCESS_KEY_ID` | Base64 encoded AWS Access Key ID | `""` |
| `secrets.AWS_SECRET_ACCESS_KEY` | Base64 encoded AWS Secret Access Key | `""` |

## Example values.yaml

```yaml
replicaCount: 2
image:
  repository: your-registry/csv-processor
  tag: v1.0.0
env:
  AWS_REGION: eu-west-1
  AWS_S3_BUCKET: my-csv-bucket
secrets:
  AWS_ACCESS_KEY_ID: "YXdzLWFjY2Vzcy1rZXk="        # Base64 encoded AWS Access Key
  AWS_SECRET_ACCESS_KEY: "YXdzLXNlY3JldC1rZXk="    # Base64 encoded AWS Secret Key
```
