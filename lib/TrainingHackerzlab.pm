package TrainingHackerzlab;
use Mojo::Base 'Mojolicious';
use TrainingHackerzlab::Model;

# This method will run once at server start
sub startup {
    my $self = shift;

    my $mode    = $self->mode;
    my $moniker = $self->moniker;
    my $home    = $self->home;
    my $common  = $home->child( 'etc', "$moniker.common.conf" )->to_string;
    my $conf    = $home->child( 'etc', "$moniker.$mode.conf" )->to_string;

    # 設定ファイル (読み込む順番に注意)
    $self->plugin( Config => +{ file => $common } );
    $self->plugin( Config => +{ file => $conf } );
    my $config = $self->config;

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer') if $config->{perldoc};

    # コマンドをロードするための他の名前空間
    push @{ $self->commands->namespaces }, 'TrainingHackerzlab::Command';

    $self->helper( model =>
            sub { TrainingHackerzlab::Model->new( +{ conf => $config } ); } );

    # ルーティング前に共通して実行
    $self->hook(
        before_dispatch => sub {
            my $c   = shift;
            my $url = $c->req->url;

            # 認証保護されたページ
            if ( $url =~ m{^/hackerz/.+} ) {

                # セッション情報からログイン者の情報を取得
                my $params = +{ login_id => $c->session('user') };
                my $model = $self->model->auth->req_params($params);
                return if $model->session_check;

                # セッション無き場合ログインページへ
                my $master = $model->db->master;
                my $msg    = $master->auth->to_word('NEED_LOGIN');
                $c->flash( msg => $msg );
                $c->redirect_to('/auth');
                return;
            }
        }
    );

    # Router
    my $r = $self->routes;

    # トップページ
    $r->get('/')->to('Hackerz#index');
    $r->get('/hackerz')->to('Hackerz#index');

    # 認証関連
    my $id = [ id => qr/[0-9]+/ ];
    $r->get('/auth/create')->to('Auth#create');
    $r->get( '/auth/:id/edit', $id )->to('Auth#edit');
    $r->get( '/auth/:id',      $id )->to('Auth#show');
    $r->get('/auth')->to('Auth#index');
    $r->get('/auth/logout')->to('Auth#logout');
    $r->post('/auth/login')->to('Auth#login');
    $r->post('/auth/logout')->to('Auth#logout');
    $r->post( '/auth/:id/update', $id )->to('Auth#update');
    $r->post( '/auth/:id/remove', $id )->to('Auth#remove');
    $r->post('/auth')->to('Auth#store');

    # 認証保護されたページ
    # アプリメニュー
    $r->get('/hackerz/menu')->to('Hackerz::Menu#index');
    $r->get('/hackerz/ranking')->to('Hackerz::Ranking#index');

    my $answer = $r->under('/hackerz/answer');
    $answer->get( '/:id/list',   $id )->to('Hackerz::Answer#list');
    $answer->get( '/:id/score',  $id )->to('Hackerz::Answer#score');
    $answer->get( '/:id/result', $id )->to('Hackerz::Answer#result');
    $answer->post('')->to('Hackerz::Answer#store');

    # 各問題画面
    my $question = $r->under('/hackerz/question');
    $question->get( '/:id/:action', $id )->to('Hackerz::Question#');
}

1;
