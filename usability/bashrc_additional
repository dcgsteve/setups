# Aliases
alias dc='docker-compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}" | tail -n +2 | sort -k 1 -h'
alias dlogs='docker logs $1 -f --tail 50'
alias dvol='docker volume ls -q'

# Functions
dbash() { docker exec -it $1 bash; }
filter() {  awk -v pat="$1" 'NR==1 || $0~pat'; }
