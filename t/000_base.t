#!/usr/bin/perl
#
#

use strict; 
use warnings;
use Test::More tests => 9;



use FindBin;

# files to remove
my @f2r = ();

my $tmp_dir = $FindBin::Bin."/tmp";

for my $ext (['zf','gz'],['jf','bz2'],['Jf','xz']) {
  my $tf = "$FindBin::Bin/../test.tar.".$ext->[1];
  if ( -f $tf ) { unlink $tf || die "Could not remove $tf: $!" };
  my $cmd = "tar -C $FindBin::Bin -c".$ext->[0]." $tf data";
  push @f2r,$tf;
  system($cmd);
}

( -d $tmp_dir ) || mkdir $tmp_dir;

clean_dir($tmp_dir);

my $tc_list = [
  {ext=>'gz',files=>[3,4]},
  {ext=>'bz2',files=>[5,6]},
  {ext=>'xz',files=>[7,8]},
];

foreach my $tc (@$tc_list) {
  my $ext = $tc->{ext};
  my @files = map { "--file data/file.$_" } @{$tc->{files}};
  my $file_string = join(' ',@files);
  my $tcmd = "$FindBin::Bin/../extract_file --archive test.tar.$ext ".join(' ',@files)." --outdir $tmp_dir";

  `$tcmd`;

  for my $i (@{$tc->{files}}) {
    ok(-f "$tmp_dir/file.$i","Checking file.$i from test.tar.$ext");
  }
  for my $i (@{$tc->{files}}) {
    unlink "$tmp_dir/file.$i" || die "Could not unlink"
  }

  # directory must be empty if only wanted files where extracted
  ok(scalar(list_dir($tmp_dir)) == 0,"Checking if directory is empty");
  
}

for my $f ($tmp_dir,@f2r) {  
  unlink $f || die "Removing $f failed: $!";
}

exit 0;

sub clean_dir {
    
    opendir(my $dh,$_[0]);

    while (my $fn = readdir($dh) ) {
      next if ($fn eq '.' or $fn eq '..');
      unlink $fn || die "Could not remove $_[0]/$fn: $!";
    }
}

sub list_dir {
  opendir(my $dh,$_[0]);
  my @res = ();

  while (my $fn = readdir($dh) ) {
    next if ($fn eq '.' or $fn eq '..');
    push @res , $fn;
  }

  return @res;
}
