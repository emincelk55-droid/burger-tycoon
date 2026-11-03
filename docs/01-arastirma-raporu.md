# Hacker Oyunu — Araştırma Raporu #1

**Tarih:** 3 Kasım 2026
**Konu:** Örnek oyunların incelenmesi ve motor (yazılım) seçimi
**Hedef:** Android (Google Play), hikaye tabanlı, aksiyonlu, kendine has tarzda bir hacker oyunu

---

## 1. Kısa sonuç

| Karar | Öneri |
|---|---|
| **Motor** | **Godot 4.6** (dil: GDScript) |
| **Görsel yön** | 2D / 2.5D. Oyun içi sahte bir işletim sistemi + çizgi roman tarzı ara sahneler + üstten görünüm "saha" bölümleri |
| **Yedek plan** | Unity 6 (oyun büyük 3D açık dünyaya dönerse ya da ağır reklam ağı gerekirse) |
| **İlk hedef** | 1–2 ayda oynanabilir bir "dikey dilim": 1 hikaye bölümü, terminal, 2 aksiyonlu hack mini oyunu |

Bu kategoride bir boşluk var. Mevcut oyunların çoğu ya **hikayesiz simülasyon/idle** oyunu (Hack Ex, vHack, The Lonely Hacker) ya da **kısa ve tek yönlü bir hikaye** (Hacker Başlangıç). Watch Dogs'un "dünyayı hackleyerek aksiyon yapma" hissi mobilde neredeyse hiç yok. Bizim oyunumuz bu üç şeyi birleştirebilir: **güçlü hikaye + dokunmatik aksiyon + dünyayı hackleme.**

---

## 2. Örnek oyunların incelemesi

### 2.1 Hacker Başlangıç (Hacker the Beginning)
- **Yapımcı:** Kurgu Studios / Furkan Yurtsever (Türk yapımı)
- **Ne:** Üç arkadaşın hikayesini anlatan hacker gerilimi. 21 bölüm, yaklaşık 2 saat. Ara sahneler çizgi roman tarzında. Türkçe, İngilizce, Korece ve Fransızca dil desteği var.
- **Oynanış:** Güvenlik açığı bulma, şifre kırma, ağa sızma. Elde edilen veri hikayenin devamını açıyor.
- **Güçlü yanı:** Hikaye ve karakter odaklı. Çizgi roman sahneleri az bütçeyle güçlü atmosfer kuruyor.
- **Zayıf yanı:** Kısa. Tekrar oynama değeri düşük. İndirme sayısı düşük görünüyor (üçüncü taraf tahmini).
- **Bizim için ders:** Çizgi roman ara sahneleri ve bölüm yapısı mobilde iyi çalışıyor. Oyunu daha uzun tutmalı ve seçimlerin sonucu gerçekten değiştirmesini sağlamalıyız.

### 2.2 Yalnız Hacker
- Bu adla ayrı bir oyun bulamadım. Büyük ihtimalle **The Lonely Hacker**'ın Türkçe mağaza adı (oyunun başka dillerde de çevrilmiş adları var). **Senden teyit lazım.** Farklı bir oyunsa geliştirici adını yazarsan ayrıca incelerim.

### 2.3 Hackers (Join the Cyberwar)
- **Yapımcı:** Trickster Arts (Çekya), 2016, iOS + Android
- **Ne:** Kendi 3D ağını kurup savunuyorsun, diğer oyuncuların ağlarına online saldırıyorsun. Uplink'e benzetiliyor.
- **Güçlü yanı:** Komut yazmak yerine **görsel arayüz** kullanıyor. Ağ "haritası" çok okunaklı. Savunma kurma + saldırı döngüsü kuvvetli.
- **Zayıf yanı:** Mikro yönetim ağır. Bekleme süreleri ve sunucu bağımlılığı var. Hikaye zayıf.
- **Bizim için ders:** Hacklemeyi **görselleştirmek** mobil için çok doğru. Düğüm ağı haritası fikri hikaye görevlerinde kullanılabilir.

### 2.4 Hack Ex – Simulator
- **Ne:** Diğer oyuncuların sanal banka hesaplarını kırmak, virüs yükleyip para kazanmak, logları temizlemek. Hack Ex 2 de çıktı.
- **Güçlü yanı:** Basit döngüsü bağımlılık yapıyor. Reklamlar çoğunlukla isteğe bağlı.
- **Zayıf yanı:** Oyuncular tekrar eden tıklamalardan, çok uzun yükleme sürelerinden ("150+ gün" şikayeti) ve hatalardan/çökmelerden yakınıyor. **Hikaye, görev ve hedef yok** diye eleştiriliyor.
- **Bizim için ders:** "Log silme", "iz bırakma" gibi fikirler eğlenceli. Ama bekleme süresiyle oyuncuyu sıkmamalı, her işlemi hikayeye bağlamalıyız.

### 2.5 Watch Dogs (Ubisoft)
- **Ne:** Açık dünya aksiyon. Şehrin altyapısını (kameralar, trafik ışıkları, kapılar, telefonlar) hackleyip aksiyonun parçası yapıyorsun. Etrafındaki insanların gizli bilgilerini görebiliyorsun.
- **Güçlü yanı:** Hack **bir silah gibi** kullanılıyor. Hack ile aksiyon iç içe. Hikaye kişisel (intikam, aile).
- **Zayıf yanı (bizim açımızdan):** Dev bütçeli 3D bir AAA oyunu. Mobilde birebir yapılamaz, yapılmamalı da.
- **Bizim için ders:** "Hack = aksiyon aracı" fikri. Biz bunu **üstten görünüm 2D saha bölümlerinde** kendi tarzımızla uygulayabiliriz: kameradan kameraya atla, kapıyı aç, drone'u devral, alarmı kapat. Adını, karakterlerini ve görünüşünü kopyalamıyoruz. Sadece tür fikrinden ilham alıyoruz.

### 2.6 The Lonely Hacker
- **Yapımcı:** Sabin Trupsor ("The Lonely Developer"), ücretli ($0.99), uygulama içi satın alma yok
- **Ne:** Gerçek ülke ve şehirlerden oluşan bir dünya haritası. Şehirler arası seyahat edip ağları ve cihazları hackliyorsun. "Gerçekçi" yazılım ve donanım araçları, kara pazarda eşya satma ve mini oyunlar var.
- **Güçlü yanı:** Derinlik ve simülasyon hissi var. Her aracın öğreticisi var.
- **Zayıf yanı:** **Sabit bir hikaye yok.** Öğrenme eğrisi dik, oyun döngüsü tekrar ediyor. Vaat edilen özellikler gelmedi, güncellemeler durmuş görünüyor (son sürüm Mayıs 2024).
- **Bizim için ders:** Harita + seyahat + ekipman sistemi çok sevilmiş. Ama vaatleri tutmak ve oyunu düzenli güncellemek şart.

### 2.7 vHackOS (vHack Revolutions)
- **Ne:** Metin tabanlı MMO hacker simülatörü. Hedef tarama, malware ile saldırı, ekip (crew) kurma, sıralamalar, "vTC Miner" ile idle madencilik, günlük görevler, etkinlikler ve sohbet var.
- **Güçlü yanı:** Sosyal özellikler ve idle sistem oyuncuyu her gün geri getiriyor. Arayüzü bir "işletim sistemi" gibi.
- **Zayıf yanı:** Hikaye yok. Sunucu maliyeti ve hile/denge yönetimi gerekiyor.
- **Bizim için ders:** Oyun içi sahte bir işletim sistemi (masaüstü, uygulamalar, mesajlar) çok iyi bir **ana menü/merkez** olur. Online özellikleri ilk sürüme koymayalım, sonradan ekleyelim.

### 2.8 HackBot Hacking Game
- **Yapımcı:** RoboBot Studio, tahminen **~15 milyon indirme**, ~4.0 puan (üçüncü taraf tahmini)
- **Ne:** Cyberpunk temalı. Hedefi inceleyip şifresini kırıyorsun. Tamamı **kısa hack mini oyunlarından** oluşuyor. Hızlı Maç ve Dereceli Maç modları var. Ücretsiz, reklam ve satın alma var.
- **Güçlü yanı:** Kısa, dokunmatik, hızlı oturumlar. Mobilde en çok indirilenlerden biri olmasının sebebi bu.
- **Zayıf yanı:** Derinlik ve hikaye sınırlı.
- **Bizim için ders:** **Aksiyonlu mini oyunlar** mobilde kazanıyor. Hikayemizin içindeki her hack anı 30–90 saniyelik refleks ya da bulmaca mini oyunu olmalı.

### 2.9 Özet tablo

| Oyun | Hikaye | Aksiyon | Derinlik | Sosyal | Alacağımız fikir |
|---|---|---|---|---|---|
| Hacker Başlangıç | ★★★ | ★ | ★ | – | Çizgi roman sahneleri, bölüm yapısı |
| Hackers | ★ | ★★ | ★★★ | ★★★ | Görsel ağ haritası |
| Hack Ex | – | ★ | ★★ | ★★ | İz bırakma / log silme |
| Watch Dogs | ★★★ | ★★★ | ★★★ | ★ | Hack = aksiyon aracı |
| The Lonely Hacker | – | ★ | ★★★ | – | Dünya haritası, ekipman, kara pazar |
| vHackOS | – | ★ | ★★ | ★★★ | Sahte işletim sistemi arayüzü |
| HackBot | ★ | ★★★ | ★ | ★★ | Kısa refleks mini oyunları |

---

## 3. Bizim oyunun "değişik tarzı" (ilk fikir)

Oyunun beş ayağı:

1. **Hikaye:** Bölümlere ayrılmış, seçimli, birden fazla sonu olan bir senaryo. Ara sahneler çizgi roman / görsel roman tarzında.
2. **Merkez = sahte telefon/PC işletim sistemi:** Oyuncu ana menü yerine karakterin cihazını kullanır. Mesajlar, e-posta, terminal, araç mağazası, harita bu cihazdadır. Hikaye bu cihaza gelen mesajlarla ilerler.
3. **Aksiyonlu hack mini oyunları:** Kod akışı yönlendirme, frekans eşleme, firewall labirenti, zamanlı şifre kırma gibi dokunmatik ve refleks gerektiren oyunlar.
4. **Saha bölümleri (asıl farkımız):** Üstten görünüm 2D/2.5D şehir ve bina haritaları. Karakter fiziksel olarak sızarken çevreyi hackler: kamera, kapı, ışık, drone, telefon. Gizlilik + aksiyon.
5. **İlerleme:** Araçlar, donanım, yetenek ağacı, itibar. Seçimler hikayeyi ve dünyayı etkiler.

**Önemli:** Oyundaki hackleme tamamen kurgusal olacak. Gerçek bir saldırıyı öğretmeyecek. Bu hem etik hem de Google Play politikaları ve yaş sınıflandırması açısından gerekli.

Bunlar sadece başlangıç fikirleri. Senin beğendiğin şeylerle birlikte ayrıntılı tasarım belgesinde (GDD) netleştireceğiz.

---

## 4. Motor (yazılım) seçimi

HTML istemediğin için yerel (native) derlenen oyun motorlarını karşılaştırdım.

| Kriter | **Godot 4.6** | Unity 6 | Unreal 5 | Flutter + Flame |
|---|---|---|---|---|
| Maliyet | Tamamen ücretsiz, açık kaynak, gelir payı yok | Yıllık gelir/fon 200 bin $ altında ücretsiz. Üstünde Pro (2.310 $/yıl/kişi) | Ücretsiz. 1M $ gelirden sonra %5 telif | Ücretsiz |
| 2D + arayüz gücü | Çok güçlü (2D motoru ayrı ve olgun, UI sistemi iyi) | Güçlü | Zayıf (3D odaklı) | Orta |
| Aksiyon / fizik | İyi | Çok iyi | Çok iyi | Zayıf |
| APK boyutu | Küçük (~30–40 MB'tan başlar) | Orta | Büyük | Küçük |
| Google Play Billing | Resmi eklenti var, Godot Vakfı bakımını üstleniyor | Resmi, çok olgun | Var | Var |
| Reklam (AdMob) / Play Games | Topluluk eklentileri var, yeterli | En olgun ekosistem | Var | Var |
| **Benim (Claude) kodu yazıp yönetebilmem** | **Çok iyi:** sahne ve kaynak dosyaları düz metin (.tscn/.tres), her şeyi kodla kurabilirim | Orta: sahne ve prefab dosyaları editöre bağımlı, işin çoğunu senin editörde yapman gerekir | Zayıf: Blueprint ve binary dosyalar | İyi |
| Otomatik derleme (GitHub Actions) | Kolay, lisans yok | Mümkün ama Unity lisansı gerekir | Zor | Kolay |
| Diyalog/hikaye araçları | Dialogue Manager, Ink eklentileri | Ink, Yarn Spinner | Var | Az |

### Neden Godot?
1. **Oyunun doğasına uyuyor.** Hacker oyunu arayüz yoğun (sahte işletim sistemi, terminal, ağ haritası) ve 2D/2.5D. Godot'nun en güçlü olduğu alan bu.
2. **Birlikte çalışma şeklimize uyuyor.** Kodun neredeyse tamamını ben yazacağım. Godot'da sahneler, arayüz ve ayarlar okunabilir metin dosyaları. Böylece her şeyi git'te takip edebilir, değişiklikleri inceleyebilir ve geri alabiliriz. Unity'de birçok işi senin editörde elle yapman gerekirdi.
3. **Sıfır lisans riski.** Unity'nin 2023'teki "kurulum başı ücret" krizi gibi bir sürpriz Godot'da olamaz. Açık kaynak (MIT lisansı).
4. **Mobil için aktif gelişiyor.** Godot 4.6 ve 4.5.2 sürümleri mobil kararlılığa odaklandı. Play Billing eklentisinin bakımını Godot Vakfı üstleniyor.
5. **Küçük APK, düşük donanımda iyi performans.** Türkiye'de ve gelişen pazarlarda orta-alt segment telefonlar çok yaygın.

### Riskler ve çözümleri
| Risk | Çözüm |
|---|---|
| Reklam ağı eklentileri topluluk yapımı | Para kazanma modelini mümkün olduğunca **tek seferlik satın alma** üzerine kurmak. Reklam sadece isteğe bağlı ödüllü reklam olarak kalır |
| Ekosistem Unity'den küçük | Hazır asset yerine kendi stilimizi kurmak (bu zaten "değişik tarz" hedefimize uyuyor) |
| Oyun ileride büyük 3D açık dünyaya dönerse | O durumda Unity 6'ya geçmek. Kararı prototipten sonra tekrar değerlendiririz |

### Unity ne zaman daha iyi olurdu?
Oyun Watch Dogs gibi tam 3D açık dünya olsaydı, gelirin büyük kısmı reklam aracılığından (mediation) gelseydi ya da ekipte Unity bilen biri olsaydı. Bizim durumumuzda bunların hiçbiri öncelikli değil.

---

## 5. Google Play tarafında bilmen gerekenler

- **12 test kullanıcısı / 14 gün kuralı:** Hesabın Kasım 2023'ten sonra açılmış **kişisel** bir hesapsa, yayına çıkmadan önce en az **12 kişiyle 14 gün kesintisiz kapalı test** yapman gerekiyor. Kurumsal (şirket) hesaplar bu kuraldan muaf. Test edecek 12 kişiyi şimdiden düşünmeye başlamakta fayda var.
- **Hedef API seviyesi:** 31 Ağustos 2026'dan itibaren yeni uygulamalar ve güncellemeler **Android 16 (API 36)** hedeflemek zorunda. Godot 4.6 export ayarlarında bunu ayarlayacağız.
- **Yaş sınıflandırması (IARC) ve içerik:** Hacker teması sorun değil. Ama oyun gerçek bir hack yöntemi öğretmemeli ve "gerçek hack aracı" gibi pazarlanmamalı.
- **Paket adı:** Örneğin `com.<stüdyoadı>.<oyunadı>`. Bir kere seçilince değişmiyor, isimle birlikte karar vereceğiz.

---

## 6. Yol haritası (öneri, 9–12 ay)

| Faz | Süre | Çıktı |
|---|---|---|
| 0. Konsept | 2–4 hafta | Oyun adı, hikaye özeti, karakterler, görsel stil, tasarım belgesi (GDD) |
| 1. Prototip | 1–2 ay | Godot projesi, sahte işletim sistemi, 2 mini oyun, 1 kısa saha bölümü. Telefonda test |
| 2. Dikey dilim | 1–2 ay | Tam cilalı ilk bölüm: ses, efektler, ara sahne, kayıt sistemi |
| 3. Üretim | 4–6 ay | Tüm bölümler, ilerleme sistemi, dil desteği (TR + EN), ayarlar, satın alma |
| 4. Kapalı test | 3–4 hafta | 12+ test kullanıcısı, hata düzeltme, denge |
| 5. Yayın | – | Play Store sayfası, görseller, fragman, lansman |
| 6. Sonrası | sürekli | Yeni bölümler, belki online özellikler (vHack/Hackers tarzı) |

**Para kazanma önerisi (taslak):** İlk bölümler ücretsiz, tüm hikaye tek seferlik satın almayla açılır. Kozmetik ürünler (tema, terminal görünümü) satılır. Ödüllü reklam isteğe bağlı olur. Kazanmak için para ödemek (pay-to-win) olmaz. Hack Ex ve vHack'te en çok şikayet edilen şey bekleme süreleri ve agresif satın almalar.

---

## 7. Repo düzeni (öneri)

```
burger-tycoon/              (repo adı şimdilik aynı kalabilir, istersen sonra değiştiririz)
├── burger-tycoon-final.zip (eski oyun, dokunmadım)
├── docs/                   raporlar, tasarım belgesi (GDD), hikaye taslakları
└── game/                   Godot 4.6 projesi (prototip aşamasında oluşturulacak)
```

---

## 8. Senden beklediklerim (sıradaki adım)

1. **"Yalnız Hacker"** The Lonely Hacker mı, yoksa başka bir oyun mu?
2. **Bilgisayarın var mı (Windows/Mac)?** Godot editörü ücretsiz ve küçük (~100 MB). Prototipi telefonunda denemek için ya bilgisayarından APK alacağız ya da GitHub üzerinden otomatik APK üreteceğiz.
3. Bu 8 oyunda **en çok sevdiğin 3 an/özellik** neydi? Neleri hiç sevmedin?
4. **Hikaye** için aklında bir şey var mı? (Mekan Türkiye mi, kurgusal bir şehir mi? Ana karakter kim? Ton karanlık/ciddi mi, esprili mi?)
5. **Görsel tarz:** Neon/cyberpunk, karanlık-gerçekçi, çizgi roman, piksel art... Örnek olarak beğendiğin oyunlar ya da görseller varsa paylaş.
6. **Dil:** Türkçe + İngilizce ile başlayalım mı?

---

## Kaynaklar

- Hacker the Beginning — App Store: https://apps.apple.com/us/app/-/id1668827917 · AppGoblin: https://appgoblin.info/apps/com.KurguStudios.HackerBaslangic
- The Lonely Hacker — App Store: https://apps.apple.com/us/app/-/id1633242696 · RAWG: https://rawg.io/games/the-lonely-hacker
- Hackers (video game) — Wikipedia: https://en.wikipedia.org/wiki/Hackers_(video_game) · Androidsis: https://en.androidsis.com/become-the-best-hacker-on-the-planet-multiplayer-game-hackers/
- Hack Ex — GameBrain: https://gamebrain.co/game/hack-ex · Pocket Gamer: https://www.pocketgamer.com/hack-ex-simulator/
- vHack Revolutions — App Store: https://apps.apple.com/us/app/id1464606057 · AppFollow: https://apps.appfollow.io/ios/vhack-revolutions-hacker-game/1464606057?country=us
- HackBot — AppGoblin: https://appgoblin.info/apps/com.testa.hackbot · App Store: https://apps.apple.com/app/id1206361960
- Unity fiyatlandırma: https://unity.com/products/pricing-updates
- Godot mobil güncellemesi (Nisan 2026): https://godotengine.org/article/godot-mobile-update-apr-2026/
- Godot Google Play Billing: https://github.com/godot-sdk-integrations/godot-google-play-billing
- Android hedef API gereksinimi: https://developer.android.com/google/play/requirements/target-sdk
- Google Play 12 test kullanıcısı kuralı (özet): https://www.testerscommunity.com/blog/google-play-closed-testing-requirements-2026

> Not: İndirme sayıları ve bazı puanlar üçüncü taraf takip sitelerinin tahminleridir, resmi değildir. Watch Dogs bilgileri genel bilinen oynanış özelliklerine dayanır.
