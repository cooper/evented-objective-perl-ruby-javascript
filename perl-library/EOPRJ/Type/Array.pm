# Copyright (c) 2012, Mitchell Cooper
# Type::Array: the array object and/or class.
package EOPRJ::Type::Array;

use warnings;
use strict;
use utf8;

use parent 'EOPRJ::Type::Object';

our $VERSION = '1.0';

# creates a new array.
sub new {
    my ($class, $eoprj, %opts) = @_;
    my $array = $class->SUPER::new($eoprj, %opts);
    
    # if 'array' is specified, use this as the initial array.
    if ($opts{array}) {
        $array->{array} = $opts{array};
    }
    
    # TODO: add $Class to ISAIGNORE.
    
    # set the *ISA* variables to their default values.
    $array->set_property(ISA   => sub { $eoprj->{Array}->property('defaultISA')   });
    $array->set_property(NOISA => sub { $eoprj->{Array}->property('defaultNOISA') });
    
    return $array;
}

# creates a new Array class or object, not an array itself.
# this will not actually be an instance of this class at all.
sub construct {
    my ($class, $eoprj, %opts) = @_;
    my $Array = $opts{object} || EOPRJ::Type::Object->new($eoprj, %opts);
    
    my @insta_methods = qw(push);
    my @class_methods = qw();
    
    my $instanceMethods = EOPRJ::Type::Array->new($eoprj, array => \@insta_methods);
    my    $classMethods = EOPRJ::Type::Array->new($eoprj, array => \@class_methods);
    
    # $array.push($value: Object)
    $Array->set_property_autoload(push => sub {
        EOPRJ::Type::Function->new($eoprj, code => \&_push);
    });
    
    
    # create instanceMethods and classMethods.
    $Array->set_property( instanceMethods => EOPRJ::Type::Array->new($eoprj, array => \@insta_methods) );
    $Array->set_property(    classMethods => EOPRJ::Type::Array->new($eoprj, array => \@class_methods) );
    
    # create ISAONLY, properties only accessible through ISA inheritance.
    $Array->set_property(ISAONLY => EOPRJ::Type::Array->new($eoprj, array => [$instanceMethods]));
    
    # create defaultISA, defaultNOISA.
    $Array->set_property(defaultISA   => EOPRJ::Type::Array->new($eoprj, array => [   $Array    ]));
    $Array->set_property(defaultNOISA => EOPRJ::Type::Array->new($eoprj, array => [$classMethods]));
    
    # set each of the above values' defaultClassProperty property to true.
    $Array->own_property( 'defaultISA' )->set_property(defaultClassProperty => EOPRJ::true());
    $Array->own_property('defaultNOISA')->set_property(defaultClassProperty => EOPRJ::true());
    
    
    return $Array;
}

########################
### INSTANCE METHODS ###
########################

# THIS IS NOT A REAL INSTANCE METHOD AND IS ONLY ACCESSIBLE IN PERL.
# returns a Pure Perl list / array of the FLATTENED elements in this array.
sub flattened_perl_array {
    my $array = shift;print "flattening ".($array->{name} ? $array->{name} : $array)."\n";
    $array->{array} ||= [];
    my @final;
    
    # flatten any child arrays.
    foreach my $ary ($array->perl_array) {
        next if $ary == $array; # give up on this one if the array is this array.
        
        # if it is an array, flatten it.
        if ($ary->is_array) {
            my @flat = $ary->flattened_perl_array;
            push @final, @flat if scalar @flat > 0;
        }
        
        # otherwise, push it if it's another type of object.
        elsif ($ary->is_object) {
            push @final, $ary;
        }
        
    }

    return @final;
}

# THIS IS NOT A REAL INSTANCE METHOD AND IS ONLY ACCESSIBLE IN PERL.
# returns a Pure Perl list / array of the elements in this array.
sub perl_array {
    my $array = shift;
    $array->{array} ||= [];
    return @{$array->{array}};
}

# $array.contains(value: $object)
# returns true if the array contains the exact specific object supplied.
sub _contains {
    my ($this, $scope, $params, $special) = @_;
    return EOPRJ::undefined() unless defined $params->{value};
    
    # check for a matching object.
    foreach my $value ($this->perl_array) { # TODO: make sure this is an instance of ::Array
        return EOPRJ::true() if $value == $params->{value};
    }
    
    return EOPRJ::false();
}

# returns true if the array contains a string that is,
# in terms of characters, equal to the string supplied.
sub _contains_string {
}

# append an element. takes 'value' argument.
sub _push {
}

1
