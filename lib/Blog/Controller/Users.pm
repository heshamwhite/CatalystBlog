package Blog::Controller::Users;
use Moose;
use namespace::autoclean;
use Digest::MD5 qw(md5_hex);

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Blog::Controller::Users - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub login :Local {
     my ($self, $c) = @_;
    	$c->log->debug('*** INSIDE login METHOD hell yea ***');

    # Get the username and password from form
    my $username = $c->request->params->{username};
    my $password = $c->request->params->{password};

    # If the username and password values were found in form
    if ($username && $password) {
        # Attempt to log the user in
        if ($c->authenticate({ username => $username, password => md5_hex($password)  } )) {
            # If successful, then let them use the application
            $c->response->redirect($c->uri_for(
                $c->controller('posts')->action_for('list')));
            return;
        } else {
            # Set an error message
            $c->stash(error_msg => "Bad username or password.");
        }
    } else {
        # Set an error message
        $c->stash(error_msg => "Empty username or password.") unless ($c->user_exists());
    }

    # If either of above don't work out, send to the login page
    $c->stash(template => 'users/login.tt');

}

sub logout :Local {
    my ($self, $c) = @_;

    # Clear the user's state
    $c->logout;

    # Send the user to the starting point
    $c->response->redirect($c->uri_for('/'));
}



sub base :Chained('/') :PathPart('users') :CaptureArgs(0) {
	my ($self, $c) = @_;
	# Store the ResultSet in stash so it's available for other methods
	$c->stash(resultset => $c->model('DB::User'));
	# Print a message to the debug log
	$c->log->debug('*** INSIDE BASE METHOD ***');
}

sub baseRUD :Chained('base') :PathPart('id') :CaptureArgs(1) {
	my ($self, $c, $id) = @_;

	# Store the ResultSet in stash so it's available for other methods
	$c->stash(resultset => $c->model('DB::User'),
				user => $c->stash->{resultset}->find($id)
		);
	# Print a message to the debug log
	$c->log->debug('*** INSIDE BASE METHOD ***');
}	

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Users in Users.');
}

sub list :Local {
    my ( $self, $c ) = @_;
	$c->stash(users =>  [$c->model('DB::User')->all]);
	$c->stash(template => 'users/list.tt');
}

=head2 form_create
Display form to collect information for user to
create
=cut
sub form_new :Chained('base') :PathPart('new') :Args(0) {
	my ($self, $c) = @_;
	# Set the TT template to use
	$c->stash(template => 'users/create.tt');
}

=head2 form_create_do
Take information from form and add to database
=cut
sub form_create_do :Chained('base') :PathPart('save') :Args(0) {
	my ($self, $c) = @_;
	# Retrieve the values from the form
	my $username = $c->request->params->{username} || 'N/A';
	my $email = $c->request->params->{email} || 'N/A';
	my $password= $c->request->params->{password} || 'N/A';
	my $first_name= $c->request->params->{first_name} || 'N/A';
	my $last_name= $c->request->params->{last_name} || 'N/A';

	# Create the user
	my $user = $c->model('DB::User')->create({
	username => $username,
	email => $email,
	password =>  md5_hex($password),
	first_name => $first_name,
	last_name => $last_name
	});
	# Store new model object in stash and set template
	$c->stash(user => $user,
	template => 'users/show.tt');
	#$c->forward('list');

}

=head2 delete
    
    Delete a book
    
=cut

sub show :Chained('baseRUD') :PathPart('show') :Args(0) {
    my ($self, $c) = @_;

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash(template => 'users/show.tt');
}
    
sub delete :Chained('baseRUD') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash->{user}->delete;

    # Set a status message to be displayed at the top of the view
    $c->stash->{status_msg} = "Book deleted.";

    # Forward to the list action/method in this controller
    $c->forward('list');
}

sub edit :Chained('baseRUD') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;
    $c->stash(template => 'users/edit.tt');

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
  
}

sub form_update :Chained('baseRUD') :PathPart('update') :Args(0) {
	my ($self, $c) = @_;
	# Retrieve the values from the form
	my $username = $c->request->params->{username} || 'N/A';
	my $email = $c->request->params->{email} || 'N/A';
	my $password= $c->request->params->{password} || 'N/A';
	my $first_name= $c->request->params->{first_name} || 'N/A';
	my $last_name= $c->request->params->{last_name} || 'N/A';

	# Create the user
	$c->stash->{user}->update({
	username => $username,
	email => $email,
	password =>  md5_hex($password),
	first_name => $first_name,
	last_name => $last_name
	});
	# Store new model object in stash and set template
	$c->stash(	template => 'users/show.tt');
	#$c->forward('list');
}



=encoding utf8

=head1 AUTHOR

haw,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
