#!/usr/bin/perl
#
#

use strict; 
use warnings;
use Test::More tests => 3;
use Cwd;
use Data::Dumper;

use FindBin;

my $org_cwd = getcwd();

# files to remove
my @f2r = ();

my $tmp_dir = $FindBin::Bin."/tmp";

( -d $tmp_dir ) || mkdir $tmp_dir;

clean_dir($tmp_dir);

# create zip file
chdir $FindBin::Bin;

`zip -r $tmp_dir/test.zip ./data`;
chdir $tmp_dir;

my $tcmd = "$FindBin::Bin/../extract_file --archive test.zip --files data/file.3 --files data/file.4 --outdir $tmp_dir";

`$tcmd`;

for my $i (qw/file.3 file.4/) {
  ok(-f "$tmp_dir/$i","Checking $i from test.zip");
}

my $cmd = "$FindBin::Bin/../extract_file --archive test.zip --files '--illegal-option'  --outdir $tmp_dir";

my @out = `$cmd`;
my $VAR1 = [
          'Extracting from /home/fschreiner/gh/obs-service-extract_file/t/tmp/test.zip:
',
          '   --illegal-option
',
          'illegal --file option: --illegal-option
'
        ];

is_deeply($VAR1,\@out,"Checking with illegal option");

clean_dir($tmp_dir);

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
