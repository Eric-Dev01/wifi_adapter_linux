#!/bin/bash

# Script de Instalação Automática para AIC8800D80 (Wi-Fi 6 + BT)
# Compatível com Ubuntu, Pop!_OS, Linux Mint e derivados Debian.

echo "🚀 Iniciando instalação do driver AIC8800D80..."

# 1. Verificar dependências e instalar
echo "📦 Atualizando repositórios e instalando dependências..."
sudo apt update
sudo apt install -y git dkms build-essential linux-headers-$(uname -r)

# 2. Limpar instalações anteriores (Crítico para evitar conflitos de firmware)
echo "🧹 Limpando firmware antigo para evitar travamentos..."
sudo rm -rf /lib/firmware/aic8800*
sudo rm -rf /usr/src/aic8800*

# 3. Clonar o repositório mais estável (shenmintao)
echo "📥 Baixando driver mais recente..."
cd /tmp
if [ -d "aic8800d80" ]; then
    rm -rf aic8800d80
fi
git clone https://github.com/shenmintao/aic8800d80.git
cd aic8800d80

# 4. Instalação via Script Oficial (Configura DKMS automaticamente)
echo "🛠️ Compilando e instalando driver (isso pode levar alguns minutos)..."
chmod +x install.sh
sudo ./install.sh

if [ $? -eq 0 ]; then
    echo "✅ Instalação concluída com sucesso!"
    
    # Carregar módulos imediatamente sem reiniciar
    echo "⚡ Carregando módulos do kernel..."
    sudo modprobe aic_load_fw
    sudo modprobe aic8800_fdrv
    
    # Verificar status
    if lsmod | grep -q "aic8800_fdrv"; then
        echo "🎉 Driver carregado! Wi-Fi deve estar disponível."
        echo "💡 Dica: Se o Bluetooth não aparecer, tente o branch 'bluetooth' do repositório."
    else
        echo "⚠️ O driver foi instalado, mas não carregou. Reinicie o computador."
    fi
else
    echo "❌ Erro na instalação. Verifique se o Secure Boot está desativado na BIOS."
    exit 1
fi

# Limpeza
cd ..
rm -rf aic8800d80

echo "🏁 Fim do script."   
