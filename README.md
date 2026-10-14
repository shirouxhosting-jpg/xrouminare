# XROUMINARE — Custom Theme untuk Pterodactyl Panel

**One Panel. Endless Possibilities.**

Theme bergaya **Saweria** untuk Pterodactyl Panel: UI playful dengan tombol warna solid ber-border hitam dan bayangan hitam tebal, Light/Dark/System mode tanpa reload, sidebar baru, dashboard baru, dan halaman login baru — tanpa mengubah backend, API, permission, maupun database.

---

## 1. Ringkasan Audit Environment

| Item | Hasil |
|---|---|
| Direktori kerja | `D:\ProjectAI\xrouminer` (awalnya kosong, tidak ada instalasi Pterodactyl lokal / akses VPS) |
| Basis theme | Source resmi **pterodactyl/panel v1.11.11** (tag stabil 1.x terbaru; v2.0 masih beta) di-clone ke `panel/` |
| Frontend panel | React 16.14 + webpack 4 + Tailwind CSS 3.0.24 + styled-components/twin.macro |
| Sistem tema bawaan | **Tidak ada** (dark-only) — sistem Light/Dark/System dibangun dari nol di theme ini |
| Node lokal | v24.19.0 (build memakai `NODE_OPTIONS=--openssl-legacy-provider` karena webpack 4) |
| Build lokal | ✅ `yarn build:production` dijalankan dan sukses (lihat bagian 8) |

> Theme ini ditargetkan untuk **Pterodactyl v1.11.x** dan diverifikasi terhadap **v1.11.11**.

## 2. Struktur Proyek

```
xrouminer/
├── panel/               # Source Pterodactyl v1.11.11 + modifikasi XROUMINARE
├── theme-bundle/        # Hasil scripts/pack.sh — file theme siap deploy ke VPS
├── scripts/
│   ├── pack.sh          # Kumpulkan file theme dari panel/ ke theme-bundle/
│   ├── install.sh       # Installer di VPS: backup → copy → build
│   └── uninstall.sh     # Rollback di VPS dari backup
└── preview/             # Preview statis design system (tidak untuk produksi)
```

## 3. Fitur

- **Design tokens** Saweria (cyan/kuning/pink/hijau/ungu, border hitam, shadow offset 5px) sebagai CSS variables di `resources/scripts/assets/css/xrou-theme.css`.
- **Light / Dark / System mode**: toggle di sidebar (dan drawer mobile), tersimpan di `localStorage` (`xrou-theme`), anti-flash via inline script di `wrapper.blade.php`, mengikuti preferensi OS saat mode System.
- **Seluruh panel ikut ter-theme**: palet `gray/neutral/black` Tailwind dipetakan ke CSS variables (`tailwind.config.js`), jadi console, file manager, database, schedules, users, backups, network, startup, settings, account, activity — semuanya berubah antara Light/Dark tanpa reload.
- **Sidebar baru** (`XrouAppShell`): sidebar kiri desktop, drawer di mobile, header dengan search (Ctrl+/), avatar, admin link; sub-navigasi server pindah ke sidebar (permission-aware).
- **Dashboard baru**: sapaan pengguna, 4 stat card (Total/Running/Stopped/Suspended — data nyata dari API client), ringkasan resource (CPU/RAM/Disk agregat), daftar server berupa card dengan badge Online/Offline, filter, pagination, empty state, skeleton loading.
- **Login baru**: kartu brand + form, show/hide password, tombol Login cyan, link "Lupa password?" (Pterodactyl tidak punya registrasi mandiri, jadi tombol Daftar tidak disertakan).
- **Komponen reusable** di `resources/scripts/components/xrou/`: `XrouButton` (via restyle elemen Button bawaan), `XrouCard`, `XrouInput`, `XrouBadge`, `XrouModal` (via restyle Modal bawaan), `XrouToast` (via restyle MessageBox/FlashMessage), `XrouThemeToggle`, `XrouSidebar` (XrouAppShell), `XrouServerCard`, `XrouEmptyState`, `XrouLoadingSkeleton`, `XrouLogo` (SVG buatan sendiri), `XrouPasswordField`, `XrouStatCard`.
- **Console**: WebSocket & command input dipertahankan; terminal tetap gelap di kedua mode (seperti referensi); tombol power Start (hijau), Restart (kuning/netral), Stop/Kill (pink) sesuai permission.
- **Responsive**: sidebar jadi drawer, card grid menyesuaikan, tidak ada horizontal overflow.

## 4. File yang Dibuat (baru — aman dihapus saat rollback)

| File | Isi |
|---|---|
| `resources/scripts/assets/css/xrou-theme.css` | Design tokens Light/Dark + komponen CSS (.xrou-btn, .xrou-card, dst.) |
| `resources/scripts/components/xrou/` (13 file) | Component library theme (lihat daftar di atas) |

## 5. File yang Diubah (menggantikan file bawaan)

| File | Perubahan | Dampak saat update panel |
|---|---|---|
| `tailwind.config.js` | Palet → CSS variables + ramp warna XROUMINARE | **Diperkirakan conflict** — merge manual: bagian `colors`, `fontFamily`, `borderColor`, `boxShadow` |
| `resources/views/templates/wrapper.blade.php` | Anti-flash script + font Nunito + body class | Conflict ringan; tambahkan kembali blok script anti-flash & import font |
| `resources/scripts/components/App.tsx` | +1 import CSS theme | Konflik kecil; tambahkan 1 baris import setelah `tailwind.css` |
| `resources/scripts/assets/css/GlobalStylesheet.ts` | Scrollbar dipindah ke theme CSS | Konflik kecil |
| `elements/Button.tsx`, `elements/Input.tsx`, `elements/Modal.tsx`, `elements/GreyRowBox.tsx`, `elements/ScreenBlock.tsx`, `elements/DropdownMenu.tsx`, `elements/dialog/style.module.css`, `elements/button/style.module.css`, `elements/activity/style.module.css` | Restyle visual, **API/props tidak berubah** | Jika panel update mengubah file ini, ambil versi baru lalu terapkan ulang pola warna (nilai var `--xrou-*`) |
| `server/console/Console.tsx`, `server/console/style.module.css` | Terminal transparan + frame tema | Sama seperti di atas |
| `auth/LoginFormContainer.tsx`, `auth/LoginContainer.tsx` | Redesign; logika Formik/reCAPTCHA/2FA **tidak diubah** | Jika alur auth berubah di versi baru, ulangi redesign |
| `dashboard/DashboardContainer.tsx` | Redesign penuh (data tetap dari API) | Sama |
| `routers/DashboardRouter.tsx`, `routers/ServerRouter.tsx` | NavigationBar/SubNavigation → XrouAppShell | **Paling rawan conflict** — inti perubahannya: bungkus konten dengan `<XrouAppShell serverNav={...}>` |

> **Backend tidak disentuh sama sekali** (tidak ada perubahan PHP kecuali template blade untuk anti-flash/font).

## 6. Instalasi di VPS

Dari mesin ini (Windows), kirim project ke VPS lalu jalankan installer:

```bash
# 1. (lokal) Buat bundle theme
bash scripts/pack.sh

# 2. (lokal → VPS) Upload project, mis. via rsync/scp
scp -r theme-bundle scripts user@vps:/tmp/xrouminer/

# 3. (VPS) Jalankan installer — argumen = path instalasi panel
cd /tmp/xrouminer/scripts
bash install.sh /var/www/pterodactyl
```

Installer akan: memverifikasi versi panel → mem-backup file yang ditimpa ke `<panel>/.xrou-backup-<timestamp>/` → menyalin theme → `yarn install` → `yarn build:production` → `php artisan view:clear`.

**Cara manual** (tanpa script): salin isi `theme-bundle/` ke folder panel (timpa), jalankan build:

```bash
cd /var/www/pterodactyl
yarn install --ignore-engines
NODE_OPTIONS=--openssl-legacy-provider yarn build:production   # Node >= 17
php artisan view:clear
```

## 7. Mengaktifkan Light/Dark/System Mode

1. Login ke panel → lihat **sidebar kiri bagian bawah**: kotak "Mode" dengan 3 tombol ☀ Light / ◐ System / ☾ Dark.
2. Klik salah satu — tema berubah **tanpa reload**.
3. Pilihan tersimpan di browser (localStorage key `xrou-theme`) dan bertahan antar halaman/sesi.
4. Mode **System** mengikuti pengaturan OS secara langsung (termasuk perubahan real-time).
5. Halaman pertama yang dimuat langsung sesuai tema tersimpan — tidak ada flash warna (script anti-flash di `wrapper.blade.php` berjalan sebelum CSS).

## 8. Verifikasi

- Build produksi dijalankan di mesin ini: `yarn build:production` → **sukses**, output di `panel/public/assets/` (`bundle.*.js` + chunks + `manifest.json`).
- Preview statis design system: buka `preview/index.html` (berisi Button/Card/Badge/Input/Toast dalam Light & Dark — bukan aplikasi panel penuh).
- **Di VPS yang belum diverifikasi oleh script ini** (tidak ada akses VPS dari mesin lokal), lakukan cek berikut setelah install:
  - `/auth/login` tampil kartu XROUMINARE; coba password salah → toast error tampil.
  - Login → dashboard memuat stat card dan daftar server dari API.
  - Toggle Light/Dark di sidebar → seluruh halaman berubah tanpa reload; refresh halaman → tema tersimpan.
  - Buka satu server: console connect (cek log WebSocket), kirim command, Start/Restart/Stop sesuai permission.
  - File manager: upload, new file, editor, rename, delete (konfirmasi dialog tampil dengan gaya baru).
  - DevTools → Console tidak ada error merah; Network → semua asset 200.

## 9. Rollback

```bash
# Opsi A — otomatis (pakai backup terbaru):
bash scripts/uninstall.sh /var/www/pterodactyl

# Opsi B — manual:
cd /var/www/pterodactyl
cp -a .xrou-backup-<timestamp>/. /tmp/restore/   # lihat isi backup
# salin kembali file dari backup ke path aslinya, hapus components/xrou,
# lalu build ulang:
NODE_OPTIONS=--openssl-legacy-provider yarn build:production
php artisan view:clear
```

Backup hanya dibuat untuk file yang ditimpa; file baru (folder `components/xrou/`, `xrou-theme.css`) dihapus manual oleh uninstaller.

## 10. Catatan Kompatibilitas & Ketahanan Update

- **Target: Pterodactyl v1.11.x.** Diuji terhadap v1.11.11. Panel v2/Pelican **tidak** didukung (arsitektur frontend berbeda).
- Semua perubahan berada di frontend (`resources/scripts`, `tailwind.config.js`) + 1 template blade. `git pull` update panel akan conflict pada file di bagian 5 — strategi aman: `git stash` → update → `git stash pop` → resolve → build.
- API, permission, routing, WebSocket, autentikasi, CSRF, 2FA, dan database **tidak dimodifikasi**, sehingga fitur panel tetap utuh.
- Tidak ada migrasi database dan tidak ada perubahan `.env`/config produksi.
- Admin CP (`/admin`) adalah area Blade terpisah di Pterodactyl 1.x dan **tidak ikut ter-theme** (default stock). Ini keterbatasan arsitektur panel, bukan bug theme.
- Mode System butuh `prefers-color-scheme` (didukung semua browser modern).

## 11. Yang Belum Selesai / Batasan

- Verifikasi runtime di VPS nyata (login, WebSocket console, file manager) belum dapat dijalankan dari mesin lokal ini — ikuti checklist bagian 8.
- Admin CP tidak di-theme (keterbatasan panel 1.x).
- Tombol "Daftar" tidak dibuat karena Pterodactyl tidak mendukung registrasi mandiri; jika Anda memakai plugin registrasi, tambahkan tombol kuning dengan class `xrou-btn xrou-btn-secondary`.
- Ilustrasi dekoratif besar (seperti maskot di referensi) digantikan bentuk dekoratif sederhana berbasis CSS/SVG agar bebas lisensi.
