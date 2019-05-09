CC=latexmk
CFLAGS=-xelatex -synctex=1 -interaction=nonstopmode -shell-escape

all:thesis presentation

presentation: presentation-standalone presentation-handout

thesis:
	$(CC) $(CFLAGS) thesis.tex

presentation-standalone:
	$(CC) $(CFLAGS) presentation.tex

presentation-handout: presentation-standalone
	$(CC) $(CFLAGS) presentation-handout.tex

clean:
	$(CC) -c
clean-all:
	$(CC) -C