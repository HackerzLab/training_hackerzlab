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
    };

    if ( !$user ) {
        $check->{constant} = $master->auth->constant('NOT_LOGIN_ID');
        return $check;
    }

    if ( $user->password ne $params->{password} ) {
        $check->{constant} = $master->auth->constant('NOT_PASSWORD');
        return $check;
    }
    return $check;
}

1;
