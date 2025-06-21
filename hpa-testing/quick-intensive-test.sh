#!/bin/bash

# Quick Intensive Load Test - Generates very high CPU load through load balancer
# This is a simplified version for immediate testing

set -e

echo "🔥 Quick Intensive Load Test"
echo "==========================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Create simple load generator
create_simple_load_generator() {
    print_status "Creating quick load generator..."
    
    kubectl run intensive-load-test --image=alpine/curl --restart=Never --rm -i --tty --command -- sh -c "
        echo '🔥 Starting VERY intensive load generation...'
        
        # Create large CSV data
        echo 'id,name,email,description,data1,data2,data3,data4,data5' > /tmp/big.csv
        for i in \$(seq 1 5000); do
            echo \"\$i,User\$i,user\$i@test.com,Very long description with lots of text for user \$i,\$(head -c 100 /dev/urandom | base64 | tr -d '\n'),\$(head -c 100 /dev/urandom | base64 | tr -d '\n'),\$(head -c 100 /dev/urandom | base64 | tr -d '\n'),\$(head -c 100 /dev/urandom | base64 | tr -d '\n'),\$(head -c 100 /dev/urandom | base64 | tr -d '\n')\" >> /tmp/big.csv
        done
        
        echo 'Starting intensive load...'
        
        # Generate massive API load
        for i in {1..50}; do
            (
                while true; do
                    # Heavy file uploads
                    curl -s -X POST -F 'csvFile=@/tmp/big.csv' http://csv-processor.default.svc.cluster.local:3000/upload > /dev/null 2>&1
                    
                    # Multiple GET requests
                    for j in {1..10}; do
                        curl -s http://csv-processor.default.svc.cluster.local:3000/ > /dev/null 2>&1 &
                    done
                done
            ) &
        done
        
        # Generate massive Nginx load  
        for i in {1..30}; do
            (
                while true; do
                    # Many concurrent requests
                    for j in {1..20}; do
                        curl -s http://csv-processor-nginx.default.svc.cluster.local:80/ > /dev/null 2>&1 &
                    done
                    
                    # Large POST requests
                    curl -s -X POST -d \"\$(head -c 50000 /dev/urandom | base64)\" http://csv-processor-nginx.default.svc.cluster.local:80/ > /dev/null 2>&1 &
                done
            ) &
        done
        
        echo '🚀 INTENSIVE LOAD STARTED!'
        echo 'API: 50 threads with 5K-row CSV uploads'
        echo 'Nginx: 30 threads with 50KB payloads'
        echo ''
        echo 'Monitor with: kubectl get hpa'
        echo 'Expected: CPU should exceed 50% and trigger scaling'
        echo ''
        echo 'Press Ctrl+C to stop the test'
        
        # Keep running until interrupted
        wait
    "
}

# Monitor during test
monitor_quick() {
    print_status "Monitor HPA status with this command (in another terminal):"
    echo ""
    echo "watch -n 10 'kubectl get hpa && echo \"\" && kubectl top pods -l \"app.kubernetes.io/name in (csv-processor,csv-processor-nginx)\"'"
    echo ""
}

# Main execution
main() {
    echo "This will create VERY intensive load to trigger HPA scaling"
    echo "Expected CPU: 50-80% (should trigger scaling)"
    echo ""
    
    monitor_quick
    
    read -p "Press Enter to start intensive load test..."
    
    create_simple_load_generator
}

main
