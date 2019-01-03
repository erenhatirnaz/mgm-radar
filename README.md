# mgm-radar

T.C. Tarım ve Orman Bakanlığı Meteoroloji Genel Müdürlüğü tarafından sağlanan
meteorolojik radar görüntülerini indiren ve varsayılan resim görüntüleyiciniz
ile açan bir araç. Varsayılan resim görüntüleyiciniz yerine başka bir resim
görüntüleyici ile açmak istiyorsanız `mgm-radar.sh` dosyasındaki 27.satırı
düzenleyebilirsiniz. Bu betik, GNU/Linux dağıtımlarında kullanılabilir.

## Motivasyonum

Gün içerisinde birkaç kez bu radar görüntülerini kontrol ettiğim için hem kendime
kolaylık olması için, hem de insanların işine yarayabileceğini düşünerek böyle
bir betik kodladım. Ben gün içerisinde sıkça kullanıyorum.

## Kurulumu ve Kaldırılması

Gereksinimler:
- Bash 4.0 veya üzeri
- `wget` - görüntüleri indirmek için (`sudo apt install wget`)
- `imagemagick` - hareketli gif oluşturmak için (`sudo apt install imagemagick`)

Kurulum aşamaları:
```sh
$ git clone https://github.com/erenhatirnaz/mgm-radar.git
$ cd mgm-radar
$ chmod u+x ./mgm-radar.sh
$ make yukle
```

NOT: `make yukle` komutu bu depo içerisinde bulunan `mgm-radar.sh` dosyasının
sembolik bir bağlantısını (bir nevi kopyasını) `~/.local/bin/mgm-radar` konumuna
kaydeder ve böylece terminalizinde her yerden ulaşabilme olanağı sağlar. Eğer
siz kişisel betiklerinizi farklı bir dizinde saklıyorsanız
(mesela ben `~/scripts/` konumunu kullanıyorum), o zaman `Makefile` dosyası
içerisindeki 2.satırdaki `hedef` değişkenini düzenleyebilirsiniz.

Kaldırmak için ise:
```sh
$ make kaldir
```
komutunu çalıştırabilirsiniz.

## Kullanımı

Meteorolojik radar bulunan illeri ve kodlarını öğrenmek için `mgm-radar radarlar`
komutunu çalıştırabilirsiniz. `mgm-radar --yardim` komutu ile yardım dökümanını
görüntüleyebilirsiniz.

Meteorolojik radarın son kaydettiği radar görüntüsünü indirmek ve görüntülemek
için:
```sh
$ mgm-radar sondurum --il-kodu 61 --urun vil
```

Meteorolojik radarın son kaydettiği 15 görüntüyü hareketli GIF olarak indirmek
ve görüntülemek için:
```sh
$ mgm-radar hareketli --il-kodu 61 --urun ppi
```

Radar görüntüleri varsayılan olarak `/tmp/radar/` konumuna indirilir. Burası
geçiçi bir dizidir ve bilgisayarınızı kapattığınızda silinir. Kalıcı olarak başka
bir dizine indirmek için `-d|--dizin` parametresini kullanın. Örnek:
```sh
$ mgm-radar sondurum -i 34 -u maks -d ~/Resimler/radar/
```
Bu parametre ile verdiğiniz dizinin oluşturulmuş olması gerekir.

NOT: Birleştirilmiş görüntü için mgm.gov.tr sadece PPI ürünü sunmaktadır.

## Lisansı

GNU Genel Kamu Lisansı v3
