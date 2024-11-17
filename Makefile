.PHONY: test mock-sunucu-baslat mock-sunucu-durdur yukle kaldir

kaynak = $(shell realpath "./mgm-radar.sh")
hedef = "${HOME}/.local/bin/mgm-radar"

betik = $(shell basename "$(hedef)")

PORT := 8080
MOCK_DIR := ".mock_data"

yukle:
	ln -s $(kaynak) $(hedef)
	@echo "mgm-radar.sh: $(hedef) konumuna yüklenmiştir! \`$(betik) --yardim\` komutu ile test edebilrsiniz."

mock-sunucu-baslat:
	@if [ -f mock_server.pid ] && kill -0 $$(cat mock_server.pid) 2>/dev/null; then \
		echo "Mock sunucu zaten çalıştığı tespit edildi. Durduruluyor..."; \
		$(MAKE) mock-sunucu-durdur; \
	fi
	@mkdir -p "$(MOCK_DIR)"
	@tar -xf mock_data.tar -C "$(MOCK_DIR)"
	@echo "Mock sunucu $(PORT) portu üzerinde başlatılıyor..."
	@python3 -m http.server $(PORT) --directory $(MOCK_DIR) > mock_server.log 2>&1 & echo $$! > mock_server.pid
	@sleep 1

mock-sunucu-durdur:
	@if [ -f mock_server.pid ]; then \
		echo "Mock sunucu durduruluyor..."; \
		kill $$(cat mock_server.pid) 2>/dev/null || true; \
		rm -rf mock_server.* "$(MOCK_DIR)"; \
	else \
		echo "Çalışan bir mock sunucu yok."; \
	fi

test: mock-sunucu-baslat
	@rm -rf /tmp/mgm-radar
	@bash test.sh
	@$(MAKE) mock-sunucu-durdur

kaldir:
	rm $(hedef)
	@echo "mgm-radar.sh: $(hedef) konumundan silinmiştir!"
