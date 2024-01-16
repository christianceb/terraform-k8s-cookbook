# quickstart auth

https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html#cli-authentication-user-configure-csv

aws configure --profile bsdl-programmed

# Region
us-east-2

aws configure list-profiles

terraform plan -var profile=quickstart-poc
terraform apply -var profile=quickstart-poc
aws s3 ls --profile=quickstart-poc
terraform destroy -var profile=quickstart-poc


aws ec2 describe-images --owner 099720109477 --profile=quickstart-poc --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy*" "Name=architecture,Values=x86_64" --no-cli-pager --output text --query 'Images[*].Description'

https://stackoverflow.com/questions/49743220/how-to-create-an-ssh-key-in-terraform


terraform output -raw primary-private-key > primary.private && chmod 400 primary.private
terraform output -raw primary-public-key > primary.public

https://medium.com/@hmalgewatta/setting-up-an-aws-ec2-instance-with-ssh-access-using-terraform-c336c812322f

# Newly created EBS volumes need to be formatted, mounted and put into fstab for it to be used

https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html

# Update lock file

terraform init -upgrade

# DigitalOcean token

https://docs.digitalocean.com/reference/api/create-personal-access-token/
