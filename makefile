CC=latexmk
CFLAGS=-xelatex -synctex=1 -interaction=nonstopmode -shell-escape

all:proposal thesis presentation

presentation: presentation-standalone presentation-handout

proposal:
	$(CC) $(CFLAGS) proposal.tex

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