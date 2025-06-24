# User Guide

Welcome to the CSV Processor! This guide will help you understand how to use the application to upload, process, and manage your CSV files.

## What is CSV Processor?

CSV Processor is a web-based application that allows you to:
- **Upload CSV files** through a simple web interface
- **View file contents** line by line in your browser
- **Store files securely** in cloud storage (AWS S3)
- **Access previous uploads** and processing history

The application is designed to handle CSV (Comma-Separated Values) files efficiently and securely, making it easy to work with data files in various formats.

## Getting Started

### Accessing the Application

The CSV Processor can be accessed through your web browser at:
- **Local development**: http://localhost:3000
- **Deployed instance**: Your organization's provided URL

No registration or login is required for basic functionality.

### System Requirements

**For users:**
- Any modern web browser (Chrome, Firefox, Safari, Edge)
- Internet connection
- JavaScript enabled

**File requirements:**
- CSV format (.csv extension)
- Maximum file size: 10MB
- UTF-8 encoding recommended

## Using the Application

### 1. Upload a CSV File

1. **Open the application** in your web browser
2. **Click "Choose File"** or drag and drop your CSV file onto the upload area
3. **Select your CSV file** from your computer
4. **Click "Upload"** to start processing

![Upload Interface](./docs/images/upload-interface.png)

### 2. View Processing Results

After uploading, you'll see:
- **File information**: Name, size, upload time
- **Processing status**: Success or error messages
- **Row count**: Number of rows processed
- **Data preview**: First few rows displayed in a table format

### 3. Understanding the Results

The application shows your CSV data in a clean, organized table:
- **Row numbers** on the left
- **Column headers** (if detected)
- **Data cells** with proper formatting
- **Processing summary** at the top

## Features Explained

### File Upload
- **Drag and drop**: Simply drag your CSV file onto the upload area
- **File validation**: Automatic checking for valid CSV format
- **Size limits**: Files up to 10MB are supported
- **Progress indication**: Visual feedback during upload

### CSV Processing
- **Line-by-line parsing**: Files are processed row by row for efficiency
- **Header detection**: Column headers are automatically identified
- **Error handling**: Invalid rows are reported with specific error messages
- **Encoding support**: UTF-8 encoding ensures proper character display

### Cloud Storage
- **Automatic backup**: Successfully processed files are stored in the cloud
- **Secure access**: Files are stored with proper security measures
- **Intelligent lifecycle management**: Files automatically transition through storage classes for cost optimization:
  - **0-30 days**: Standard storage for immediate access
  - **30-90 days**: Standard-IA for reduced costs on older files
  - **90+ days**: Glacier and Deep Archive for long-term, cost-effective storage
- **7-year retention**: Files are automatically managed and cleaned up after 7 years

### Data Display
- **Tabular format**: Clean, easy-to-read table presentation
- **Row highlighting**: Alternate row colors for better readability
- **Responsive design**: Works on desktop and mobile devices
- **Copy-friendly**: Easy to select and copy data from the display

## Supported CSV Formats

### Basic Format
```csv
Name,Age,City
John Doe,30,New York
Jane Smith,25,Los Angeles
```

### With Quoted Fields
```csv
"Last Name","First Name","Address"
"Smith, Jr.","John","123 Main St, Apt 4B"
"O'Connor","Mary","456 Oak Avenue"
```

### With Special Characters
```csv
Product,Price,Description
"Widget A",$19.99,"High-quality widget with ""premium"" features"
"Widget B",$29.99,"Standard widget, good value"
```

## Best Practices

### Preparing Your CSV Files

1. **Use proper headers**: Include descriptive column names in the first row
2. **Consistent formatting**: Keep date formats, numbers, and text consistent
3. **Handle special characters**: Use quotes around fields containing commas or newlines
4. **Check encoding**: Save files as UTF-8 to ensure proper character display
5. **Remove empty rows**: Clean up your data before uploading

### File Organization

- **Descriptive names**: Use clear, descriptive filenames
- **Date stamping**: Include dates in filenames for version control
- **Size management**: Split very large files into smaller chunks if needed

### Working with Data

- **Review results**: Always check the processed output for accuracy
- **Note processing time**: Large files may take a few moments to process
- **Save important data**: Download or backup critical information

## Troubleshooting

### Common Issues and Solutions

#### "No file selected" Error
**Problem**: Upload button clicked without selecting a file
**Solution**: Make sure to select a CSV file before clicking upload

#### "File too large" Error
**Problem**: Your file exceeds the 10MB limit
**Solutions**:
- Split the file into smaller parts
- Remove unnecessary columns or rows
- Compress the data by removing extra spaces

#### "Invalid file format" Error
**Problem**: File is not in CSV format or is corrupted
**Solutions**:
- Ensure file has .csv extension
- Open in a spreadsheet program and re-save as CSV
- Check for special characters that might corrupt the file

#### Processing Takes Too Long
**Problem**: Large files are slow to process
**Solutions**:
- Be patient - large files naturally take more time
- Consider splitting very large files
- Check your internet connection

#### Data Appears Scrambled
**Problem**: Text shows strange characters or formatting
**Solutions**:
- Save your file with UTF-8 encoding
- Check for hidden characters in your data
- Ensure commas are properly escaped in text fields

#### Upload Fails Repeatedly
**Problem**: Files won't upload despite seeming correct
**Solutions**:
- Try refreshing the page
- Check your internet connection
- Clear your browser cache
- Try a different browser

### Getting Help

If you continue to experience issues:

1. **Check the error message**: Read any error messages carefully for specific guidance
2. **Try a simple test file**: Create a basic CSV with a few rows to test functionality
3. **Contact support**: Reach out to your system administrator or technical support
4. **Document the issue**: Note the exact error message and steps that led to the problem

## Security and Privacy

### Data Handling
- **Secure transmission**: Files are uploaded using secure HTTPS connections
- **Temporary processing**: Files are only stored temporarily during processing
- **Cloud backup**: Processed files are securely stored in cloud storage
- **Access controls**: Proper security measures protect your data

### Privacy Considerations
- **No registration required**: Use the service without creating accounts
- **Data processing**: Files are processed server-side for security
- **Retention policies**: Files may be automatically archived or deleted based on policies
- **No data sharing**: Your CSV data is not shared with third parties

### Best Practices for Sensitive Data
- **Review content**: Ensure you're comfortable uploading the data
- **Remove sensitive information**: Consider removing personal or confidential data
- **Use test data**: Try the service with non-sensitive data first
- **Understand policies**: Check with your organization about data handling policies

## Limitations

### Current Limitations
- **File size**: Maximum 10MB per file
- **File types**: Only CSV format supported
- **Processing time**: 30-second timeout for very large files
- **Concurrent uploads**: One file at a time per session

### Planned Improvements
- Support for larger files
- Additional file formats (Excel, TSV)
- Batch processing capabilities
- User accounts and file management
- Advanced data validation and transformation

## Tips for Better Results

### Data Quality
- **Clean your data**: Remove empty rows and columns
- **Consistent formatting**: Use the same date and number formats throughout
- **Proper encoding**: Use UTF-8 encoding to avoid character issues
- **Test with samples**: Try a small sample first to verify formatting

### Performance
- **Optimal file size**: Files between 1-5MB typically process fastest
- **Avoid complexity**: Simple CSV structures process more reliably
- **Good naming**: Use descriptive filenames for better organization

### Workflow Integration
- **Batch similar files**: Process related files together
- **Document your process**: Keep notes on file sources and processing dates
- **Regular maintenance**: Periodically review and organize your uploaded files

## Frequently Asked Questions

**Q: Can I upload Excel files?**
A: Currently, only CSV format is supported. You can convert Excel files to CSV using Excel's "Save As" feature.

**Q: What happens to my files after processing?**
A: Files are securely stored in cloud storage and may be archived according to retention policies.

**Q: Is there a limit to how many files I can upload?**
A: There's no specific limit, but each file must be under 10MB.

**Q: Can I download my processed files?**
A: Currently, the application displays processed data in the browser. Download functionality may be added in future versions.

**Q: Is my data secure?**
A: Yes, files are transmitted securely and stored with appropriate security measures.

**Q: Can I process files with non-English characters?**
A: Yes, as long as your file is saved with UTF-8 encoding.

**Q: What if my CSV has thousands of rows?**
A: Large files are supported up to 10MB, though processing time may increase with file size.

---

We hope this guide helps you make the most of CSV Processor. For additional support or feature requests, please contact your system administrator or submit feedback through your organization's channels.
