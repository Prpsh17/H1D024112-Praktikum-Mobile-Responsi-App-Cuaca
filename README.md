# Nama : Prapasha Budi Harimawan
# NIM : H1D024112

# Minimalist Weather App — Responsi Flutter

Aplikasi cuaca berbasis **Flutter (Dart)** dengan pola arsitektur **MVVM (Model–View–ViewModel)**, state management **Provider**, penyimpanan lokal **SharedPreferences**, dan data cuaca *real-time* dari **Open-Meteo REST API**.
---

## Fitur Utama

1. **Home / Weather Screen**
   - Menampilkan nama kota terpilih beserta tombol simpan favorit (`★`).
   - Menampilkan suhu terkini berukuran besar dengan simbol derajat melingkar halus dan kondisi cuaca hasil pemetaan kode WMO.
   - Menampilkan prakiraan cuaca harian (3 kolom terlihat sesuai template UI, dapat digeser horizontal hingga 7 hari ke depan) lengkap dengan ikon garis minimalis serta suhu maksimum dan minimum (`max° | min°`).
   - Menampilkan detail informasi tambahan: **Suhu yang Dirasakan**, **Kelembapan**, **Kecepatan Angin**, **Curah Hujan**, dan **Peluang Hujan Maksimum**.
   - Mendukung *pull-to-refresh* serta penanganan kondisi *loading*, *data kosong*, dan *error* (dengan tombol **Coba Lagi**).
   - Drawer menu (`≡`) untuk berpindah cepat antar lokasi favorit dan mengganti satuan suhu (`°C` / `°F`).

2. **Search / Location Screen**
   - Pencarian kota secara langsung melalui **Open-Meteo Geocoding API** dengan *debounce* 450 ms.
   - Memilih hasil pencarian untuk menampilkan cuacanya di Home Screen.
   - Menyimpan dan menghapus lokasi favorit serta menampilkan **Riwayat Pencarian** yang tersimpan permanen di **SharedPreferences** (tetap tersedia saat aplikasi dibuka kembali).

---

## Screenshot Aplikasi

> Tambahkan hasil tangkapan layar dari emulator/perangkat Anda ke folder `screenshots/` lalu sesuaikan nama file di bawah ini sebelum dikumpulkan.

| Home / Weather Screen | Search / Location Screen | Menu Favorit & Pengaturan |
| :---: | :---: | :---: |
| ![Home Screen](<img width="361" height="797" alt="image" src="https://github.com/user-attachments/assets/c702ddc9-2bd0-46ae-9251-dbd0a423d4b4" />
) | ![Search Screen](<img width="362" height="803" alt="image" src="https://github.com/user-attachments/assets/503878a6-7bd9-4640-b6b8-52ad5d841403" />
) | ![Menu Drawer](<img width="360" height="799" alt="image" src="https://github.com/user-attachments/assets/54b05fe4-b300-401c-8a72-d33f2bd67c85" />
) |
