# benodigdheden
# 1. passfile
# 2. Port redirection rule

# Runnen met command: timeout 5 ./closeport.sh -l

echo "closing"
{ echo "srv nat portmap disable 2 "; sleep 1; } | sshpass -f ./passfile ssh -T admin@192.168.10.1 

