# Aliases
alias dc='docker-compose'
alias dl='docker logs $1 -f --tail 50'
alias dv='docker volume ls -q'
alias dstats='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'

# Functions
dbash() { docker exec -it $1 bash; }
dash() { docker exec -it $1 ash; }
filter() {  awk -v pat="$1" 'NR==1 || $0~pat'; }
dps() { docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | filter $1; }
dpsp() { docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}" | filter $1; }
