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

# DB 認証
sub check {
    my $self   = shift;
    my $master = $self->db->master;
    my $params = $self->req_params;
    my $cond   = +{
        login_id => $params->{login_id},
        deleted  => $master->deleted->constant('NOT_DELETED'),
    };
    my $user = $self->db->teng->single( 'user', $cond );
    my $check = +{
        user     => $user,
        constant => $master->auth->constant('IS_LOGIN'),
        msg => $master->auth->word( $master->auth->constant('IS_LOGIN') ),
    };

    if ( !$user ) {
        my $constant = $master->auth->constant('NOT_LOGIN_ID');
        $check->{constant} = $constant;
        $check->{msg}      = $master->auth->word($constant);
        return $check;
    }

    if ( $user->password ne $params->{password} ) {
        my $constant = $master->auth->constant('NOT_PASSWORD');
        $check->{constant} = $constant;
        $check->{msg}      = $master->auth->word($constant);
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
