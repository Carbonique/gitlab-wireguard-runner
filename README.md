Kern:

Minimale dependencies. De systemen moeten onwetend zijn over het feit dat ze via de cloud worden aangestuurd.

Oplossing:

AWS EC2 Spot GitLab runner (Wireguard Client) --> RPI Zero W gateway (Wireguard Server) --> Lokale Pi's.


Eisen:

1. De Zero W gateway staat alleen aan wanneer nodig en wordt getriggerd vanuit een GitLab Pipeline.
2. De AWS EC2 Runners worden on-demand opgebouwd vanuit een GitLab Pipeline
3. Lokale devices zijn stateless (in die beperkte zin dat lokale data vooralsnog op een SSD/HDD staat)

Technologisch:

1. EC2 spot opbouwen met Terraform?
2. Zero W Wireguard Gateway opzetten met Ansible
3. Deployment richting Pi's is dan combi van GitLab + Ansible (Voor nu in ieder geval)

timeout 5 ./openport.sh -l

De router zet poorten open indien nodig ( srv nat portmap enable 2 udp)
2 = indexnummer van de regel. 
Regel nog wel handmatig aanmaken

Toekomst

1. Runner provisioner en auto-scaling runners op AWS
2. RPI Zero W gateway aan/uit zetten via Node Red + ESP 8266. (Dat creeërt dan wel een dependency, maar ach)


Luci:
Zie ook https://www.reddit.com/r/openwrt/comments/bahhua/openwrt_wireguard_vpn_server_tutorial/

1. Lan verbinden
2. Bridgen
3. statisch ip geven in router
4. root password instelen


Architectuur:

openwrt <---> Runner Provisioner (AWS) <- (ip forwarding) -> Autoscaling runners (max 3)

Project in drie fases:

1. AWS infra opzetten (Terraform)
2. AWS infra provisionen (Ansible)
3. Lokale gedeelte automatiseren (openwrt + router ports)


## GitLab runner:
1. Install
2. Register
3. Config.toml
4. \

VARS:

GITLAB_RUNNER_CI_TOKEN
GITLAB_RUNNER_REGISTRATION_TOKEN