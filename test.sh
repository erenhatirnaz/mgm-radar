#!/bin/bash

# Renk kodları
KIRMIZI='\033[1;31m'
YESIL='\033[1;32m'
MAVI='\033[1;36m'
TEMIZLE='\033[0m'

HATA_SAYISI=0
hata() {
	echo -e "  ${KIRMIZI}${*}${TEMIZLE}" >&2
	((HATA_SAYISI++))
}

# Kontrol fonksiyonları
dosya_olmali() {
	if [[ -f "$1" ]]; then
		return 0
	else
		hata "'$1' dosyasının oluşturulmuş olması bekleniyordu." >&2
		return 1
	fi
}

dosya_olmamali() {
	if [[ ! -f "$1" ]]; then
		return 0
	else
		hata "'$1' dosyasının olmaması bekleniyordu." >&2
		return 1
	fi
}

dizin_olmali() {
	if [[ -d "$1" ]]; then
		return 0
	else
		hata "'$1' dizinin oluşturulmuş olması bekleniyordu." >&2
		return 1
	fi
}

bos_olmamali() {
	if [[ -n "$1" ]]; then
		return 0
	else
		hata "Boş olmaması gereken bir değişkenin içeriği boş." >&2
		return 1
	fi
}

iceriyor_olmali() {
	if [[ "$1" == *"$2"* ]]; then
		return 0
	else
		hata "'$1' değerinin '$2' ifadesini içermesi bekleniyordu."
		return 1
	fi
}

icermiyor_olmali() {
	if [[ ! "$1" == *"$2"* ]]; then
		return 0
	else
		hata "'$1' değerinin '$2' ifadesini içermemesi bekleniyordu."
		return 1
	fi
}

esit_olmali() {
	if [[ "$1" == "$2" ]]; then
		return 0
	else
		hata "'$1' değerinin '$2' değerine eşit olması bekleniyordu."
		return 1
	fi
}

resim_turu_esit_olmali() {
	local dosya beklenen_deger gercek_deger
	dosya="$1"
	beklenen_deger="$2"

	gercek_deger=$(identify "$1" | awk '{print $2}' | head -1)

	if [[ "$gercek_deger" == "$beklenen_deger" ]]; then
		return 0
	else
		hata "'${dosya}' resminin türü '${gercek_deger}' yerine '${beklenen_deger}'"\
				 "olması bekleniyordu."
		return 1
	fi

	unset dosya beklenen_deger gercek_deger
}

resim_katman_sayisi_esit_olmali() {
	local dosya beklenen_deger gercek_deger
	dosya="$1"
	beklenen_deger="$2"

	gercek_deger=$(identify "$1" | wc -l)

	if [[ "$gercek_deger" -eq "$beklenen_deger" ]]; then
		return 0
	else
		hata "'${dosya}' dosyasının '${gercek_deger}' olan katman sayısı"\
				 "'${beklenen_deger}' olması bekleniyordu."
		return 1
	fi

	unset dosya beklenen_deger gercek_deger
}

# Testler
test_varsayilan_indirme_klasoru_olustu_mu() {
	./mgm-radar.sh > /dev/null

	dizin_olmali "/tmp/mgm-radar/"
}

test_gecersiz_altkomut_hatası_veriyor_mu() {
	altkomutlar=( deneme 123 sondurum2 hareketli3 radarlar2 -v1 --version2 -y5 --yardim54 )

	for altkomut in "${altkomutlar[@]}"; do
		cikti=$(./mgm-radar.sh "$altkomut" 2>&1)

		iceriyor_olmali "$cikti" "Geçersiz"

		unset cikti altkomut
	done
}

test_gecerli_altkomutlar_kabul_ediliyor_mu() {
	altkomutlar=( radarlar sondurum hareketli -y --yardim -v --versiyon )

	for altkomut in "${altkomutlar[@]}"; do
		cikti=$(./mgm-radar.sh "$altkomut" 2>&1)

		icermiyor_olmali "$cikti" "Geçersiz"

		unset cikti altkomut
	done
}

test_arguman_isleyici_calisiyor_mu() {
	bash -x mgm-radar.sh sondurum -i 6 -u vil -d test/ -s 1>&2 2>test.log >/dev/null

	il_kodu=$(grep IL_KODU "test.log" | cut -d= -f2)
	urun=$(grep URUN "test.log" | cut -d= -f2)
	dizin=$(grep DIZIN "test.log" | cut -d= -f2 | sort | head -1)
	sadece_indir=$(grep SADECE_INDIR "test.log" | cut -d= -f2 | sort -r | head -1)

	esit_olmali "$il_kodu" "6"
	esit_olmali "$urun" "vil"
	esit_olmali "$dizin" "test/"
	esit_olmali "$sadece_indir" "true"
}

test_il_kontrol_fonksiyonu_calisiyor_mu() {
	cikti=$(./mgm-radar.sh sondurum -i 2>&1)

	iceriyor_olmali "$cikti" "zorunludur"
}

test_urun_kontrol_fonksiyonu_calisiyor_mu() {
	cikti1=$(./mgm-radar.sh sondurum -i 6 -u 2>&1)
	cikti2=$(./mgm-radar.sh sondurum -i 6 -u asd 2>&1)

	iceriyor_olmali "$cikti1" "zorunludur"
	iceriyor_olmali "$cikti2" "Geçersiz"
}

test_dizin_kontrol_fonksiyonu_casiliyor_mu() {
	cikti=$(./mgm-radar.sh sondurum -i 6 -u vil -d test123/ 2>&1 >/dev/null)

	iceriyor_olmali "$cikti" "Böyle bir dizin yok"
}

test_urun_isimleri_kisaltildi_mi() {
	declare -A kontroller=( [ruzgar]=rzg [maks]=max )

	for uzun in "${!kontroller[@]}"; do
		kisa="${kontroller[$uzun]}"
		bash -x mgm-radar.sh sondurum -s -i 6 -u "$uzun" -d test/ 1>&2 2>test.log > /dev/null

		urun=$(grep URUN "test.log" | cut -d= -f2 | sort -r | head -1)

		esit_olmali "$urun" "$kisa"

		unset kisa kuzun urun
		rm -rf test.log
	done
}

test_il_kodu_0_ise_urun_ppi_olmali() {
	yes e | bash -x mgm-radar.sh sondurum -i 0 -u vil -s -d test/ 1>&2 2>test.log > /dev/null

	urun=$(grep URUN "test.log" | cut -d= -f2 | sort | head -1)

	esit_olmali "$urun" "ppi"
}

test_il_kodu_gecersiz_hatasi_veriyor_mu() {
	cikti=$(./mgm-radar.sh sondurum -i 123 -u vil 2>&1 >/dev/null)

	iceriyor_olmali "$cikti" "radarı bulunmuyor"
}

test_sondurum_fonksiyonu_gecerli_jpeg_indiriyor_mu() {
	./mgm-radar.sh sondurum -i 6 -u ppi -s -d test/ >/dev/null 2>&1

	radar_goruntusu="test/6-ppi.jpg"

	dosya_olmali "$radar_goruntusu"
	resim_turu_esit_olmali "$radar_goruntusu" "JPEG"
	resim_katman_sayisi_esit_olmali "$radar_goruntusu" 1
}

test_hareketli_fonksiyonu_gecerli_gif_olusturuyor_mu() {
	./mgm-radar.sh hareketli -i 6 -u ppi -s -d test/ >/dev/null 2>&1

	radar_goruntusu="test/6-ppi.gif"

	dosya_olmali "$radar_goruntusu"
	dosya_olmamali "6-vil"{1..15}".jpg"
	resim_turu_esit_olmali "$radar_goruntusu" "GIF"
	resim_katman_sayisi_esit_olmali "$radar_goruntusu" "15"
}

test_radarlar_fonksiyonu_liste_yazdiriyor_mu() {
	cikti=$(./mgm-radar.sh radarlar | head -1)

	iceriyor_olmali "$cikti" "bulunan iller"
}

test_internet_baglantisi_yoksa_hata_veriyor_mu() {
	cikti=$(unshare -rn ./mgm-radar.sh -d test/ 2>&1)

	iceriyor_olmali "$cikti" "bir sorun oluştu"
}

test_sadece_indir_aciksa_resim_gostermiyor_mu() {
	cikti=$(./mgm-radar.sh sondurum -i 6 -u vil -d test/ -s 2>&1)

	icermiyor_olmali "$cikti" "\`xdg-open\` ile açıldı"
}

test_hata_mesajlari_loglaniyor_mu() {
	unshare -rn ./mgm-radar.sh 2>/dev/null

	cikti=$(cat "mgm-radar.log")

	dosya_olmali "mgm-radar.log"
	iceriyor_olmali "$cikti" "Network is unreachable"
}

# Test sürecinde radar görüntüleri test/ dizinine indirilecek
mkdir -p test

# Test çalıştırıcı
for fonk in $(declare -F | cut -d' ' -f3 | grep '^test_*'); do
	echo "$fonk"
	eval "$fonk"
	rm -rf {mgm-radar,test,hata-ayikla}.log test/*.{jpg,gif}
	unset cikti cikti1 cikti2 radar_goruntusu urun dizin sadece_indir il_kodu \
				kontroller alkomutlar
done
rm -rf test/

# Sonuç
TEST_SAYISI=$(declare -F | cut -d' ' -f3 | grep -c '^test_*')
echo -e "\\n${MAVI}$TEST_SAYISI${TEMIZLE} test çalıştırıldı.\\n"

if [[ $HATA_SAYISI -gt 0 ]]; then
	echo -e "${KIRMIZI}BAŞARISIZ (Hata Sayısı=${HATA_SAYISI})${TEMIZLE}"
	exit 1
else
	echo -e "${YESIL}BAŞARILI${TEMIZLE}"
	exit 0
fi
