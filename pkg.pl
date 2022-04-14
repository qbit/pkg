#! /usr/bin/perl
# ex:ts=8 sw=4:
#
# Copyright (c) 2019-2022 Aaron Beiber <abieber@openbsd.org>
# Copyright (c) 2010 Marc Espie <espie@openbsd.org>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

use strict;
use warnings;
use DBI;

$| = 1;

my @l = qw(
  add
  check
  create
  delete
  help
  info
  pkginfo
  regen
  search
);

# Commands that we wrap.
my %a = (
    "chk"     => "check",
    "cr"      => "create",
    "del"     => "delete",
    "h"       => "help",
    "i"       => "add",
    "inf"     => "info",
    "install" => "add",
    "rm"      => "delete"
);

# Commands that are unique to pkg.
my %b = (
    "pi" => "pkginfo",
    "re" => "regen",
    "s"  => "search"
);

my %opts = ( %a, %b );

my $srcDBfile = '/usr/local/share/sqlports';
my $dbfile    = '/tmp/sqlports.fts';
my $dbh;

sub run_sql {
    my ( $dbh, $sql ) = @_;

    my $sth = $dbh->prepare($sql) or die $dbh->errstr . "\n$sql\n";
    $sth->execute()               or die $dbh->errstr;
    return $sth;
}

sub createIDX {
    print STDERR "Creating full text database...";
    my $dbh = DBI->connect( "dbi:SQLite:dbname=:memory:", "", "" );
    run_sql( $dbh, "ATTACH DATABASE '$srcDBfile' AS ports;" );
    run_sql(
        $dbh, q{
	CREATE VIRTUAL TABLE
	    ports_fts
	USING fts5(
	    FULLPKGNAME,
	    FULLPKGPATH,
	    COMMENT,
	    DESCRIPTION);
    }
    );
    run_sql(
        $dbh, q{
	INSERT INTO
	    ports_fts
	(FULLPKGNAME, FULLPKGPATH, COMMENT, DESCRIPTION)
	SELECT
	    fullpkgname,
	    _paths.fullpkgpath,
	    comment,
	    _descr.value
	FROM
	    ports._ports
	JOIN _paths ON _paths.id=_ports.fullpkgpath
	JOIN _descr ON _descr.fullpkgpath=_ports.fullpkgpath;
    }
    );

    $dbh->sqlite_backup_to_file($dbfile)
      or die $!;
    $dbh->disconnect();
    print STDERR "Done.\n";
}

my $db_built = 0;
if ( !-e $dbfile ) {
    $db_built = 1;
    createIDX();
}

$dbh = DBI->connect( "dbi:SQLite:dbname=$dbfile", "", "" );

sub run {
    my ( $cmd, $name ) = @_;
    return if defined $b{$name};

    my $module = "OpenBSD::Pkg\u$cmd";

    ## no critic
    eval "require $module";
    ## use critic

    if ($@) {
        die $@;
    }
    exit( $module->parse_and_run($name) );
}

for my $i (@l) {
    if ( $0 =~ m/\/?pkg_$i$/ ) {
        run( $i, "pkg_$i" );
    }
}

if (@ARGV) {
    for my $i (@l) {
        $ARGV[0] = $opts{ $ARGV[0] } if defined $opts{ $ARGV[0] };
        if ( $ARGV[0] eq $i ) {
            shift;
            if ( $i eq "help" ) {
                usage();
                exit();
            }
            if ( $i eq "regen" && $db_built == 0 ) {
                unlink($dbfile);
                createIDX();
                exit();
            }
            if ( $i eq "pkginfo" ) {

                # Take a FULLPKGNAME and return DESCR_CONTENTS and COMMENT
                my $ssth = $dbh->prepare(
                    q{
		    SELECT
			COMMENT,
			DESCRIPTION
		    FROM ports_fts
		    WHERE
			FULLPKGNAME = ?;
		}
                );
                $ssth->bind_param( 1, join( " ", @ARGV ) );
                $ssth->execute();
                while ( my $row = $ssth->fetchrow_hashref ) {
                    print "Comment:\n$row->{COMMENT}\n\n";
                    print "Description:\n$row->{DESCRIPTION}\n";
                }
                exit();
            }
            if ( $i eq "search" ) {

                # TODO: what would be a better UX for displaying this stuff?
                my $ssth = $dbh->prepare(
                    q{
		    SELECT
			FULLPKGNAME,
			FULLPKGPATH,
			COMMENT,
			DESCRIPTION,
			highlight(ports_fts, 2, '[', ']') AS COMMENT_MATCH,
			highlight(ports_fts, 3, '[', ']') AS DESCR_MATCH
		    FROM ports_fts
		    WHERE ports_fts MATCH ? ORDER BY rank;
		}
                );
                $ssth->bind_param( 1, join( " ", @ARGV ) );
                $ssth->execute();
                while ( my $row = $ssth->fetchrow_hashref ) {
                    my $l = 20 - length( $row->{FULLPKGNAME} );
                    $l = 1 if $l <= 0;
                    print(
                        $row->{FULLPKGNAME},   " " x $l,
                        $row->{COMMENT_MATCH}, "\n"
                    );
                }
                exit();
            }
            else {
                run( $i, "pkg $i" );
            }
        }
    }
}

sub usage {
    keys %opts;
    my %u_opts;
    while ( my ( $key, $val ) = each %opts ) {
        $u_opts{$val} = [] unless defined $u_opts{$val};

        #print "$key\n";
        push( @{ $u_opts{$val} }, $key );
    }

    print STDERR "Usage: pkg [";
    my $c   = 1;
    my $len = @l;
    for my $v (@l) {
        next unless $v;
        print STDERR $v, ",", join( ",", sort @{ $u_opts{$v} } );
        print STDERR "|" unless $c >= $len;
        $c++;
    }
    print STDERR "] [args]\n";
}

usage();
exit(1);
