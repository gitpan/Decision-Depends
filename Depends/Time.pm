package Decision::Depends::Time;

require 5.005_62;
use strict;
use warnings;

use Carp;

our $VERSION = '0.01';

our %attr = ( depend => 1,
	      depends => 1,
	      force => 1,
	      time => 1,
	      orig => 1 );

sub new
{
  my $class = shift;
  $class = ref($class) || $class;

  my ( $state, $spec ) = @_;

  my $self = { %$spec, state => $state };


  # ensure that no bogus attributes are set
  my @notok = grep { ! exists $attr{$_} } keys %{$self->{attr}};
  croak( __PACKAGE__, 
	 "->new: bad attributes for Time dependency `$self->{val}': ",
	 join( ', ', @notok ) ) if @notok;

  # ensure that the dependency exists
#  croak( __PACKAGE__, "->new: non-existant dependency: $self->{val}" )
#      unless -f $self->{val};

  bless $self, $class;
}

sub depends
{
  my ( $self, $target, $time )  = @_;

  my $state = $self->{state};

  my $depfile = $self->{val};
  my $depfiles =
     exists $self->{attr}{orig} ?
       [ $depfile ] : $state->getSLinks( $depfile );

  my $links = $depfile ne $depfiles->[0];

  my @deps = ();

  # loop through dependencies, check if any is younger than the target
  for my $dep ( @$depfiles )
  {
    my $deptag = $dep;
    $deptag .= " (slinked to `$depfile')" if $links;

    my @sb;
    my $dtime = 
      $state->getTime( $dep ) ||
	((@sb = stat( $dep )) ? $sb[9] : undef);

    croak( __PACKAGE__, "->cmp: non-existant dependency: $dep" )
      unless defined $dtime;

    $state->setTime( $dep, $dtime );

    my $is_not_equal = 
      ( exists $self->{attr}{force} ? 
	$self->{attr}{force} : $state->Force )
	|| $dtime > $time;

    # if time of dependency is greater than of target, it's younger
    if ( $is_not_equal )
    {
      print STDOUT "    file `$deptag' is younger\n" if $state->Verbose;
      push @deps, $dep;
    }
    else
    {
      print STDOUT "    file `$deptag' is older\n" if $state->Verbose;
    }
  }

  time => \@deps;
}

sub update
{
  # do nothing; keep DepXXX class API clean
}

sub pprint
{
  my $self = shift;

  $self->{val};
}

1;
