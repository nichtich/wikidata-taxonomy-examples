#!/usr/bin/env perl
#
# convert CSV output of wikidata-taxonomy to LaTeX
#
use v5.14;
use Catmandu -all;
use Pandoc::Elements;

binmode(STDOUT, ":encoding(UTF-8)");

my $file = shift @ARGV;
my $entries = importer('CSV', file => $file);
my %items;

say '\begin{tabbing}';
say '\hspace*{58mm}X\= \kill';

$entries->each(sub {
    my $item = shift;
    
    $items{ $item->{item} } //= { 
        sites => $item->{sites},
        instances => $item->{size},
    };

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
say '';

my $classes   = keys %items;
my $instances = grep {$_->{instances}} values %items;
my $sites     = grep {$_->{sites}} values %items;

say '\vfill';
say '\begin{tabbing}';
say '\hspace*{15mm}\=\hspace*{32mm}\=\kill';
say '\\>\textbf{Summary}\\\\';
say "\\>number of classes:\\`$classes (100\\%)\\\\";
say "\\>with instance:\\`$instances (".int($instances/$classes*100)."\\%)\\\\";
say "\\>with sitelink:\\`$sites (".int($sites/$classes*100)."\\%)";
$instances = shift @ARGV;
if ($instances) {
    say "\\\\\\>number of instances:\\`$instances";
}
say '\end{tabbing}';

