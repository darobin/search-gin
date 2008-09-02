#!/usr/bin/perl

package Search::GIN::Query::Attributes;
use Moose;

use Carp qw(croak);

use namespace::clean -except => [qw(meta)];

with qw(
    Search::GIN::Query
    Search::GIN::Keys::Deep
);

has attributes => (
    isa => "HashRef",
    is  => "rw",
    required => 1,
);

has compare => (
    isa => "Str|CodeRef",
    is  => "rw",
    default => "compare_naive",
);

sub extract_values {
    my $self = shift;

    return (
        method => "all",
        values => [ $self->process_keys($self->attributes) ],
    );
}

sub consistent {
    my ( $self, $index, $obj ) = @_;

    my $class = ref $obj;

    my $meta = Class::MOP::get_metaclass_by_name($class);

    my $query = $self->attributes;

    my %got;

    foreach my $attr_name ( keys %$query ) {
        my $expected = $query->{$attr_name};

        my $meta_attr = $meta->find_attribute_by_name($attr_name) || return;
        $got{$attr_name} = $meta_attr->get_value($obj);
    }

    my $cmp = $self->compare;

    return $self->$cmp( \%got, $query );
}

sub compare_naive {
    my ( $self, $got, $exp ) = @_;

    return unless keys %$got == keys %$exp;

    foreach my $key ( keys %$exp ) {
        return unless overload::StrVal($got->{$key}) eq overload::StrVal($exp->{$key});
    }

    return 1;
}

sub compare_test_deep {
    my ( $self, $got, $exp ) = @_;

    require Test::Deep::NoTest;
    Test::Deep::NoTest::eq_deeply($got, $exp);
}

# FIXME Data::Compare too

__PACKAGE__->meta->make_immutable;

__PACKAGE__

__END__