echo "Injecting to LAB"
sshpass -p $PASS ssh -oStrictHostKeyChecking=no $USERNAME@10.100.1.10

echo "Running command"
create ltm node /paas/t-eun-ek3-api.azurewebsites.net fqdn { name t-eun-ek3-api.azurewebsites.net address-family ipv4 autopopulate enabled}

save sys config

