package TrainingHackerzlab::Controller::Exakids;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

sub index {
    my $self        = shift;
    my $model       = $self->model->exakids;
    my $to_template = $model->to_template_index;
    $self->stash(
        %{$to_template},
        template => 'exakids/index',
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

sub menu {
    my $self           = shift;
    my $model          = $self->model->exakids;
    my $exa_ids_browse = $self->app->config->{exa_ids_browse};
    my $is_exa_browse  = 0;
    for my $id ( @{$exa_ids_browse} ) {
        next if $self->login_user->id ne $id;
        $is_exa_browse = 1;
    }
    my $exa_ids_browsesp = $self->app->config->{exa_ids_browsesp};
    my $is_exa_browsesp  = 0;
    for my $id ( @{$exa_ids_browsesp} ) {
        next if $self->login_user->id ne $id;
        $is_exa_browsesp = 1;
    }
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
    my $to_template = $model->to_template_menu( $self->login_user->id );
    $self->stash(
        %{$to_template},
        is_exa_browse   => $is_exa_browse,
        is_exa_browsesp => $is_exa_browsesp,
        is_exa          => $is_exa,
        is_exa_sp       => $is_exa_sp,
        is_exakids_menu => 1,
        login_user      => $self->login_user->get_columns,
        template        => 'exakids/menu',
        format          => 'html',
        handler         => 'ep',
    );
    $self->render();
    return;
}

sub ranking {
    my $self        = shift;
    my $model       = $self->model->exakids;
    my $to_template = $model->to_template_ranking( $self->login_user->id );
    $self->stash(
        %{$to_template},
        login_user => $self->login_user->get_columns,
        template   => 'exakids/ranking',
        format     => 'html',
        handler    => 'ep',
    );
    $self->render();
    return;
}

sub edit {
    my $self     = shift;
    my $params   = $self->req->params->to_hash;
    my $model    = $self->model->exakids->req_params($params);
    my $master   = $model->db->master;
    my $template = 'exakids/edit';

    $self->stash(
        login_user => $self->login_user->get_columns,
        template   => $template,
        format     => 'html',
        handler    => 'ep',
    );
    my $edit_user = $self->login_user->get_columns;
    delete $edit_user->{password};
    $self->render_fillin( $template, $edit_user );
    return;
}

sub update {
    my $self     = shift;
    my $params   = $self->req->params->to_hash;
    my $model    = $self->model->auth->req_params($params);
    my $master   = $model->db->master;
    my $template = 'exakids/edit';

    $self->stash(
        login_user => $self->login_user->get_columns,
        format     => 'html',
        handler    => 'ep',
    );

    # DB 存在確認
    my $check = $model->check;

    # ログインIDがない
    if ( $check->{constant} eq $master->auth->constant('NOT_LOGIN_ID') ) {
        $self->stash( msg => $check->{msg} );
        $self->render_fillin( $template, $params );
        return;
    }

    # パスワード違い
    if ( $check->{constant} eq $master->auth->constant('NOT_PASSWORD') ) {
        $self->stash( msg => $check->{msg} );
        $self->render_fillin( $template, $params );
        return;
    }

    # あわせて名前も登録させる
    my $update = $model->update;
    $self->flash( msg => $update->{msg} );
    $self->redirect_to('/exakids/menu');
    return;
}

sub entry {
    my $self = shift;
    return if $self->transition_logged_in;
    my $params      = $self->req->params->to_hash;
    my $model       = $self->model->auth->req_params($params);
    my $exakids     = $self->model->exakids;
    my $to_template = $exakids->to_template_index;
    my $master      = $model->db->master;
    my $template    = 'exakids/index';
    $self->stash(
        %{$to_template},
        format  => 'html',
        handler => 'ep',
    );

    # DB 存在確認
    my $check = $model->check;

    # ログインIDがない
    if ( $check->{constant} eq $master->auth->constant('NOT_LOGIN_ID') ) {
        $self->stash( msg => $check->{msg} );
        $self->render_fillin( $template, $params );
        return;
    }

    # パスワード違い
    if ( $check->{constant} eq $master->auth->constant('NOT_PASSWORD') ) {
        $self->stash( msg => $check->{msg} );
        $self->render_fillin( $template, $params );
        return;
    }

    # あわせて名前も登録させる
    my $update = $model->update;

    # 認証
    $self->session( user => $check->{user}->login_id );
    $self->flash( msg => $check->{msg} );
    $self->redirect_to('/exakids/menu');
    return;
}

sub refresh {
    my $self = shift;
    $self->app->commands->run( 'generate', 'sqlitedb' );
    $self->session( expires => 1 );
    $self->redirect_to('/');
    return;
}

sub user {
    my $self        = shift;
    my $res         = +{ status => 500, };
    my $params      = $self->req->params->to_hash;
    my $exakids     = $self->model->exakids->req_params($params);
    my $to_template = $exakids->to_template_user;
    if ( !$to_template ) {
        $self->render( json => $res );
        return;
    }
    $res = +{ %{$res}, %{$to_template}, };
    $self->render( json => $res );
    return;
}

1;
