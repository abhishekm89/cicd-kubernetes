# Project Requirements: (Reference)
    # CICD-containers-setup-1.png
    # CICD-containers-setup-2.png
    
# Creating HELM charts under empty HELM repo.
mkdir helm
cd helm
helm create vprofilecharts
cd helm/vprofilecharts/templates
rm -rf *

# Copy your kubernetes definition files under /helm/vprofilecharts/templates

cp kubernetes/vpro-app/* /helm/vprofilecharts/templates/

kubectl create namespace test
helm install --namespace test vprofile-stack helm/vprofilecharts --set appimage=abhishekm89/app:latest
helm list
kubectl get all

helm delete vprofile-stack --namespace test

kubectl create namespace prod

# write Jenkinsfile
# Adding KOPS VM as slave to Jenkins 
    # Login to KOPS Server:
        # Install openjdk-8-jdk
        # mkdir /opt/jenkins-slave
        # sudo chown ubuntu.ubuntu /opt/jenkins-slave -R
        # update KOPS Security Group (Allow Port 22 from Jenkins SG)
    # Manage Jenkins > Manage Nodes & Clouds > New Node
        # Node Name: kops
        # Labels: KOPS
        # Remote root directory: /opt/jenkins-slave
        # Launch Agent: via SSH
            # Host: <private IP of KopsInstance>
            # Credentials: SSH Username with private Key
            # HostKey Verification: Non-Verifying