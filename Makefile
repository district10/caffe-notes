PANDOCOPTIONS := -s -S --ascii -c http://tangzx.qiniudn.com/main.css \
	-f markdown+east_asian_line_breaks

all: publish/misc.html
clean:
	rm -rf publish
gh:
	git add -A; git commit -m "`uname` - `date`"; git push;
fetch:
	make -C pynotebooks
note: n
n:
	$(EDITOR) misc.md
m:
	$(EDITOR) Makefile

publish/%.html: %.md
	mkdir -p $(@D)
	pandoc $(PANDOCOPTIONS) $< -o $@
