use utf8;
package Blog::Schema::Result::User;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Blog::Schema::Result::User

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<users>

=cut

__PACKAGE__->table("users");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_nullable: 0

=head2 username

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 password

  data_type: 'char'
  is_nullable: 1
  size: 32

=head2 email

  data_type: 'varchar'
  is_nullable: 1
  size: 50

=head2 first_name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=head2 last_name

  data_type: 'varchar'
  is_nullable: 1
  size: 30

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_nullable => 0 },
  "username",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "password",
  { data_type => "char", is_nullable => 1, size => 32 },
  "email",
  { data_type => "varchar", is_nullable => 1, size => 50 },
  "first_name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
  "last_name",
  { data_type => "varchar", is_nullable => 1, size => 30 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07042 @ 2015-05-05 14:20:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nZCqmEq8sY70omQEj34XnA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;
