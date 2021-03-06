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
        msg      => $master->auth->to_word('IS_LOGOUT'),
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

# ユーザー削除実行
sub remove {
    my $self   = shift;
    my $master = $self->model->auth->db->master;
    if ( $self->req->method eq 'POST' ) {
        my $params = +{ user_id => $self->stash->{id}, };
        my $model = $self->model->auth->req_params($params);

        # 削除対象なしの場合はトップへ
        if ( $model->remove ) {
            $self->session( expires => 1 );
            $self->redirect_to('/auth/remove');
            return;
        }
        $self->flash( msg => $master->auth->to_word('NOT_LOGIN_ID') );
        $self->redirect_to('/');
        return;
    }
    $self->render(
        msg      => $master->auth->to_word('USER_DELETED'),
        template => 'auth/remove',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

# ユーザー新規登録実行
sub store {
    my $self = shift;
    return if $self->transition_logged_in;

    my $params   = $self->req->params->to_hash;
    my $model    = $self->model->auth->req_params($params);
    my $master   = $model->db->master;
    my $template = 'auth/create';

    $self->stash(
        msg     => $master->auth->to_word('HAS_ERROR_INPUT'),
        format  => 'html',
        handler => 'ep',
    );

    # 簡易的なバリデート
    return $self->render_fillin( $template, $params )
        if $model->has_error_easy;

    # DB 登録実行
    my $store = $model->store;

    # ログイン処理
    $self->session( user => $params->{login_id} );

    # 書き込み保存終了、リダイレクトアプリメニューへ
    $self->flash( msg => $store->{msg} );
    $self->redirect_to('/hackerz/menu');
    return;
}

1;
