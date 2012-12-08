# Copyright (c) 2012, Mitchell Cooper
# Scope: represets a lexical scope in EOPRJ.
package EOPRJ::Scope;

use warnings;
use strict;
use utf8;

use parent 'EOPRJ::Type::Object';

# creates a new Scope.
sub new {
    my ($class, $eoprj, %opts) = @_;
    my $scope = $class->SUPER::new($eoprj, %opts);
    
    # determine the containing scope.
    $scope->{parent_scope} = $opts{parent_scope} || $eoprj;

    # add default properties.
    $scope->_apply_default_properties($eoprj);
    
    # return the new scope.
    return $scope;
}

# add the properties that all Objects start out with.
sub _apply_default_properties {
    my ($scope, $eoprj) = @_;
    
    # create the SPECIAL property.
    my $special = EOPRJ::Type::Object->new;
    # TODO: make special inherit from the parent scope's SPECIAL (unless it's the same scope.)
    $special->set_property('scope', sub { $scope });
    $special->set_property('return', sub { EOPRJ::Type::Object->new($eoprj) });
    $scope->set_property('SPECIAL', $special);
    
    # TODO:push parent_scope to ISA (unless it is the same scope.)

    
}

1
