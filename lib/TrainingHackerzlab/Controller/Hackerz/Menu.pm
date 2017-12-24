package TrainingHackerzlab::Controller::Hackerz::Menu;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# トップページ画面 (ログイン中)
sub index {
    my $self = shift;
    $self->render(
        template => 'hackerz/menu/index',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

1;
