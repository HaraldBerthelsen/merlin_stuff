@files = glob("database/wav/*.wav");

$new_base = "arctic_a";
$nr = 1;
for ($i=0; $i<@files; $i++) {
    $file = $files[$i];
    chomp($file);
    $new_file = sprintf "database/wav/%s%04d.wav", $new_base, $nr;
    $cmd = "mv $file $new_file";
    print "$cmd\n";
    `$cmd`;
    
    $nr++;

    if ($nr == 594 && $new_base eq "arctic_a") {
	$new_base = "arctic_b";
	$nr = 1;
    }
    
}
