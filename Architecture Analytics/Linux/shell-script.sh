# Mostrar o diretório atual (Print Working Directory)
$ pwd
/home/usuario

# Listar arquivos e pastas
$ ls          # listagem simples
$ ls -l       # listagem longa (detalhada)
$ ls -la      # inclui arquivos ocultos (começam com .)
$ ls -lh      # tamanhos em formato legível (KB, MB)

# Navegar entre diretórios
$ cd /var/log     # caminho absoluto
$ cd ../..        # dois diretórios acima
$ cd ~            # vai para home do usuário
$ cd -            # volta ao diretório anterior

# Hierarquia do Sistema de Arquivos Linux
/              ← raiz de tudo
├── bin/       ← binários essenciais (ls, cp, mv...)
├── etc/       ← arquivos de configuração do sistema
├── home/      ← diretórios dos usuários
│   └── usuario/  ← seu diretório pessoal (~)
├── tmp/       ← arquivos temporários (limpos no reboot)
├── var/       ← dados variáveis (logs, banco, mail)
│   └── log/   ← logs do sistema
├── usr/       ← programas instalados pelo usuário
└── proc/      

# Criar, mover e deletar 
# Criar diretórios
$ mkdir minha_pasta
$ mkdir -p projetos/linux/aula1   # cria toda a hierarquia

# Criar arquivos
$ touch arquivo.txt               # cria arquivo vazio
$ echo "Olá Linux" > saudacao.txt # cria com conteúdo

# Copiar
$ cp arquivo.txt backup.txt       # copia arquivo
$ cp -r pasta/ pasta_backup/      # copia diretório inteiro

# Mover / Renomear
$ mv arquivo.txt novo_nome.txt    # renomear
$ mv arquivo.txt /tmp/            # mover para outro local

# Deletar
$ rm arquivo.txt                  # remove arquivo
$ rm -rf pasta/                   




# Permissões e Usuários
$ ls -l
-rwxr-xr--  1  alice  devs  2048  Mar 20  script.sh

  Tipo─┐  ┌─Dono  ┌─Grupo  ┌─Outros
       │  │       │         │
  - rwx r-x r--
  │ │││ │││ │││
  │ │││ │││ └└└── Outros: r=leitura, -=sem escrita, -=sem exec
  │ │││ └└└────── Grupo:  r=leitura, -=sem escrita, x=execução
  │ └└└────────── Dono:   r=leitura,  w=escrita,    x=execução
  └────────────── Tipo: - arquivo, d diretório, l link simbólico

# Alterando permissões com chmod

# Método simbólico (mais legível)
$ chmod u+x script.sh     # dá execução ao dono (u=user)
$ chmod g-w arquivo.txt   # remove escrita do grupo
$ chmod o+r doc.pdf       # dá leitura a outros (o=others)
$ chmod a+r publico.txt   # dá leitura a todos (a=all)

# Método octal (mais rápido)
$ chmod 755 script.sh    # rwxr-xr-x
$ chmod 644 arquivo.txt  # rw-r--r--
$ chmod 600 privado.key  # rw------- (só o dono lê)

# Tabela octal:
# 4 = leitura (r)
# 2 = escrita  (w)
# 1 = execução (x)
# 7 = 4+2+1 = rwx | 6 = 4+2 = rw- | 5 = 4+1 = r-x

# Alterar dono do arquivo
$ chown alice arquivo.txt
$ chown alice:devs arquivo.txt  # muda dono E grupo


#############################################################################################

# Visualização e Busca
# Visualizar conteúdo 
$ cat HPC_2k.log        # mostra tudo de uma vez
$ less HPC_2k.log 	    # paginado (q para sair)
$ head -20 HPC_2k.log 	# primeiras 20 linhas
$ tail -20 HPC_2k.log  # últimas 20 linhas
$ tail -f /var/log/syslog  # monitora log em tempo real

# Buscar texto dentro de arquivos
$ grep "erro" HPC_2k.log         # busca a palavra "erro"
$ grep -i "erro" HPC_2k.log      # ignora  maiúsculas/minúsculas

# Buscar arquivos
$ find . -name "*.log"            # busca por nome
$ find . -size +1M               # arquivos maiores que 1MB
$ find . -mtime -7               # modificados nos últimos 7 dias

# Pipes — combinar comandos
$ ls -l | grep ".sh"             # filtrar resultado do ls
$ cat HPC_2k.log | grep "ERRO" | wc -l  # contar erros no log

# Redirecionamento
$ echo "texto" > arquivo.txt     # sobrescreve
$ echo "mais" >> arquivo.txt     # acrescenta
$ comando 2> erros.log           # redireciona erros
$ comando &> tudo.log            # redireciona stdout e stderr

# Scripts Shell
# Hello World e Estrutura Básica

# Script: 01_hello.sh

#!/bin/bash
# Comentários começam com #
# Este script é uma introdução ao Bash

# Variáveis: sem espaços ao redor do =
NOME="Linux"
VERSAO=1

# echo imprime na tela
echo "Olá, $NOME!"
echo "Este é o script número $VERSAO"

# date: data/hora atual
echo "Executado em: $(date)"

# Variáveis especiais do sistema
echo "Usuário atual: $USER"
echo "Diretório home: $HOME"
echo "Diretório atual: $PWD"

#!/bin/bash	Shebang: diz ao SO qual interpretador usar. Deve ser a primeira linha.
NOME="Linux"	Define uma variável. Sem espaços! NOME = "Linux" causaria erro.
echo "Olá, $NOME!"	O $ antes do nome da variável acessa seu valor (substituição).
$(date)	Subshell: executa o comando dentro e usa o resultado como texto.
$USER, $HOME	Variáveis de ambiente: definidas pelo sistema automaticamente.

# Condicionais if else
Script: 02_condicional.sh

#!/bin/bash

# $1 é o primeiro argumento passado ao script
NUMERO=$1

# Verificar se o argumento foi fornecido
if [ -z "$NUMERO" ]; then
    echo "Uso: $0 <numero>"
    exit 1
fi

# Comparação numérica
if [ "$NUMERO" -gt 100 ]; then
    echo "$NUMERO é GRANDE (maior que 100)"
elif [ "$NUMERO" -gt 10 ]; then
    echo "$NUMERO é MÉDIO (entre 11 e 100)"
else
    echo "$NUMERO é PEQUENO (10 ou menos)"
fi

Linha / Comando	O que faz e POR QUÊ
$1	Argumento posicional: $1 é o 1º, $2 o 2º... $0 é o nome do script.
[ -z "$NUMERO" ]	-z verifica se a string está vazia. Usar aspas evita erros se estiver vazia.
exit 1	Encerra o script com código de erro. Convenção: 0 = sucesso, 1+ = erro.
-gt	Greater Than (maior que). Comparadores: -lt (menor), -ge (>=), -le (<=), -eq (igual).
elif	Else If: encadeia condições alternativas. Equivalente ao else if de outras linguagens.

# Loops e Automação

#!/bin/bash

echo "=== Loop FOR com lista ==="
for FRUTA in maçã banana laranja uva; do
    echo "  Fruta: $FRUTA"
done

echo ""
echo "=== Loop FOR com range ==="
for I in $(seq 1 5); do
    echo "  Contando: $I"
done

echo ""
echo "=== Loop WHILE ==="
CONTADOR=0
while [ $CONTADOR -lt 3 ]; do
    echo "  Contador: $CONTADOR"
    CONTADOR=$((CONTADOR + 1))
done

echo ""
echo "=== Loop em arquivos ==="
for ARQUIVO in *.sh; do
    echo "  Script encontrado: $ARQUIVO"
done

Linha / Comando	O que faz e POR QUÊ
for X in lista; do	Itera sobre cada item da lista. O ; do pode ir na mesma linha ou na próxima.
$(seq 1 5)	Gera sequência de números: 1 2 3 4 5. Útil para loops numéricos.
while [ cond ]; do	Executa enquanto a condição for verdadeira. Cuidado com loops infinitos!
$((CONTADOR + 1))	Aritmética em Bash: $(( )) faz cálculos. Alternativa: let ou expr.
*.sh	Glob (wildcard): o shell expande automaticamente para todos arquivos .sh no diretório.


# Funcções e Script Completo
# Script: 04_funcoes.sh

#!/bin/bash

# ─── FUNÇÕES ───────────────────────────────────────

# Função para mostrar cabeçalho
mostrar_cabecalho() {
    echo "================================"
    echo "  $1"
    echo "================================"
}

# Função que verifica se arquivo existe
verificar_arquivo() {
    local ARQUIVO="$1"   # local = variável só existe dentro da função
    if [ -f "$ARQUIVO" ]; then
        echo "✓ Arquivo existe: $ARQUIVO"
        return 0   # sucesso
    else
        echo "✗ Arquivo NÃO encontrado: $ARQUIVO"
        return 1   # erro
    fi
}

# ─── PROGRAMA PRINCIPAL ────────────────────────────

mostrar_cabecalho "Verificador de Arquivos"

ARQUIVOS=("/etc/hosts" "/etc/shadow" "/tmp/teste.txt")

for ARQ in "${ARQUIVOS[@]}"; do
    verificar_arquivo "$ARQ"
done

Linha / Comando	O que faz e POR QUÊ
funcao() { ... }	Define uma função. Chamada como um comando normal: funcao argumento.
$1 dentro da função	Dentro de funções, $1, $2... são os argumentos passados À FUNÇÃO, não ao script.
local ARQUIVO	Variável local: existe apenas dentro da função. Evita conflitos com variáveis globais.
-f "$ARQUIVO"	Testa se é um arquivo regular. Outros: -d (diretório), -e (existe), -r (legível).
"${ARQUIVOS[@]}"	Expande todos os elementos do array. As aspas evitam problemas com espaços nos nomes.





####################### Linux Aula 2 ########################

Objetivos da Aula
Ao final desta aula o aluno será capaz de:
•	Gerenciar processos, serviços e recursos do sistema
•	Escrever scripts robustos com tratamento de erros
•	Usar expressões regulares e ferramentas de processamento de texto (sed, awk)
•	Criar tarefas agendadas com cron
•	Gerenciar redes e conexões via linha de comando
•	Implementar pipelines de automação profissionais


# Monitoramento de processos

# Processos em tempo real
$ top                       # monitor interativo (q para sair)
$ htop                      # versão melhorada (se instalado)

# Snapshot de processos
$ ps aux                    # todos processos
$ ps aux | sort -k3 -rn | head -10  # top 10 por CPU
$ ps aux | sort -k4 -rn | head -10  # top 10 por Memória

# Informações de memória e CPU
$ free -h                   # uso de RAM
$ vmstat 2 5                # estatísticas a cada 2s (5 vezes)
$ uptime                    # carga do sistema (load average)
$ nproc                     # número de CPUs/cores
$ cat /proc/cpuinfo         # informações detalhadas da CPU

# Encontrar processo por nome
$ pgrep nginx               # retorna PIDs do nginx
$ pidof bash                # PID do processo bash


# Controle de processos 

# Sinais: formas de comunicar com processos
$ kill -9 1234              # SIGKILL: força encerramento (PID 1234)
$ kill -15 1234             # SIGTERM: encerramento educado (padrão)
$ killall nginx             # mata todos os processos "nginx"
$ pkill -f "python script"  # mata por nome completo

# Executar em background
$ comando &                 # envia para background
$ jobs                      # lista jobs em background
$ fg %1                     # traz job 1 para foreground
$ bg %1                     # continua job 1 em background

# nohup: processo continua mesmo após logout
$ nohup long_script.sh &
$ nohup long_script.sh > /var/log/meu_script.log 2>&1 &

# Prioridade de processos (nice)
$ nice -n 10 heavy_job.sh   # menor prioridade (10 = gentil)
$ renice -n -5 -p 1234      # muda prioridade de processo em execução

# Serviços com systemd

# systemctl: gerenciar serviços modernos
$ systemctl status nginx          # status do serviço
$ sudo systemctl start nginx      # iniciar
$ sudo systemctl stop nginx       # parar
$ sudo systemctl restart nginx    # reiniciar
$ sudo systemctl reload nginx     # recarregar config sem reiniciar

# Habilitar/desabilitar no boot
$ sudo systemctl enable nginx     # inicia automaticamente no boot
$ sudo systemctl disable nginx    # não inicia no boot

# Listar serviços
$ systemctl list-units --type=service --state=running

# Logs do serviço (journald)
$ journalctl -u nginx             # todos os logs do nginx
$ journalctl -u nginx -f          # logs em tempo real
$ journalctl -u nginx --since "1 hour ago"
$ journalctl -p err               # apenas erros do sistema


## Processamento de texto: regex

# Expressões regulares essenciais
 

# Exemplos práticos com grep -E (Extended Regex)
$ grep -E "^[0-9]{1,3}\.[0-9]{1,3}" arquivo.txt   # endereços IP
$ grep -E "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+" emails.txt  # emails
$ grep -E "^$" arquivo.txt                           # linhas vazias
$ grep -E "(ERRO|WARN|FATAL)" log.txt                # múltiplos padrões

# sed com regex
$ sed -E "s/[0-9]+/NUM/g" texto.txt   # substitui todos os números
$ sed -E "/^\s*$/d" arquivo.txt       # remove linhas em branco/espaços

# awk com regex
$ awk "/^[0-9]/" dados.txt            # linhas que começam com número


## Automação com Cron e tratamento de erros
sudo apt update
sudo apt install cron
# Cron, agendamento de tarefas
# Sintaxe do crontab:
# * * * * * comando
# │ │ │ │ │
# │ │ │ │ └─── Dia da semana (0-7, 0 e 7 = domingo)
# │ │ │ └───── Mês (1-12)
# │ │ └─────── Dia do mês (1-31)
# │ └───────── Hora (0-23)
# └─────────── Minuto (0-59)

# Editar crontab do usuário atual
$ crontab -e

# Exemplos práticos:
# A cada minuto:
* * * * * /home/usuario/script.sh

# Todo dia às 2:30 da manhã:
30 2 * * * /usr/local/bin/backup.sh

# Toda segunda-feira às 9h:
0 9 * * 1 /scripts/relatorio_semanal.sh
# A cada 5 minutos:
*/5 * * * * /scripts/monitorar.sh

# Todo dia 1º do mês às meia-noite:
0 0 1 * * /scripts/limpeza_mensal.sh

# Listar crons ativos:
$ crontab -l

# Remover todos os crons:
$ crontab -r

# Scripts robustos com tratamento de erros

#!/bin/bash

# ─── CONFIGURAÇÕES DE SEGURANÇA ────────────────────
set -e            # encerra se qualquer comando falhar
set -u            # erro se usar variável não definida
set -o pipefail   # erro se qualquer parte de pipe falhar

# ─── VARIÁVEIS ─────────────────────────────────────
LOG_FILE="/var/log/meu_script.log"
DATA=$(date "+%Y-%m-%d %H:%M:%S")

# ─── FUNÇÕES ────────────────────────────────────────
log() {
    local NIVEL="$1"
    local MSG="$2"
    echo "[$DATA] [$NIVEL] $MSG" | tee -a "$LOG_FILE"
}

cleanup() {
    log "INFO" "Limpando recursos temporários..."
    rm -f /tmp/meu_script_*
    log "INFO" "Finalizado."
}

# Trap: executa cleanup em saída (normal ou erro)
trap cleanup EXIT

# ─── VERIFICAÇÕES PRÉ-EXECUÇÃO ──────────────────────
verificar_root() {
    if [ "$aluno" -ne 0 ]; then
        log "ERRO" "Este script requer root. Use: sudo $0"
        exit 1
    fi
}

# ─── MAIN ───────────────────────────────────────────
log "INFO" "Script iniciado"

# Exemplo de comando com verificação de resultado
if cp /etc/hosts /tmp/hosts_backup 2>/dev/null; then
    log "OK" "Backup criado com sucesso"
else
    log "ERRO" "Falha ao criar backup"
    exit 1
fi

log "INFO" "Concluído com sucesso"


Linha / Comando	O que faz e POR QUÊ
set -e	Exit on error: qualquer comando com código de saída != 0 encerra o script. Evita execução parcial.
set -u	Unbound variables: usar variável não declarada vira erro. Previne bugs difíceis de detectar.
set -o pipefail	Sem isso, "cmd_falha | cmd_ok" retornaria 0 (sucesso). Com isso, o pipe falha corretamente.
tee -a "$LOG_FILE"	tee lê stdin e escreve em stdout E em arquivo. -a (append) não sobrescreve o log.
trap cleanup EXIT	Trap captura sinais. EXIT garante que cleanup() rode sempre que o script terminar.
$EUID -ne 0	EUID = Effective User ID. Root sempre tem ID 0. Verifica se o script roda como root.

# Diagnóstico de rede

# Informações de interface
$ ip addr show              # endereços IP de todas interfaces
$ ip addr show eth0         # apenas eth0
$ ip route show             # tabela de roteamento

# Conectividade e DNS
$ ping -c 4 google.com      # testa conectividade (4 pacotes)
$ traceroute google.com     # rastrea rota até destino
$ nslookup google.com       # resolve DNS
$ dig google.com            # DNS detalhado

# Portas e conexões
$ ss -tuln                  # portas em escuta (TCP/UDP)
$ ss -tunp                  # inclui PID do processo
$ netstat -tuln             # alternativa clássica

# Transferência e download
$ curl -I https://site.com  # apenas headers HTTP
$ curl -o arquivo.zip https://url/arquivo.zip
$ wget https://url/arquivo

# Verificar se porta está aberta
$ nc -zv 192.168.1.1 80     # testa porta 80
$ nc -zv 192.168.1.1 22     # testa porta SSH


# SSH e automação remota
# Conexão SSH básica
$ ssh usuario@192.168.1.100
$ ssh -p 2222 usuario@host  # porta customizada

# Executar comando remoto sem abrir sessão
$ ssh usuario@host "df -h"
$ ssh usuario@host "ls /var/log/*.log | wc -l"

# Gerar par de chaves SSH (autenticação sem senha)
$ ssh-keygen -t ed25519 -C "meu@email.com"
# Cria: ~/.ssh/id_ed25519 (privada) e id_ed25519.pub (pública)

# Copiar chave pública para servidor
$ ssh-copy-id usuario@host

# Copiar arquivos com scp
$ scp arquivo.txt usuario@host:/destino/
$ scp -r pasta/ usuario@host:/destino/

# Config SSH (~/.ssh/config) para atalhos
Host meuservidor
    HostName 192.168.1.100
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_ed25519

# Com config: ssh meuservidor  (em vez do comando longo)


 
#Pipeline de automação avançado
Script: 06_backup_avançado.sh

#!/bin/bash
set -euo pipefail

# ─── CONFIGURAÇÃO ───────────────────────────────────
SOURCE_DIR="${1:-/etc}"
BACKUP_DIR="${2:-/tmp/backups}"
MAX_BACKUPS=7             # manter últimos 7 backups
DATA=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/backup_${DATA}.tar.gz"
LOG="$BACKUP_DIR/backup.log"

# ─── FUNÇÕES ────────────────────────────────────────
log() { echo "[$(date +%H:%M:%S)] $*" | tee -a "$LOG"; }

criar_backup() {
    log "Iniciando backup de: $SOURCE_DIR"
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_FILE" "$SOURCE_DIR" 2>/dev/null
    SIZE=$(du -sh "$BACKUP_FILE" | cut -f1)
    log "Backup criado: $BACKUP_FILE ($SIZE)"
}

rotacionar_backups() {
    local COUNT
    COUNT=$(ls "$BACKUP_DIR"/backup_*.tar.gz 2>/dev/null | wc -l)
    if [ "$COUNT" -gt "$MAX_BACKUPS" ]; then
        local DELETAR=$((COUNT - MAX_BACKUPS))
        log "Removendo $DELETAR backup(s) antigo(s)..."
        ls -t "$BACKUP_DIR"/backup_*.tar.gz | tail -"$DELETAR" | xargs rm -f
    fi
}

verificar_integridade() {
    if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
        log "✓ Integridade OK"
    else
        log "✗ ERRO: backup corrompido!"
        exit 1
    fi
}

# ─── EXECUÇÃO ───────────────────────────────────────
log "=== INÍCIO DO BACKUP ==="
criar_backup
verificar_integridade
rotacionar_backups
log "=== BACKUP CONCLUÍDO ==="


Linha / Comando	O que faz e POR QUÊ
"${1:-/etc}"	Valor padrão: usa $1 se fornecido, senão usa /etc. Torna o script flexível sem obrigar argumentos.
tar -czf	-c cria arquivo, -z comprime com gzip, -f especifica nome. Resultado: .tar.gz (tarball comprimido).
du -sh | cut -f1	du -sh mostra tamanho humanizado. cut -f1 pega só a primeira coluna (o tamanho, sem o nome).
ls -t | tail -N | xargs rm	ls -t ordena por tempo (mais novo primeiro), tail pega os mais antigos, xargs passa para rm.
tar -tzf > /dev/null	-t lista conteúdo, -z descomprime, -f lê arquivo. Redirecionar para /dev/null descarta a saída; apenas o código de saída importa.
local COUNT	Variável local na função. Boa prática para não poluir o escopo global com variáveis temporárias.
