all:thesis presentation
thesis:
	latexmk -xelatex -synctex=1 -interaction=nonstopmode -shell-escape thesis.tex
presentation:
	latexmk -xelatex -synctex=1 -interaction=nonstopmode -shell-escape presentation.tex
	latexmk -xelatex -synctex=1 -interaction=nonstopmode -shell-escape presentation-handout.tex
clean:
	latexmk -c
clean-all:
	latexmk -C