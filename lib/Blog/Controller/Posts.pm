package Blog::Controller::Posts;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller'; }

=head1 NAME

Blog::Controller::Posts - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Blog::Controller::Posts in Posts.');
}

sub base :Chained('/') :PathPart('posts') :CaptureArgs(0) {
	my ($self, $c) = @_;
	# Store the ResultSet in stash so it's available for other methods
	$c->stash(resultset => $c->model('DB::Post'));
	# Print a message to the debug log
	$c->log->debug('*** INSIDE BASE METHOD ***');
}

sub baseRUD :Chained('base') :PathPart('id') :CaptureArgs(1) {
	my ($self, $c, $id) = @_;

	# Store the ResultSet in stash so it's available for other methods
	$c->stash(resultset => $c->model('DB::Post'),
				post => $c->stash->{resultset}->find($id)
		);
	# Print a message to the debug log
	$c->log->debug('*** INSIDE BASE METHOD ***');
}	

sub list :Local {
    my ( $self, $c ) = @_;
	$c->stash(posts =>  [$c->model('DB::Post')->all]);
	$c->stash(template => 'posts/list.tt');
}

sub show :Chained('baseRUD') :PathPart('show') :Args(0) {
    my ($self, $c) = @_;
    my $myid = $c->stash->{post}->id;
    my @comments = $c->model( 'DB::Comment' )->search(  { post_id => $myid } );
    $c->log->debug(@comments);

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash(template => 'posts/show.tt',
    		comments => [@comments]
    	);
}

sub addcomment :Chained('baseRUD') :PathPart('addcomment') :Args(0) {
    my ($self, $c) = @_;
    my $myid = $c->stash->{post}->id;

	my $body = $c->request->params->{body} || 'N/A';
	# Create the comment
	my $comment = $c->model('DB::Comment')->create({
	body => $body,
	user_id =>  $c->user->get("id"),
	post_id =>  $myid
	});
	# Store new model object in stash and set template
    my @comments = $c->model( 'DB::Comment' )->search( { post_id => $myid } );

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash(template => 'posts/show.tt',
    		comments => [@comments]
    	);
}

sub deletecomment :Chained('baseRUD') :PathPart('deletecomment') :Args(1) {
    my ($self, $c, $commentid) = @_;

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
	my $comment = $c->model('DB::Comment')->find($commentid);
    $comment->delete;
   	my @comments = $c->model( 'DB::Comment' )->search( { post_id => $c->stash->{post}->id } );

    # Set a status message to be displayed at the top of the view
    $c->stash->{status_msg} = "comment deleted.";

    # Forward to the list action/method in this controller
   	$c->stash(	template => 'posts/show.tt',
   				comments => [@comments]);

}
sub editcomment :Chained('baseRUD') :PathPart('editcomment') :Args(1) {
    my ($self, $c, $commentid) = @_;

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
	my $comment = $c->model('DB::Comment')->find($commentid);
   	$c->stash(template => 'posts/editcomment.tt',
   			  comment  => $comment );

}
sub updatecomment :Chained('baseRUD') :PathPart('updatecomment') :Args(1) {
    my ($self, $c, $commentid) = @_;

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
	my $comment = $c->model('DB::Comment')->find($commentid);
	my $body = $c->request->params->{body} || 'N/A';

	$comment->update({ body => $body });
	my @comments = $c->model( 'DB::Comment' )->search( { post_id => $c->stash->{post}->id } );

	# Store new model object in stash and set template
	$c->stash(	template => 'posts/show.tt',
				comments => [@comments]);

}        
sub delete :Chained('baseRUD') :PathPart('delete') :Args(0) {
    my ($self, $c) = @_;

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
    $c->stash->{post}->delete;

    # Set a status message to be displayed at the top of the view
    $c->stash->{status_msg} = "post deleted.";

    # Forward to the list action/method in this controller
    $c->forward('list');
}

sub edit :Chained('baseRUD') :PathPart('edit') :Args(0) {
    my ($self, $c) = @_;
    $c->stash(template => 'posts/edit.tt');

    # Use the book object saved by 'object' and delete it along
    # with related 'book_author' entries
  
}

sub form_new :Chained('base') :PathPart('new') :Args(0) {
	my ($self, $c) = @_;
	# Set the TT template to use
	$c->stash(template => 'posts/create.tt');
}

=head2 form_create_do
Take information from form and add to database
=cut
sub form_create_do :Chained('base') :PathPart('save') :Args(0) {
	my ($self, $c) = @_;
	# Retrieve the values from the form
	my $title = $c->request->params->{title} || 'N/A';
	my $body = $c->request->params->{body} || 'N/A';

	# Create the user
	my $post = $c->model('DB::Post')->create({
	title => $title,
	body => $body,
	user_id =>  $c->user->get("id")
	});
	# Store new model object in stash and set template
	$c->stash(post => $post,
	template => 'posts/show.tt');
	#$c->forward('list');

}
sub form_update :Chained('baseRUD') :PathPart('update') :Args(0) {
	my ($self, $c) = @_;
	# Retrieve the values from the form
	my $title = $c->request->params->{title} || 'N/A';
	my $body = $c->request->params->{body} || 'N/A';

	# Create the user
	$c->stash->{post}->update({
	title => $title,
	body => $body
	});
	# Store new model object in stash and set template
	$c->stash(	template => 'posts/show.tt');
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
