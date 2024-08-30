# gcp-storage-buckt-terraform
Step-by-Step Guide to Setting Up Terraform on GCP
 Step 1: Set Up a Service Account with Proper Roles.
 
        Go to the Google Cloud Console:

       Visit the IAM & Admin > Service Accounts section.
        Create a New Service Account:

       Click Create Service Account.
       Provide a name and description for the service account.
       Assign the Required Roles:

       Assign the Storage Admin role (roles/storage.admin) to the service account to allow it to manage Google Cloud Storage buckets.
       Generate and Download a JSON Key:

       After creating the service account, go to the Keys section.
       Click Add Key > Create New Key and select JSON.
       Download the JSON key file to your local machine.

  Step 2: Transfer the Service Account Key to Your VM.
  
          Upload the JSON Key to Your VM:
          Use scp or another secure method to transfer the JSON key file to your VM running on GCP (Ubuntu instance, in your case).
          scp /path/to/your/service-account-key.json ubuntu@<VM_IP>:/home/ubuntu/

Step 3: Configure the Environment for Terraform.

          Set the GOOGLE_APPLICATION_CREDENTIALS Environment Variable:
          On your VM, run the following command to set the environment variable that points to your service account key:

          export GOOGLE_APPLICATION_CREDENTIALS="/home/ubuntu/service-account-key.json"

Step4:
      Now run terrafrom

    
