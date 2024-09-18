# PERMISSIONS TO BE ADDED VIA SDK

gcloud projects add-iam-policy-binding militaryknowledge --member "serviceAccount:810277572019-compute@developer.gserviceaccount.com" --role "roles/container.admin"

gcloud projects add-iam-policy-binding militaryknowledge --member "serviceAccount:810277572019-compute@developer.gserviceaccount.com" --role "roles/container.admin"

gcloud iam service-accounts add-iam-policy-binding 810277572019-compute@developer.gserviceaccount.com --member "user:dimitri.griparis@ctengineeringgroup.com" --role "roles/iam.serviceAccountUser" --project militaryknowledge 
#ADD A STATIC ADDRESS FOR NAT GATEWAY 
then refer to it in your script this is easier than running it all the time in Infra and incurring costs.

gcloud compute addresses create nat_gateway --region europe-west1 --project militaryknowledge

gcloud iam service-accounts add-iam-policy-binding 810277572019-compute@developer.gserviceaccount.com --member "user:dimitri.griparis@ctengineeringgroup.com" --role "roles/iam.serviceAccountUser" --project militaryknowledge

gcloud projects add-iam-policy-binding militaryknowledge --member "user:dimitri.griparis@ctengineeringgroup.com" --role "roles/container.admin"    

nat gateway has been remove from folder gke and will be added to infra when we are ready to implement this as a solution since the nat gateway has a charge for the static ip
