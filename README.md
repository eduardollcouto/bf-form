# bf-form
# DevSecOps Lab: Ataque de Força Bruta em Formulário Web (DVWA)

Este repositório documenta um projeto prático que simula e documenta um ataque de **Força Bruta** contra um formulário de *login* de aplicação *web* em um ambiente de laboratório isolado (DVWA), utilizando a ferramenta **Medusa**.

## Objetivo Educacional

O principal objetivo deste projeto é **compreender, simular e propor defesas** contra ataques de **Força Bruta** em **Formulários Web (Camada 7)**. O foco está em:

1.  **Uso Ético de Ferramentas:** Utilizar o **Medusa** e seu módulo HTTP para automação de *login* em ambientes controlados.
2.  **Desenvolvimento Seguro:** Entender as vulnerabilidades de autenticação que permitem esses ataques.
3.  **Mitigação Prática:** Documentar e implementar os controles de segurança mais eficazes para prevenir a força bruta em aplicações web (ex: *Rate Limiting*, CAPTCHA).

## Arquitetura do Laboratório

Todos os testes foram realizados em um ambiente de máquinas virtuais (VMs) isolado usando o VirtualBox ou similar, configurado com uma rede **Host-Only** para garantir o isolamento.

* **Máquina Atacante:** Kali Linux (Contém o Medusa, Python, e Bash scripts)
* **Máquina Alvo:** DVWA (*Damn Vulnerable Web Application* hospedada em uma VM)
* **Rede:** Host-Only (Ex: 192.168.15.0/24)

## Scripts Implementados

Foram criados e utilizados scripts interativos em **Bash** e **Python** para automatizar o processo de teste, garantindo a criação de *wordlists* de senhas e usuários personalizadas.

| Script | Serviço Alvo | Linguagem | Ação Principal |
| :--- | :--- | :--- | :--- |
| `dvwa_bruteforce.py` | Formulário Web (Módulo `http` do Medusa) | Python | Cria listas personalizadas e automatiza o ataque contra o formulário de *login*. |
| `dvwa_bruteforce.sh` | Formulário Web (Módulo `http` do Medusa) | Bash | Cria listas personalizadas e automatiza o ataque contra o formulário de *login*. |

---

## Detalhamento do Comando de Ataque (HTTP Form)

O ataque de Força Bruta contra formulários *web* exige que o atacante simule o envio de dados POST do navegador, usando o Medusa para interagir na Camada 7 (Aplicação).

### 1. Criação da Lista de Usuários (*Users List*)

O comando `echo` é usado para criar uma lista básica de usuários para o ataque.

| Comando de Exemplo | Descrição |
| :--- | :--- |
| `echo -e "admin\nuser\ntester" > users_dvwa.txt` | Cria um arquivo de texto com cada usuário em uma nova linha. O `>` cria ou sobrescreve o arquivo de saída. |

### 2. Criação da Lista de Senhas (*Wordlist*)

A ferramenta **`crunch`** é usada para gerar uma *wordlist* com um conjunto de caracteres e comprimento definidos.

| Comando de Exemplo | Descrição dos Parâmetros |
| :--- | :--- |
| `crunch 7 7 abcdefghijklmnopqrstuvwxyz0123456789 -o pass_dvwa.txt -c 10` | Define o **comprimento de 7** (`7 7`), lista os **caracteres permitidos** (minúsculas e números) e **salva 10 senhas** no arquivo `pass_dvwa.txt`. |

### 3. Execução do Ataque de Força Bruta (Medusa)

O Medusa é o vetor principal para testar as combinações de credenciais, usando o módulo HTTP.

#### Comando de Exemplo (Módulo HTTP)

medusa -h 192.168.15.36 -U users_dvwa.txt -P pass_dvwa.txt -M http \
-m PAGE:'/dvwa/login.php' \
-m FORM:'username=^USER^&password=^PASS^&Login=Login' \
-m 'FAIL=Login failed' -t 6

| Parâmetro |	Tipo | Descrição 
| -M http	| Módulo | Especifica que a auditoria será feita usando o protocolo HTTP.
| -m PAGE:'...'	| Payload	| Define a URI específica que recebe a requisição de login POST.
| -m FORM:'...'	| Payload	| Define a estrutura dos dados POST, onde ^USER^ e ^PASS^ são substituídos pelas entradas das wordlists.
| -m 'FAIL=...'	| Payload	| A string de erro que o Medusa procura na resposta HTML para determinar que a tentativa de login falhou

### Objetivo e Ação do Ataque

O ataque automatiza a tentativa de login no formulário web do DVWA:

**1. Montagem:** O Medusa monta a requisição HTTP POST com as credenciais.
**2. Análise:** O Medusa analisa o conteúdo da resposta HTTP em busca da string de falha (Login failed).
**3. Sucesso:** A ausência da string de falha na resposta é o indicador de que uma combinação válida foi encontrada, comprovando a vulnerabilidade.

### Principais Recomendações de Mitigação (Webforms)
**1. Limite de Taxa (Rate Limiting):** Implementar um WAF (Web Application Firewall) ou proxy reverso para impor um limite no número de solicitações POST por endereço IP em um curto período (ex: 5 requisições por minuto).
**2. CAPTCHA/MFA:** Exigir a resolução de um CAPTCHA (como reCAPTCHA) após um número pequeno de tentativas falhas (ex: 3). Para maior segurança, implementar Autenticação Multifator (MFA).
**3. Bloqueio de Conta:** Configurar a aplicação para bloquear temporariamente a conta do usuário após um número limite de falhas.
**4. Monitoramento SIEM:** Criar regras que alertem sobre o padrão de falhas (muitas requisições POST para a página de login resultando na string de erro "Login failed" vindas do mesmo IP).

## Aviso Legal

**ESTE MATERIAL É APENAS PARA FINS EDUCACIONAIS E DE ESTUDO ÉTICO.** O teste de segurança e a Força Bruta só devem ser realizados em sistemas para os quais você possui **permissão explícita por escrito**. O uso deste código em ambientes não autorizados é ilegal e antiético.
