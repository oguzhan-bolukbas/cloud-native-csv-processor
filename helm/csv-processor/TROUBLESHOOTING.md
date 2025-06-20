## Troubleshooting

If you encounter an error like "Unexpected server error" or need to check pod status:

1. Check the pod status:
```bash
# List all pods with the app label
kubectl get pods -l app.kubernetes.io/name=csv-processor

# Get detailed information about the pod
kubectl describe pod -l app.kubernetes.io/name=csv-processor
```

2. Check pod logs:
```bash
# Get logs from the pod
kubectl logs -l app.kubernetes.io/name=csv-processor

# If you need to follow the logs
kubectl logs -l app.kubernetes.io/name=csv-processor -f

# If there are multiple pods, get logs from all of them
kubectl logs -l app.kubernetes.io/name=csv-processor --all-containers
```

Common issues and solutions:

1. Pod failing to start:
   - Check if secrets are properly configured in `values-override.yaml`
   - Verify the image name and tag are correct
   - Check if the AWS credentials are valid

2. Application errors:
   - Verify AWS S3 bucket exists and is accessible
   - Check if the AWS region is correctly configured
   - Ensure the AWS credentials have proper permissions

3. Resource issues:
   - Check if the pod has enough resources (CPU/Memory)
   - Verify if the node has enough resources available
