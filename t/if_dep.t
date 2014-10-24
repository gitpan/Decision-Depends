use strict;
use warnings;

use Test::More tests => 4;

use Decision::Depends;
use Decision::Depends::Var;

require 't/common.pl';
require 't/depends.pl';

our $verbose = 0;

#---------------------------------------------------

# no deps, non-existant target, ok return
eval {
  cleanup();
  Decision::Depends::Configure( { File => 'data/deps' } );
  if_dep {  -target => 'data/targ1' }
    action { touch( 'data/targ1' ) };
};
print STDERR $@ if $@ && $verbose;
ok ( !$@ && -f 'data/targ1', 
   'if_dep no deps, non-existant target, ok return' );

#---------------------------------------------------

# no deps, non-existant target, sfile, ok return
eval {
  cleanup();
  Decision::Depends::Configure( { File => 'data/deps' } );
  if_dep {  -target => -sfile => 'data/targ1' }
    action { };
};
print STDERR $@ if $@ && $verbose;
ok ( !$@ && -f 'data/targ1', 
   'if_dep no deps, non-existant target, sfile, ok return' );


#---------------------------------------------------

# no deps, non-existant target, die
eval {
  cleanup();
  Decision::Depends::Configure( { File => 'data/deps' } );
  if_dep {  -target => 'data/targ1' }
    action { die("ERROR (expected)\n") };
};
print STDERR $@ if $@ && $verbose;
ok ( $@ && $@ =~ /^ERROR/ && ! -f 'data/targ1', 
   'if_dep no deps, non-existant target, die' );


#---------------------------------------------------

# no deps, non-existant target, rethrow
eval {
  cleanup();
  Decision::Depends::Configure( { File => 'data/deps' } );
  if_dep {  -target => 'data/targ1' }
    action { die("ERROR (expected)\n") }
	or die( "rethrow ERROR" );
};
print STDERR $@ if $@ && $verbose;
ok ( $@ && $@ =~ /^rethrow ERROR/ && ! -f 'data/targ1', 
   'if_dep no deps, non-existant target, rethrow' );


#---------------------------------------------------
#cleanup();
