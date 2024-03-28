from flask import request
from google.cloud import storage
from google.cloud import pubsub_v1
import json


# Set your Google Cloud project ID
project_id = "orbital-outpost-416405"
topic_name = "cca-topic"      

def hello_http(request):
    source_bucket_name = 'cca-source'
    error_bucket_name = 'cca-error'
    json_files_present = False
    attributes = {"service": "failure"}

    # Initialize the client
    storage_client = storage.Client()
    publisher = pubsub_v1.PublisherClient()

    # Get the list of objects in the error bucket
    blobs = storage_client.list_blobs(error_bucket_name)

    # Iterate through the objects and send them to Pub/Sub
    for blob in blobs:
        if blob.name.endswith('.json'):
            json_files_present = True
            # Check if the file is also present in the source bucket
            source_blob = storage_client.get_bucket(source_bucket_name).blob(blob.name)
            if source_blob and source_blob.exists():
                # Download the JSON content from the error bucket
                error_content = blob.download_as_string().decode('utf-8')
                error_data = json.loads(error_content)

                # Download the JSON content from the source bucket
                source_content = source_blob.download_as_string().decode('utf-8')
                source_data = json.loads(source_content)
                
                # Check if 'empid' is present and matches in both files
                if 'empid' in error_data and 'empid' in source_data and error_data['empid'] == source_data['empid']:
                    # Construct the message payload
                    message_payload = json.dumps({'data': source_content}).encode('utf-8')

                    # Add attributes to the message
                    attributes = {"service": "failure", "context": json.dumps(attributes)}

                    # Publish the message to Pub/Sub
                    topic_path = publisher.topic_path(project_id, topic_name)
                    future = publisher.publish(topic_path, data=message_payload ,**attributes)
                    message_id = future.result()

                    print(f"Published message to Pub/Sub topic: {topic_path}, Message ID: {message_id}")

                    # Delete the object from the error bucket
                    blob.delete()
                    print(f"Deleted object {blob.name} from error bucket")
                else:
                    print(f"Error: 'empid' mismatch in files {blob.name} - Skipping processing")
            else:
                print(f"Error: File {blob.name} not found in source bucket")
        else:
            print(f"Error: File {blob.name} is not a JSON file - Skipping processing")

    if not json_files_present:
        print("No json files found in the error bucket.")  

    # Return a response
    return "Processed the error bucket."      
 
# if __name__ == "__main__":
#     event = {}  # Dummy event object
#     context = {}  # Dummy context object
#     hello_http(event, context)
#   #hello_http()