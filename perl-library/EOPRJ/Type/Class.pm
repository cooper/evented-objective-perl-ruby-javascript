# Copyright (c) 2012, Mitchell Cooper
# Type::Class: the base class for all classes.
package EOPRJ::Type::Class;

use warnings;
use strict;
use utf8;

use parent 'EOPRJ::Type::Object';

# creates a new Class object / class.
# this will not really be blessed to this class.
sub construct {
    my ($class, $eoprj, %opts) = @_;
}

# creates a new Class.
sub new {
    my ($package, $eoprj, %opts) = @_;
    my $class = $package->SUPER::new(%opts);

    # add default properties.
    $class->_apply_default_properties($eoprj);
    
    # return the new object.
    return $class;
}

# add the properties that all Objects start out with.
sub _apply_default_properties {
    my ($class, $eoprj) = @_;
    
    
}

1
