#berrybrew

The perlbrew for Windows Strawberry Perl! 

`berrybrew` can download, install, remove and manage multiple concurrent 
versions of Strawberry Perl for Windows. There is no requirement to have
Strawberry Perl installed before using `berrybrew`.

Adding and removing perls available is as simple as editing a JSON file, and 
works at runtime. No more need to recompile the binary!

##Installation

#####Git clone

    git clone https://github.com/stevieb9/berrybrew

#####Pre-built zip archive

[berrybrew.zip](https://github.com/stevieb9/berrybrew/blob/master/berrybrew.zip?raw=true "berrybrew zip archive") `SHA1: 983c819e1f3404d4a6ede1c8ea404343edf8ff40`

#####Configuration

    cd berrybrew
    bin\berrybrew.exe config

#####Compile your own

    git clone https://github.com/stevieb9/berrybrew
    cd berrybrew
    mcs -lib:lib -r:ICSharpCode.SharpZipLib.dll,Newtonsoft.Json.dll -out:bin/berrybrew.exe -win32icon:berrybrew.ico src/berrybrew.cs
    bin\berrybrew.exe config

##Commands

    berrybrew <command> [option]

    available   List available Strawberry Perl versions and which are installed
    config      Add berrybrew to your PATH
    install     Download, extract and install a Strawberry Perl
    remove      Uninstall a Strawberry Perl
    switch      Switch to use a different Strawberry Perl
    off         Disable berrybrew entirely
    exec        Run a command for every installed Strawberry Perl

    version     Show the version number only
    license     Show berrybrew license


##Synopsis

List all available versions of Perl:
    
    > berrybrew available

    The following Strawberry Perls are available:

            5.24.0_64       [installed]*
            5.24.0_64_PDL
            5.24.0_32
            5.22.2_64
            5.22.2_32
            5.22.1_64       [installed]
            5.22.1_32       [installed]
            5.20.3_64
            5.20.3_32
            5.18.4_64
            5.18.4_32       [installed]
            5.16.3_64
            5.16.3_32
            5.14.4_64       [installed]
            5.14.4_32       [installed]
            5.12.3_32
            5.10.1_32

    * Currently using

Install a specific version:

    > berrybrew install 5.10.1_32

Switch to a different version (permanently):

    > berrybrew switch 5.10.1_32

    Switched to 5.10.1_32, start a new terminal to use it.

Disable berrybrew entirely, and return to system Perl, if available:

    > berrybrew off

Start a new cmd.exe to use the new version:

    > perl -v

    This is perl, v5.10.1 (*) built for MSWin32-x86-multi-thread

    ...       

Uninstall a version of perl:

    > berrybrew remove 5.10.1_32

    Successfully removed Strawberry Perl 5.10.1_32

Execute something across all perls:

    > berrybrew exec prove -l

    Perl-5.20.1_64
    ==============
    t\DidYouMean.t .. ok
    All tests successful.
    Files=1, Tests=5,  0 wallclock secs ( 0.06 usr +  0.00 sys =  0.06 CPU)
    Result: PASS

    Perl-5.20.1_32
    ==============
    t\DidYouMean.t .. ok
    All tests successful.
    Files=1, Tests=5,  0 wallclock secs ( 0.03 usr +  0.03 sys =  0.06 CPU)
    Result: PASS

    Perl-5.18.4_64
    ==============
    t\DidYouMean.t ..
    Dubious, test returned 5 (wstat 1280, 0x500)
    Failed 5/5 subtests

    Test Summary Report
    -------------------
    t\DidYouMean.t (Wstat: 1280 Tests: 5 Failed: 5)
      Failed tests:  1-5
      Non-zero exit status: 5
    Files=1, Tests=5,  0 wallclock secs ( 0.02 usr +  0.05 sys =  0.06 CPU)
    Result: FAIL

Execute on only a selection of installed versions:

    > berrybrew exec --with 5.22.1_64,5.10.1_32 perl "die()"

    Perl-5.22.1_64
    ==============
    Died at -e line 1.

    Perl-5.10.1_64
    ==============
    Died at -e line 1.

##Add/Remove Perls Available

Simply edit the `perls.json` file in the repository's root directory.


##Requirements

- .Net Framework 2.0 or higher

- Windows only!

- [Mono](http://www.mono-project.com) (only if compiling your own version)


##Troubleshooting

If you run into trouble installing a Perl, try clearing the berrybrew cached
downloads in `C:/berrybrew/temp/`.


##Version

    sb-20160601

##License

2 Clause FreeBSD - see LICENSE

##Original Author

David Farrell [http://perltricks.com]

##This Fork Maintained By

Steve Bertrand `steveb<>cpan.org`

##See Also

- [StrawberryPerl](http://strawberryperl.com) - Strawberry Perl for Windows

- [Perlbrew](http://perlbrew.pl) - the original Perl version manager for Unix
based systems.
