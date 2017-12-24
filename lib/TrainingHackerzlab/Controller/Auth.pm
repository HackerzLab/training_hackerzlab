package TrainingHackerzlab::Controller::Auth;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# ユーザー登録画面
sub create {
    my $self = shift;
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
    $self->render( text => 'index' );
    return;
}

# ユーザーログイン実行
sub login {
    my $self = shift;
    $self->render( text => 'login' );
    return;
}

# ユーザーログアウト実行
sub logout {
    my $self = shift;
    $self->render( text => 'logout' );
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
