package TrainingHackerzlab::Controller::Hackerz;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# トップページ画面 (ログインなし)
sub index {
    my $self = shift;
    return if $self->transition_logged_in;
    $self->render(
        template => 'hackerz/index',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

1;
