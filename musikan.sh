#!/bin/bash

FOLDER_PENCARIAN="$HOME/storage/shared/music"
EKSTENSI_MUSIK=("mp3" "flac" "wav" "ogg" "aac" "m4a")

# Fungsi validasi input yang lebih robust
input_pilihan_user() {
    local pilihan
    while true; do
        read -p "Pilih folder : " pilihan
        
        # Handle input kosong
        if [[ -z "$pilihan" ]]; then
            echo -e "\e[31mError: Input tidak boleh kosong!\e[0m"
            continue
        fi
        
        # Handle input non-numerik
        if [[ ! "$pilihan" =~ ^[0-9,]+$ ]]; then
            echo -e "\e[31mError: Hanya menerima angka dan koma!\e[0m"
            continue
        fi
        
        # Split input
        IFS=',' read -ra indeks_terpilih <<< "$pilihan"
        
        # Validasi setiap indeks
        local valid=1
        for indeks in "${indeks_terpilih[@]}"; do
            indeks=$(echo "$indeks" | tr -d ' ')
            if ! [[ "$indeks" =~ ^[0-9]+$ ]] || \
               [[ "$indeks" -lt 1 ]] || \
               [[ "$indeks" -gt "${#folder_musik[@]}" ]]; then
                echo -e "\e[31mError: Pilihan '$indeks' tidak valid (harus 1-${#folder_musik[@]})\e[0m"
                valid=0
                break
            fi
        done
        
        [[ $valid -eq 1 ]] && break
    done
    
    echo "${indeks_terpilih[@]}"
}

cari_folder_musik() {
    echo "Mencari folder musik di $FOLDER_PENCARIAN..."
    
    declare -A folder_unik
    
    for ekstensi in "${EKSTENSI_MUSIK[@]}"; do
        while IFS= read -r -d $'\0' file; do
            folder=$(dirname "$file")
            folder_unik["$folder"]=1
        done < <(find "$FOLDER_PENCARIAN" -type f -iname "*.$ekstensi" -print0 2>/dev/null)
    done
    
    folder_musik=("${!folder_unik[@]}")
    
    if [[ ${#folder_musik[@]} -eq 0 ]]; then
        echo -e "\e[31mError: Tidak ditemukan folder berisi musik!\e[0m"
        exit 1
    fi
    
    echo -e "\n\e[1;32mDaftar Folder Musik:\e[0m\n"
    for i in "${!folder_musik[@]}"; do
        echo "$((i+1)). $(basename "${folder_musik[i]}")"
    done
    echo ""
}

mainkan_musik() {
    clear
    termux-volume music 2
    trap "clear" EXIT
    local files=()
    for folder in "${folder_terpilih[@]}"; do
        for ekstensi in "${EKSTENSI_MUSIK[@]}"; do
            while IFS= read -r -d $'\0' file; do
                files+=("$file")
            done < <(find "$folder" -type f -iname "*.$ekstensi" -print0 2>/dev/null)
        done
    done
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo -e "\e[31mError: Tidak ada file musik di folder terpilih!\e[0m"
        return 1
    fi
    
    echo -e "\nMemutar ${#files[@]} lagu dari ${#folder_terpilih[@]} folder..."
    
    mpv --shuffle --no-video -- "${files[@]}"
    return $?
}

# Main Program
clear
cari_folder_musik

# Dapatkan pilihan valid
indeks_terpilih=($(input_pilihan_user))

# Konversi ke folder
folder_terpilih=()
for indeks in "${indeks_terpilih[@]}"; do
    folder_terpilih+=("${folder_musik[indeks-1]}")
done

# Mainkan dengan error handling
if ! mainkan_musik; then
    echo -e "\e[31mGagal memutar musik. Silakan cek folder dan file.\e[0m"
    exit 1
fi
