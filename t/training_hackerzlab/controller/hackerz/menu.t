use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};
use t::Util;

my $test_util = t::Util->new();
my $t         = $test_util->init;

sub _url_list {
    my $id = shift || '';
    return +{
        top       => "/",
        index     => "/hackerz/menu",
        logout    => "/auth/logout",
        ranking   => "/hackerz/ranking",
        report    => "/hackerz/answer/report",
        remove    => "/auth/$id/remove",
        collected => "/hackerz/question/collected/$id",
    };
}

subtest 'router' => sub {
    my $url = _url_list(9999);
    $t->ua->max_redirects(1);
    $t->get_ok( $url->{index} )->status_is(200);
    $t->ua->max_redirects(0);
};

# トップページ画面 (ログイン中)
subtest 'get /hackerz/menu index' => sub {
    subtest 'template' => sub {
        my $user_id = 1;
        $test_util->login( $t, $user_id );

        my $url = _url_list($user_id);
        $t->get_ok( $url->{index} )->status_is(200);

        # 各問題集ボタン
        my $cond = +{ deleted => 0 };
        my @collected_rows
            = $t->app->test_db->teng->search( 'collected', $cond );
        for my $row (@collected_rows) {
            my $url = _url_list( $row->id );
            $t->element_exists("a[href=$url->{collected}]");
        }

        # 総合ランキングボタン
        $t->element_exists("a[href=$url->{ranking}]");

        # 成績一覧ボタン
        $t->element_exists("a[href=$url->{report}]");

        # ログアウトボタン
        my $form
            = "form[name=form_logout][method=post][action=$url->{logout}]";
        $t->element_exists($form);
        $t->element_exists("$form button[type=submit]");

        # 登録情報削除ボタン
        $form = "form[name=form_remove][method=post][action=$url->{remove}]";
        $t->element_exists($form);
        $t->element_exists("$form button[type=submit]");

        $test_util->logout($t);
    };
    subtest 'fail' => sub {
        my $master = $t->app->test_db->master;
        my $msg    = $master->auth->to_word('NEED_LOGIN');
        my $url    = _url_list();
        $t->get_ok( $url->{index} )->status_is(302);
        my $location_url = $t->tx->res->headers->location;
        $t->get_ok($location_url)->status_is(200);

        # 失敗時の画面
        $t->content_like(qr{\Q<b>$msg</b>\E});
    };
    subtest 'success' => sub {
        ok(1);
    };
};

done_testing();
