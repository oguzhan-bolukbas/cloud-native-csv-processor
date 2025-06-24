# Development Guide

Welcome to the CSV Processor development guide! This document will help you get started with contributing to the project, whether you're fixing bugs, adding features, or improving documentation.

## Getting Started

### Prerequisites

Before you begin, make sure you have the following installed:

- **Node.js** (v18.0.0 or higher) - [Download here](https://nodejs.org/)
- **Docker** - [Install Docker](https://docs.docker.com/get-docker/)
- **kubectl** - [Install kubectl](https://kubernetes.io/docs/tasks/tools/)
- **Git** - [Install Git](https://git-scm.com/downloads)

**Optional but recommended:**
- **Minikube** for local Kubernetes testing
- **Helm** for deployment management
- **AWS CLI** for cloud operations

### Setting Up Your Development Environment

1. **Clone the repository**:
   ```bash
   git clone https://github.com/your-username/cloud-native-csv-processor.git
   cd cloud-native-csv-processor
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Set up environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Start the development server**:
   ```bash
   npm run dev
   ```

5. **Verify the setup**:
   Open http://localhost:3000 in your browser and try uploading a test CSV file.

## Project Structure

Understanding the project layout will help you navigate and contribute effectively:

```
├── src/                    # Application source code
│   ├── app.js             # Main application entry point
│   ├── controllers/       # Request handlers
│   ├── routes/           # API route definitions
│   ├── utils/            # Utility functions
│   └── public/           # Static files (HTML, CSS, JS)
├── tests/                 # Test files
│   ├── unit/             # Unit tests
│   └── integration/      # Integration tests
├── helm/                 # Kubernetes Helm charts
├── terraform/            # Infrastructure as Code
├── docker-compose.yml    # Local development setup
├── Dockerfile           # Container build instructions
└── package.json         # Node.js dependencies and scripts
```

### Key Files Explained

- **`src/app.js`**: Express.js application setup and middleware configuration
- **`src/controllers/uploadController.js`**: Handles CSV file upload and processing logic
- **`src/utils/csvParser.js`**: CSV parsing and validation utilities
- **`src/utils/s3Uploader.js`**: AWS S3 integration for file uploads
- **`helm/csv-processor/`**: Kubernetes deployment templates

## Development Workflow

### 1. Making Changes

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following the coding standards below

3. **Test your changes**:
   ```bash
   npm test                 # Run unit tests
   npm run test:integration # Run integration tests
   ```

4. **Test manually**:
   - Upload various CSV files
   - Test error conditions
   - Verify S3 integration (if configured)

### 2. Coding Standards

We follow these conventions to maintain code quality:

#### JavaScript/Node.js
- Use **ES6+** features where appropriate
- Follow **camelCase** naming convention
- Use **async/await** for asynchronous operations
- Add **JSDoc comments** for functions
- Keep functions small and focused

**Example**:
```javascript
/**
 * Processes a CSV file and extracts row data
 * @param {string} filePath - Path to the CSV file
 * @param {Object} options - Processing options
 * @returns {Promise<Array>} Array of parsed CSV rows
 */
async function processCsvFile(filePath, options = {}) {
  try {
    // Implementation here
  } catch (error) {
    console.error('CSV processing failed:', error);
    throw error;
  }
}
```

#### Error Handling
- Always handle errors gracefully
- Provide meaningful error messages
- Log errors with context
- Use try-catch blocks for async operations

```javascript
// Good
try {
  const result = await uploadToS3(file);
  return { success: true, data: result };
} catch (error) {
  console.error('S3 upload failed:', { filename: file.name, error: error.message });
  return { success: false, error: 'Upload failed' };
}
```

#### API Responses
- Use consistent response format
- Include proper HTTP status codes
- Provide clear error messages

```javascript
// Consistent success response
res.status(200).json({
  success: true,
  message: 'Operation completed successfully',
  data: result
});

// Consistent error response
res.status(400).json({
  success: false,
  error: 'Invalid input',
  message: 'CSV file is required'
});
```

### 3. Testing

#### Running Tests
```bash
# Run all tests
npm test

# Run specific test file
npm test -- uploadController.test.js

# Run tests in watch mode
npm test -- --watch

# Run tests with coverage
npm test -- --coverage
```

#### Writing Tests
We use **Jest** for testing. Follow these patterns:

**Unit Test Example**:
```javascript
const { parseCsvRow } = require('../src/utils/csvParser');

describe('csvParser', () => {
  describe('parseCsvRow', () => {
    it('should parse a simple CSV row correctly', () => {
      const input = 'John,Doe,30,Engineer';
      const expected = ['John', 'Doe', '30', 'Engineer'];
      
      const result = parseCsvRow(input);
      
      expect(result).toEqual(expected);
    });

    it('should handle quoted fields with commas', () => {
      const input = '"Smith, John",Doe,30,"Software Engineer"';
      const expected = ['Smith, John', 'Doe', '30', 'Software Engineer'];
      
      const result = parseCsvRow(input);
      
      expect(result).toEqual(expected);
    });
  });
});
```

**Integration Test Example**:
```javascript
const request = require('supertest');
const { app } = require('../src/app');

describe('POST /api/upload', () => {
  it('should upload and process a CSV file', async () => {
    const response = await request(app)
      .post('/api/upload')
      .attach('csvFile', 'tests/fixtures/sample.csv')
      .expect(200);

    expect(response.body.success).toBe(true);
    expect(response.body.data.processedRows).toBeGreaterThan(0);
  });
});
```

### 4. Docker Development

#### Building and Running Locally
```bash
# Build the Docker image
docker build -t csv-processor:dev .

# Run the container
docker run -p 3000:3000 -e NODE_ENV=development csv-processor:dev

# Use Docker Compose for full stack
docker-compose up --build
```

#### Multi-stage Build
Our Dockerfile uses multi-stage builds for optimization:
- **Build stage**: Installs dependencies
- **Production stage**: Minimal runtime image

### 5. Kubernetes Development

#### Local Testing with Minikube
```bash
# Start Minikube
minikube start

# Deploy to Minikube
helm install csv-processor ./helm/csv-processor \
  --set image.tag=dev \
  --set image.pullPolicy=Never

# Test the deployment
kubectl port-forward service/csv-processor-nginx 8080:80
```

#### Debugging Kubernetes Issues
```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=csv-processor

# View pod logs
kubectl logs -l app.kubernetes.io/name=csv-processor --tail=100

# Describe pod for troubleshooting
kubectl describe pod <pod-name>

# Access pod shell for debugging
kubectl exec -it <pod-name> -- /bin/sh
```

## Adding New Features

### 1. Planning
Before starting development:
- Check existing issues and discussions
- Create an issue to discuss the feature
- Get feedback from maintainers
- Plan the implementation approach

### 2. Implementation Checklist
- [ ] Write/update unit tests
- [ ] Write/update integration tests
- [ ] Update API documentation
- [ ] Add environment variable documentation
- [ ] Test with different CSV formats
- [ ] Test error conditions
- [ ] Update Helm chart if needed
- [ ] Test Kubernetes deployment

### 3. Common Feature Patterns

#### Adding a New API Endpoint
1. **Define the route** in `src/routes/upload.js`
2. **Create the controller** in `src/controllers/`
3. **Add input validation**
4. **Write tests**
5. **Update API documentation**

#### Adding Configuration Options
1. **Add environment variable** to `.env.example`
2. **Update `src/app.js`** to read the variable
3. **Update Helm values** if needed
4. **Document in README**

#### Adding Utility Functions
1. **Create in `src/utils/`**
2. **Export the function**
3. **Write comprehensive tests**
4. **Add JSDoc documentation**

## Performance Considerations

### 1. File Processing
- Stream large files instead of loading into memory
- Implement processing timeouts
- Add progress indicators for large uploads
- Consider chunked processing for very large files

### 2. Memory Management
- Clean up temporary files
- Monitor memory usage during CSV processing
- Use streaming where possible
- Implement proper error cleanup

### 3. S3 Integration
- Use multipart uploads for large files
- Implement retry logic with exponential backoff
- Handle S3 rate limiting
- Optimize for cost with lifecycle policies

## Debugging Tips

### 1. Common Issues
- **Port conflicts**: Check if port 3000 is already in use
- **File permissions**: Ensure upload directory is writable
- **Memory issues**: Monitor memory usage with large files
- **S3 permissions**: Verify AWS credentials and bucket policies

### 2. Debugging Tools
```bash
# Enable debug logging
DEBUG=csv-processor:* npm run dev

# Monitor memory usage
node --inspect src/app.js

# Profile performance
node --prof src/app.js
```

### 3. Log Analysis
- Use structured logging for better analysis
- Include request IDs for tracing
- Log important business events
- Monitor error rates and patterns

## Contributing Guidelines

### 1. Pull Request Process
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests and documentation
5. Submit a pull request
6. Address review feedback

### 2. Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

**Types**: feat, fix, docs, style, refactor, test, chore

**Examples**:
- `feat(api): add file validation endpoint`
- `fix(csv): handle malformed CSV headers`
- `docs(readme): update installation instructions`

### 3. Code Review Checklist
- [ ] Code follows project conventions
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No breaking changes (or properly documented)
- [ ] Performance impact considered
- [ ] Security implications reviewed

## Getting Help

### Resources
- **Project Documentation**: Check the various MD files in the repo
- **API Reference**: See [API Documentation](../api/)
- **Architecture**: See [Architecture Overview](../architecture.md)
- **Issues**: GitHub Issues for bug reports and features

### Community
- Create GitHub issues for bugs and feature requests
- Tag maintainers for urgent issues
- Join discussions in pull requests
- Help other contributors with questions

### Troubleshooting
If you're stuck, try these steps:
1. Check the logs for error messages
2. Search existing issues
3. Create a minimal reproduction case
4. Ask for help with specific error messages

Remember: Every contributor was once a beginner. Don't hesitate to ask questions and learn from the community!

Happy coding! 🚀
