from flask import Flask, jsonify
import boto3

app = Flask(__name__)

# AWS S3 setup
s3_client = boto3.client('s3')
BUCKET_NAME = 's3-list-flask-app'  # Change to your S3 bucket name

def list_s3_content(path=''):
    """Helper function to list content of an S3 bucket directory."""
    try:
        # List objects with a prefix matching the path (or an empty string for top-level content)
        response = s3_client.list_objects_v2(Bucket=BUCKET_NAME, Prefix=path, Delimiter='/')
        
        # If there are no objects (both files and directories), return an empty list
        if 'Contents' not in response:
            return [], []

        # Extract files
        files = [item['Key'].split('/')[-1] for item in response['Contents'] if item['Key'] != path]
        
        # Extract directories (common prefixes)
        directories = [item['Prefix'].split('/')[-2] for item in response.get('CommonPrefixes', [])]

        return directories, files
    except Exception as e:
        # Log the error (if needed) and return empty lists for any exception that occurs
        print(f"Error listing S3 content: {str(e)}")
        return [], []

@app.route('/list-bucket-content', defaults={'path': ''})
@app.route('/list-bucket-content/<path:path>')
def list_bucket_content(path):
    """API endpoint to list S3 bucket contents based on path."""
    directories, files = list_s3_content(path)
    
    # Return both directories and files in the response
    return jsonify({"directories": directories, "files": files})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
