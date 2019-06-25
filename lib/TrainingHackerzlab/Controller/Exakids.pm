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
    my $self        = shift;
    my $model       = $self->model->exakids;
    my $to_template = $model->to_template_menu;
    $self->stash(
        %{$to_template},
        template => 'exakids/menu',
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

sub entry {
    my $self = shift;
    return if $self->transition_logged_in;
    my $params   = $self->req->params->to_hash;
    my $model    = $self->model->auth->req_params($params);
    my $master   = $model->db->master;
    my $template = 'exakids/index';

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

    # あわせて名前も登録させる
    my $update = $model->update;

    # 認証
    $self->session( user => $check->{user}->login_id );
    $self->flash( msg => $check->{msg} );
    $self->redirect_to('/exakids/menu');
    return;
}

1;
