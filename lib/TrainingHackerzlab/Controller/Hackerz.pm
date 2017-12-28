package TrainingHackerzlab::Controller::Hackerz;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# トップページ画面 (ログインなし)
sub index {
    my $self = shift;
    return if $self->not_access;
    $self->render(
        template => 'hackerz/index',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

1;
