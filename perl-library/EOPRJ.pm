# Copyright (c) 2012, Mitchell Cooper.
package EOPRJ;

use warnings;
use strict;
use parent 'EOPRJ::Scope';

use Scalar::Util 'blessed';

use EOPRJ::Object;

use EOPRJ::Type::Object;
use EOPRJ::Type::Function;
use EOPRJ::Type::String;
use EOPRJ::Type::Array;
use EOPRJ::Type::Hash;

use EOPRJ::Type::Class;
use EOPRJ::Type::Method;

# data type constants.
my ($undefined, $true, $false) = (\'undefined', \'true', \'false');
sub undefined () { $undefined }
sub true      () { $true      }
sub false     () { $false     }

sub new {
    my ($class, %opts) = @_;
    my $eoprj = $class->SUPER::new(undef, %opts);
    
    # create the Object object.
    my $Object = $eoprj->{Object} = EOPRJ::Type::Object->new($eoprj);
    $eoprj->set_property(Object => EOPRJ::Type::Object->construct($eoprj, object => $Object));
    
    # create the Array object.
    my $Array = $eoprj->{Array} = EOPRJ::Type::Object->new($eoprj);
    $eoprj->set_property(Array => EOPRJ::Type::Array->construct($eoprj, object => $Array));
    
    return $eoprj;
}

# returns Perl boolean whether or not a value is a valid EOPRJ value.
sub valid_value {
    my $value = shift;
    
    # if it's one of these non-object values, it's good.
    if ($value == EOPRJ::undefined() || $value == EOPRJ::true() || $value == EOPRJ::false()) {
        return 1;
    }
    
    # if it's an object, it's good.
    if (blessed($value) && $value->isa('EOPRJ::Object')) {
        return 1;
    }
    
    # it is none of these; not good.
    return;
}

1
