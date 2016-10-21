

#( arctic_a0001 "Author of the danger trail, Philip Steels, etc." )
# > database/txt/arctic_a0001.txt containing:
#Author of the danger trail, Philip Steels, etc.

$outdir = "database/txt";

while (<>) {
    chomp;
    $line = $_;
    $line =~ /\( (\S+) \"([^\"]+)\" \)/;
    $base = $1;
    $text = $2;

    $filename = sprintf "%s/%s.txt", $outdir, $base;
    
    open(OUT, ">${filename}") || die "Unable to open $filename: $!\n";
    print OUT "$text\n";
    close(OUT);
}
