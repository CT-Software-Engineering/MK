# PERMISSIONS TO BE ADDED VIA SDK

gcloud iam service-accounts add-iam-policy-binding 810277572019-compute@developer.gserviceaccount.com --member "user:dimitri.griparis@ctengineeringgroup.com" --role "roles/iam.serviceAccountUser" --project militaryknowledge 

gcloud projects add-iam-policy-binding militaryknowledge --member "user:dimitri.griparis@ctengineeringgroup.com" --role "roles/container.admin"  

Go to IAM & Admin > IAM

Find the service account in the list

Click on the pencil icon to edit permissions

Add your account with the "Service Account User" role

#ADD A STATIC ADDRESS FOR NAT GATEWAY 
then refer to it in your script this is easier than running it all the time in Infra and incurring costs.
gcloud compute addresses create nat_gateway --region europe-west1 --project militaryknowledge


nat gateway has been remove from folder gke and will be added to infra when we are ready to implement this as a solution since the nat gateway has a charge for the static ip
