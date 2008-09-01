#!/usr/bin/perl

package Search::GIN::Extract::Class;
use Moose::Role;

use MRO::Compat;

use namespace::clean -except => [qw(meta)];

with qw(
    Search::GIN::Core
    Search::GIN::Keys::Deep
);

sub extract_values {
    my ( $self, $obj, @args ) = @_;

    my $class = ref $obj;

    my $isa = $class->mro::get_linear_isa();

    my $meta = Class::MOP::get_metaclass_by_name($class);
    my @roles = $meta && $meta->can("calculate_all_roles") ? $meta->calculate_all_roles : ();

    return $self->process_keys({
        blessed => $class,
        class   => $isa,
        does    => \@roles,
    });
}

__PACKAGE__

__END__

=pod

=head1 NAME

Search::GIN::Extract::Class - 

=head1 SYNOPSIS

	use Search::GIN::Extract::Class;

=head1 DESCRIPTION

=cut

