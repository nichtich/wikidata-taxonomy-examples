#!/usr/bin/env perl
#
# convert Wikidata classification given in CSV format to LaTeX
#
use v5.14;
use Catmandu -all;
use Pandoc::Elements;

binmode(STDOUT, ":encoding(UTF-8)");

my $file = shift @ARGV;
my $items = importer('CSV', file => $file);

say '\begin{tabbing}';
say '\hspace*{58mm}X\= \kill';

$items->each(sub {
    my $item = shift;
    
    my $level = $item->{level};
    if ($level) {
        $level =~ s/./\\cdot\\:/g; 
        $level = '$'.$level.'$ ';
    }

    my $parents = '';
    if ($item->{parents}) {
        $parents = '$' . ('\uparrow' x $item->{parents}) . '$';
    }

    my $content = $item->{size} || '';
    $content .= '{\raisebox{.4\height}{\scalebox{.6}{+}}}' 
             . $item->{sites} if $item->{sites};
     
    my $label = $item->{label};
    if (length $item->{level} < 2) {
        $label = "\\textbf{$label}"; 
    }

    if ( $item->{level} =~ /=/ ) {
        say "$level \\textit{$label}\\\\" 
    } else {
        say "$level $label $parents \\` $content\\\\";
    }
});

say '\end{tabbing}';
