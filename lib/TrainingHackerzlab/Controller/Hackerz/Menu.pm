package TrainingHackerzlab::Controller::Hackerz::Menu;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# トップページ画面 (ログイン中)
sub index {
    my $self              = shift;
    my $to_template_index = $self->model->hackerz->menu->to_template_index;
    $self->render(
        %{$to_template_index},
        template => 'hackerz/menu/index',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

1;
