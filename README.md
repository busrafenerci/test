# Luna

Luna, kadınların menstrual döngülerini sade ve doğal bir akışla takip etmelerine yardımcı olmak için geliştirilen Flutter tabanlı bir mobil uygulamadır.

> **Takvim tutmaz. Seni tanır.**

## Projenin amacı

Luna'nın temel amacı, kullanıcıyı karmaşık formlar ve manuel süre girişleriyle uğraştırmadan regl başlangıç ve bitiş tarihlerini kaydetmek, döngü bilgilerini göstermek ve ilerleyen sürümlerde kişiselleştirilmiş içgörüler üretmektir.

Temel kullanım akışı:

1. Kullanıcı **Regl Başladı** butonuna basar.
2. Luna geçici bir regl süresi tahminiyle devam eden bir kayıt oluşturur.
3. Kullanıcı regl sona erdiğinde **Reglim Bitti** butonuna basar.
4. Gerçek regl süresi başlangıç ve bitiş tarihlerinden hesaplanır.
5. Tamamlanan kayıtlar gelecek döngü tahminlerinde kullanılabilir.

## Mevcut durum

Projenin ilk çalışan sürümü oluşturulmuştur. Genel tamamlanma oranı yaklaşık **%45–50** seviyesindedir.

Bu oran, uygulamanın yayınlanmaya hazır olduğu anlamına gelmez. Temel mimari ve veri modeli büyük ölçüde hazırdır; kullanıcı deneyimi, hata senaryoları ve ileri seviye özellikler geliştirilmeye devam edecektir.

## Şu ana kadar tamamlananlar

### Temel yapı

- Flutter proje yapısı oluşturuldu.
- Ana ekran geliştirildi.
- Takvim ekranı geliştirildi.
- Mor ağırlıklı Luna tasarım dili oluşturuldu.
- `StorageService`, `CycleCalculator` ve `PeriodRecord` yapıları oluşturuldu.
- Gerçek ve tahmini regl günleri takvimde farklı biçimlerde gösterildi.

### PeriodRecord veri modeli

Eski yaklaşım:

```text
Başlangıç tarihi + sabit regl süresi
```

Yeni yaklaşım:

```text
Başlangıç tarihi + isteğe bağlı bitiş tarihi + kayıt durumu
```

Yeni modelde şu alan ve özellikler bulunur:

- `startDate`
- `endDate`
- `predictedLength`
- `isOngoing`
- `effectiveEndDate`
- `periodLength`
- `actualPeriodLength`
- `containsDate()`
- `finish()`
- `reopen()`
- `copyWith()`
- `toJson()`
- `fromJson()`

`endDate` boşsa kayıt devam eden regl kaydı olarak kabul edilir.

### Eski kayıtların yeni modele taşınması

Eski JSON formatı desteklenmeye devam eder.

Eski format:

```json
{
  "startDate": "2026-07-24T00:00:00.000",
  "periodLength": 5
}
```

Yeni format:

```json
{
  "startDate": "2026-07-24T00:00:00.000",
  "endDate": "2026-07-28T00:00:00.000",
  "predictedLength": 4
}
```

Eski kayıtlar okunurken tamamlanmış kayıtlar olarak yeni modele dönüştürülür.

### StorageService geliştirmeleri

- Regl kayıtlarını okuma ve kaydetme
- `endDate` ve `predictedLength` alanlarını koruma
- Yeni regl başlangıcı oluşturma
- Devam eden regl kaydını bulma
- Devam eden kayıt olup olmadığını kontrol etme
- Devam eden regl kaydını bitirme
- Uygulama yeniden açıldığında kayıtları koruma

Temel metotlar:

```dart
getPeriodRecords()
savePeriodRecords()
getOngoingPeriod()
hasOngoingPeriod()
startPeriod()
finishOngoingPeriod()
```

### Yeni regl kayıt akışı

```text
Regl Başladı
      ↓
Devam eden kayıt
      ↓
Reglim Bitti
      ↓
Tamamlanmış kayıt
```

Kullanıcı artık regl süresini manuel seçmez. Gerçek süre başlangıç ve bitiş tarihleri arasından hesaplanır.

### Takvim geliştirmeleri

- Gerçek regl kayıtları gösterilir.
- Tahmini regl günleri gösterilir.
- Gün seçimi desteklenir.
- Seçilen günün döngü bilgisi gösterilir.
- Gerçek kayıt kaldırılabilir.
- Devam eden kayıt varsa **Reglim Bitti** butonu gösterilir.
- Devam eden kayıt yoksa **Regl Başladı** butonu gösterilir.
- Kayıt tamamlandığında takvim verileri yeniden yüklenir.

### CycleCalculator uyumluluğu

Mevcut ana ekranı bozmamak için aşağıdaki yapılar korunmuştur:

- `CycleResult`
- `CyclePhase`
- `calculate()`
- `calculatePredictedPeriodLength()`

Yeni mimariye geçiş aşamalı olarak yapılmaktadır.

## Bilinen sorun

Kullanıcı önceki ayda regl başlangıcı oluşturup bitişi işaretlemezse kayıt açık kalır. Daha sonraki bir tarihte **Reglim Bitti** denildiğinde eski başlangıç tarihi ile yeni bitiş tarihi arasındaki tüm günler aynı regl kaydı olarak kabul edilebilir.

Planlanan kalıcı çözüm:

- Eski açık kaydı tespit etmek
- Kullanıcıya kaydı tamamlama, düzeltme veya silme seçenekleri sunmak
- Yanlışlıkla çok uzun regl kaydı oluşmasını engellemek
- Yeni döngüyü eski açık kayıttan ayırmak

## Faz 1 için kalan işler

- Seçili gün kartını geliştirmek
- Ana ekranı zenginleştirmek
- Tahmin sistemini iyileştirmek
- Eski açık kayıt yönetimini tamamlamak
- Hata mesajlarını kullanıcı dostu hale getirmek
- Çift ve geçersiz kayıtları engellemek
- Model, storage ve calculator testleri yazmak
- Uygulama kapatılıp açıldığında veri kalıcılığını test etmek
- Temel ayarlar ve bildirim altyapısını planlamak

## Faz 2 için düşünülen özellikler

Belirti takibi ikinci faza bırakılabilir.

- Ağrı seviyesi
- Ruh hali
- Akıntı
- İlaç kullanımı
- Kullanıcı notları
- Belirti eğilimleri
- Kişiselleştirilmiş içgörüler
- Bildirimler

## Faz 3 için düşünülen özellikler

- Bulut yedekleme
- Kullanıcı hesabı
- PDF raporu
- Doktora göster modu
- Partner paylaşımı
- Ana ekran widget'ı
- Çoklu dil
- Karanlık tema
- Premium özellikler
- Android ve iOS mağaza yayını

## Önerilen faz planı

### Faz 1 — Temel çalışan ürün

- Regl başlangıç ve bitiş kaydı
- Takvim görünümü
- Döngü ve regl tahmini
- Ana ekran bilgileri
- Eski açık kayıt yönetimi
- Temel ayarlar
- Hata yönetimi
- Yerel veri saklama
- Temel testler

### Faz 2 — Kişiselleştirme

- Belirti takibi
- Notlar
- Ruh hali
- Ağrı seviyesi
- Bildirimler
- Kişiselleştirilmiş içgörüler

### Faz 3 — İleri özellikler

- Bulut senkronizasyonu
- Kullanıcı hesabı
- PDF raporu
- Doktor ve partner paylaşımı
- Widget
- Premium özellikler

## Kullanılan teknolojiler

- Flutter
- Dart
- Android Studio
- Android Emulator
- Yerel veri saklama

## Projeyi çalıştırma

```bash
flutter doctor
flutter pub get
flutter run
```

Kod kontrolü:

```bash
flutter analyze
```

## Son güncelleme

Bu sürümde:

- `PeriodRecord` başlangıç ve bitiş tarihini destekleyecek şekilde yenilendi.
- Eski kayıtlar için migration desteği eklendi.
- Storage katmanında `endDate` bilgisinin kaybolması engellendi.
- `startPeriod()` ve `finishOngoingPeriod()` akışları eklendi.
- Takvim ekranında **Regl Başladı** ve **Reglim Bitti** davranışları geliştirildi.
- Uygulama yeniden açıldığında kayıtların korunması test edildi.
- Eski açık kayıtların çok uzun bir döneme dönüşmesi bilinen sorun olarak kaydedildi.
