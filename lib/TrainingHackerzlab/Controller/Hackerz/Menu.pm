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

    my $exa_ids_sp = $self->app->config->{exa_ids_sp};
    my $is_exa_sp  = 0;
    for my $id ( @{$exa_ids_sp} ) {
        next if $self->login_user->id ne $id;
        $is_exa_sp = 1;
    }

    my $to_template_index
        = $self->model->hackerz->menu->to_template_index( $is_exa,
        $is_exa_sp );
    $self->render(
        %{$to_template_index},
        is_exa    => $is_exa,
        is_exa_sp => $is_exa_sp,
        user      => $self->login_user->get_columns,
        template  => 'hackerz/menu/index',
        format    => 'html',
        handler   => 'ep',
    );
    return;
}

1;
