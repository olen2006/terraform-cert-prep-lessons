#----------------------------------------------------------
# My Terraform
# Flobal variables in Remote state on S3
#
# 12.03.2020
#----------------------------------------------------------
// export GOOGLE_CLOUD_KEYFILE_JSON="mygcp-creds.json"   

provider "google" {
credentials=file("mygcp-creds.json")
project= "mineral-voyage-297607" 
region="us-west1"
zone="us-west1-a"
}

resource "google_compute_instance" "my_server" {
    name="my-gcp-server"
    machine_type="f1-micro"
    boot_disk{
        initialize_params{
            image="debian-cloud/debian-9"
        }
    }
 network_interface{
     network="default"
 }
}