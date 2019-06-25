package TrainingHackerzlab::Model::Auth;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};

# 簡易的なバリデート
sub has_error_easy {
    my $self   = shift;
    my $params = $self->req_params;
    return 1 if !$params->{login_id};
    return 1 if !$params->{password};
    return 1 if !$params->{name};

    # 二重登録防止
    my $cond = +{
        login_id => $params->{login_id},
        deleted  => $self->db->master->deleted->constant('NOT_DELETED'),
    };
    my $user = $self->db->teng->single( 'user', $cond );
    return 1 if $user;
    return;
}

# 削除
sub remove {
    my $self = shift;
    my $cond = +{
        id      => $self->req_params->{user_id},
        deleted => $self->db->master->deleted->constant('NOT_DELETED'),
    };
    my $user = $self->db->teng->single( 'user', $cond );

    # 存在確認
    return if !$user;

    # 関連情報も全て削除
    my $txn = $self->db->teng->txn_scope;
    $user->soft_delete;
    $txn->commit;
    return 1;
}

# 登録実行
sub store {
    my $self   = shift;
    my $master = $self->db->master;

    my $user_params = +{
        login_id => $self->req_params->{login_id},
        password => $self->req_params->{password},
        name     => $self->req_params->{name},
        approved => $master->approved->constant('APPROVED'),
        deleted  => $master->deleted->constant('NOT_DELETED'),
    };
    my $user_id = $self->db->teng_fast_insert( 'user', $user_params );

    my $store = +{
        user_id => $user_id,
        msg     => $master->auth->to_word('DONE_ENTRY'),
    };
    return $store;
}

# 更新(エクサキッズ拡張用)
sub update {
    my $self        = shift;
    my $master      = $self->db->master;
    my $user_params = +{
        password => $self->req_params->{password} || '',
        name     => $self->req_params->{name}     || '',
    };
    my $update_cond = +{ id => $self->req_params->{user_id} };

    # login_id 指定時
    if ( exists $self->req_params->{login_id} ) {
        delete $update_cond->{id};
        $update_cond->{login_id} = $self->req_params->{login_id};
    }
    my $update_id
        = $self->db->teng_update( 'user', $user_params, $update_cond );
    my $update = +{
        user_id => $update_id,
        msg     => $master->auth->to_word('DONE_ENTRY'),
    };
    return $update;
}

# DB 認証
sub check {
    my $self   = shift;
    my $master = $self->db->master;
    my $params = $self->req_params;
    my $cond   = +{
        login_id => $params->{login_id},
        deleted  => $master->deleted->constant('NOT_DELETED'),
    };

    # user_id の指定がされている場合はそちらで検索
    if ( exists $params->{user_id} ) {
        delete $cond->{login_id};
        $cond->{id} = $params->{user_id};
    }

    my $user = $self->db->teng->single( 'user', $cond );
    my $check = +{
        user     => $user,
        constant => $master->auth->constant('IS_LOGIN'),
        msg      => $master->auth->to_word('IS_LOGIN'),
    };

    if ( !$user ) {
        $check->{constant} = $master->auth->constant('NOT_LOGIN_ID');
        $check->{msg}      = $master->auth->to_word('NOT_LOGIN_ID');
        return $check;
    }

    if ( $user->password ne $params->{password} ) {
        $check->{constant} = $master->auth->constant('NOT_PASSWORD');
        $check->{msg}      = $master->auth->to_word('NOT_PASSWORD');
        return $check;
    }
    return $check;
}

# セッション用確認
sub session_check {
    my $self   = shift;
    my $params = $self->req_params;
    my $cond   = +{
        login_id => $params->{login_id},
        deleted  => $self->db->master->deleted->constant('NOT_DELETED'),
    };
    my $user = $self->db->teng->single( 'user', $cond );
    return $user if $user;
    return;
}

1;
