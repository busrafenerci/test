# Changelog

Bu dosya, Luna projesinde yapılan önemli değişiklikleri, hata düzeltmelerini ve yeni eklenen özellikleri kronolojik ve yapılandırılmış bir şekilde takip eder.

## [Unreleased] - 2026-07-25

### ✨ Eklenen Özellikler ve İyileştirmeler
* **Dikey Ekran ve UI Optimizasyonu:** `CalendarScreen` içerisindeki `SingleChildScrollView` yapısı kaldırılarak sayfanın modern cihazlarda (Pixel 8 vb.) dikey ekrana tam oturması ve gereksiz kaydırma çubuklarının oluşması engellendi.
* **Akıllı Grid Oranı:** Takvim grid yapısının hücre boyut oranı (`childAspectRatio`) dikeyde alan kazandıracak şekilde optimize edildi.
* **Gelişmiş Kayıt Yönetimi:** Devam eden veya yanlış girilen regl kayıtları üzerinde "Regl Kaydını Kaldır" seçeneği aktif hale getirildi; böylece kullanıcılar hatalı başlatılan kayıtları kolayca silebilir hale geldi.
* **Otomatik Kapatma ve Uyarı Akışı:** Devam eden açık bir kayıt varken yeni regl başlatılmak istendiğinde, kullanıcıya eski kaydın varsayılan (4 gün) süreyle tamamlanıp yeni döngünün başlatılacağını belirten net bir onay mekanizması eklendi.

---

## [0.2.0] - 2026-07-20 (Yakın Dönem Geliştirmeleri)

### 🚀 Yeni Özellikler
* **Yeni Veri Modeli (`PeriodRecord`):** Sabit regl süresi yaklaşımından, `startDate`, bitiş tarihi (`endDate`) ve kayıt durumu (`isOngoing`) barındıran esnek yeni modele geçiş yapıldı[cite: 4].
* **Migration Desteği:** Eski JSON formatındaki kayıtların, uygulama açılışında veri kaybı olmaksızın yeni modele sorunsuz bir şekilde uyarlanması sağlandı[cite: 4].
* **Depolama Katmanı (`StorageService`):** Devam eden regl kaydını bulma (`getOngoingPeriod`), regl başlatma (`startPeriod`) ve bitirme (`finishOngoingPeriod`) fonksiyonları eklendi[cite: 4].
* **Gelişmiş Takvim Görünümü:** Takvim üzerinde gerçek regl günleri, tahmini regl günleri, doğurgan dönem ve PMS günleri farklı renk ve ikonlarla görselleştirildi.

---

## [0.1.0] - İlk Sürüm (Faz 1 Temeli)

### 🌱 İlk Adımlar
* Temel Flutter proje yapısı kuruldu.
* Ana ekran ve takvim ekranı iskeleti oluşturuldu[cite: 4].
* Mor renk paletiyle Luna tasarım dili belirlendi[cite: 4].
* Yerel veri saklama altyapısı ve `CycleCalculator` entegrasyonu sağlandı[cite: 4].