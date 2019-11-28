kaynak = $(shell realpath "./mgm-radar.sh")
hedef = "${HOME}/.local/bin/mgm-radar"

betik = $(shell basename "$(hedef)")

yukle:
	ln -s $(kaynak) $(hedef)
	@echo "mgm-radar.sh: $(hedef) konumuna yüklenmiştir! \`$(betik) --yardim\` komutu ile test edebilrsiniz."

test:
	@rm -rf /tmp/mgm-radar
	@bash test.sh

kaldir:
	rm $(hedef)
	@echo "mgm-radar.sh: $(hedef) konumundan silinmiştir!"
