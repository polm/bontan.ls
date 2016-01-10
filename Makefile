all: src/mikan.ls src/bontan.ls src/sudachi.ls src/kinkan.ls
	lsc -c -o lib src/

clean:
	rm -f lib/*
