# Kör Nokta (çalışma adı)

Hikaye tabanlı, aksiyonlu bir hacker oyunu. Android için **Godot 4.7** ile geliştiriliyor.

- `game/` — Godot projesi
- `docs/01-arastirma-raporu.md` — örnek oyunlar ve motor seçimi
- `docs/02-oyun-tasarim-belgesi.md` — oyun tasarım belgesi (GDD)
- `burger-tycoon-final.zip` — önceki oyun (arşiv)

## Telefonda denemek
Her push'ta GitHub Actions oyunu test eder ve bir Android APK derler.
1. GitHub'da repo sayfasında **Releases** bölümüne gir.
2. En üstteki "Kör Nokta · geliştirici sürümü" kaydından `KorNokta-dev.apk` dosyasını indir.
3. Dosyayı aç ve kur (Android "bilinmeyen kaynaklardan yükleme" izni isteyebilir).

## Bilgisayarda açmak
1. [Godot 4.7](https://godotengine.org/download) indir (standart sürüm, .NET değil).
2. Godot'da **Import** → `game/project.godot` seç.
3. F5 ile çalıştır.

Testleri çalıştırmak için: `godot --headless --path game -- --run-tests`
