package TrainingHackerzlab::Controller::Auth;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# ユーザー登録画面
sub create {
    my $self = shift;
    return if $self->transition_logged_in;
    $self->render(
        template => 'auth/create',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

# ユーザーパスワード変更画面 (未実装)
sub edit {
    my $self = shift;
    $self->render( text => 'edit' );
    return;
}

# ユーザー情報詳細 (未実装)
sub show {
    my $self = shift;
    $self->render( text => 'show' );
    return;
}

# ログイン入力画面
sub index {
    my $self = shift;
    return if $self->transition_logged_in;
    $self->render(
        template => 'auth/index',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

# ユーザーログイン実行
sub login {
    my $self = shift;
    return if $self->transition_logged_in;
    my $params   = $self->req->params->to_hash;
    my $model    = $self->model->auth->req_params($params);
    my $master   = $model->db->master;
    my $template = 'auth/index';

    $self->stash(
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

    # 認証
    $self->session( user => $params->{login_id} );
    $self->flash( msg => $check->{msg} );
    $self->redirect_to('/hackerz/menu');
    return;
}

# ユーザーログアウト画面
sub logout {
    my $self = shift;

    # ユーザーログアウト実行
    if ( $self->req->method eq 'POST' ) {
        $self->session( expires => 1 );
        $self->redirect_to('/auth/logout');
        return;
    }
    my $master = $self->model->auth->db->master;
    $self->render(
        msg => $master->auth->word( $master->auth->constant('IS_LOGOUT') ),
        template => 'auth/logout',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

# ユーザーパスワード変更実行 (未実装)
sub update {
    my $self = shift;
    $self->render( text => 'update' );
    return;
}

# ユーザー削除実行 (未実装)
sub remove {
    my $self = shift;
    $self->render( text => 'remove' );
    return;
}

# ユーザー新規登録実行
sub store {
    my $self = shift;
    $self->render( text => 'store' );
    return;
}

1;
