# Copyright (c) 2012, Mitchell Cooper

# Type::Object: the extended object, which implements a few methods.
package EOPRJ::Type::Object;

use warnings;
use strict;
use utf8;

use parent 'EOPRJ::Object';

# creates a new Object.
sub new {
    my ($class, $eoprj, %opts) = @_;
    my $obj = $class->SUPER::new($eoprj, %opts);

    # add default properties.
    $obj->_apply_default_properties($eoprj);
    
    # set the *ISA* variables to their default values.
    $obj->set_property(ISA   => sub { $eoprj->{Object}->own_property('defaultISA')   });
    $obj->set_property(NOISA => sub { $eoprj->{Object}->own_property('defaultNOISA') });
    
    # set isRegisteredObject property to true.
    $obj->set_property(isRegisteredObject => EOPRJ::true());
    
    # return the new object.
    return $obj;
}

# creates a new Object object / class.
# this will not really be blessed to this class.
sub construct {
    my ($class, $eoprj, %opts) = @_;
    my $Object = $opts{object} || EOPRJ::Type::Object->new($eoprj, %opts);
    
    my @insta_methods = qw();
    my @class_methods = qw();
    # multiaccessible = qw(isRegisteredObject);
    
    my $instanceMethods = EOPRJ::Type::Array->new($eoprj, array => \@insta_methods);
    my    $classMethods = EOPRJ::Type::Array->new($eoprj, array => \@class_methods);
    
    ## $array.push($value: Object)
    #$Array->set_property_autoload(push => sub {
    #    EOPRJ::Type::Function->new($eoprj, code => \&_push);
    #});
    
    # create instanceMethods and classMethods.
    $Object->set_property( instanceMethods => EOPRJ::Type::Array->new($eoprj, array => \@insta_methods) );
    $Object->set_property(    classMethods => EOPRJ::Type::Array->new($eoprj, array => \@class_methods) );
    
    # create ISAONLY, properties only accessible through ISA inheritance.
    $Object->set_property(ISAONLY => EOPRJ::Type::Array->new($eoprj, array => [$instanceMethods]));
    
    # create defaultISA, defaultNOISA.
    $Object->set_property(defaultISA   => EOPRJ::Type::Array->new($eoprj, array => [$Object]));
    $Object->set_property(defaultNOISA => EOPRJ::Type::Array->new($eoprj, array => [$classMethods]));
    
    # set each of the above values' defaultClassProperty property to true.
    $Object->own_property( 'defaultISA' )->set_property(defaultClassProperty => EOPRJ::true());
    $Object->own_property('defaultNOISA')->set_property(defaultClassProperty => EOPRJ::true());
    
    return $Object;
}

# add the properties that all Objects start out with.
sub _apply_default_properties {
    my ($obj, $eoprj) = @_;
    
    # in each of these, we use code references that generate them as they are accessed.
    
    # create empty arrays for ISA, NOISA, and ISAIGNORE.
    #foreach my $prop (qw|ISA NOISA ISAIGNORE|) {
    #    $obj->set_property_autoload($prop, sub {
    #        EOPRJ::Type::Array->new($eoprj, array => delete $obj->{"initial_$prop"} || [])
    #    });
    #}
    
    # create empty hashes for GETTERS and SETTERS.
    #foreach my $prop (qw|GETTERS SETTERS|) {
    #    $obj->set_property_autoload($prop, sub { EOPRJ::Type::Hash->new($eoprj) });
    #}
    
}

1
