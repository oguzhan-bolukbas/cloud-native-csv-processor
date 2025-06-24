# Performance & Monitoring Guide

## Overview

This guide covers performance optimization strategies, monitoring setup, and observability practices for the CSV Processor application. Proper monitoring and performance tuning are essential for maintaining a reliable, scalable cloud-native application.

## Performance Optimization

### Application Performance

#### Node.js Optimization
```javascript
// Optimize CSV processing with streaming
const fs = require('fs');
const { Transform } = require('stream');

class CSVProcessor extends Transform {
  constructor(options) {
    super({ objectMode: true });
    this.rowCount = 0;
    this.maxRows = options.maxRows || 10000;
  }

  _transform(chunk, encoding, callback) {
    if (this.rowCount >= this.maxRows) {
      return callback(new Error('Row limit exceeded'));
    }
    
    const row = this.parseCSVRow(chunk.toString());
    this.rowCount++;
    this.push({ rowNumber: this.rowCount, data: row });
    callback();
  }
}

// Usage: Stream processing for large files
const processCsvStream = (filePath) => {
  return new Promise((resolve, reject) => {
    const results = [];
    const processor = new CSVProcessor({ maxRows: 10000 });
    
    fs.createReadStream(filePath)
      .pipe(processor)
      .on('data', (row) => results.push(row))
      .on('end', () => resolve(results))
      .on('error', reject);
  });
};
```

#### Memory Management
```javascript
// Implement memory-efficient file processing
const processLargeCSV = async (filePath) => {
  const results = [];
  const BATCH_SIZE = 1000;
  let currentBatch = [];
  
  return new Promise((resolve, reject) => {
    fs.createReadStream(filePath)
      .pipe(csv())
      .on('data', (row) => {
        currentBatch.push(row);
        
        if (currentBatch.length >= BATCH_SIZE) {
          // Process batch and clear memory
          results.push(...processBatch(currentBatch));
          currentBatch = [];
          
          // Force garbage collection if available
          if (global.gc) {
            global.gc();
          }
        }
      })
      .on('end', () => {
        if (currentBatch.length > 0) {
          results.push(...processBatch(currentBatch));
        }
        resolve(results);
      })
      .on('error', reject);
  });
};
```

### Container Performance

#### Dockerfile Optimization
```dockerfile
# Multi-stage build for optimal image size
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

FROM node:18-alpine AS runtime
WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Copy application files
COPY --from=builder /app/node_modules ./node_modules
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Set proper ownership
RUN chown -R nodejs:nodejs /app
USER nodejs

# Use dumb-init for proper signal handling
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "src/app.js"]
```

#### Resource Management
```yaml
# Kubernetes resource optimization
apiVersion: apps/v1
kind: Deployment
spec:
  template:
    spec:
      containers:
      - name: csv-processor
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
```

### Database and Storage Performance

#### S3 Optimization
```javascript
// Optimize S3 uploads with multipart for large files
const { S3Client, PutObjectCommand, CreateMultipartUploadCommand } = require('@aws-sdk/client-s3');

class OptimizedS3Uploader {
  constructor() {
    this.s3Client = new S3Client({
      region: process.env.AWS_REGION,
      maxAttempts: 3,
      retryMode: 'adaptive'
    });
  }

  async uploadFile(filePath, bucket, key) {
    const fileSize = fs.statSync(filePath).size;
    const MULTIPART_THRESHOLD = 100 * 1024 * 1024; // 100MB

    if (fileSize > MULTIPART_THRESHOLD) {
      return this.multipartUpload(filePath, bucket, key);
    } else {
      return this.simpleUpload(filePath, bucket, key);
    }
  }

  async simpleUpload(filePath, bucket, key) {
    const fileStream = fs.createReadStream(filePath);
    
    const uploadParams = {
      Bucket: bucket,
      Key: key,
      Body: fileStream,
      ContentType: 'text/csv',
      ServerSideEncryption: 'AES256'
    };

    return this.s3Client.send(new PutObjectCommand(uploadParams));
  }
}
```

## Monitoring Setup

### Application Metrics

#### Custom Metrics Collection
```javascript
// Implement custom metrics collection
const prometheus = require('prom-client');

// Create custom metrics
const httpRequestDuration = new prometheus.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code']
});

const csvProcessingTime = new prometheus.Histogram({
  name: 'csv_processing_duration_seconds',
  help: 'Time taken to process CSV files',
  labelNames: ['file_size_category']
});

const fileUploadCounter = new prometheus.Counter({
  name: 'file_uploads_total',
  help: 'Total number of file uploads',
  labelNames: ['status']
});

// Middleware for metrics collection
const metricsMiddleware = (req, res, next) => {
  const start = Date.now();
  
  res.on('finish', () => {
    const duration = (Date.now() - start) / 1000;
    httpRequestDuration
      .labels(req.method, req.route?.path || req.path, res.statusCode)
      .observe(duration);
  });
  
  next();
};

// Expose metrics endpoint
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', prometheus.register.contentType);
  res.end(await prometheus.register.metrics());
});
```

#### Health Check Endpoints
```javascript
// Comprehensive health checks
app.get('/health', async (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: process.memoryUsage(),
    version: process.env.npm_package_version
  };

  // Check S3 connectivity
  try {
    await s3Client.send(new HeadBucketCommand({ 
      Bucket: process.env.AWS_S3_BUCKET 
    }));
    health.s3Status = 'connected';
  } catch (error) {
    health.s3Status = 'disconnected';
    health.s3Error = error.message;
    health.status = 'degraded';
  }

  const statusCode = health.status === 'healthy' ? 200 : 503;
  res.status(statusCode).json(health);
});

app.get('/ready', (req, res) => {
  // Simple readiness check
  res.status(200).json({ status: 'ready' });
});
```

### Kubernetes Monitoring

#### Prometheus Configuration
```yaml
# ServiceMonitor for Prometheus
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: csv-processor
  labels:
    app: csv-processor
spec:
  selector:
    matchLabels:
      app: csv-processor
  endpoints:
  - port: http
    path: /metrics
    interval: 30s
```

#### Grafana Dashboard
```json
{
  "dashboard": {
    "title": "CSV Processor Metrics",
    "panels": [
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{method}} {{route}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, http_request_duration_seconds_bucket)",
            "legendFormat": "95th percentile"
          }
        ]
      },
      {
        "title": "File Processing Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.50, csv_processing_duration_seconds_bucket)",
            "legendFormat": "Median processing time"
          }
        ]
      }
    ]
  }
}
```

### AWS CloudWatch Integration

#### Custom CloudWatch Metrics
```javascript
const { CloudWatchClient, PutMetricDataCommand } = require('@aws-sdk/client-cloudwatch');

class CloudWatchMetrics {
  constructor() {
    this.cloudWatch = new CloudWatchClient({
      region: process.env.AWS_REGION
    });
  }

  async putMetric(metricName, value, unit = 'Count', dimensions = []) {
    const params = {
      Namespace: 'CSVProcessor',
      MetricData: [
        {
          MetricName: metricName,
          Value: value,
          Unit: unit,
          Dimensions: dimensions,
          Timestamp: new Date()
        }
      ]
    };

    try {
      await this.cloudWatch.send(new PutMetricDataCommand(params));
    } catch (error) {
      console.error('Failed to put CloudWatch metric:', error);
    }
  }

  async recordFileUpload(fileSize, processingTime, success) {
    await Promise.all([
      this.putMetric('FileUploads', 1, 'Count', [
        { Name: 'Status', Value: success ? 'Success' : 'Failed' }
      ]),
      this.putMetric('FileSize', fileSize, 'Bytes'),
      this.putMetric('ProcessingTime', processingTime, 'Seconds')
    ]);
  }
}
```

## Observability

### Structured Logging

#### Winston Configuration
```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  defaultMeta: { 
    service: 'csv-processor',
    version: process.env.npm_package_version
  },
  transports: [
    new winston.transports.Console({
      format: winston.format.combine(
        winston.format.colorize(),
        winston.format.simple()
      )
    })
  ]
});

// Add CloudWatch transport for production
if (process.env.NODE_ENV === 'production') {
  logger.add(new winston.transports.CloudWatchLogs({
    logGroupName: '/aws/eks/csv-processor',
    logStreamName: `${process.env.POD_NAME || 'csv-processor'}-${Date.now()}`
  }));
}

module.exports = logger;
```

#### Request Logging Middleware
```javascript
const requestLogger = (req, res, next) => {
  const start = Date.now();
  const requestId = req.headers['x-request-id'] || generateUUID();
  
  // Add request ID to all subsequent logs
  req.log = logger.child({ requestId });
  
  req.log.info('Request started', {
    method: req.method,
    url: req.url,
    userAgent: req.get('User-Agent'),
    ip: req.ip
  });

  res.on('finish', () => {
    const duration = Date.now() - start;
    req.log.info('Request completed', {
      statusCode: res.statusCode,
      duration,
      contentLength: res.get('Content-Length')
    });
  });

  next();
};
```

### Distributed Tracing

#### OpenTelemetry Setup
```javascript
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { JaegerExporter } = require('@opentelemetry/exporter-jaeger');

const sdk = new NodeSDK({
  traceExporter: new JaegerExporter({
    endpoint: process.env.JAEGER_ENDPOINT || 'http://jaeger:14268/api/traces'
  }),
  instrumentations: [getNodeAutoInstrumentations()]
});

sdk.start();
```

### Error Tracking

#### Sentry Integration
```javascript
const Sentry = require('@sentry/node');

Sentry.init({
  dsn: process.env.SENTRY_DSN,
  environment: process.env.NODE_ENV,
  tracesSampleRate: 0.1
});

// Global error handler
app.use(Sentry.Handlers.errorHandler());

// Custom error tracking
const trackError = (error, context = {}) => {
  Sentry.captureException(error, {
    tags: {
      component: 'csv-processor'
    },
    extra: context
  });
};
```

## Performance Testing

### Load Testing with Artillery

#### Artillery Configuration
```yaml
# artillery-config.yml
config:
  target: 'http://localhost:3000'
  phases:
    - duration: 60
      arrivalRate: 1
      name: "Warm up"
    - duration: 300
      arrivalRate: 10
      name: "Sustained load"
    - duration: 60
      arrivalRate: 50
      name: "Spike test"
  payload:
    path: "test-files.csv"
    fields:
      - "filename"

scenarios:
  - name: "Upload CSV files"
    weight: 100
    flow:
      - post:
          url: "/api/upload"
          formData:
            csvFile: "{{ filename }}"
      - think: 2
```

#### Load Testing Script
```bash
#!/bin/bash
# load-test.sh

echo "Starting load test..."

# Prepare test files
mkdir -p test-files
for i in {1..10}; do
  echo "name,age,city" > test-files/test-${i}.csv
  echo "John Doe,30,New York" >> test-files/test-${i}.csv
done

# Run Artillery load test
artillery run artillery-config.yml --output report.json

# Generate HTML report
artillery report report.json

echo "Load test completed. Check report.html for results."
```

### Performance Benchmarking

#### Benchmark Suite
```javascript
// benchmark.js
const Benchmark = require('benchmark');
const { parseCsvRow } = require('./src/utils/csvParser');

const suite = new Benchmark.Suite();

// Add benchmark tests
suite
  .add('CSV parsing - simple', () => {
    parseCsvRow('John,Doe,30,Engineer');
  })
  .add('CSV parsing - quoted', () => {
    parseCsvRow('"Smith, John","Doe",30,"Senior Engineer"');
  })
  .add('CSV parsing - complex', () => {
    parseCsvRow('"Complex, \"Field\"","With\nNewlines",123,"Final Field"');
  })
  .on('cycle', (event) => {
    console.log(String(event.target));
  })
  .on('complete', function() {
    console.log('Fastest is ' + this.filter('fastest').map('name'));
  })
  .run({ async: true });
```

## Alerting

### Prometheus Alerts

#### AlertManager Rules
```yaml
# alerts.yml
groups:
  - name: csv-processor
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} requests per second"

      - alert: HighMemoryUsage
        expr: container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is {{ $value | humanizePercentage }}"

      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod is crash looping"
          description: "Pod {{ $labels.pod }} is restarting frequently"
```

### CloudWatch Alarms

#### Terraform Configuration
```hcl
resource "aws_cloudwatch_metric_alarm" "high_error_rate" {
  alarm_name          = "csv-processor-high-error-rate"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ErrorRate"
  namespace           = "CSVProcessor"
  period              = "300"
  statistic           = "Average"
  threshold           = "5"
  alarm_description   = "This metric monitors error rate"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "high_latency" {
  alarm_name          = "csv-processor-high-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ResponseTime"
  namespace           = "CSVProcessor"
  period              = "300"
  statistic           = "Average"
  threshold           = "5000"
  alarm_description   = "This metric monitors response time"
  alarm_actions       = [aws_sns_topic.alerts.arn]
}
```

## Troubleshooting Performance Issues

### Common Performance Problems

#### High Memory Usage
```javascript
// Memory monitoring utility
const monitorMemory = () => {
  const used = process.memoryUsage();
  const messages = [];
  
  for (let key in used) {
    const value = Math.round(used[key] / 1024 / 1024 * 100) / 100;
    messages.push(`${key}: ${value} MB`);
    
    if (key === 'heapUsed' && value > 400) {
      console.warn('High heap usage detected:', value, 'MB');
    }
  }
  
  console.log('Memory usage:', messages.join(', '));
};

// Monitor memory every 30 seconds
setInterval(monitorMemory, 30000);
```

#### Slow File Processing
```javascript
// Performance profiling for CSV processing
const profileCsvProcessing = async (filePath) => {
  const start = process.hrtime.bigint();
  
  try {
    const result = await processCsvFile(filePath);
    const end = process.hrtime.bigint();
    const duration = Number(end - start) / 1000000; // Convert to milliseconds
    
    console.log(`CSV processing took ${duration}ms for ${result.length} rows`);
    
    // Log slow processing
    if (duration > 5000) {
      console.warn('Slow CSV processing detected', {
        duration,
        rows: result.length,
        filePath
      });
    }
    
    return result;
  } catch (error) {
    console.error('CSV processing failed', error);
    throw error;
  }
};
```

### Debugging Tools

#### Node.js Profiling
```bash
# CPU profiling
node --prof src/app.js

# Memory profiling
node --inspect src/app.js

# Heap snapshot
node --inspect --inspect-brk src/app.js
```

#### Kubernetes Debugging
```bash
# Get resource usage
kubectl top pods -l app=csv-processor

# Check pod logs
kubectl logs -l app=csv-processor --tail=100 -f

# Describe problematic pods
kubectl describe pod <pod-name>

# Execute commands in pod
kubectl exec -it <pod-name> -- /bin/sh
```

Remember: Performance optimization is an iterative process. Always measure before and after changes, and focus on the bottlenecks that have the most impact on user experience.
