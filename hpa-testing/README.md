# HPA Testing Suite

This directory contains a streamlined testing script for validating Kubernetes Horizontal Pod Autoscaler (HPA) behavior for the CSV Processor application.

## 🎯 Overview

The HPA testing suite provides a simple, effective tool to:
- Test HPA scale-up behavior under intensive load
- Validate HPA scale-down behavior after load removal
- Generate high CPU load to trigger HPA scaling
- Demonstrate proper HPA configuration and behavior

## 📁 Contents

| File | Description |
|------|-------------|
| `quick-intensive-test.sh` | High-intensity load generator for HPA testing |
| `README.md` | This guide |
| `TESTING_RESULTS.md` | Detailed test results and analysis |

## 🚀 Quick Start

### Prerequisites

Before running the HPA test, ensure:
- ✅ Kubernetes cluster is running
- ✅ CSV Processor application is deployed
- ✅ Metrics server is installed and working
- ✅ HPAs are created and active

### Verification Commands

```bash
# Check if applications are running
kubectl get pods -l 'app.kubernetes.io/name in (csv-processor,csv-processor-nginx)'

# Check HPA status
kubectl get hpa

# Verify metrics server
kubectl top pods
```

### Running the Test

```bash
cd hpa-testing
./quick-intensive-test.sh
```

## 📊 Test Script Details

### `quick-intensive-test.sh`

**High-intensity load generator** for comprehensive HPA scaling validation.

**Features:**
- Very high CPU load generation (50-80%)
- Immediate scaling trigger (usually within 30-60 seconds)
- Large CSV file uploads and concurrent requests to both API and Nginx
- Tests both scale-up and scale-down behavior
- Real-time monitoring guidance

**What it does:**
- Creates a large 5000-row CSV file with substantial data
- Generates 50 concurrent API threads with heavy file uploads
- Generates 30 concurrent Nginx threads with large payloads
- Produces sustained high CPU load to trigger HPA scaling

**Expected Results:**
- CPU utilization should exceed 50% threshold
- Both API and Nginx services should scale from 1 to 2+ replicas
- After stopping the test, services should scale back down to 1 replica after the stabilization window (2 minutes)

## 📈 Monitoring During Test

Use these commands to monitor the HPA behavior in real-time:

```bash
# Watch HPA status (recommended)
watch -n 10 'kubectl get hpa && echo "" && kubectl top pods -l "app.kubernetes.io/name in (csv-processor,csv-processor-nginx)"'

# Simple HPA monitoring
kubectl get hpa -w

# Pod status monitoring
kubectl get pods -w
```

## 🎯 Expected Test Results

### Successful Scaling Indicators

1. **CPU Metrics**: Should show >50% utilization during load
2. **Scale-Up**: Replicas should increase from 1 to 2-4 pods
3. **Scale-Down**: After stopping load, should return to 1 replica after ~2-3 minutes
4. **Pod Status**: New pods should be in "Running" state

### Sample Output

**During Load:**
```
NAME                  REFERENCE                        TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
csv-processor         Deployment/csv-processor         cpu: 71%/50%    1         5         2          11h
csv-processor-nginx   Deployment/csv-processor-nginx   csv: 57%/50%    1         5         2          11h
```

**After Load (Scale-Down):**
```
NAME                  REFERENCE                        TARGETS         MINPODS   MAXPODS   REPLICAS   AGE
csv-processor         Deployment/csv-processor         cpu: 0%/50%     1         5         1          11h
csv-processor-nginx   Deployment/csv-processor-nginx   cpu: 0%/50%     1         5         1          11h
```

## 🔧 HPA Configuration

The test validates the following HPA behavior:

### Scale-Up Behavior
- **Threshold**: 50% CPU utilization
- **Response**: Immediate scaling when threshold exceeded
- **Max Replicas**: 5 pods per service

### Scale-Down Behavior
- **Stabilization Window**: 2 minutes (120 seconds)
- **Policy**: Conservative scale-down to prevent thrashing
- **Min Replicas**: 1 pod per service

## 🔍 Troubleshooting

### Common Issues

#### 1. HPA Shows `<unknown>` CPU Metrics
**Solution**: Ensure metrics server is running and configured properly:
```bash
kubectl get deployment metrics-server -n kube-system
```

#### 2. No Scaling Despite High Load
**Solution**: Check that resource requests are configured in deployments:
```bash
kubectl get deployment csv-processor -o yaml | grep -A5 resources
```

#### 3. Test Pod Fails to Start
**Solution**: Check cluster resources and try again:
```bash
kubectl get pods
kubectl describe pod intensive-load-test
```

## 🧹 Cleanup

After testing, clean up any remaining test pods:

```bash
kubectl delete pod intensive-load-test --ignore-not-found=true
```

## 📊 Test Timeline

A typical test run follows this timeline:

1. **0-30s**: Load generation starts, CPU begins to rise
2. **30-60s**: CPU exceeds 50%, HPA triggers scale-up
3. **60-120s**: New pods start, load distributes, CPU stabilizes
4. **Test Stop**: Load generation stops, CPU drops to 0%
5. **2-3 minutes later**: HPA scales down to minimum replicas

## 🎯 Conclusion

This streamlined HPA testing tool provides a quick and effective way to validate that your Kubernetes HPA configuration is working correctly. The test successfully demonstrates both scale-up and scale-down behavior, ensuring your application can handle varying loads efficiently.

The `quick-intensive-test.sh` script is designed to be simple, reliable, and provide immediate feedback on your HPA configuration's effectiveness.
