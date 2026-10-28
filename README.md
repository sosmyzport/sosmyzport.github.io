# Portfolyo ve yönetim paneli

Bu klasör, mevcut Wix sitesine dokunmadan hazırlanan bağımsız portfolyo sürümüdür. Tasarım ve içerik bu projede; Wix'e aktarım veya yayınlama yapılmadı.

## Önizleme

`index.html` dosyasına çift tıklayarak önizleme açılır. Bu, yerel deneme modudur: düzenlemeler yalnızca aynı tarayıcıda tutulur ve Google girişi/kalıcı bulut depolama çalışmaz. Güvenli yönetim için siteyi HTTPS üzerinden barındırıp Supabase adımlarını tamamlamak gerekir. Projeyi açmadan önce bu klasörün tamamını aynı yerde tutun.

## İçeriği düzenleme

Sağ üstteki **Düzenle** panelinden sayfa metinlerini, proje sırasını ve vaka anlatımlarını, yetenekleri, sertifikaları ve iletişim bağlantılarını yönetin. Proje istatistikleri “teyit bekliyor” etiketi taşır; yalnızca doğruladığınız rakamları panelden onaylayın. İzlenme sıralaması sadece onaylı toplam izlenme alanını kullanır. Yedek indir/yükle JSON dosyasıyla içeriği taşıyabilir. Sertifika ve yeni görsel/PDF dosyaları panelden eklenebilir. Yerel denemede görsel/PDF 1,5 MB sınırındadır; video yüklemek için bulut yapılandırması gerekir.

## İlk yönetici kurulumu (Supabase)

Ücretsiz başlangıç için Supabase kullanıldı; içerik tek bir JSON kaydında tutulur, medya Storage’da saklanır. Google istemci sırrı hiçbir zaman web dosyalarına yazılmaz; Google OAuth ayarları Supabase panelinde kalır. Güvenlik SQL’i `supabase/migrations/20261025000000_portfolio.sql` içindedir.

1. Supabase projesi oluşturun ve Project URL ile **publishable/anon** anahtarını alın. Gizli `service_role` anahtarını asla paylaşmayın veya `config.js` dosyasına koymayın.
2. `config.js` içindeki `supabaseUrl` ve `supabasePublishableKey` alanlarını birlikte doldurun. Değerlerden biri eksik veya URL geçersizse yönetim paneli bunu durum mesajında açıkça bildirir; ikisi de boşsa site yerel önizleme modunda kalır ve kaydetmeler yalnızca o tarayıcıda tutulur. Bu dosyada gizli anahtar bulunmamalıdır.
3. Supabase SQL Editor'da önce `supabase/migrations/20261025000000_portfolio.sql`, sonra `supabase/seed.sql` dosyalarının içeriğini sırayla çalıştırın. İkinci dosya başlangıç içeriğini ekler. Google Client ID/Secret değerini Supabase Auth → Providers → Google kısmına girin. Supabase Auth URL Configuration'da canlı site adresini ve OAuth dönüş adresini allowlist'e ekleyin.
4. Siteyi HTTPS adresinde açıp **Google ile giriş** yapın. Yönetim panelindeki **Kullanıcı numarasını kopyala** düğmesine basın. Supabase SQL Editor’da `INSERT INTO public.portfolio_admins(user_id) VALUES ('KOPYALANAN-UUID');` sorgusunu bir kez çalıştırın. Yalnızca allowlist’e eklenen kullanıcı düzenleyebilir.
5. Siteyi yenileyin; panelde “Yönetici onaylı” görünmeli. İçerik **Değişiklikleri kaydet** ile buluta yazılır.

Supabase SQL Editor ve Google Cloud OAuth ayarları hesap sahibi tarafından yapılmalıdır; Google kimlik bilgisi veya parola bu klasöre eklenmemelidir. SQL kurallarında herkese açık okuma ve yalnızca allowlist yöneticilerine yazma politikaları vardır. Medya bucket’ı ziyaretçilerin dosyaları görüntüleyebilmesi için public read kullanır; ekleme/değiştirme/silme admin RLS politikalarına tabidir.

## Medya dosyaları ve sınırlar

Gerçek görseller `assets/` altında; videolar `assets/videos/` altında. Galeri ve projeler bu yolları `portfolio-data.js` içinden kullanır. Dosya değiştirmek için yeni dosyayı aynı klasöre koyup paneldeki mevcut dosyayı kaldırın ve yenisini yükleyin. Taslak görsel düzenleri gerçek görsel yokken rastgele stok kullanmaz.

## Proje sayfalarında sosyal profiller

`A Country A Song` ve `KatmanEdition` proje kartlarının altında Instagram ve TikTok profil kartları doğrudan görünür; açılır düğme yoktur. Instagram için eski Wix sitesindeki gibi `instagram.com/<kullanıcı-adı>/embed/` profil görünümü kullanılır. TikTok kartı profil adı ve en son kontrol edilen takipçi/beğeni sayılarını gösterir, yalnızca profil sayfasına bağlantı verir; böylece gönderi/video akışı yüklenmez.

Supabase Free planı şu an dosya başına 50 MB, toplam 1 GB Storage ve aylık 5 GB cache egress + 5 GB uncached egress sınırı bildiriyor; kota ve ücretler değişebilir. Mevcut `dil.mp4` yaklaşık 146 MB olduğundan Free Storage’a yüklenemez; sıkıştırın veya video barındırma servisine yükleyip optimize bir önizleme kullanın. `belediyeedit.mov` tarayıcı uyumluluğu değişken olduğundan MP4’e dönüştürün. Upload paneli MP4 kabul eder ve 50 MB üstünü engeller. Bu sınırlar Supabase belgesine göredir: [plan fiyatları](https://supabase.com/pricing), [yükleme sınırları](https://supabase.com/docs/guides/storage/uploads/file-limits), [depolama](https://supabase.com/docs/guides/storage/buckets/fundamentals), [OAuth Google](https://supabase.com/docs/guides/auth/social-login/auth-google), [RLS](https://supabase.com/docs/guides/database/postgres/row-level-security).

## Proje dosyaları

- `index.html`, `styles.css`, `project-layouts.css`: portfolyo arayüzü; temel stiller ile proje düzenleri ayrı dosyalardadır.
- `portfolio-data.js`: varsayılan proje/istatistik/yetenek içeriği.
- `portfolio-app.js`: render, Google OAuth, veri ve medya bağlantısı.
- `admin.js`: düzenleme ve yedekleme işlevleri.
- `config.js`: Supabase genel URL ve publishable key; gizli anahtar içermez.
- `supabase/migrations/`: tablo, bucket ve RLS güvenlik kuralları.
- `supabase/tests/security-smoke-checks.sql`: ilk kurulum sonrası manuel güvenlik kontrol listesi.

İçerik kaynağında teyitsiz metrikler işaretli, sertifika ve iletişim bilgileri boş. Kullanıcının sağlamadığı müşteri, iletişim, yorum veya araç bilgisi eklenmemiştir. Kanuni animasyonu daha küçük seçilmiş iş olarak yer alır.

## Vimeo ve YouTube videoları

Videolar Vimeo veya YouTube’da barındırılabilir; Vimeo ve YouTube bağlantıları sitede oynatıcı olarak açılır. Vimeo’da video gizlilik ayarlarının gömmeye izin verdiğini doğrula. Vimeo paylaşım penceresinden **Copy regular link** ile aldığın bağlantıyı kullan; inceleme/yorum bağlantısı kullanma. Portfolyoda **Düzenle → Videolar** bölümünden bağlantıyı kaydedebilir ve istersen **İlgili proje** ile proje kartına bağlayabilirsin. Proje içindeki örnek medya bağlantıları `portfolio-data.js` içinden güncellenir. Vimeo oynatıcısı ve YouTube oynatıcısı kart açıldığında yüklenir.

YouTube kullanırsan video **Liste dışı** olmalı; bağlantıya sahip olan herkes izleyebilir. “Gizli” videoyu kullanma. Liste dışı ayarları için [YouTube görünürlük açıklaması](https://support.google.com/youtube/answer/157177?hl=en), siteye gömme için [YouTube gömme yönergesi](https://support.google.com/youtube/answer/171780?hl=en) sayfasına bakabilirsin. Her iki sağlayıcıda da video sahibi gömmeyi kapatırsa oynatıcı sitede çalışmaz.
