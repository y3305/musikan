#!/bin/bash

# Judul instalasi
echo -e "\e[1;36m=== Instalasi Pemutar Musik Termux ===\e[0m"

# Cek dependensi
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

# Clone repo (jika belum)
if [ ! -d "musikan" ]; then
    git clone https://github.com/y3305/musikan.git || {
        echo -e "\e[31mGagal clone repository!\e[0m"
        exit 1
    }
    cd musikan
else
    cd musikan
    git pull origin main || {
        echo -e "\e[33mWarning: Gagal update repository\e[0m"
    }
fi

# Cek apakah script utama ada
if [ ! -f "musikan.sh" ]; then
    echo -e "\e[31mError: File musikan.sh tidak ditemukan!\e[0m"
    exit 1
fi

# Beri izin eksekusi
chmod +x musikan.sh

# Buat symlink untuk akses global (perbaikan nama file)
ln -sf "$PWD/musikan.sh" /data/data/com.termux/files/usr/bin/musikan || {
    echo -e "\e[31mGagal membuat symlink!\e[0m"
    exit 1
}

echo -e "\e[1;32mInstalasi selesai!\e[0m"
echo -e "Jalankan dengan perintah: \e[1mmusikan\e[0m"
echo -e "Untuk uninstall, jalankan: \e[1mrm -rf ~/musikan && rm /data/data/com.termux/files/usr/bin/musikan\e[0m"