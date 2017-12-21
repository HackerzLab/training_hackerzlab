package TrainingHackerzlab::Controller::Menu;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

sub index {
    my $self = shift;
    $self->render(text => 'index');
}

1;
