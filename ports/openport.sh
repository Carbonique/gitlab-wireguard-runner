
# benodigdheden
# 1. passfile
# 2. Port redirection rule

# Runnen met command: timeout 5 ./openport.sh -l

echo "opening"
{ echo "srv nat portmap enable 2 udp"; sleep 1; } | sshpass -f ./passfile ssh -T admin@192.168.10.1 

