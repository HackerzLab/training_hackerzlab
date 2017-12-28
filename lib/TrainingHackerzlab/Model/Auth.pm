package TrainingHackerzlab::Model::Auth;
use Mojo::Base 'TrainingHackerzlab::Model::Base';
use Mojo::Util qw{dumper};

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
