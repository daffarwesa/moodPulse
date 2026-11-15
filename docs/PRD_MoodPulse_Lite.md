# Product Requirements Document (PRD): MoodPulse Lite

*Versi sederhana untuk tugas aplikasi mobile (5 halaman, 3+ fitur dinamis)*

**Platform:** Android (Flutter + Dart)
**Penyimpanan Data:** 100% lokal (SQLite via sqflite), tanpa internet dan tanpa server
**Target Rilis:** MVP untuk tugas, 1–2 minggu pengerjaan

> **Catatan implementasi prototype:** Untuk tahap frontend ini, data contoh hanya disimpan di memori aplikasi melalui `DemoStore`. Tidak ada SQLite, backend, atau penyimpanan permanen; perubahan akan kembali ke contoh awal setelah aplikasi dimulai ulang. Bagian database dan persistensi di bawah adalah kebutuhan produk asli, belum diterapkan pada prototype ini.

---

## 0. Petunjuk untuk AI Assistant (Baca Dulu)

Dokumen ini adalah sumber konteks utama proyek. Saat membantu membangun aplikasi:

1. **Patuhi scope.** Kerjakan hanya fitur di bagian "Termasuk (In Scope)". Jangan menambahkan fitur dari daftar "Tidak Termasuk (Out of Scope)".
2. **Jaga kesederhanaan.** Ini proyek tugas kuliah level pemula. Pilih solusi paling sederhana dan mudah dipahami, hindari over-engineering (tanpa dependency injection yang rumit, tanpa multi-module, tanpa library tambahan yang tidak perlu).
3. **Tech stack:** Flutter, Dart, Provider, SQLite (sqflite), dan Navigator. Operasi database memakai Future/asinkron. Tanpa internet, tanpa API eksternal, tanpa Firebase.
4. **Bahasa UI:** Bahasa Indonesia.
5. **Kerjakan bertahap** sesuai urutan di bagian Lampiran, dan pastikan tiap tahap bisa dijalankan sebelum lanjut.
6. **Jika ada hal yang ambigu,** pilih opsi paling sederhana yang memenuhi kriteria penerimaan, lalu sebutkan asumsinya.

---

## 1. Latar Belakang & Tujuan

**Masalah:** Menulis jurnal harian konvensional memakan waktu sehingga orang sering berhenti di tengah jalan.

**Tujuan:** Aplikasi *micro-journal* sederhana untuk mencatat mood, mencentang kebiasaan harian, dan menulis catatan singkat dalam waktu kurang dari 30 detik per hari, dengan data tersimpan lokal di perangkat.

**Tujuan Tugas:** Memenuhi syarat minimal berupa 5 halaman berbeda dengan navigasi yang berfungsi dan minimal 3 fitur fungsional yang berjalan dinamis.

## 2. Target Pengguna

Mahasiswa dan individu yang ingin membangun kebiasaan refleksi diri tanpa beban menulis panjang, serta tanpa perlu login atau koneksi internet.

## 3. Ruang Lingkup

### Termasuk (In Scope)

- Splash Screen
- Pencatatan mood harian (skala 1–5)
- Checklist kebiasaan harian
- Catatan singkat (maks. 280 karakter)
- Riwayat entri dan detail entri (edit dan hapus)
- Kelola kebiasaan (tambah, edit, hapus)
- Statistik sederhana (bonus)

### Tidak Termasuk (Out of Scope)

Foto dan kompresi, kalender heatmap, grafik tren, analisis korelasi, ekspor PDF, notifikasi pengingat, onboarding, sinkronisasi *cloud*, dan kunci biometrik.

## 4. Daftar Halaman (5 Screen)

| # | Halaman | Deskripsi |
| :--- | :--- | :--- |
| 1 | **Splash Screen** | Menampilkan logo dan nama aplikasi selama 2 detik, lalu otomatis menuju Home |
| 2 | **Home (Check-in Harian)** | 5 tombol mood, daftar checklist kebiasaan, kotak catatan, tombol Simpan |
| 3 | **Riwayat** | Daftar entri per tanggal, diurutkan dari terbaru |
| 4 | **Detail Entri** | Detail satu hari: mood, kebiasaan yang dicentang, catatan; tombol Edit dan Hapus |
| 5 | **Kelola Kebiasaan** | Tambah, edit, dan hapus daftar kebiasaan |

*Opsional:* jika dosen mensyaratkan Login, tambahkan halaman Login lokal (PIN atau username sederhana) setelah Splash. Ini menjadi halaman ke-6 dan tidak memerlukan server.

## 5. Fitur Fungsional

### F1. CRUD Mood & Catatan Harian

**Deskripsi:** Pengguna mencatat mood hari ini dengan skala 5 tingkat (1: Sangat Buruk, 2: Buruk, 3: Biasa Saja, 4: Baik, 5: Sangat Baik) beserta catatan singkat.

**Kriteria Penerimaan:**

- Pengguna dapat memilih mood dengan satu ketukan pada tombol ikon/emoji.
- Catatan dibatasi 280 karakter dan menampilkan indikator sisa karakter.
- Sistem hanya menyimpan satu entri per tanggal (`YYYY-MM-DD`). Jika sudah ada entri hari ini, Home menampilkan data tersebut untuk diubah.
- Entri dapat dilihat, diedit, dan dihapus dari halaman Detail Entri.

### F2. CRUD Kebiasaan & Checklist Harian

**Deskripsi:** Pengguna mengelola daftar kebiasaan positif dan mencentangnya setiap hari.

**Kriteria Penerimaan:**

- Pengguna dapat menambah, mengedit, dan menghapus kebiasaan (contoh: Olahraga, Tidur 7 Jam, Baca Buku, Minum 2L Air).
- Daftar kebiasaan aktif muncul sebagai checklist di Home.
- Centang tersimpan bersama entri hari tersebut dan tampil kembali di Detail Entri.
- Menghapus kebiasaan tidak merusak entri lama (relasi ikut dibersihkan dengan aman).

### F3. Riwayat Dinamis

**Deskripsi:** Daftar seluruh entri yang tersimpan, selalu ter-update otomatis dari database.

**Kriteria Penerimaan:**

- Setiap item menampilkan tanggal, ikon mood, dan cuplikan catatan.
- Daftar diurutkan dari tanggal terbaru.
- Mengetuk item membuka halaman Detail Entri.
- Daftar langsung berubah setelah ada entri yang ditambah, diedit, atau dihapus.
- Jika belum ada data, tampil pesan *empty state* (misal: "Belum ada catatan").

### F4. Statistik Sederhana (Bonus)

**Deskripsi:** Ringkasan singkat di Home atau Riwayat.

**Kriteria Penerimaan:**

- Menampilkan rata-rata mood 7 hari terakhir.
- Menampilkan *current streak* (hari berturut-turut) untuk tiap kebiasaan aktif, atau jumlah hari pengisian berturut-turut.

## 6. Rancangan Database Lokal (SQLite via sqflite)

### Tabel `daily_entries`

| Kolom | Tipe | Keterangan |
| :--- | :--- | :--- |
| `date_key` | TEXT (PK) | Format `YYYY-MM-DD` |
| `mood_score` | INTEGER | 1 sampai 5 |
| `note_text` | TEXT (Nullable) | Maks. 280 karakter |
| `updated_at` | INTEGER | Timestamp pembaruan terakhir |

### Tabel `habits`

| Kolom | Tipe | Keterangan |
| :--- | :--- | :--- |
| `id` | INTEGER (PK, Auto) | ID kebiasaan |
| `title` | TEXT | Nama kebiasaan |
| `created_at` | INTEGER | Timestamp pembuatan |

### Tabel `entry_habit_cross_ref`

| Kolom | Tipe | Keterangan |
| :--- | :--- | :--- |
| `date_key` | TEXT (PK, FK) | Relasi ke `daily_entries.date_key` |
| `habit_id` | INTEGER (PK, FK) | Relasi ke `habits.id` |

Relasi bersifat *many-to-many*. Gunakan `ON DELETE CASCADE` pada kedua foreign key agar data penghubung ikut terhapus saat entri atau kebiasaan dihapus.

## 7. Alur Pengguna & Navigasi

```
Splash → Home
Home → Riwayat → Detail Entri → (Edit / Hapus) → kembali ke Riwayat
Home → Kelola Kebiasaan → kembali ke Home
```

**Alur check-in harian:**

1. Buka aplikasi dan lihat Splash selama 2 detik.
2. Di Home, pilih mood, centang kebiasaan yang sudah dilakukan, dan isi catatan (opsional).
3. Tekan Simpan. Data masuk ke database dan muncul di Riwayat.
4. Buka Riwayat, ketuk entri untuk melihat detail, lalu edit atau hapus bila perlu.

Navigasi menggunakan *bottom navigation* (Home, Riwayat, Kebiasaan) atau tombol di Home. Tombol *Back* harus berfungsi normal di semua halaman.

## 8. Kebutuhan Non-Fungsional

- **Privasi:** Data hanya tersimpan di perangkat, tanpa analitik atau pelacakan pihak ketiga.
- **Performa:** Operasi database menggunakan API asinkron sqflite agar UI tidak macet.
- **Kegunaan:** Check-in harian dapat diselesaikan kurang dari 30 detik.
- **Validasi:** Mood wajib dipilih sebelum menyimpan; catatan tidak boleh melebihi 280 karakter; nama kebiasaan tidak boleh kosong.
- **Stabilitas:** Aplikasi tidak *crash* saat data kosong, rotasi layar, atau menekan tombol *Back*.

## 9. Kriteria Keberhasilan (Checklist Tugas)

- [ ] Minimal 5 halaman berbeda tersedia (Splash, Home, Riwayat, Detail, Kelola Kebiasaan)
- [ ] Navigasi antar halaman berfungsi dengan baik, termasuk tombol *Back*
- [ ] Minimal 3 fitur dinamis berjalan: CRUD mood, CRUD kebiasaan dan checklist, riwayat yang ter-update otomatis
- [ ] Data tetap tersimpan setelah aplikasi ditutup dan dibuka kembali
- [ ] Tidak ada *crash* pada alur utama

---

## Lampiran: Urutan Pembangunan yang Disarankan

Minta AI mengerjakan satu tahap per prompt, dan uji tiap tahap sebelum lanjut:

1. Setup proyek, SQLite database (3 tabel, Repository), dan Splash Screen.
2. Home: pilih mood dan simpan entri.
3. Kelola Kebiasaan dan checklist di Home.
4. Riwayat dan Detail Entri (edit, hapus).
5. Statistik sederhana, perapian UI, pengujian.
