note: n
n:
	$(EDITOR) misc.md
m:
	$(EDITOR) Makefile

gh:
	git add -A; git commit -m "`uname` - `date`"; git push;
