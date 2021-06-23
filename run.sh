
cd ./terraform
terraform apply -auto-approve


# Stop output in file
terraform output ec2_runner_ips > ../ansible/hosts

cd ../
cd ./ansible

echo "Removing ["
sed -i 's/\[//' ./hosts

echo "Removing ]"
sed -i 's/\]//' ./hosts

echo "Removing ,"
sed -i 's/,//' ./hosts

echo "Removing quotes 1"
sed -i 's/["]//' ./hosts

echo "Removing quotes 2"
sed -i 's/["]//' ./hosts


echo "Sleeping 40 seconds"
sleep 40 

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook playbook.yml -i hosts