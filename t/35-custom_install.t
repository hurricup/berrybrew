use warnings;
use strict;

use lib 't/';
use BB;
use Test::More;
use Win32::TieRegistry;

my $c = $ENV{BBTEST_REPO} ? "$ENV{BBTEST_REPO}/build/berrybrew" : 'c:/repos/berrybrew/build/berrybrew';
my $customfile = $ENV{BBTEST_REPO} ? "$ENV{BBTEST_REPO}/build/data/perls_custom.json" : 'c:/repos/berrybrew/build/data/perls_custom.json';

my $path_key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment\Path';

my $o;
my $path;

my @avail = BB::get_avail();
my @installed = BB::get_installed();

if (! @installed){
    note "\nInstalling $avail[-1] because none were installed\n";
    `$c install $avail[-1]`;
    push @installed, $avail[-1];    # [pryrt] needed, otherwise next block would be skipped
}

note "\nCloning $installed[-1] to custom\n";
$o = `$c clone $installed[-1] custom`;
ok -s $customfile > 5, "custom perls file size ok after add";

$o = `$c available`;

open my $fh, '<', 't\data\custom_available.txt' or die $!;

my @o_lines = split /\n/, $o;

my $count = 0;
for my $base (<$fh>){
    chomp $base;
    is $o_lines[$count], $base, "line $count ok after custom add";
    $count++;
}

@installed = BB::get_installed();

{
    my $ver = 'custom';

    $o = `$c switch $ver`;
    like $o, qr/Switched to $ver/, "switch to custom install ok";

    $path = $Registry->{$path_key};
    like $path, qr/C:\\berrybrew\\test\\$ver/, "PATH set ok for $ver";
}

{
    my $o = `$c off`;
    like $o, qr/berrybrew perl disabled/, "off ok";

    my $path = $Registry->{$path_key};
    unlike $path, qr/^C:\\berrybrew\\/, "PATH set ok for 'off'";
}

$o = `$c remove custom`;
like $o, qr/Successfully/, "remove custom install ok";

@avail = BB::get_avail();
ok ! grep {'custom' eq $_} @avail;

@installed = BB::get_installed();
ok ! grep {'custom' eq $_} @installed;

is -s $customfile, 2, "custom perls file size ok after remove";

done_testing();
