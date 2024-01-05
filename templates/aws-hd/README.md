# quickstart auth

https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-user.html#cli-authentication-user-configure-csv

# Region
us-east-2

aws configure list-profiles

terraform plan -var profile=quickstart-poc
terraform apply -var profile=quickstart-poc
aws s3 ls --profile=quickstart-poc
terraform destroy -var profile=quickstart-poc


aws ec2 describe-images --owner 099720109477 --profile=quickstart-poc --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-jammy*" "Name=architecture,Values=x86_64" --no-cli-pager --output text --query 'Images[*].Description'

https://stackoverflow.com/questions/49743220/how-to-create-an-ssh-key-in-terraform


terraform output -raw primary_private_key > id_ed25519.pem && chmod 400 id_ed25519.pem
terraform output -raw primary_public_key > id_ed25519.pub

terraform output -raw primary_private_key > id_ed25519.pem && chmod 400 id_ed25519.pem | terraform output -raw primary_public_key > id_ed25519.pub

https://medium.com/@hmalgewatta/setting-up-an-aws-ec2-instance-with-ssh-access-using-terraform-c336c812322f
