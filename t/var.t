#!perl

use strict;
use warnings;

use Test::More;
plan( tests => 21 );

use YAML;

use Decision::Depends;
use Decision::Depends::Var;

require 't/common.pl';
require 't/depends.pl';

our $verbose = 0;
our $error = 0;
my $err;

our ( $deplist, $targets, $deps );

#---------------------------------------------------

# check different means of specifying variable name
eval {
  cleanup();
  touch( 'data/targ1' );
  ( $deplist, $targets, $deps ) = 
    submit( -target => 'data/targ1',
	    -depend => -var => ( -foo => 'data/dep1' ) );
};
$err = $@;
ok ( !$@ && 
     eq_hash( $deps, { 'data/targ1' => {
					var    => [ 'foo' ],
					time   => [],
					sig    => [] }} 
	    ), 'variable dependency, variable name as attribute' )
	    or diag( $err );

# check different means of specifying variable name
eval {
  cleanup();
  touch( 'data/targ1' );
  ( $deplist, $targets, $deps ) = 
    submit( -target => 'data/targ1',
	    -depend => '-var=foo' => 'data/dep1'  );
};
$err = $@;
ok ( !$@ && 
     eq_hash( $deps, { 'data/targ1' => {
					var    => [ 'foo' ],
					time   => [],
					sig    => [] }} 
	    ), 'variable dependency, variable name as attr value' )
	    or diag( $err );

# check different means of specifying variable name
eval {
  cleanup();
  touch( 'data/targ1' );
  ( $deplist, $targets, $deps ) = 
    submit( -target => 'data/targ1',
	    -depend => -var => { foo => 'data/dep1' } );
};
$err = $@;
ok ( !$@ && 
     eq_hash( $deps, { 'data/targ1' => {
					var    => [ 'foo' ],
					time   => [],
					sig    => [] }} 
	    ), 'variable dependency, variable name as attr value via hashref' )
	    or diag( $err );

#---------------------------------------------------

# variable dependency, no var.  this is ok.
eval {
  cleanup();
  touch( 'data/targ1' );
  ( $deplist, $targets, $deps ) = 
    submit( -target => 'data/targ1',
	    -depend => -var => ( -foo => 'data/dep1' ) );
};
$err = $@;
ok ( !$@ && 
     eq_hash( $deps, { 'data/targ1' => {
					var    => [ 'foo' ],
					time   => [],
					sig    => [] }} 
	    ), 'variable dependency, no variable' )
	    or diag( $err );

#---------------------------------------------------

# variable dependency, var with same value.
eval {
  cleanup();
  touch( 'data/targ1' );
  ( $deplist, $targets, $deps ) = 
    submit( -target => 'data/targ1',
	    -depend => -var => ( -foo => 'val' ),
	    sub { $Decision::Depends::self->{State}->setVar( 'data/targ1', foo => 'val' ) }
	    );
};
$err = $@;
ok ( !$@ &&
     eq_hash( $deps, { } ),
     'variable dependency, unchanged value' )
	    or diag( $err );

#---------------------------------------------------

# variable dependency, var with different value.
eval {
  cleanup();
  touch( 'data/targ1' );
  ( $deplist, $targets, $deps ) = 
    submit( -target => 'data/targ1',
	    -depend => -var => ( -foo => 'val' ),
	    sub { $Decision::Depends::self->{State}->setVar( 'data/targ1', foo => 'val2' ) }
	    );
};
$err = $@;
ok ( !$@ &&
     eq_hash( $deps, { 'data/targ1' => {
					var    => [ 'foo' ],
					time   => [],
					sig    => [] } } 
	    ),
     'variable dependency, different value' )
	    or diag( $err );

#---------------------------------------------------

# variable dependency, var with same value.
eval {
  cleanup();
  touch( 'data/targ1' );
  ( $deplist, $targets, $deps ) = 
    submit( -target => 'data/targ1',
	    -force => -depend => -var => ( -foo => 'val' ),
	    sub { $Decision::Depends::self->{State}->setVar( 'data/targ1', foo => 'val' ) }
	    );
};
$err = $@;
ok ( !$@ &&
     eq_hash( $deps, { 'data/targ1' => {
					var    => [ 'foo' ],
					time   => [],
					sig    => [] } } 
	    ),
     'local force variable dependency' )
	    or diag( $err );

#---------------------------------------------------

# variable dependency, var with same value.
eval {
  cleanup();
  touch( 'data/targ1' );
  ( $deplist, $targets, $deps ) = 
    submit( { Force => 1 },
            -target => 'data/targ1',
	    -depend => -var => ( -foo => 'val' ),
	    sub { $Decision::Depends::self->{State}->setVar( 'data/targ1', foo => 'val' ) }
	    );
};
$err = $@;
ok ( !$@ &&
     eq_hash( $deps, { 'data/targ1' => {
					var    => [ 'foo' ],
					time   => [],
					sig    => [] } } 
	    ),
     'global force variable dependency' )
	    or diag( $err );

#---------------------------------------------------

# variable dependency, guess numeric variable

eval {
  cleanup();
  Decision::Depends::Configure( { Verbose => $verbose, File => 'data/deps' } );

  my $val = '0.1470';

  $error = 1;
  if_dep { -slink => 'data/targ1', -var => -val => $val }
  action {
    $error = 0;
  };
};
$err = $@;
ok ( ! $error && !$@,  'setup guessed numerical variable deps' )
	    or diag( $err );

eval {
  my $val = 0.147;
  if_dep { -slink => 'data/targ1', -var => -val => $val }
  action {
    die( "shouldn't get here!\n" );
  };
};
$err = $@;
ok ( !$@,  'guessed numerical values' )
	    or diag( $err );


#---------------------------------------------------

# variable dependency, force numeric variable

eval {
  cleanup();
  Decision::Depends::Configure( { Verbose => $verbose, File => 'data/deps1' } );

  my $val = '0.1470';

  $error = 1;
  if_dep { -slink => 'data/targ1', -var => -numcmp => -val => $val }
  action {
    $error = 0;
  };
};
$err = $@;
ok ( ! $error && !$@,  'setup forced numerical variable deps' )
	    or diag( $err );

eval {
  my $val = 0.147;
  if_dep { -slink => 'data/targ1', -var => -numcmp => -val => $val }
  action {
    die( "shouldn't get here!\n" );
  };
};
$err = $@;
ok ( !$@,  'forced numerical values' )
	    or diag( $err );

eval {
  my $val = 0.147;
  $error = 1;
  if_dep { -slink => 'data/targ1', -var => -strcmp => -val => $val }
  action {
    $error = 0;
  };
};
$err = $@;
ok ( !$@,  'forced string compare of num values' )
	    or diag( $err );

#---------------------------------------------------

# variable dependency, force string compare

eval {
  cleanup();
  Decision::Depends::Configure( { Verbose => $verbose, File => 'data/deps1' } );

  my $val = 'snake';

  $error = 1;
  if_dep { -slink => 'data/targ1', -var => -val => $val }
  action {
    $error = 0;
  };
};
$err = $@;
ok ( ! $error && !$@,  'setup forced string variable deps' )
	    or diag( $err );

eval {
  my $val = 'snake';
  if_dep { -slink => 'data/targ1', -var => -strcmp => -val => $val }
  action {
    die( "shouldn't get here!\n" );
  };
};
$err = $@;
ok ( !$@,  'forced numerical values' )
	    or diag( $err );

eval {
  my $val = 0.147;
  $error = 1;
  if_dep { -slink => 'data/targ1', -var => -strcmp => -val => $val }
  action {
    $error = 0;
  };
};
$err = $@;
ok ( !$error && !$@,  'forced string compare of num values' )
	    or diag( $err );

#---------------------------------------------------

{
    cleanup();
    Decision::Depends::Configure( { Verbose => $verbose, File => 'data/deps1' } );

    my $scalar = 'snake';
    my @array  = ( 'snake' );
    my %hash   = ( reptile => 'snake' );

    # make sure everything is fresh
    sub var { return { scalar => $scalar,
                       array  => \\@array,
                       hash   => \\%hash }
          };

    # variable dependency, HASH, ARRAY values

    # first make sure the parsing works
    eval {


        $error = 1;
        if_dep { -slink => 'data/targ1', 
                   -var => var();
             }
          action {
              $error = 0;
          };
    };
    $err = $@;
    ok ( ! $error && !$@,  'hash, array parse' )
      or diag( $err );

    # make sure output is what is expected
    ok( eq_hash( YAML::LoadFile( 'data/deps1' )->{Var}{'data/targ1'},
               {
                scalar => $scalar,
                array  => \@array,
                hash   => \%hash }),
        "hash, array values" );

    # now change something and see what happens.
    for my $tst (
                 [ scalar => sub { $scalar = 'bird' } ],
                 [ array  => sub { @array = ( 'bird' ) } ],
                 [ hash   => sub { %hash  = ( avian => 'bird' ) } ]
                )
    {
        my ( $label, $sub ) = @$tst;

        eval {
            $sub->();

            $error = 1;
            if_dep { -slink => 'data/targ1', 
                       -var   => var() }
              action {
                  $error = 0;
              };
        };
        $err = $@;
        ok ( ! $error && !$@,  "change $label" )
          or diag( $err );
    }

}

#---------------------------------------------------

cleanup();
