# Copyright (c) 2012, Mitchell Cooper
# Type::Function: the function object and/or class.
package EOPRJ::Type::Function;

use warnings;
use strict;
use utf8;

use parent 'EOPRJ::Type::Object';

# creates a new function.
sub new {
    my ($class, $eoprj, %opts) = @_;
    my $function = $class->SUPER::new($eoprj, %opts);
    
    # set the function code.
    # TODO: ensure that code exists and is a code reference.
    $function->{function_code} = $opts{code};
    
    return $function;
}

# calls a function. typically, this is called by the EOPRJ::Object class.
# $parent_scope : the scope that the function is in.
# $special_vars : a perl hashref of name:value special (@) variables.
# $params       : a perl hashref of name:value arguments passed to the function.
sub _call_function {
    my ($function, $parent_scope, $params, $special_vars) = @_;
    return unless $function->{function_code};
    
    # create a new scope with the parent scope in ISA.
    my $scope = EOPRJ::Scope->new($function->{eoprj}, parent_scope => $parent_scope || $function->{eoprj});
    
    # TODO: set special variables.
    
    # TODO: ensure that all parameters are valid with EOPRJ::valid_value().
    
    # call the function with this new scope.
    my $spec = $scope->property('SPECIAL');
    $function->{function_code}->($spec->property('this'), $scope, $params || {}, $spec);
    
    # return the scope.
    return $scope;
}

# creates a new Function class or object, not a function itself.
# this will not actually be an instance of this class at all.
sub construct {
    my ($class, $eoprj, %opts) = @_;
    my $Function = EOPRJ::Type::Object->new($eoprj, %opts);
    return $Function;
}

########################
### INSTANCE METHODS ###
########################

1
