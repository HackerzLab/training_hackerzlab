package TrainingHackerzlab::Controller::Hackerz::Menu;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# トップページ画面 (ログイン中)
sub index {
    my $self    = shift;
    my $exa_ids = $self->app->config->{exa_ids};
    my $is_exa  = 0;
    for my $id ( @{$exa_ids} ) {
        next if $self->login_user->id ne $id;
        $is_exa = 1;
    }
    my $to_template_index
        = $self->model->hackerz->menu->to_template_index($is_exa);
    $self->render(
        %{$to_template_index},
        is_exa   => $is_exa,
        user     => $self->login_user->get_columns,
        template => 'hackerz/menu/index',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

1;
