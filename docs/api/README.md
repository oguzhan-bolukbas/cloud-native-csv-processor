# API Documentation

## Overview

The CSV Processor provides a RESTful API for uploading and processing CSV files. The API is designed to be simple and intuitive, with clear responses and error handling.

**Base URL**: `http://localhost:3000/api` (local) or your deployed endpoint

## Authentication

Currently, the API does not require authentication. In production environments, consider implementing:
- API keys
- OAuth 2.0
- JWT tokens

## Endpoints

### 1. Upload CSV File

Upload and process a CSV file.

**Endpoint**: `POST /api/upload`

**Content-Type**: `multipart/form-data`

**Parameters**:
- `csvFile` (file, required): The CSV file to upload
  - Maximum file size: 10MB
  - Supported formats: `.csv`
  - Encoding: UTF-8

**Example Request** (using curl):
```bash
curl -X POST \
  http://localhost:3000/api/upload \
  -H 'Content-Type: multipart/form-data' \
  -F 'csvFile=@sample.csv'
```

**Example Request** (using JavaScript fetch):
```javascript
const formData = new FormData();
formData.append('csvFile', fileInput.files[0]);

fetch('/api/upload', {
  method: 'POST',
  body: formData
})
.then(response => response.json())
.then(data => console.log(data));
```

**Successful Response** (200 OK):
```json
{
  "success": true,
  "message": "File uploaded and processed successfully",
  "data": {
    "filename": "sample.csv",
    "originalName": "sample.csv",
    "size": 1024,
    "uploadedAt": "2025-06-24T10:30:00.000Z",
    "processedRows": 150,
    "s3Location": "https://your-bucket.s3.amazonaws.com/uploads/1750532867905-sample.csv",
    "rowData": [
      {
        "rowNumber": 1,
        "data": ["Name", "Age", "City"]
      },
      {
        "rowNumber": 2,
        "data": ["John Doe", "30", "New York"]
      }
      // ... more rows (limited to first 10 for display)
    ]
  }
}
```

**Error Responses**:

**400 Bad Request** - No file uploaded:
```json
{
  "success": false,
  "error": "No file uploaded",
  "message": "Please select a CSV file to upload"
}
```

**400 Bad Request** - Invalid file type:
```json
{
  "success": false,
  "error": "Invalid file type",
  "message": "Only CSV files are allowed"
}
```

**413 Payload Too Large** - File too large:
```json
{
  "success": false,
  "error": "File too large",
  "message": "File size must be less than 10MB"
}
```

**500 Internal Server Error** - Processing error:
```json
{
  "success": false,
  "error": "Processing failed",
  "message": "An error occurred while processing the CSV file",
  "details": "Specific error details for debugging"
}
```

### 2. Health Check

Check the health status of the API.

**Endpoint**: `GET /api/health`

**Example Request**:
```bash
curl http://localhost:3000/api/health
```

**Response** (200 OK):
```json
{
  "status": "healthy",
  "timestamp": "2025-06-24T10:30:00.000Z",
  "uptime": 3600,
  "version": "1.0.0",
  "environment": "production"
}
```

### 3. Get Processing Status

Get the status of file processing operations.

**Endpoint**: `GET /api/status`

**Response** (200 OK):
```json
{
  "status": "operational",
  "stats": {
    "totalUploads": 45,
    "successfulUploads": 42,
    "failedUploads": 3,
    "averageProcessingTime": "2.5s"
  },
  "s3Status": "connected",
  "lastActivity": "2025-06-24T10:25:00.000Z"
}
```

## Data Models

### CSV Row Data
```json
{
  "rowNumber": "integer",
  "data": ["string", "string", "..."]
}
```

### Upload Response
```json
{
  "success": "boolean",
  "message": "string",
  "data": {
    "filename": "string",
    "originalName": "string",
    "size": "integer (bytes)",
    "uploadedAt": "string (ISO 8601)",
    "processedRows": "integer",
    "s3Location": "string (URL)",
    "rowData": ["CsvRowData"]
  }
}
```

### Error Response
```json
{
  "success": "boolean (false)",
  "error": "string",
  "message": "string",
  "details": "string (optional)"
}
```

## Rate Limiting

Currently, no rate limiting is implemented. For production use, consider:
- 100 requests per minute per IP
- 10 file uploads per hour per IP
- Burst allowance for legitimate traffic

## File Processing Details

### CSV Parsing Rules
- Files are processed line by line
- Empty lines are skipped
- Headers are automatically detected
- Maximum 10,000 rows per file
- UTF-8 encoding expected

### S3 Upload Process
1. File is temporarily stored locally
2. CSV content is parsed and validated
3. Original file is uploaded to S3
4. Local temporary file is cleaned up
5. S3 lifecycle policies manage long-term storage

### Error Handling
- Malformed CSV files return detailed error messages
- S3 upload failures are retried up to 3 times
- Processing timeouts after 30 seconds

## Response Headers

All API responses include:
```
Content-Type: application/json
X-API-Version: 1.0.0
X-Response-Time: <processing_time_ms>
```

## Environment Variables

The API behavior can be configured using these environment variables:

- `PORT`: Server port (default: 3000)
- `NODE_ENV`: Environment mode (development/production)
- `AWS_REGION`: AWS region for S3 uploads
- `AWS_S3_BUCKET`: S3 bucket name
- `MAX_FILE_SIZE`: Maximum upload size in bytes
- `UPLOAD_TIMEOUT`: Upload timeout in milliseconds

## Examples

### Complete Upload Example

**HTML Form**:
```html
<form id="uploadForm" enctype="multipart/form-data">
  <input type="file" name="csvFile" accept=".csv" required>
  <button type="submit">Upload CSV</button>
</form>

<script>
document.getElementById('uploadForm').addEventListener('submit', async (e) => {
  e.preventDefault();
  
  const formData = new FormData(e.target);
  
  try {
    const response = await fetch('/api/upload', {
      method: 'POST',
      body: formData
    });
    
    const result = await response.json();
    
    if (result.success) {
      console.log('Upload successful:', result.data);
      displayResults(result.data.rowData);
    } else {
      console.error('Upload failed:', result.message);
    }
  } catch (error) {
    console.error('Network error:', error);
  }
});
</script>
```

### Node.js Client Example

```javascript
const fs = require('fs');
const FormData = require('form-data');
const fetch = require('node-fetch');

async function uploadCSV(filePath) {
  const form = new FormData();
  form.append('csvFile', fs.createReadStream(filePath));
  
  try {
    const response = await fetch('http://localhost:3000/api/upload', {
      method: 'POST',
      body: form
    });
    
    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Upload error:', error);
    throw error;
  }
}

// Usage
uploadCSV('./sample.csv')
  .then(result => console.log(result))
  .catch(error => console.error(error));
```

## Testing the API

### Using curl
```bash
# Health check
curl http://localhost:3000/api/health

# Upload a file
curl -X POST \
  -F "csvFile=@test-data.csv" \
  http://localhost:3000/api/upload

# Check status
curl http://localhost:3000/api/status
```

### Using Postman
1. Create a new POST request to `/api/upload`
2. Set body type to "form-data"
3. Add key "csvFile" with type "File"
4. Select your CSV file and send

## Troubleshooting

### Common Issues

**"No file uploaded" error**:
- Ensure the form field name is exactly "csvFile"
- Check that the file is properly selected

**"File too large" error**:
- Current limit is 10MB
- Compress your CSV or split into smaller files

**S3 upload failures**:
- Verify AWS credentials are configured
- Check S3 bucket permissions
- Ensure the bucket exists in the specified region

**Timeout errors**:
- Large files may exceed processing timeout
- Consider increasing `UPLOAD_TIMEOUT` environment variable
