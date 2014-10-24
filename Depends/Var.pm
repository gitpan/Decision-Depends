package Decision::Depends::Var;

require 5.005_62;
use strict;
use warnings;

use Carp;

our $VERSION = '0.01';

# regular expression for a floating point number
our $RE_Float = qr/^[+-]?(\d+[.]?\d*|[.]\d+)([dDeE][+-]?\d+)?$/;

our %attr = ( depend => 1,
	      depends => 1,
	      force => 1,
	      var => 1,
	      case => 1,
	      numcmp => undef,
	      strcmp => undef,
	      no_case => 1,
	    );

sub new
{
  my $class = shift;
  $class = ref($class) || $class;

  my ( $state, $spec ) = @_;

  my $self = { %$spec, state => $state };

  # ensure that no bogus attributes are set
  my @notok = grep { ! exists $attr{$_} } keys %{$self->{attr}};


  # use the value of the var attribute if it's set (i.e. not 1)
  if ( '1' ne $self->{attr}{var} )
  {
    croak( __PACKAGE__, '->new: too many variable names(s): ',
	   join(', ', $self->{attr}{var}, @notok ) ) if @notok;
  }

  # old style: the variable name is an attribute.
  else
  {
    croak( __PACKAGE__, '->new: too many variable names(s): ',
	   join(', ', @notok ) ) if @notok > 1;

    croak( __PACKAGE__, 
	   ": must specify a variable name for `$self->{val}'" )
      unless @notok == 1;
    $self->{attr}{var} = $notok[0];
  }

  croak( __PACKAGE__,
	 ": specify only one of the attributes `-numcmp' or `-strcmp'" )
    if exists $self->{attr}{numcmp} && exists $self->{attr}{strcmp};


  bless $self, $class;
}

sub depends
{
  my ( $self, $target ) = @_;

  my $var = $self->{attr}{var};

  my $state = $self->{state};

  my $prev_val = $state->getVar( $target, $var );

  my @deps = ();

  if ( defined $prev_val )
  {
    my $is_not_equal = 
      ( exists $self->{attr}{force} ? 
	$self->{attr}{force} : $state->Force ) ||
	cmpVar( exists $self->{attr}{case}, 
		$self->{attr}{numcmp}, 
		$self->{attr}{strcmp}, 
		$prev_val, $self->{val} );

    if ( $is_not_equal )
    {
      print STDOUT 
	"    variable `", $var, "' is now (", $self->{val},
	"), was ($prev_val)\n"
	  if $state->Verbose;

      push @deps, $var;
    }
    else
    {
      print STDOUT "    variable `", $var, "' is unchanged\n"
	if $state->Verbose;
    }
  }
  else
  {
    print STDOUT "    No value on file for variable `", $var, "'\n"
	if $state->Verbose;
      push @deps, $var;
  }

  var => \@deps;
}

sub cmp_strVar
{
  my ( $case, $var1, $var2 ) = @_;
  
  ( $case ? uc($var1) ne uc($var2) : $var1 ne $var2 );
}

sub cmp_numVar
{
  my ( $var1, $var2 ) = @_;
  
  $var1 != $var2;
}

sub cmpVar
{
  my ( $case, $num, $str, $var1, $var2 ) = @_;

  if ( defined $num && $num )
  {
    cmp_numVar( $var1, $var2 );
  }

  elsif ( defined $str && $str )
  {
    cmp_strVar( $case, $var1, $var2 );
  } 

  elsif ( $var1 =~ /$RE_Float/o && $var2 =~ /$RE_Float/o) 
  {
    cmp_numVar( $var1, $var2 );
  }

  else
  {
    cmp_strVar( $case, $var1, $var2 );
  }
}

sub update
{
  my ( $self, $target ) = @_;

  $self->{state}->setVar( $target, $self->{attr}{var}, $self->{val} );
}

sub pprint
{
  my $self = shift;

  "$self->{attr}{var} = $self->{val}";
}

1;
