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

            $self->helper( login_user => sub {undef} );

            # 認証保護されたページ
            if ( $url =~ m{^/hackerz/.+} ) {

                # セッション情報からログイン者の情報を取得
                my $params = +{ login_id => $c->session('user') };
                my $model = $self->model->auth->req_params($params);
                if ( my $login_user = $model->session_check ) {
                    $self->helper( login_user => sub {$login_user} );
                    return;
                }

                # セッション無き場合ログインページへ
                my $master = $model->db->master;
                my $msg    = $master->auth->to_word('NEED_LOGIN');
                $c->flash( msg => $msg );
                $c->redirect_to('/auth');
                return;
            }
            if (   ( $url =~ m{^/exakids/.*} )
                && ( $url !~ m{^/exakids/entry.*} ) )
            {
                # セッション情報からログイン者の情報を取得
                my $params = +{ login_id => $c->session('user') };
                my $model = $self->model->auth->req_params($params);
                if ( my $login_user = $model->session_check ) {
                    $self->helper( login_user => sub {$login_user} );
                    return;
                }

                # セッション無き場合ログインページへ
                my $master = $model->db->master;
                my $msg    = $master->auth->to_word('NEED_LOGIN');
                $c->flash( msg => $msg );
                $c->redirect_to('/exakids');
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
    my $id      = [ id      => qr/[0-9]+/ ];
    my $user_id = [ user_id => qr/[0-9]+/ ];
    $r->get('/auth/create')->to('Auth#create');
    $r->get( '/auth/:id/edit', $id )->to('Auth#edit');
    $r->get( '/auth/:id',      $id )->to('Auth#show');
    $r->get('/auth')->to('Auth#index');
    $r->get('/auth/logout')->to('Auth#logout');
    $r->get('/auth/remove')->to('Auth#remove');
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
    $answer->get('/report')->to('Hackerz::Answer#report');
    $answer->get( '/:id/result', $id )->to('Hackerz::Answer#result');
    $answer->post('')->to('Hackerz::Answer#store');

    # 各問題画面
    my $question = $r->under('/hackerz/question');
    $question->get('')->to('Hackerz::Question#index');
    $question->get( '/:id/think', $id )->to('Hackerz::Question#think');
    $question->get( '/:id/survey/:action', $id )
        ->to('Hackerz::Question::Survey#');

    # ヒント開封履歴
    my $hint = $r->under('/hackerz/hint');
    $hint->post('/opened')->to('Hackerz::Hint#opened');

    # 問題集
    my $collected_id = [ collected_id => qr/[0-9]+/, sort_id => qr/[0-9]+/ ];
    my $collected = $r->under('/hackerz/question/collected');
    $collected->get( '/:id', $id )->to('Hackerz::Question::Collected#show');
    $collected->get( '/:collected_id/:sort_id/think', $collected_id )
        ->to('Hackerz::Question::Collected#think');
    $collected->get( '/:collected_id/:sort_id/survey/:action', $collected_id )
        ->to('Hackerz::Question::Survey#');
    $collected->post( '/:collected_id/:sort_id/survey/:action',
        $collected_id )->to('Hackerz::Question::Survey#');

    # exa kids
    my $exa = $r->under('/exakids');
    $exa->get('')->to('Exakids#index');
    $exa->get('/menu')->to('Exakids#menu');
    $exa->get('/:user_id/edit')->to('Exakids#edit');
    $exa->get('/ranking')->to('Exakids#ranking');
    $exa->post('/:user_id/update')->to('Exakids#update');
    $exa->post('/entry')->to('Exakids#entry');
    $exa->post('/refresh')->to('Exakids#refresh');
}

1;
