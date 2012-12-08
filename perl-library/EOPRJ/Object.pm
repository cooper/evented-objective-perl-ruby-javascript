# Copyright (c) 2012, Mitchell Cooper
# Object: the basic object type, which
package EOPRJ::Object;

use warnings;
use strict;
use utf8;

use Scalar::Util 'blessed';

# create a new object.
sub new {
    my ($class, $eoprj, %opts) = @_;
    my $obj = bless { eoprj => $eoprj }, $class;
    $obj->{eoprj} ||= $obj;
    return $obj;
}

# literally redefine the object.
sub redefine {
    # TODO: I'm not sure what I'm going to do yet here.
    # this is the ^$ carat assignment syntax, by the way.
    
    # I do know at least that I will have to replace the properties.
    # then, make sure it is blessed to EOPRJ::Object (and nothing else?)...
    
    # clear the hash.
    #%$obj = ();
    
    # reset blessing.
    #bless $obj, 'EOPRJ::Type::Object'; # or should we use a plain old object?
    
}

# set a property.
# $obj->set_property(someProperty => $someValue)
# where $someValue is either
# a) an EOPRJ::Object (or something that inherits from it)
# b) a code reference that returns an EOPRJ::Object
# returns perl boolean true if set successfully, false otherwise.
sub set_property {
    my ($obj, $prop_name, $value) = @_;
    
    # ensure that it is a valid EOPRJ value.
    if (ref $value ne 'CODE' && !EOPRJ::valid_value($value)) {
        return;
    }
    
    # if we are setting it undefined, that just means we're deleting it.
    if ($value == EOPRJ::undefined()) {
        # XXX: delete method.
        delete $obj->{properties}{$prop_name};
        return 1;
    }
    
    # store the value.
    $obj->{properties}{$prop_name} = $value;
    
    # good.
    return 1;
}

# convenience subroutine creates a code reference property that will automatically load
# this property as soon as it is needed.
# for example, to set an array property,
# $obj->set_property_autoload(myProp => sub { EOPRJ::Type::Array->new($eoprj) })
sub set_property_autoload {
    my ($obj, $prop_name, $code) = @_;
    $obj->set_property($prop_name => sub {
    
        # create the new value.
        my $value = $code->();
        
        # reassign this property to the new value.
        $obj->set_property($prop_name, $value);
        
        # return the value.
        return $value;
        
    });
}

# calls a property. in other words, calls a function or all of the handlers of a method.
sub call_property {
    my ($obj, $prop_name, $scope, $params, $special_vars) = @_;
    my $prop = $obj->property($prop_name);
    return if !$prop || !$prop->{function_code};
    
    # call the function. returns the scope object.
    return EOPRJ::Type::Function::_call_function($prop, $scope || $obj->{eoprj}, $params, $special_vars || {});

}

# $prop_name: a perl string property name.
# returns perl boolean.
# returns true if the object's ISAONLY contains the supplied property name.
sub isaonly_has {
    my ($obj, $prop_name) = @_;return 0; # XXX:contains
    
    # if it has no ISAONLY at all, return.
    return unless my $isaonly = $obj->own_property('ISAONLY');
    return unless $isaonly->is_array;
    
    # ensure that ISAONLY is an array.
    return if !blessed($isaonly) || !$isaonly->isa('EOPRJ::Type::Array');
    
    # return true if it contains this string.
    return $isaonly->contains_string($prop_name)->{result};
    
}

# $prop_name: a perl string property name.
# returns perl boolean.
# returns true if the object's NOISA contains the supplied property name.
sub noisa_has {
    my ($obj, $prop_name) = @_;return 0; # XXX:contains
    
    # if it has no NOISA at all, return.
    return unless my $noisa = $obj->own_property('NOISA');
    return unless $noisa->is_array;
    
    # ensure that NOISA is an array.
    return if !blessed($noisa) || !$noisa->isa('EOPRJ::Type::Array');
    
    # return true if it contains this string.
    return $noisa->contains_string($prop_name)->{result};
    
}


# $object: EOPRJ object.
# returns perl boolean.
# returns true if an object is in ISAIGNORE.
sub isaignore_has {
    my ($obj, $object) = @_;return 0; # XXX:contains

    # if it has no ISAIGNORE at all, return.
    return unless my $isaignore = $obj->own_property('ISAIGNORE');
    return unless $isaignore->is_array;
    
    # ensure that ISAIGNORE is an array.
    return if !blessed($isaignore) || !$isaignore->isa('EOPRJ::Type::Array');
    
    # return true if it contains this string.
    return $isaignore->contains($object)->{result};
        
}

# gets a property, taking both own properties and ISA inheritance into account.
# $prop_name: perl string, the name of the property.
# $root_obj:  an EOPRJ object that will be checked for ISAIGNORE. defaults to $obj.
# returns EOPRJ value if a property is found or EOPRJ::undefined.
sub property {
    my ($obj, $prop_name, $root_obj) = @_;

    # first, see if this object has the property.
    if ((my $value = $obj->own_property($prop_name)) != EOPRJ::undefined()) {
    
        # if it's in ISAONLY, give up here because own property is undesired.
        #return EOPRJ::undefined() if $obj->isaonly_has($prop_name);
        
        # if it's not, we've found our value.
        return _value_of($value);
        
    }
    
    # if it's in NOISA, give up here because we already checked own properties.
    return EOPRJ::undefined() if $obj->noisa_has($prop_name);
    
    # TODO: use getter if one is present.
    
    # second, search ISA.
    return $obj->isa_property($prop_name, $root_obj || $obj);

}

# gets a property from this object only, ignoring all ISA, getters, setters, etc.
# $prop_name: perl string, the name of the property.
# returns EOPRJ value if a property is found or EOPRJ::undefined.
sub own_property {
    my ($obj, $prop_name) = @_;
    
    # no property exists.
    return EOPRJ::undefined() unless defined $obj->{properties}{$prop_name};

    # it exists; return it.
    return _value_of($obj->{properties}{$prop_name});
    
}

# returns EOPRJ boolean true if object has its own property RIGHT NOW
# (autoload / callbacks do not count as having the property right now.)
sub has_own_property_now {
    my ($obj, $prop_name) = @_;
    return EOPRJ::false() unless defined $obj->{properties}{$prop_name};
    return EOPRJ::false() if ref $obj->{properties}{$prop_name} eq 'CODE';
    return EOPRJ::true();
}

# gets a property through ISA.
# $prop_name: perl string, the name of the property.
# $root_obj:  an EOPRJ object that will be checked for ISAIGNORE. defaults to $obj.
# returns EOPRJ value if a property is found or EOPRJ::undefined.
sub isa_property {
    my ($obj, $prop_name, $root_obj) = @_;

    # we're not going to find anything from an object that has no ISA.
    return EOPRJ::undefined() unless my $isa = $obj->own_property('ISA');
    
    # ensure that ISA is an array.
    return EOPRJ::undefined() if !blessed($isa) || !$isa->is_array;
    
    # go through each ISA object.
    my %done;
    foreach my $isa_obj ($isa->flattened_perl_array) {
        next if $isa_obj == $obj;
        
        # we've already checked this object.
        next if $done{$isa_obj};
        $done{$isa_obj} = 1;
        
        # the root object has this in its ISAIGNORE.
        return EOPRJ::undefined() if $root_obj->isaignore_has($isa_obj);
        
        # try to fetch the property from the object.
        my $result = $isa_obj->property($prop_name, $root_obj || $obj);
        
        # it returned an object, so we will use it.
        return _value_of($result) if $result != EOPRJ::undefined();
        
    }
    
    # nothing was returned, so return undefined.
    return EOPRJ::undefined();
    
}


# returns an EOPRJ value or EOPRJ::undefined.
# if a value is a code reference, calls it, then returns its EOPRJ return value.
sub _value_of {
    my $value = shift;
    
    # if it's undefined, true, or false, don't waste our processing power.
    return $value if $value == EOPRJ::undefined();
    return $value if $value == EOPRJ::true();
    return $value if $value == EOPRJ::false();
    
    # first, let's see if this value is an object already.
    if (blessed($value) && $value->isa('EOPRJ::Object')) {
        return $value;
    }

    # second, check if it's a code reference waiting to be called.
    if (ref $value && ref $value eq 'CODE') {
    
        # call it.
        my $result = $value->();
        
        # see if the return value is an object.
        if (blessed($result) && $result->isa('EOPRJ::Object')) {
            return $result;
        }
        
        # it's not an object...
    }
    
    # fallback and return undefined.
    return EOPRJ::undefined();
    
}

###############################
### PERL CLASS TRANSFORMERS ###
###############################

# TODO:  all of these need to actually check if $Whatever is in ISA.

sub is_array {
    return 1 if shift->isa('EOPRJ::Type::Array');
}

sub is_object {
    return 1 if shift->isa('EOPRJ::Type::Object');
}

##############################
### ISA ALTERATION METHODS ###
##############################

# adds an object to ISA, creating a new ISA array if necessary.
# returns Perl 1 if a new array was created, 0 if not.
sub isa_add_object {
    my ($obj, $add_obj) = @_;

    # first, check if the ISA is nonexistent or is a default initial ISA.
    my $currentISA = my $defaultISA = $obj->own_property('ISA');
    if ($defaultISA == EOPRJ::undefined() || $defaultISA->property('defaultClassProperty') != EOPRJ::undefined()) {
        
        # it is. we must create a new ISA array.
        my $array  = $defaultISA != EOPRJ::undefined() ? [$add_obj, $defaultISA] : [$add_obj];
        my $newISA = EOPRJ::Type::Array->new($obj->{eoprj}, array => $array);
        
        # set the new ISA.
        $obj->set_property(ISA => $newISA);
        
        return 1;
    }
    
    # it already exists and is not default. simply push to the array.
    $currentISA->call_property(push => $obj->{eoprj}, { value => $add_obj });
    
    return 0;
}

# adds an object to ISAIGNORE, creating a new ISAIGNORE array if necessary.
# returns Perl 1 if a new array was created, 0 if not.
sub isaignore_add_object {
    my ($obj, $add_obj) = @_;

    # first, check if the ISAIGNORE is nonexistent or is a default initial ISAIGNORE.
    my $currentISAIGNORE = my $defaultISAIGNORE = $obj->own_property('ISAIGNORE');
    if ($defaultISAIGNORE == EOPRJ::undefined() || $defaultISAIGNORE->property('defaultClassProperty') != EOPRJ::undefined()) {
        
        # it is. we must create a new ISAIGNORE array.
        my $array        = $defaultISAIGNORE != EOPRJ::undefined() ? [$add_obj, $defaultISAIGNORE] : [$add_obj];
        my $newISAIGNORE = EOPRJ::Type::Array->new($obj->{eoprj}, array => $array);
        
        # set the new ISA.
        $obj->set_property(ISAIGNORE => $newISAIGNORE);
        
        return 1;
    }
    
    # it already exists and is not default. simply push to the array.
    $currentISAIGNORE->call_property(push => $obj->{eoprj}, { value => $add_obj });
    
    return 0;
}

# adds a property to NOISA, creating a new NOISA array if necessary.
# returns Perl 1 if a new array was created, 0 if not.
sub noisa_add_property {
    my ($obj, $add_prop) = @_;

    # if add_prop is a plain Perl string, turn it into an EOPRJ string.
    if (!ref $add_prop) {
        $add_prop = EOPRJ::Type::String->new($obj->{eoprj}, $add_prop);
    }

    # first, check if the NOISA is nonexistent or is a default initial NOISA.
    my $currentNOISA = my $defaultNOISA = $obj->own_property('NOISA');
    if ($defaultNOISA == EOPRJ::undefined() || $defaultNOISA->property('defaultClassProperty') != EOPRJ::undefined()) {
        
        # it is. we must create a new NOISA array.
        my $array    = $defaultNOISA != EOPRJ::undefined() ? [$add_prop, $defaultNOISA] : [$add_prop];
        my $newNOISA = EOPRJ::Type::Array->new($obj->{eoprj}, array => $array);
        
        # set the new NOISA.
        $obj->set_property(NOISA => $newNOISA);
        
        return 1;
    }
    
    # it already exists and is not default. simply push to the array.
    $currentNOISA->call_property(push => $obj->{eoprj}, { value => $add_prop });
    
    return 0;
}

# adds a property to ISAONLY, creating a new ISAONLY array if necessary.
# returns Perl 1 if a new array was created, 0 if not.
sub isaonly_add_property {
    my ($obj, $add_prop) = @_;

    # if add_prop is a plain Perl string, turn it into an EOPRJ string.
    if (!ref $add_prop) {
        $add_prop = EOPRJ::Type::String->new($obj->{eoprj}, $add_prop);
    }

    # first, check if the ISAONLY is nonexistent or is a default initial ISAONLY.
    my $currentISAONLY = my $defaultISAONLY = $obj->own_property('ISAONLY');
    if ($defaultISAONLY == EOPRJ::undefined() || $defaultISAONLY->property('defaultClassProperty') != EOPRJ::undefined()) {
        
        # it is. we must create a new ISAONLY array.
        my $array      = $defaultISAONLY != EOPRJ::undefined() ? [$add_prop, $defaultISAONLY] : [$add_prop];
        my $newISAONLY = EOPRJ::Type::Array->new($obj->{eoprj}, array => $array);
        
        # set the new ISAONLY.
        $obj->set_property(ISAONLY => $newISAONLY);
        
        return 1;
    }
    
    # it already exists and is not default. simply push to the array.
    $currentISAONLY->call_property(push => $obj->{eoprj}, { value => $add_prop });
    
    return 0;
}

1
