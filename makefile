all:build-thesis build-presentation build-presentation-handout
build-thesis:
	latexmk -xelatex -synctex=1 -interaction=nonstopmode -shell-escape thesis.tex
build-presentation:
	latexmk -xelatex -synctex=1 -interaction=nonstopmode -shell-escape presentation.tex
build-presentation-handout:
	latexmk -xelatex -synctex=1 -interaction=nonstopmode -shell-escape presentation-handout.tex
clean:
	latexmk -c
clean-all:
	latexmk -C