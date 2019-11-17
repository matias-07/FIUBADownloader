use strict;
use warnings;
use LWP::Simple;
use HTML::Parse;
use HTML::Element;

die "ERROR: Se debe pasar un código de materia como parámetro" if (!defined $ARGV[0]);

my $codigo_materia = substr($ARGV[0], 0, 2) . ":" . substr($ARGV[0], 2);
my $dir = $ARGV[0];

my $url = "http://wiki.foros-fiuba.com.ar";
my $url_materia = "/materias:" . $codigo_materia;

my $content = get($url . $url_materia);
die "ERROR: No se pudo obtener contenido" if (!defined $content);

my $parsed = HTML::Parse::parse_html($content);

my @media_links = map { $_->[0] } grep { substr($_->[0], 0, 7) eq "/_media" } @{$parsed->extract_links()};

my $downloads = scalar(@media_links);

mkdir($dir) unless ($downloads == 0);

foreach my $link (@media_links) {
	my $filename = $dir . "/" . substr($link, rindex($link, ":") + 1);
	if (-e $filename) {
		$downloads--;
		next;
	}
	print "Descargando $filename...\n";
	getstore($url . $link, $filename);
}

my $message = ($downloads > 0 ? "\n" : "") . "Cantidad de archivos descargados: $downloads\n";
print $message;
