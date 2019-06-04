# Use xelatex instead of pdflatex
$pdflatex = 'xelatex -synctex=1 -interaction=nonstopmode -shell-escape %O %S';
$out_dir = 'build';
$aux_dir = 'build';

add_cus_dep('glo', 'gls', 0, 'makeglossaries');
add_cus_dep('acn', 'acr', 0, 'makeglossaries');
sub makeglossaries {
   my ($base_name, $path) = fileparse( $_[0] );
   pushd $path;
   my $return = system "makeglossaries $base_name";
   popd;
   return $return;
}

push @generated_exts, 'glo', 'gls', 'glg';
push @generated_exts, 'acn', 'acr', 'alg';
$clean_ext .= ' %R.ist %R.xdy';

do './includes/gitinfo2.pm';