# Script de Instalação Automática para AIC8800D80 (Wi-Fi 6 + BT)

Este repositório contém um script de automação focado na compilação, instalação e correção de problemas de firmware para adaptadores USB baseados no chipset **AIC8800D80** (provendo suporte a Wi-Fi 6 e Bluetooth).

## 🐧 Compatibilidade
O script foi projetado e testado para ecossistemas baseados em Debian e seus derivados diretos, incluindo:
- Ubuntu
- Pop!_OS
- Linux Mint
- Debian GNU/Linux

## 🛠️ Correções Implementadas pelo Script
O script vai além do instalador padrão, incorporando mecanismos de segurança que solucionam falhas comuns de compilação desse hardware em ambientes Linux:

1. **Prevenção de Erros de DKMS:** Cria dinamicamente a estrutura e o arquivo `dkms.conf` caso o instalador nativo falhe em gerar o registro para atualizações automáticas de Kernel.
2. **Mitigação de Estouro de Memória (Segfault):** Força a compilação em modo single-thread (`make -j1`) caso o instalador padrão sofra falhas de segmentação de memória (RAM) causadas por concorrência de múltiplos núcleos de processamento.
3. **Limpeza Preventiva:** Remove firmwares ou módulos antigos (`/lib/firmware/aic8800*` e `/usr/src/aic8800*`) antes de aplicar o novo código para prevenir conflitos em nível de Kernel.

## 📋 Detalhamento das Etapas
* **Fase 1 (Dependências):** Sincroniza os repositórios e instala ferramentas de compilação essenciais.
* **Fase 2 (Sanitização):** Limpa vestígios de instalações prévias do driver.
* **Fase 3 (Obtenção do Código):** Clona o repositório estável no diretório `/tmp`.
* **Fase 4 (Compilação e Fallback):** Tenta executar o instalador original. Caso falhe, ativa automaticamente a esteira de contingência manual (compilação segura via `-j1` e injeção de parâmetros de build restritos no DKMS).
* **Fase 5 (Ativação):** Executa o carregamento em tempo de execução dos novos módulos de firmware.
* **Fase 6 (Validação):** Inspeciona se o driver foi devidamente ativado.

## 🚀 Como Executar

1. Dê permissão de execução ao script:
   ```bash
   chmod +x install_driver.sh
