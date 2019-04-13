\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{fhwn-masterthesis}[2019/04/08 Masterthesis Template for FH WN]

\LoadClass[oneside,12pt,bibliography=totoc]{scrbook}

\RequirePackage{gitinfo2}

%'oneside' specifies that the pages will be printed on one sides of a every page. If you want to print on both sides of your pages use the parameter 'twoside'. Remember to order the printing job on one side of every page!!!


    %%%%------------------PREAMBLE----------------%%%%
    %%----------------------------------------------%%

    %%%%%-------------------PACKAGES-----------------%%%%% 
    
%\RequirePackage[utf8]{inputenc}
\RequirePackage[a4paper,top=25mm,bottom=30mm,left=30mm,right=25mm]{geometry}   %allows to change margins and distances within the page's frame. Be careful with this tool. Remember to delete the frame!!!!

%\RequirePackage{showframe}
%\RequirePackage[english]{babel}    %the package babel is not necessary as long as you write your thesis in English.
\RequirePackage{csquotes}
\RequirePackage{graphicx}   %loads the graphics package, necessary for pictures
\RequirePackage{url}
\RequirePackage[breaklinks]{hyperref}   %Automatically turn all your internal references into hyperlinks. 
% \RequirePackage{breakurl}
%\RequirePackage{wallpaper}

\def\UrlBreaks{\do\/\do-}

\RequirePackage[toc,page]{appendix}
\RequirePackage[final]{pdfpages}
\RequirePackage{soul}       %provides hyphenatable letterspacing, underlining and some derivatives such as everstriking and highlighting.
%\RequirePackage[intoc]{nomencl}   %helps to format a nomenclature.
%\makenomenclature

\RequirePackage[nomain,acronym,toc,shortcuts]{glossaries}

\RequirePackage[UKenglish]{isodate} %Provides the format for the date on the title page. Read the package documentation for all the possible date formats.

\RequirePackage{array}
\RequirePackage{longtable}
\RequirePackage{booktabs}
\RequirePackage{xparse}
\RequirePackage{euler}

\RequirePackage{pgfplots}
\RequirePackage{tikz}

%\RequirePackage{lipsum}
\RequirePackage{caption}
%\RequirePackage{abstract}   %This package allows to modify the Abstract style, position and font. Defines the abstract automatically.
\RequirePackage{supertabular}
\RequirePackage{tabto}

\RequirePackage{fontspec}
\setmainfont{MyFont.TTF}%Tw Cen MT
[Ligatures=TeX,
    Path=includes/fonts/,
    BoldFont=MyFont_Bold.TTF,
    ItalicFont=MyFont_Italic.TTF,
BoldItalicFont=MyFont_BoldItalic.TTF]

\RequirePackage{xcolor}
\definecolor{header-blue}{RGB}{22,48,114}

\setcounter{secnumdepth}{4}

\RequirePackage{titlesec}

\titleformat{\chapter}[hang]{\bfseries\Large\color{header-blue}}{\makebox[.63cm][l]{\thechapter.}}{0pt}{}[]
\titlespacing*{\chapter}{0pt}{18pt}{12pt}

\titleformat{\section}[hang]{\bfseries\large\color{header-blue}}{\makebox[1.27cm][l]{\thesection}}{0pt}{}[]
\titlespacing*{\section}{0pt}{6pt}{12pt}

\titleformat{\subsection}[hang]{\bfseries\normalsize\color{header-blue}}{\makebox[1.5cm][l]{\thesubsection}}{0pt}{}[] 
\titlespacing*{\subsection}{0pt}{6pt}{12pt}

\titleformat{\subsubsection}[hang]{\bfseries\normalsize\color{header-blue}}{\makebox[1.5cm][l]{\thesubsubsection}}{0pt}{}[]
\titlespacing*{\subsubsection}{0pt}{6pt}{12pt}

\titleformat{\paragraph}[hang]{\bfseries\normalsize\color{header-blue}}{\makebox[2.5cm][l]{\theparagraph}}{0pt}{}[]
\titlespacing*{\paragraph}{0pt}{6pt}{12pt}

% \RequirePackage{fancyhdr}

% \fancypagestyle{mystyle}{
%     \fancyhf{} %Clear Everything.
%     \fancyfoot[C]{\thepage} %Page Number
%     \renewcommand{\headrulewidth}{0pt} %0pt for no rule, 2pt thicker etc...
%     \renewcommand{\footrulewidth}{0pt}
%     % \fancyfoot[L]{BOTTOM LEFT}
%     % \fancyfoot[R]{BOTTOM RIGHT}
%     \fancyhead[L]{\leftmark}
%     \fancyhead[R]{\rightmark}
% }

%\RequirePackage{footnote}      %Just in case you want to include footnotes
%\RequirePackage{indentfirst}    %Indent in every first paragraph after \chapter and \section.
\RequirePackage[onehalfspacing]{setspace}      %Change spacing easily with simple commands

\RequirePackage{amsmath}       %This package introduces several new commands that are more powerful and flexible than the ones provided by LaTeX. Uncomment them if you are using complex mathematical notation.
\RequirePackage{mathtools}     %The mathtools package fixes some amsmath quirks and adds some useful settings, symbols, and environments to amsmath.

\RequirePackage[capitalise,nameinlink,noabbrev]{cleveref}
\RequirePackage{epigraph}
\RequirePackage{pgffor}

\creflabelformat{equation}{#2#1#3}

\RequirePackage[section]{placeins}
\makeatletter
\AtBeginDocument{%
  \expandafter\renewcommand\expandafter\subsection\expandafter{%
    \expandafter\@fb@secFB\subsection
  }%
}
\makeatother

\RequirePackage[group-separator={,}]{siunitx}

\RequirePackage{smartdiagram}
\usetikzlibrary{calc,trees,positioning,arrows,chains,shapes.geometric,%
    decorations.pathreplacing,decorations.pathmorphing,shapes,%
    matrix,shapes.symbols}

\renewcommand{\labelitemii}{-}
\renewcommand{\labelitemi}{--}

\newcolumntype{!}{>{\global\let\currentrowstyle\relax}}
\newcolumntype{^}{>{\currentrowstyle}}
\newcommand{\rowstyle}[1]{\gdef\currentrowstyle{#1}%
  #1\ignorespaces
}

\RequirePackage[backend=bibtex,style=authoryear,sorting=anyvt,natbib=true]{biblatex}
\clubpenalty = 10000 
\widowpenalty = 10000
\displaywidowpenalty = 10000

\definecolor{mygreen}{rgb}{0,0.6,0}
\definecolor{mygray}{rgb}{0.5,0.5,0.5}
\definecolor{mylightgray}{rgb}{0.9,0.9,0.9}
\definecolor{mymauve}{rgb}{0.58,0,0.82}

\RequirePackage{listings}

\lstset{ %
  %backgroundcolor=\color{mylightgray},   % choose the background color; you must add \usepackage{color} or \usepackage{xcolor}
  basicstyle=\linespread{0.8}\footnotesize,        % the size of the fonts that are used for the code
	%basicstyle=\small\sffamily,
  breakatwhitespace=false,         % sets if automatic breaks should only happen at whitespace
  breaklines=true,                 % sets automatic line breaking
  captionpos=t,                    % sets the caption-position to bottom
  commentstyle=\color{mygreen},    % comment style
  deletekeywords={...},            % if you want to delete keywords from the given language
  escapeinside={\%*}{*)},          % if you want to add LaTeX within your code
  extendedchars=true,              % lets you use non-ASCII characters; for 8-bits encodings only, does not work with UTF-8
  frame=tb,                    % adds a frame around the code
  keepspaces=true,                 % keeps spaces in text, useful for keeping indentation of code (possibly needs columns=flexible)
  keywordstyle=\color{blue},       % keyword style
  %language=Octave,                 % the language of the code
  morekeywords={*,...},            % if you want to add more keywords to the set
  numbers=left,                    % where to put the line-numbers; possible values are (none, left, right)
  numbersep=5pt,                   % how far the line-numbers are from the code
  numberstyle=\tiny\color{mygray}, % the style that is used for the line-numbers
  rulecolor=\color{black},         % if not set, the frame-color may be changed on line-breaks within not-black text (e.g. comments (green here))
  showspaces=false,                % show spaces everywhere adding particular underscores; it overrides 'showstringspaces'
  showstringspaces=false,          % underline spaces within strings only
  showtabs=false,                  % show tabs within strings adding particular underscores
  stepnumber=1,                    % the step between two line-numbers. If it's 1, each line will be numbered
  stringstyle=\color{mymauve},     % string literal style
  tabsize=2,                       % sets default tabsize to 2 spaces
  title=\lstname                   % show the filename of files included with \lstinputlisting; also try caption instead of title
}
