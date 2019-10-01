#!/bin/bash

# mgm-radar.sh
# Copyright (C) 2019 Eren Hatırnaz <erenhatirnaz@hotmail.com.tr> [GPG: 0x8e64942a]
#
# Bu program özgür yazılımdır: Özgür Yazılım Vakfı tarafından yayımlanan GNU
# Genel Kamu Lisansı’nın sürüm 3 ya da (isteğinize bağlı olarak) daha sonraki
# sürümlerinin hükümleri altında yeniden dağıtabilir ve/veya değiştirebilirsiniz.
#
# Bu program, yararlı olması umuduyla dağıtılmış olup, programın BİR TEMİNATI
# YOKTUR; TİCARETİNİN YAPILABİLİRLİĞİNE VE ÖZEL BİR AMAÇ İÇİN UYGUNLUĞUNA dair
# bir teminat da vermez. Ayrıntılar için GNU Genel Kamu Lisansı’na göz atınız.
#
# Bu programla birlikte GNU Genel Kamu Lisansı’nın bir kopyasını elde etmiş
# olmanız gerekir. Eğer elinize ulaşmadıysa <http://www.gnu.org/licenses/>
# adresine bakınız.

readonly betik_ismi="mgm-radar"
readonly versiyon_numarasi="0.2.0"

readonly betik=$(readlink -f "$0")
readonly ana_dizin=$(dirname "$betik")
readonly indirme_dizini="/tmp/mgm-radar/"
readonly hata_raporu="${ana_dizin}/mgm-radar.log"
readonly baglanti="https://mgm.gov.tr/FTPDATA/uzal/radar"

readonly onek="${betik_ismi}: "
readonly hata="${onek}$(basename "$hata_raporu"): "

readonly goruntuleyici="xdg-open"

if [[ "$1" =~ ^(-h|--hata-ayikla)$ ]]; then
	set -x
	exec > "${ana_dizin}/hata-ayikla.log" 2>&1
	shift
fi

versiyon() {
	cat << EOF
${betik_ismi} versiyon ${versiyon_numarasi}

Copyright (C) 2019 Eren Hatırnaz <erenhatirnaz@hotmail.com.tr> [GPG: 0x8e64942a]
Bu bir özgür yazılımdır, ve bazı koşullar altında yeniden dağıtmakta
serbestsiniz; ayrıntılar için LICENSE dosyasına bakın.
Bu programın KESİNLİKLE HİÇBİR TEMİNATI YOKTUR; ayrıntılar için LICENSE
dosyasına bakın.
EOF
}

yardim() {
	cat << EOF
$(versiyon | head -n1)
T.C. Tarım ve Orman Bakanlığı Meteoroloji Genel Müdürlüğü tarafından sağlanan
meteorolojik radar görüntülerini indirir ve varsayılan resim görüntüleyiciniz
ile açar. Varsayılan resim görüntüleyiciniz yerine başka bir görüntüleyici ile
açmasını istiyorsanız bu betik dosyasındaki 29.satırı düzenleyebilirsiniz.

Kullanım:
  $(basename "$0") [-h] <alt_komut> <argümanlar> [-y|--yardim] [-v|--versiyon]

Alt Komutlar:
   sondurum    Sistemdeki son radar görüntüsünü indirir.
  hareketli    Sistemdeki son 15 radar görüntüsünü indirir ve bunları hareketli
               bir GIF dosyasına çevirir.
   radarlar    Meteoroloji radarı bulunan tüm illeri ve kodlarını yazdırır.

Argümanlar:
  -i, --il-kodu [SAYI]      İndirmek istediğiniz meteoroloji radarının bulunduğu
                            ilin plaka numarası. Meteoroloji radarı bulunan
                            iller için \`$(basename "$0") radarlar\` komutunu
                            çalıştabilirsiniz.
  -u, --urun [URUN]         Meteoroloji radarından görüntüsünü indirmek
                            istediğiniz ürün. İndirebileceğiniz meteorolojik
                            radar ürünleri: vil, ppi, maks, ruzgar.
  -d, --dizin [DİZİN]       Radar görüntüsünün indirilmesini istediğiniz dizin.
                            Varsayılan değer: ${indirme_dizini}. Bu dizine
                            indirilen görüntüler geçiçidir. Kalıcı olması için
                            bir dizin belirtin.
  -s, --sadece-indir        İndirilen radar görüntülerinin varsayılan resim
                            görüntüleyiciniz ile açılmasını engeller.
  -h, --hata-ayikla         Hata ayıklama modunu etkinleştirir. Bu mod
                            etkinleştirildiğinde bütün çıktılar 'mgm-radar.log'
                            dosyasına yazdırılıyor.
  -y, --yardim              Bu yardım mesajını yazdırır.
  -v, --versiyon            Betiğin versiyon numarasını yazdırır.

Lisans:
  GNU Genel Kamu Lisansı versiyon 3

Hata Raporlama:
  Betik kodlarıyla ilgili olduğunu düşündüğünüz bir hata alırsanız aşağıdaki
  bağlantıdan hata bildirimi yapabilirsiniz ya da bana e-posta gönderebilirsiniz.
  Daha verimli hata çözümleme süreci için mümkünse betiği hata ayıklama modunda
  çalıştırıp, oluşacak olan 'hata-ayikla.log' dosyasını da hata bildiriminize
  ekleyiniz. Betiği hata ayıklama modunda çalıştırmak için betik ismi ile alt
  komut arasına -h ya da --hata-ayikla yazmanız yeterli olacaktır. Örneğin:
  $ mgm-radar -h sondurum -i 6 -u vil

    https://github.com/erenhatirnaz/mgm-radar/issues/new

Yazar:
  Eren Hatırnaz <erenhatirnaz@hotmail.com.tr> [GPG: 0x8e64942a]
EOF
}

radarlar() {
	cat << EOF
Meteoroloji radarı bulunan iller ve kodları:
+-----------------------+
| İl             | Kodu |
|----------------+------|
| Afyonkarahisar |    3 |
| Ankara         |    6 |
| Antalya        |    7 |
| Balıkesir      |   10 |
| Bursa          |   16 |
| Erzurum        |   25 |
| Gaziantep      |   27 |
| Hatay          |   31 |
| İstanbul       |   34 |
| İzmir          |   35 |
| Muğla          |   48 |
| Samsun         |   55 |
| Sivas          |   58 |
| Trabzon        |   61 |
| Şanlıurfa      |   63 |
| Zonguldak      |   67 |
| Karaman        |   70 |
| Kilis          |   79 |
+-----------------------+
Birleştirilmiş görüntü için 0 kodunu kullanın. 0 kodu için ürün türü ppi olarak
sınırlandırılmıştır.
EOF
}

# Kullanıcıdan alınan il kodunu mgm.gov.tr'deki dizin yapısındaki karşılığını
# döndürür. Eğer meteoroloji radarı bulunmayan bir ilin kodu girilirse hata
# mesajı yazdırır.
il_str() {
	local il_kodu="$1"

	case "${il_kodu}" in
		0) echo "comp";;
		3) echo "afy";;
		6) echo "ank";;
		7) echo "ant";;
		10) echo "blk";;
		16) echo "brs";;
		25) echo "erz";;
		27) echo "gzt";;
		31) echo "hty";;
		34) echo "ist";;
		35) echo "izm";;
		48) echo "mgl";;
		55) echo "smn";;
		58) echo "svs";;
		61) echo "trb";;
		63) echo "srf";;
		67) echo "zng";;
		70) echo "krm";;
		79) echo "mob";;
		*)
			echo "${onek}${il_kodu}: Bu ilde meteoroloji radarı bulunmuyor." >&2
			exit 1
			;;
	esac
}

il_kontrol() {
	local il_kodu="$1"

	if [[ -z "$il_kodu" ]]; then
		echo "${onek}İl kodu belirtilmesi zorunludur." >&2
		exit 1
	fi
}

urun_kontrol() {
	local urun="$1"

	if [ -z "$urun" ]; then
		echo "${onek}Ürün belirtilmesi zorunludur." >&2
		exit 1
	fi

	if [[ ! "$urun" =~ ^(vil|max|ppi|rzg)$ ]]; then
		echo "${onek}${urun}: Geçersiz ürün." >&2
		exit 1
	fi
}

dizin_kontrol() {
	local dizin="$1"
	if [ ! -d "$dizin" ]; then
		echo "${onek}${dizin}: Böyle bir dizin yok." >&2
		exit 1
	fi
}

sondurum() {
	local il_kodu="$1"
	local urun="$2"
	local dizin="$3"

	il_kontrol "$il_kodu"
	urun_kontrol "$urun"
	dizin_kontrol "$dizin"

	local il
	set -e
	il=$(il_str "$il_kodu")
	set +e
	local indirme_baglantisi="${baglanti}/${il}/${il}${urun}15.jpg"
	local dosya_yolu="${dizin}/${il_kodu}-${urun}.jpg"

	if wget -O "${dosya_yolu}" "${indirme_baglantisi}" 2>"$hata_raporu"; then
		INDIRILEN_DOSYA="$dosya_yolu"
		echo "${onek}${dosya_yolu}: Radar görüntüsü indirildi."
	else
		echo "${hata}Radar görüntüsü indirilirken hata oluştu." >&2
		exit 1
	fi
}

hareketli() {
	local il_kodu="$1"
	local urun="$2"
	local dizin="$3"

	il_kontrol "$il_kodu"
	urun_kontrol "$urun"
	dizin_kontrol "$dizin"

	local il
	set -e
	il=$(il_str "$il_kodu")
	set +e
	local indirme_baglantisi="${baglanti}/${il}/${il}${urun}"
	local dosya_yolu="${dizin}/${il_kodu}-${urun}"

	for i in {1..15}; do
		dsy="${dosya_yolu}${i}.jpg"
		bglnt="${indirme_baglantisi}${i}.jpg"
		printf "%s indiriliyor..." "${dsy}"
		if wget -O "$dsy" "$bglnt" 2>"$hata_raporu"; then
			printf " Tamamlandı\\n"
		else
			echo
			echo "${hata}Radar görüntüsü indirilirken hata oluştu." >&2
			exit 1
		fi
	done

	echo "Hareketli GIF dosyasına dönüştürülüyor..."
	gif_dosyasi="${dosya_yolu}.gif"
	if LC_ALL=en_US.UTF convert "${dosya_yolu}"{1..15}".jpg" \
					 -delay 20 -loop 0 "${gif_dosyasi}" 2>"$hata_raporu"; then
		INDIRILEN_DOSYA="${gif_dosyasi}"
		echo "${onek}${dosya_yolu}.gif: Radar görüntüleri GIF olarak kaydedildi."
	else
		echo "${hata}GIF dosyası oluşturulması sırasında hata oluştu." >&2
	fi

	if rm "${dosya_yolu}"{1..15}".jpg"; then
		echo "GIF oluşturmak için indirilen görüntüler silindi."
	fi
}

rapor() {
	local il_kodu="$1"
	local dizin="${3%%/}"
	local format="$4"

	il_kontrol "$il_kodu"
	dizin_kontrol "$dizin"

	if [[ ! "$format" =~ ^(dikey|yatay|kare)$ ]]; then
		echo "${hata}${format}: Geçersiz format."
		exit 1
	fi
	format="${format/kare/2}"
	format="${format/dikey/1}"
	format="${format/yatay/4}"

	for urun in ppi vil max rzg; do
		sondurum "$il_kodu" "$urun" "${indirme_dizini%%/}"
	done

	local cikti="${dizin}/${il_kodu}_rapor.jpg"
	if LC_ALL=en_US.UTF montage -mode concatenate -tile ${format}x \
					 "${indirme_dizini}${il_kodu}-"*.jpg "$cikti" 2>"$hata_raporu"; then
		INDIRILEN_DOSYA="$cikti"
		echo "${onek}${cikti}: Radar ürünleri raporu oluşturuldu."
	else
		echo "${hata}Radar ürünleri raporu oluşturulması sırasında hata oluştu." >&2
		exit 1
	fi
}

mkdir -p -- "${indirme_dizini}"

# İnternet bağlantısı kontrolü
if ! ping -c 1 -W 1 8.8.8.8 1>/dev/null 2>"$hata_raporu"; then
	echo "${hata}İnternet bağlantınız ile ilgili bir sorun oluştu." >&2
	exit 1
fi

# -y|--yardim ve -v|--versiyon argümanları için
ALT_KOMUT=${1:-"--yardim"}
[[ "$ALT_KOMUT" =~ ^(-y|--yardim)$ ]] && yardim && exit 0
[[ "$ALT_KOMUT" =~ ^(-v|--versiyon)$ ]] && versiyon && exit 0

if [[ ! "$ALT_KOMUT" =~ ^(sondurum|hareketli|radarlar|rapor)$ ]]; then
	echo "${onek}${ALT_KOMUT}: Geçersiz alt komut." >&2
	exit 1
fi
shift

# Argümanların işlenmesi
SADECE_INDIR=false
DIZIN=${indirme_dizini}
FORMAT="kare"

while [[ $# -gt 0 ]]
do
	case $1 in
		-i|--il-kodu)
			IL_KODU="${2,,}"
			shift
			shift
			;;
		-u|--urun)
			URUN="${2,,}"
			# mgm.gov.tr 'deki dizin yapısından dolayı dönüştürülüyor:
			URUN="${URUN/maks/max}"
			URUN="${URUN/ruzgar/rzg}"
			shift
			shift
			;;
		-d|--dizin)
			DIZIN="$2"
			shift
			shift
			;;
		-f|--format)
			FORMAT="$2"
			shift
			shift
			;;
		-s|--sadece-indir)
			SADECE_INDIR=true
			shift
			;;
		*)
			shift
			;;
	esac
done

if [[ "$IL_KODU" == "0" && ! "$URUN" == "ppi" ]]; then
	echo "${onek}Birleştirilmiş görüntü için ürün türü ppi olarak sınırlandırılmıştır."
	read -rp "PPI ürünü ile devam edilsin mi? (e/H): " -n1 secim
	secim=${secim:-h}
	[[ ! $secim =~ [Ee]$ ]] && exit 0
	URUN="ppi"
	echo
fi

INDIRILEN_DOSYA=""
$ALT_KOMUT "$IL_KODU" "$URUN" "${DIZIN%%/}" "$FORMAT"

if [[ -n $INDIRILEN_DOSYA ]] && ! $SADECE_INDIR; then
	if $goruntuleyici "$INDIRILEN_DOSYA" 1>/dev/null 2>"$hata_raporu"; then
		echo "${onek}${INDIRILEN_DOSYA}: \`${goruntuleyici}\` ile açıldı."
		exit 0
	else
		echo "${hata}: \`${goruntuleyici}\` açılırken bir hata oluştu." >&2
		exit 1
	fi
fi
