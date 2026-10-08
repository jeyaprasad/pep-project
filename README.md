# PEP Cloud and DevOps CI/CD Project

## 1. Test Locally
To test the Docker container locally before pushing:
```bash
docker build -t imgfilter .
docker run -p 8080:80 imgfilter
```
Access the application at `http://localhost:8080`.

## 2. Git Setup and Push
Initialize the repository and push to GitHub:
```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/jeyaprasad/Insii-Image.git
git push -u origin main
```

## 3. Jenkins Server Prerequisites
On the Jenkins server, install the required packages:
```bash
sudo apt-get update
sudo apt-get install -y git docker.io unzip
# Install Terraform
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install terraform

# Add Jenkins user to the docker group
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

## 4. Jenkins Credentials
Add the following credentials in Jenkins (Manage Jenkins -> Credentials):
1. **ghcr-token**: Secret text. This should be your GitHub PAT (Personal Access Token) with `write:packages` and `repo` permissions. ID must be `ghcr-token`.
2. **aws-access-key-id**: Secret text. Your AWS IAM Access Key. ID must be `aws-access-key-id`.
3. **aws-secret-access-key**: Secret text. Your AWS IAM Secret Key. ID must be `aws-secret-access-key`.

## 5. Job 1 Configuration (Build & Push Docker Image)
- **Type**: Freestyle Project
- **Source Code Management**: Git (Repo URL: `https://github.com/jeyaprasad/Insii-Image.git`, Branch: `main`)
- **Build Triggers**: GitHub hook trigger for GITScm polling
- **Build Environment**: Use secret text(s) or file(s)
  - Bind `GHCR_TOKEN` to `ghcr-token`
- **Build Steps (Execute Shell)**:
```bash
docker build -t ghcr.io/jeyaprasad/imgfilter:latest .
echo $GHCR_TOKEN | docker login ghcr.io -u jeyaprasad --password-stdin
docker push ghcr.io/jeyaprasad/imgfilter:latest
```

## 6. Job 2 Configuration (Deploy via Terraform)
- **Type**: Freestyle Project
- **Source Code Management**: Git (Same as Job 1)
- **Build Triggers**: Build after other projects are built (Projects to watch: `job1`)
- **Build Environment**: Use secret text(s) or file(s)
  - Bind `AWS_ACCESS_KEY_ID` to `aws-access-key-id`
  - Bind `AWS_SECRET_ACCESS_KEY` to `aws-secret-access-key`
- **Build Steps (Execute Shell)**:
```bash
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_DEFAULT_REGION="ap-south-1"

terraform init
terraform validate
terraform plan
terraform apply -auto-approve
```

## 7. GitHub Webhook Setup
To automate the pipeline on `git push`:
1. Go to your GitHub repository -> Settings -> Webhooks -> Add webhook.
2. **Payload URL**: `http://<jenkins-server-ip>:8080/github-webhook/`
3. **Content type**: `application/json`
4. Choose **Just the push event**.

## 8. Making the GHCR Package Public
After the first run of `job1`, the Docker image is pushed as a **Private** package by default.
To allow the EC2 instance to pull it without logging in:
1. Go to your GitHub profile -> Packages.
2. Select `imgfilter`.
3. Click "Package settings" on the right.
4. Scroll down to the Danger Zone -> Change visibility -> Change to **Public**.

## 9. Verification & Troubleshooting
Wait 2-3 minutes after `job2` completes for the EC2 instance to boot and install Docker.
- **Verification**: Open the `website_url` output from `job2` in your browser. You should see the application with the "Deployed via Jenkins CI/CD" footer.

### Troubleshooting
- **Docker Permission Denied on Jenkins**: Ensure the `jenkins` user is in the `docker` group and you have restarted Jenkins (`sudo systemctl restart jenkins`).
- **Private GHCR Image**: If EC2 can't pull the image, verify the package visibility is set to Public in GitHub Packages.
- **Cloud-Init Logs**: SSH into the EC2 instance and run `cat /var/log/cloud-init-output.log` to see if the user_data script failed.
- **Terraform Errors**: Ensure the AWS credentials in Jenkins are valid, the region matches your account, and the key pair `<YOUR_KEYPAIR_NAME>` exists in the same region.

## 10. Re-deploying / Updating
If you make a change (e.g., modifying the footer) and push to GitHub, Jenkins will build a new Docker image and push it. However, the existing EC2 instance will **not** automatically restart the container to pull the new version.
**For demonstration purposes, the easiest way to see the update is to:**
1. Manually run `terraform destroy -auto-approve` (or add a destroy job).
2. Re-run `job2` to create a fresh EC2 instance that pulls the latest image.
*Alternatively, add an SSH step in Jenkins to connect to the EC2 instance, pull the new image, and restart the container.*
