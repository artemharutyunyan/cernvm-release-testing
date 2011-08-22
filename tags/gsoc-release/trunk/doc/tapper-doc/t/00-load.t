#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Tapper::Doc' );
}

diag( "Testing Tapper::Doc $Tapper::Doc::VERSION, Perl $], $^X" );
