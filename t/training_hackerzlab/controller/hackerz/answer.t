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
        top    => "/",
        list   => "/hackerz/answer/$id/list",
        score  => "/hackerz/answer/$id/score",
        result => "/hackerz/answer/$id/result",
        store  => "/hackerz/answer",
    };
}

subtest 'router' => sub {
    my $url = _url_list(9999);
    $t->ua->max_redirects(1);
    $t->get_ok( $url->{list} )->status_is(200);
    $t->get_ok( $url->{score} )->status_is(200);
    $t->get_ok( $url->{result} )->status_is(200);
    $t->post_ok( $url->{store} )->status_is(200);
    $t->ua->max_redirects(0);
};

# 解答一覧画面
subtest 'get /hackerz/answer/:id/list list' => sub {
    subtest 'template' => sub {
        ok(1);
    };
    subtest 'fail' => sub {
        ok(1);
    };
    subtest 'success' => sub {
        ok(1);
    };
};

# 解答結果画面
subtest 'get /hackerz/answer/:id/score score' => sub {
    subtest 'template' => sub {
        ok(1);
    };
    subtest 'fail' => sub {
        ok(1);
    };
    subtest 'success' => sub {
        ok(1);
    };
};

# 解答を送信したぞ画面
subtest 'get /hackerz/answer/:id/result result' => sub {
    subtest 'template' => sub {
        ok(1);
    };
    subtest 'fail' => sub {
        ok(1);
    };
    subtest 'success' => sub {
        ok(1);
    };
};

# 解答内容送信
subtest 'post /hackerz/answer store' => sub {
    subtest 'template' => sub {
        ok(1);
    };
    subtest 'fail' => sub {
        ok(1);
    };
    subtest 'success' => sub {
        ok(1);
    };
};

done_testing();
