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

resim_genisligi_esit_olmali() {
	local dosya beklenen_deger gercek_deger
	dosya="$1"
	beklenen_deger="$2"

	gercek_deger=$(identify "$dosya" | awk '{print $3}' | cut -dx -f1)

	if [[ "$gercek_deger" -eq "$beklenen_deger" ]]; then
		return 0
	else
		hata "'${dosya}' dosyasının '${gercek_deger}' olan genişliğinin"\
				 "'${beklenen_deger}' olması gerekiyordu."
		return 1
	fi
}

resim_uzunlugu_esit_olmali() {
	local dosya beklenen_deger gercek_deger
	dosya="$1"
	beklenen_deger="$2"

	gercek_deger=$(identify "$dosya" | awk '{print $3}' | cut -dx -f2)

	if [[ "$gercek_deger" -eq "$beklenen_deger" ]]; then
		return 0
	else
		hata "'${dosya}' dosyasının '${gercek_deger}' olan uzunluğunun"\
				 "'${beklenen_deger}' olması gerekiyordu."
		return 1
	fi
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
	altkomutlar=( radarlar sondurum hareketli rapor -y --yardim -v --versiyon )

	for altkomut in "${altkomutlar[@]}"; do
		cikti=$(./mgm-radar.sh "$altkomut" 2>&1)

		icermiyor_olmali "$cikti" "Geçersiz"

		unset cikti altkomut
	done
}

test_arguman_isleyici_calisiyor_mu() {
	bash -x mgm-radar.sh sondurum -i 6 -u vil -d test/ -f yatay -s 1>&2 2>test.log >/dev/null

	il_kodu=$(grep IL_KODU "test.log" | cut -d= -f2)
	urun=$(grep URUN "test.log" | cut -d= -f2 | head -n1)
	dizin=$(grep DIZIN "test.log" | cut -d= -f2 | sort | head -1)
	sadece_indir=$(grep SADECE_INDIR "test.log" | cut -d= -f2 | sort -r | head -1)
	format=$(grep FORMAT "test.log" | awk 'NR==5' | cut -d= -f2)

	esit_olmali "$il_kodu" "6"
	esit_olmali "$urun" "vil"
	esit_olmali "$dizin" "test/"
	esit_olmali "$sadece_indir" "true"
	esit_olmali "$format" "4"
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

# Bu test bazı teknik zorluklardan dolayı devre dışı bırakılmıştır
# test_internet_baglantisi_yoksa_hata_veriyor_mu() {
# 	cikti=$(unshare -rn ./mgm-radar.sh -d test/ 2>&1)
# 	iceriyor_olmali "$cikti" "bir sorun oluştu"
# }

test_sadece_indir_aciksa_resim_gostermiyor_mu() {
	cikti=$(./mgm-radar.sh sondurum -i 6 -u vil -d test/ -s 2>&1)

	icermiyor_olmali "$cikti" "\`xdg-open\` ile açıldı"
}

test_rapor_fonksiyonu_gecersiz_format_hatasi_veriyor_mu() {
	cikti=$(./mgm-radar.sh rapor -i 6 -f deneme -s 2>&1)

	iceriyor_olmali "$cikti" "Geçersiz"
}

test_formatlar_sayilara_cevriliyor_mu() {
	declare -A formatlar=( [kare]=2 [dikey]=1 [yatay]=4 )

	for format in "${!formatlar[@]}"; do
		bash -x mgm-radar.sh rapor -i 6 -f "$format" -s -d test/ 1>&2 2>test.log > /dev/null

		frmt=$(grep FORMAT test.log | awk 'NR==5' | cut -d= -f2)

		esit_olmali "$frmt" "${formatlar[$format]}"

		rm test.log
		unset frmt format
	done
}

test_rapor_fonksiyonu_gecerli_kare_cikti_uretiyor_mu() {
	./mgm-radar.sh rapor -i 6 -f kare -d test/ -s 2>&1 >/dev/null

	cikti_dosyasi="test/6_rapor.jpg"

	dosya_olmali "$cikti_dosyasi"
	resim_turu_esit_olmali "$cikti_dosyasi" "JPEG"
	resim_katman_sayisi_esit_olmali "$cikti_dosyasi" 1
	resim_genisligi_esit_olmali "$cikti_dosyasi" "1760"
	resim_uzunlugu_esit_olmali "$cikti_dosyasi" "1440"
}

test_rapor_fonksiyonu_gecerli_dikey_cikti_uretiyor_mu() {
	./mgm-radar.sh rapor -i 34 -f dikey -d test/ -s 2>&1 >/dev/null

	cikti_dosyasi="test/34_rapor.jpg"

	dosya_olmali "$cikti_dosyasi"
	resim_turu_esit_olmali "$cikti_dosyasi" "JPEG"
	resim_katman_sayisi_esit_olmali "$cikti_dosyasi" 1
	resim_genisligi_esit_olmali "$cikti_dosyasi" "880"
	resim_uzunlugu_esit_olmali "$cikti_dosyasi" "2880"
}

test_rapor_fonksiyonu_gecerli_yatay_cikti_uretiyor_mu() {
	./mgm-radar.sh rapor -i 35 -f yatay -d test/ -s 2>&1 >/dev/null

	cikti_dosyasi="test/35_rapor.jpg"

	dosya_olmali "$cikti_dosyasi"
	resim_turu_esit_olmali "$cikti_dosyasi" "JPEG"
	resim_katman_sayisi_esit_olmali "$cikti_dosyasi" 1
	resim_genisligi_esit_olmali "$cikti_dosyasi" "3520"
	resim_uzunlugu_esit_olmali "$cikti_dosyasi" "720"
}

test_girintileme_sorunu_olmamali() {
	yardim=$(./mgm-radar.sh --yardim | grep -P '\t')
	versiyon=$(./mgm-radar.sh --versiyon | grep -P '\t')
	radarlar=$(./mgm-radar.sh radarlar | grep -P '\t')

	esit_olmali "$yardim" ""
	esit_olmali "$versiyon" ""
	esit_olmali "$radarlar" ""
}

test_kalsin_argumanı_yoksa_goruntuler_siliniyor_olmali() {
	./mgm-radar.sh hareketli -i 6 -u vil -d test/ -s 2>&1 >/dev/null

	dosya_listesi=$(ls test/)

	icermiyor_olmali "$dosya_listesi" "6-vil1.jpg"
	icermiyor_olmali "$dosya_listesi" "6-vil7.jpg"
	icermiyor_olmali "$dosya_listesi" "6-vil15.jpg"
}

test_kalsin_argumanı_varsa_goruntuler_silinmiyor_olmali() {
	./mgm-radar.sh rapor -i 34 -d test/ -s -k 2>&1 >/dev/null

	dosya_listesi=$(ls test/)

	iceriyor_olmali "$dosya_listesi" "34-ppi.jpg"
	iceriyor_olmali "$dosya_listesi" "34-vil.jpg"
	iceriyor_olmali "$dosya_listesi" "34-max.jpg"
}

# Bu test bazı teknik zorluklardan dolayı devre dışı bırakılmıştır
# test_hata_mesajlari_loglaniyor_mu() {
# 	unshare -rn ./mgm-radar.sh 2>/dev/null
# 	cikti=$(cat "mgm-radar.log")
# 	dosya_olmali "mgm-radar.log"
# 	iceriyor_olmali "$cikti" "Network is unreachable"
# }

# İnternet bağlantısı kontrolü
if ! ping -c 1 -W 1 8.8.8.8 &>/dev/null; then
	cat <<-EOF >&2
	test.sh: İnternet bağlantınız ile ilgili bir sorun oluştu. Testlerin düzgün
	         çalışabilmesi için internet bağlantısı gereklidir.
	EOF
	exit 1
fi

# Test sürecinde radar görüntüleri test/ dizinine indirilecek
mkdir -p test

# Test çalıştırıcı
for fonk in $(declare -F | cut -d' ' -f3 | grep '^test_*'); do
	echo "$fonk"
	eval "$fonk"
	rm -rf {mgm-radar,test,hata-ayikla}.log test/*.{jpg,gif}
	unset cikti cikti1 cikti2 radar_goruntusu urun dizin sadece_indir il_kodu \
				kontroller alkomutlar yardim versiyon radarlar cikti_dosyasi dosya_listesi
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
