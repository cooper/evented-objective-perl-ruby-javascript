# Copyright (c) 2012, Mitchell Cooper

use warnings;
use strict;
use utf8;
use feature qw(say switch);

use EOPRJ;

my $eoprj  = EOPRJ->new();

# here we ensure that $Array.push is present.

say '$Array                ', my $Array = $eoprj->property('Array');
say '$Array.push           ', $Array->property('push');

# here we check if two different arrays have the same ISA.

my $myArray1 = EOPRJ::Type::Array->new($eoprj);
$eoprj->set_property(myArray => $myArray1);

say '$myArray1.ISA         ', $myArray1->property('ISA');

my $myArray2 = EOPRJ::Type::Array->new($eoprj);
$eoprj->set_property(myArray2 => $myArray2);

say '$myArray2.ISA         ', $myArray2->property('ISA');

# here, make sure $Object.defaultISA is set.

say '$Object               ', $eoprj->{Object};
say '$Object.defaultISA    ', $eoprj->{Object}->property('defaultISA');
say '$Object.defaultNOISA  ', $eoprj->{Object}->property('defaultNOISA');

# here we create two objects, making one inherit from the other to test ISA.

my $object1 = EOPRJ::Type::Object->new($eoprj);
my $object2 = EOPRJ::Type::Object->new($eoprj);
$object1->{name} = 'object1';
$object2->{name} = 'object2';

$object2->set_property(testProperty => EOPRJ::Type::Object->new($eoprj));
$object1->isa_add_object($object2);

say '$object1.testProperty ', $object1->property('testProperty');
say '$object2.testProperty ', $object2->property('testProperty');

# here, we make a third object that inherits from the first object
# (itself inheriting from the second object.)

my $object3 = EOPRJ::Type::Object->new($eoprj);
$object3->{name} = 'object3';

$object3->isa_add_object($object1);

say '$object3.testProperty ', $object3->property('testProperty');

# here, we take it to the next level. we make a fourth object with an ISA containing
# an array that contains $object2's ISA.

my $isa_array = EOPRJ::Type::Array->new($eoprj, array => [$object2->property('ISA')]);
my $object4   = EOPRJ::Type::Object->new($eoprj);
$isa_array->{name} = 'isa_array';
$object4->{name}   = 'object4';

$object4->isa_add_object($isa_array);

say '$object4.testProperty ', $object4->property('testProperty');
