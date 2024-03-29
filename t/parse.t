use strict;
use warnings;

use Test::More tests => 1;

use Decision::Depends;
use YAML qw( DumpFile LoadFile );

our $create = 0;

my @specs = ( 
	     -target => [ -unalias => 'targ1',  -no_target => 'targ2' ],
	     -depend => -md5 => [ 'dep1',  '-slurp=' => 'dep2' ],
	     '-slurp=33' => 'frank',
	     -wave => -33,
	     -snooker => \-39,
	     -temp => -frodo => { snack => 'food',
	                 flack => 'jacket' },
             -hippo => 99
	 );

my @res = $Decision::Depends::self->_build_spec_list( undef, undef, \@specs );

DumpFile( 'data/parse', \@res )
  if $create;

my $c_res = LoadFile( 'data/parse' );

ok( eq_array( \@res, $c_res ), 'token parse' );
