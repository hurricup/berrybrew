use warnings;
use strict;

use Test::More;
use IPC::Open3;
use Symbol 'gensym';
use POSIX ':sys_wait_h';
use lib 't/';
use BB;

my $c = $ENV{BBTEST_REPO} ? "$ENV{BBTEST_REPO}/build/berrybrew" : 'c:/repos/berrybrew/build/berrybrew';
my @installed = BB::get_installed();
my @avail = BB::get_avail();
my $cloned;

if (! @installed){
    note "\nInstalling $avail[-1] because none were installed\n";
    `$c install $avail[-1]`;
}
if( join("\0", '', @installed = BB::get_installed(), '') !~ /\0myclone\0/ ) {
    note "\nCloning $installed[-1] to myclone\n";
    `$c clone $installed[-1] myclone`;
    $cloned = $installed[-1];
} else {
    note "\nmyclone already exists\n";
    $cloned = $installed[-2];   # I hope
}

like join("\0", '', @installed = BB::get_installed(), ''), qr/\0myclone\0/, 'verifying myclone exists';

{   # testing single 'berrybrew use' inside the same "window"
    my $name = 'berrybrew use myclone';
    my $pid = open3( my $pinn, my $pout, my $perr = gensym, $c, 'use', 'myclone' );

    # run some commands in the environment
    print {$pinn} "where perl\n";
    print {$pinn} 'perl -le "print $]"', $/;
    print {$pinn} "exit\n";
    print {$pinn} "where perl\n";
    print {$pinn} 'perl -le "print $]"', $/;
    print {$pinn} "exit\n";

    my $t0 = time;
    while ( (time() - $t0) < 10 ) { # wait no more than 10s
        my $kid = waitpid($pid, WNOHANG);
        note "waitpid($pid)=$kid";
        last unless $kid < 0;
        sleep(1);
    }
    my $xout = join '', <$pout>;
    my $xerr = join '', <$perr>;

    diag "`$name` resulted in STDERR=\"$xerr\"\n" if $xerr;
    is $xerr, '', "$name: STDERR should be empty";

    my $re = qr/where perl\s*(\S*berrybrew.test.myclone.perl.bin.perl\.exe)\s*$/ims;
    like $xout, $re, $name.': found myclone berrybrew perl';
    foreach ( $xout =~ m/$re/gims ) {
        note "$name: found perl path: '$_'\n";
    }
    like $xout, qr/perl -le "[^"]+"\s*5\.\d+/im,  $name.': found perl version';
    foreach ( $xout =~ /perl -le "[^"]+"\s*(5\.\d+)/gim ) {
        note "$name: found perl version: $_\n";
    }
}

{   # testing multiple 'berrybrew use' versions inside the same "window"
    my $name = "berrybrew use $cloned,myclone";
    my $pid = open3( my $pinn, my $pout, my $perr = gensym, $c, 'use', join(',', $cloned, 'myclone') );

    # run some commands in the environment
    print {$pinn} "where perl\n";
    print {$pinn} 'perl -le "print $]"', $/;
    print {$pinn} "exit\n";
    print {$pinn} "where perl\n";
    print {$pinn} 'perl -le "print $]"', $/;
    print {$pinn} "exit\n";

    my $t0 = time;
    while ( (time() - $t0) < 10 ) { # wait no more than 10s
        my $kid = waitpid($pid, WNOHANG);
        note "waitpid($pid)=$kid";
        last unless $kid < 0;
        sleep(1);
    }
    my $xout = join '', <$pout>;
    my $xerr = join '', <$perr>;

    diag "`$name` resulted in STDERR=\"$xerr\"\n" if $xerr;
    is $xerr, '', "$name: STDERR should be empty";

    my $re = qr/where perl\s*(\S*berrybrew.test.$cloned.perl.bin.perl\.exe)\s*$/ims;
    like $xout, $re, $name.": found berrybrew perl $cloned";
    foreach ( $xout =~ m/$re/gims ) {
        note "$name: perl path: '$_'\n";
    }

    $re = qr/where perl\s*(\S*berrybrew.test.myclone.perl.bin.perl\.exe)\s*$/ims;
    like $xout, $re, $name.': found berrybrew perl myclone';
    foreach ( $xout =~ m/$re/gims ) {
        note "$name: perl path: '$_'\n";
    }

    $re = qr/perl -le "[^"]+"\s*(5\.\d+)\s*$/im;
    like $xout, $re,  $name.': found perl versions';
    foreach ( $xout =~ /$re/gim ) {
        note "$name: perl version: $_\n";
    }
}

{   # testing single 'berrybrew use' versions in separate window;
    #   cannot (conveniently) send commands to the spawned window,
    #   so just check that the parent process gets the PID when
    #   BBTEST_SHOW_PID is set
    my $name = "berrybrew use --win myclone";
    local $ENV{BBTEST_SHOW_PID} = 1;
    my $pid = open3( my $pinn, my $pout, my $perr = gensym, $c, 'use', '--win', join(',', 'myclone') );

    my $t0 = time;
    while ( (time() - $t0) < 10 ) { # wait no more than 10s
        my $kid = waitpid($pid, WNOHANG);
        note "waitpid($pid)=$kid";
        last unless $kid < 0;
        sleep(1);
    }
    my $xout = join '', <$pout>;
    my $xerr = join '', <$perr>;

    diag "`$name` resulted in STDERR=\"$xerr\"\n" if $xerr;
    is $xerr, '', "$name: STDERR should be empty";

    my @matches = $xout =~ /: spawned in new command window, with PID=(\d+)/gims;
    is scalar @matches, 1 , "$name: spawn one window";
    my $count = 0;
    for(@matches) {
        select undef, undef, undef, 0.5;       # wait a half-second before killing each window # was: sleep(1);
        note "kill PID#$_\n";
        $count += kill KILL => $_;
    }
    is $count, scalar @matches, "$name: kill one window";
}

{   # testing multiple 'berrybrew use' versions in separate windows;
    #   cannot (conveniently) send commands to the spawned windows,
    #   so just check that the parent process gets the PID when
    #   BBTEST_SHOW_PID is set
    my $name = "berrybrew use --win $cloned,myclone";
    local $ENV{BBTEST_SHOW_PID} = 1;
    my $pid = open3( my $pinn, my $pout, my $perr = gensym, $c, 'use', '--win', join(',', $cloned, 'myclone') );

    my $t0 = time;
    while ( (time() - $t0) < 10 ) { # wait no more than 10s
        my $kid = waitpid($pid, WNOHANG);
        note "waitpid($pid)=$kid";
        last unless $kid < 0;
        sleep(1);
    }
    my $xout = join '', <$pout>;
    my $xerr = join '', <$perr>;

    diag "`$name` resulted in STDERR=\"$xerr\"\n" if $xerr;
    is $xerr, '', "$name: STDERR should be empty";

    my @matches = $xout =~ /: spawned in new command window, with PID=(\d+)/gims;
    is scalar @matches, 2 , "$name: spawn two windows";
    my $count = 0;
    for(@matches) {
        select undef, undef, undef, 0.5;       # wait a half-second before killing each window # was: sleep(1);
        note "kill PID#$_\n";
        $count += kill KILL => $_;
    }
    is $count, scalar @matches, "$name: kill two windows";
}

done_testing();
