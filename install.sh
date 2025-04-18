#!/bin/bash

# Fungsi untuk meminta izin penyimpanan
minta_izin_penyimpanan() {
    echo -e "\e[1;33mMeminta izin akses penyimpanan...\e[0m"
    termux-setup-storage
    
    # Cek apakah izin diberikan
    if [ ! -d "$HOME/storage/shared" ]; then
        echo -e "\e[31mError: Izin penyimpanan ditolak!\e[0m"
        echo "Mohon berikan izin ketika muncul prompt Termux"
        exit 1
    fi
    
    echo -e "\e[32mIzin penyimpanan diberikan\e[0m"
}

# Judul instalasi
echo -e "\e[1;36m=== Instalasi Pemutar Musik Termux ===\e[0m"

# Minta izin penyimpanan
minta_izin_penyimpanan

# Install dependensi
dependencies=("mpv" "git" "findutils")
for pkg in "${dependencies[@]}"; do
    if ! command -v "$pkg" &> /dev/null; then
        echo -e "\e[33mMenginstall $pkg...\e[0m"
        pkg install -y "$pkg" || {
            echo -e "\e[31mGagal menginstall $pkg!\e[0m"
            exit 1
        }
    else
        echo -e "\e[32m$pkg sudah terinstall\e[0m"
    fi
done

# Buat folder musik default jika belum ada
mkdir -p "$HOME/storage/shared/Music" 2>/dev/null

# Beri izin eksekusi
chmod +x musikan.sh

# Buat symlink
ln -sf "$PWD/musikan.sh" "$PREFIX/bin/musikan" || {
    echo -e "\e[31mGagal membuat symlink!\e[0m"
    exit 1
}

# Selesai
echo -e "\e[1;32mInstalasi berhasil!\e[0m"
echo -e "Cara pakai:"
echo -e "1. Simpan file musik di \e[1m~/storage/shared/Music\e[0m"
echo -e "2. Jalankan dengan ketik: \e[1mmusikan\e[0m"
echo -e "\nUntuk uninstall:"
echo -e "\e[1mrm -rf ~/musikan && rm $PREFIX/bin/musikan\e[0m"
echo -e "\natau jalankan berintah berikut;"
echo -e "\e[1mrm chmod +x $HOME/musikan/uninstall.sh\[0m"
echo -e "\e[1mrm bash $HOME/musikan/uninstall.sh\e[0m"
