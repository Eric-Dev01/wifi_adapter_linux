#!/bin/bash

# Script de Instalação Automática para AIC8800D80 (Wi-Fi 6 + BT)
# Inclui correção automática para erro de dkms.conf faltante e estouro de memória (Segfault).
# Compatível com Ubuntu, Pop!_OS, Linux Mint e derivados Debian.

echo "🚀 Iniciando instalação do driver AIC8800D80..."

# 1. Verificar dependências e instalar
echo "📦 Atualizando repositórios e instalando dependências..."
sudo apt update
sudo apt install -y git dkms build-essential linux-headers-$(uname -r) mokutil

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

# 4. Instalação via Script Oficial
echo "🛠️ Compilando e instalando driver (isso pode levar alguns minutos)..."
chmod +x install.sh

# Executa o instalador original e captura o erro
if ! sudo ./install.sh; then
    echo "⚠️ O instalador original falhou (DKMS ou Estouro de Memória/Segfault)."
    echo "🔧 Iniciando correção automática segura (Single-thread)..."

    # --- CORREÇÃO AUTOMÁTICA ---
    
    # A. Compilar manualmente com segurança (-j1 previne falha de segmentação na RAM)
    if [ -d "drivers/aic8800" ]; then
        cd drivers/aic8800
        echo "🔨 Compilando módulo manualmente no modo de segurança (-j1)..."
        make clean
        # O -j1 força a compilar um arquivo por vez, economizando RAM
        if make -j1; then
            echo "✅ Compilação manual segura bem-sucedida."
            sudo make install
        else
            echo "❌ Falha na compilação manual. Verifique os logs acima."
            exit 1
        fi
        cd ../..
    fi

    # B. Criar estrutura DKMS e arquivo dkms.conf seguro
    echo "📝 Criando arquivo dkms.conf manualmente com limite de núcleos..."
    sudo mkdir -p /usr/src/aic8800-1.0.0
    if [ -d "drivers/aic8800" ]; then
        sudo cp -r drivers/aic8800/* /usr/src/aic8800-1.0.0/
    fi

    # O parâmetro -j1 foi adicionado no MAKE do DKMS para proteger atualizações futuras do Kernel
    sudo tee /usr/src/aic8800-1.0.0/dkms.conf <<EOF
PACKAGE_NAME="aic8800"
PACKAGE_VERSION="1.0.0"
BUILT_MODULE_NAME[0]="aic8800_fdrv"
DEST_MODULE_LOCATION[0]="/kernel/drivers/net/wireless"
AUTOINSTALL="yes"
MAKE[0]="make -j1 -C /lib/modules/\${kernelver}/build M=\${package_source}"
CLEAN="make -C /lib/modules/\${kernelver}/build M=\${package_source} clean"
EOF

    # C. Registrar e instalar no DKMS
    echo "📦 Registrando no DKMS..."
    sudo dkms add -m aic8800 -v 1.0.0
    sudo dkms build -m aic8800 -v 1.0.0
    sudo dkms install -m aic8800 -v 1.0.0
    
    if [ $? -eq 0 ]; then
        echo "✅ DKMS configurado com sucesso via correção manual segura!"
    else
        echo "⚠️ DKMS falhou mesmo com correção. O Wi-Fi funcionará agora, mas talvez exija reinstalação ao atualizar o kernel."
    fi
    # ---------------------------
else
    echo "✅ Instalação padrão concluída com sucesso!"
fi

# 5. Carregar módulos imediatamente
echo "⚡ Carregando módulos do kernel..."
sudo modprobe aic_load_fw
sudo modprobe aic8800_fdrv

# 6. Verificar status
if lsmod | grep -q "aic8800_fdrv"; then
    echo "🎉 Sucesso! Driver carregado. Wi-Fi e Bluetooth devem estar disponíveis."
    echo "💡 Dica: Reinicie o computador para garantir que tudo inicie corretamente."
else
    echo "⚠️ O driver foi instalado, mas não carregou. Reinicie o computador."
fi

# Limpeza
cd ..
rm -rf aic8800d80

echo "🏁 Fim do script."
