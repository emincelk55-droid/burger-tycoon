# KÖR NOKTA — Oyun Tasarım Belgesi (GDD) v0.1

> Çalışma adı. İngilizce adı: **BLIND SPOT**. Yayından önce isim ve marka kontrolü yapılacak.

## 1. Tek cümlede oyun
İstanbul'un her köşesini izleyen bir gözetim şirketi seni kendi yapmadığı bir suçun faili ilan ediyor. Telefonun, eski sokak kameralarında yaşayan gizemli bir yapay zekâ ve hacklediğin şehir dışında kimsen yok.

## 2. Temel bilgiler
| | |
|---|---|
| Tür | Hikaye tabanlı aksiyon / hacker gerilimi |
| Platform | Android (önce), sonra belki iOS |
| Motor | Godot 4.7 (GDScript) |
| Ekran | Dikey (portrait), tek elle oynanabilir |
| Oturum | 5–15 dakika. Her bölüm 30–60 dakika |
| Dil | Türkçe + İngilizce (ilk günden) |
| Yaş | 12+ (karanlık tema, şiddet yok denecek kadar az) |
| Model | Bölüm 0–1 ücretsiz, tüm hikaye tek seferlik satın alma, pay-to-win yok |

## 3. Dünya
- **Yer:** Yakın gelecekte (2030'lar) İstanbul. Gerçek semtler (Beyoğlu, Tarlabaşı, Karaköy, Kadıköy, Haliç), kurgusal şirketler.
- **ARGOS:** Şehrin güvenlik, trafik ve enerji altyapısını yöneten özel şirket. **GÖZ** adlı kamera ve yüz tanıma ağını işletir. Vatandaşlar "GÖZ" uygulamasıyla birbirini ihbar edebilir.
- **Ton:** Karanlık ama umutlu. Boğaz'ın gece ışıkları, sodyum lambalar, ıslak kaldırımlar. Yer yer kara mizah (eczanenin kedi maması duyurusu gibi).
- **Görsel kimlik:** Lacivert gece + sodyum lamba turuncusu + Boğaz yeşili. Neon-yeşil "Matrix" klişesinden bilerek uzak duruyoruz.

## 4. Karakterler
- **Deniz Kaya (27):** ARGOS güvenlik test ekibinde çalışan bir mühendis. Sicil no 4471. Geçen ay sistemdeki bir açığı raporladı, kimse dinlemedi. Cinsiyeti hikayede belirtilmiyor, oyuncu kendini yerine koyabiliyor.
- **KEDİ:** Beyoğlu'nun güncellenmemiş eski sokak kameralarında yaşayan yapay zekâ. Alaycı, sıcak, sırları olan biri. Gerçekte ne olduğu hikayenin ana gizemlerinden biri.
- **ARGOS:** Şirketin kendisi bir "karakter". Sistem mesajları, basın bültenleri ve iz sayacıyla oyuncuya baskı kurar.
- **İleride:** Bir gazeteci, eski bir hacker ekibi, ARGOS içinden bir muhbir, Deniz'in ailesi.

## 5. Oyun döngüsü
```
Mesaj gelir (hikaye) → Terminalde araştır → Mini oyunla gir → Bilgi / kanıt bul
      ↑                                                            ↓
 Seçim yap  ←  Sahada uygula (Bölüm 1+)  ←  Ekipman / yetenek kazan
```

### 5.1 Telefon = ana menü
Oyunun tamamı Deniz'in telefonunda geçiyor. Uygulamalar hikayeyle birlikte açılıyor:
- **Mesajlar:** Hikaye burada ilerliyor. Seçimli cevaplar.
- **Terminal:** Komutlar (tara, bağlan, kır, ls, oku, kes, iz). Telefonda yazmak zor olduğu için her zaman **hızlı komut düğmeleri** var. Yazmak isteyen yazabiliyor.
- **Harita:** Bölüm 1'de açılıyor. Saha görevlerine buradan çıkılıyor.
- **Ayarlar:** Dil, titreşim, ilerlemeyi sıfırlama.
- **İleride:** Galeri (bulunan kanıtlar), Kara Pazar (ekipman), Haberler (seçimlerin dünyadaki yankısı), Notlar.

### 5.2 Hack mini oyunları (30–90 sn, dokunmatik ve refleks)
| Ad | Durum | Nasıl oynanıyor |
|---|---|---|
| **Güvenlik Duvarı** | ✅ prototipte | İmleç gidip geliyor, yeşil boşlukta DEL'e bas. Her başarıda boşluk daralıyor, imleç hızlanıyor |
| **Sinyal Kilidi** | ✅ prototipte | Frekans ve faz sürgüleriyle kendi dalganı kameranın kayan dalgasına eşle, kilidi doldur |
| **Kod Yaması** | ✅ Bölüm 1 | Oyunun kurgusal betik dilinde kısa bir program. Kırmızı satırdaki eksik değeri yaz ya da seç. Değer çoğu zaman terminalde okunan dosyalarda saklı |
| Paket Yönlendirme | planlı | Veri paketlerini düğümler arasında yönlendir, ARGOS tarayıcılarından kaçır |
| Şifre Kırıcı | planlı | Mastermind benzeri sembol tahmini, süre baskısı |
| Yüz Değiştirme | planlı | Kamera akışında yüzünü kayıtlardan sil, karelerle yarış |

### 5.3 Saha bölümleri (asıl farkımız, Bölüm 1+)
Üstten görünüm 2D/2.5D haritalar (sokak, apartman, ARGOS veri merkezi). Deniz fiziksel olarak hareket ederken telefonla çevreyi hackliyor:
- Kameradan kameraya "atlayıp" bölgeyi görmek
- Kapı, asansör ve ışıkları kontrol etmek
- Drone devralmak, alarmı başka yere yönlendirmek
- Görüş konilerinden kaçmak (gizlilik), gerekirse kaçış sahneleri (aksiyon)

### 5.4 İz (Trace) sistemi
- Her başarısız hack izi %15, başarılı hack %3 artırıyor.
- Yüksek iz: daha sık devriye, daha zor mini oyunlar, hikayede farklı sahneler.
- İz düşürme yolları: saklanmak, kayıt silmek, KEDİ'den yardım istemek (bedeli var).

### 5.5 Seçimler ve yollar
Prologun sonunda oyuncu bir yol seçiyor. Bu seçim sonraki bölümlerdeki diyalogları, görevleri ve sonu etkiliyor:
- **Hayalet:** Görünmeden kaç. Gizlilik ağırlıklı görevler.
- **Muhbir:** Gerçeği sızdır. Gazeteci ve kanıt toplama ağırlıklı.
- **Karşı saldırı:** ARGOS'u vur. Daha aksiyonlu ama iz daha hızlı artıyor.

## 6. Hikaye planı (taslak)
| Bölüm | Ad | Özet | Durum |
|---|---|---|---|
| 0 | Kör Nokta | 02:47. KEDİ ilk mesajı atıyor. ARGOS'un Deniz'i suçlayacağını öğreniyorsun. İlk hack, ilk seçim, kamerayı döngüye alıp evden kaçış | ✅ oynanabilir |
| 1 | Tarlabaşı'ndan Kaçış | Arka kapı kilidi, sokak lambaları, ARGOS drone'u ve tramvay turnikesi. 3 kod yaması bulmacası, yola göre değişen diyaloglar | ✅ oynanabilir |
| 2 | Kirpi | Operasyon Kirpi'nin ne olduğunu araştır. Karartma neden yapıldı? | taslak |
| 3 | Haliç | Eski bir hacker ekibiyle tanışma. Kara pazar açılıyor | taslak |
| 4 | Kedi Kimdir? | KEDİ'nin kökeni. Büyük ihanet ya da büyük sır | taslak |
| 5 | GÖZ | ARGOS veri merkezine sızma. Final. Seçimlere göre 3+ son | taslak |

## 7. Teknik yapı
```
game/
├── project.godot          Godot ayarları (dikey 720x1280, GL Compatibility)
├── export_presets.cfg     Android dışa aktarma ayarı
├── autoload/              GameState (kayıt), Loc (çeviri), Story (hikaye motoru)
├── scenes/                main, açılış ekranı, bölüm sonu
├── os/                    telefon ana ekranı, uygulama çerçevesi, simgeler, İstanbul silueti
├── apps/                  Mesajlar, Terminal (+ komut mantığı), Harita, Ayarlar
├── minigames/             mini oyunlar
├── ui/                    renkler, tema, yardımcılar
├── data/story/            bölüm dosyaları (JSON, tr + en)
├── data/i18n/             arayüz metinleri (tr.json, en.json)
└── tests/                 otomatik testler
```
- **Hikaye verisi koddan ayrı:** Yeni bölüm yazmak için kod değil JSON yazılıyor. Her metin `{"tr": ..., "en": ...}` biçiminde.
- **Görseller şimdilik kodla çiziliyor:** Dosya gerektirmiyor, APK küçük kalıyor. İleride çizer/sanatçıyla gerçek görseller eklenecek.
- **Otomatik kontrol:** Her push'ta GitHub Actions testleri çalıştırıyor, Android APK derliyor ve telefondan indirilebilecek bir sürüm yayınlıyor.

## 8. Etik ve politika
- Oyundaki hackleme tamamen kurgu. Gerçek araç adları, komutlar ya da saldırı yöntemleri öğretilmiyor.
- Gerçek şirket, kişi ya da kurum adı kullanılmıyor.
- Ayarlar ekranında "Bu oyun kurgudur" notu var.

## 9. Sıradaki adımlar
1. Prototipi telefonda oyna, geri bildirim ver (his, zorluk, hikaye).
2. Saha bölümü prototipi (üstten görünüm hareket + kamera kontrolü), Bölüm 2 ile birlikte.
3. Ses: ortam sesleri, bildirim sesi, mini oyun efektleri.
4. Gerçek yazı tipleri ve görsel stil (çizer ile).
5. Play Console: paket adı kararı, kapalı test grubu (12 kişi).
