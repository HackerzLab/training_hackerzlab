package TrainingHackerzlab::Command::generatemore::mvc;
use Mojo::Base 'Mojolicious::Command';
use Mojo::Util qw{dumper class_to_file class_to_path};

has description => 'TrainingHackerzlab create mvc';
has usage => sub { shift->extract_usage };
has [qw{}];

sub run {
    my $self        = shift;
    my @class_names = @_;
    my $home        = $self->app->home;

    my $error_msg
        = 'Your application name has to be a well formed (CamelCase) Perl module name like "MyApp". ';
    for my $name (@class_names) {
        next if $name =~ /^[A-Z](?:\w|::)+$/;
        $error_msg = "Your input name [$name] ?\n" . $error_msg;
        die $error_msg;
    }

    # app 自身のクラス名取得
    die 'Can not get class name!' if $home->path('lib')->list->size ne 1;
    my $appclass = $home->path('lib')->list->first->basename('.pm');

    # Controller Base
    my $controller_base      = join '::', $appclass, 'Controller', 'Base';
    my $controller_base_file = class_to_path $controller_base;
    my $controller_base_args = +{
        class   => $controller_base,
        appname => $appclass,
    };

    $self->render_to_rel_file( 'controller_base', "lib/$controller_base_file",
        $controller_base_args );

    # Model Base
    my $model_base      = join '::', $appclass, 'Model', 'Base';
    my $model_base_file = class_to_path $model_base;
    my $model_base_args = +{
        class   => $model_base,
        appname => $appclass,
    };

    $self->render_to_rel_file( 'model_base', "lib/$model_base_file",
        $model_base_args );

    # DB Base
    my $db_base      = join '::', $appclass, 'DB', 'Base';
    my $db_base_file = class_to_path $db_base;
    my $db_base_args = +{
        class   => $db_base,
        appname => $appclass,
    };

    $self->render_to_rel_file( 'db_base', "lib/$db_base_file",
        $db_base_args );

    # Model.pm
    my $model_pm      = join '::', $appclass, 'Model';
    my $model_pm_file = class_to_path $model_pm;
    my $model_pm_args = +{
        class   => $model_pm,
        appname => $appclass,
    };

    $self->render_to_rel_file( 'model_pm', "lib/$model_pm_file",
        $model_pm_args );

    # DB.pm
    my $db_pm      = join '::', $appclass, 'DB';
    my $db_pm_file = class_to_path $db_pm;
    my $db_pm_args = +{
        class   => $db_pm,
        appname => $appclass,
    };

    $self->render_to_rel_file( 'db_pm', "lib/$db_pm_file", $db_pm_args );

    # Master.pm
    my $master_pm      = join '::', $appclass, 'DB', 'Master';
    my $master_pm_file = class_to_path $master_pm;
    my $master_pm_args = +{
        class   => $master_pm,
        appname => $appclass,
    };

    $self->render_to_rel_file( 'master_pm', "lib/$master_pm_file",
        $master_pm_args );

    # Util.pm
    my $util_pm      = join '::', $appclass, 'Util';
    my $util_pm_file = class_to_path $util_pm;
    my $util_pm_args = +{
        class   => $util_pm,
        appname => $appclass,
    };

    $self->render_to_rel_file( 'util_pm', "lib/$util_pm_file",
        $util_pm_args );

    # t::Util.pm
    my $t_util_pm      = join '::', 't', 'Util';
    my $t_util_pm_file = class_to_path $t_util_pm;
    my $t_util_pm_args = +{
        class   => $t_util_pm,
        appname => $appclass,
    };

    $self->render_to_rel_file( 't_util_pm', $t_util_pm_file,
        $t_util_pm_args );

    # t::app.t
    my $t_app_t_name = class_to_file $appclass;
    my $t_app_t_file = $t_app_t_name . '.t';
    $self->render_to_rel_file( 'test', "t/$t_app_t_file" );

    # db/app_schema.sql
    my $sql_name = class_to_file $appclass;
    my $sql_file = $sql_name . '_schema.sql';
    $self->render_to_rel_file( 'sql', "db/$sql_file" );

    # Controller
    my $controller      = join '::', $appclass, 'Controller', @class_names;
    my $controller_file = class_to_path $controller;
    my $controller_args = +{
        class   => $controller,
        appname => $appclass,
    };

    $self->render_to_rel_file( 'controller', "lib/$controller_file",
        $controller_args );

    # Test
    my @test_names = split '::', $controller;
    for my $name (@test_names) {
        $name = class_to_file $name;
    }
    my $test_name = join '/', @test_names;
    my $test_file = $test_name . '.t';
    $self->render_to_rel_file( 'test', "t/$test_file" );

    # Templates
    my @templates_names;
    for my $name (@class_names) {
        push @templates_names, class_to_file $name;
    }
    push @templates_names, 'index';
    my $templates_name = join '/', @templates_names;
    my $templates_file = $templates_name . '.html.ep';
    $self->render_to_rel_file( 'index', "templates/$templates_file" );

    # Model
    my $model      = join '::', $appclass, 'Model', @class_names;
    my $model_file = class_to_path $model;
    my $model_args = +{
        class   => $model,
        appname => $appclass,
    };
    $self->render_to_rel_file( 'model', "lib/$model_file", $model_args );

    # Doc
    my @doc_names = split '::', $controller;
    for my $name (@doc_names) {
        $name = class_to_file $name;
    }
    my $doc_name = join '/', @doc_names;
    my $doc_file = $doc_name . '.md';
    my $doc_args = +{
        name       => $doc_name,
        appname    => $appclass,
        controller => $controller_file,
        model      => $model_file,
        templates  => $templates_file,
        test       => $test_file,
    };
    $self->render_to_rel_file( 'doc', "doc/$doc_file", $doc_args );
    return;
}

1;

=encoding utf8

=head1 NAME

TrainingHackerzlab::Command::generatemore::mvc - TrainingHackerzlab mvc

=head1 SYNOPSIS

  Usage: carton exec -- script/training_hackerzlab generatemore mvc [OPTIONS]

  Options:
    -m, --mode   Does something.

    # コントローラ, モデル, テンプレート, テストコードが作成
    # package TrainingHackerzlab::Controller::Auth::Test; の場合
    $ carton exec -- script/training_hackerzlab generatemore mvc Auth Test

=head1 DESCRIPTION

=cut

__DATA__

@@ controller_base
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base 'Mojolicious::Controller';

1;

@@ model_base
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -base;
use <%= $args->{appname} %>::DB;

has [qw{conf req_params}];

has db => sub {
    <%= $args->{appname} %>::DB->new( +{ conf => shift->conf } );
};

1;

@@ db_base
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -base;

has [qw{conf}];

1;

@@ model_pm
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base '<%= $args->{appname} %>::Model::Base';

# add method
# use <%= $args->{appname} %>::Model::Example;
# has example => sub {
#     <%= $args->{appname} %>::Model::Example->new( +{ conf => shift->conf } );
# };

# add helper method
# package <%= $args->{appname} %>;
# use Mojo::Base 'Mojolicious';
# use <%= $args->{appname} %>::Model;
#
# sub startup {
#    my $self = shift;
#    ...
#    my $config = $self->config;
#    $self->helper(
#        model => sub { <%= $args->{appname} %>::Model->new( +{ conf => $config } ); } );
#    ...
# }

1;

@@ db_pm
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base '<%= $args->{appname} %>::DB::Base';
use <%= $args->{appname} %>::DB::Master;

has master => sub { <%= $args->{appname} %>::DB::Master->new(); };

1;

@@ master_pm
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -base;

has [qw{master_hash master_constant_hash}];

sub deleted {
    my $self = shift;
    my $hash = +{
        0 => 'not_deleted',
        1 => 'deleted',
    };

    my $constant = +{
        NOT_DELETED => 0,
        DELETED     => 1,
    };

    $self->master_hash($hash);
    $self->master_constant_hash($constant);
    return $self;
}

# my $word = 'deleted';
# my $deleted_id = $master->deleted->word_id($word);
sub word_id {
    my $self = shift;
    my $word = shift;
    my $word_id;
    while ( my ( $key, $val ) = each %{ $self->master_hash } ) {
        $word_id = $key;
        return $word_id if $val eq $word;
    }
    die 'error master methode word_id: ';
}

# my $word_id = 5;
# my $deleted_word = $master->deleted->word($word_id);
sub word {
    my $self    = shift;
    my $word_id = shift;
    my $word    = $self->master_hash->{$word_id};
    die 'error master methode word: ' if !defined $word;
    return $word;
}

# my $label = 'DELETED';
# my $deleted_constant = $master->deleted->constant($label);
sub constant {
    my $self     = shift;
    my $label    = shift;
    my $constant = $self->master_constant_hash->{$label};
    die 'error master methode constant: ' if !defined $constant;
    return $constant;
}

# my $constant = 5;
# my $deleted_label = $master->deleted->label($constant);
sub label {
    my $self     = shift;
    my $constant = shift;
    my $label;
    while ( my ( $key, $val ) = each %{ $self->master_constant_hash } ) {
        $label = $key;
        return $label if $val eq $constant;
    }
    die 'error master methode constant: ';
}

# +{  0 => 'not_deleted',
#     1 => 'deleted',
# };
# my $deleted_to_hash = $master->deleted->to_hash;
sub to_hash {
    my $self = shift;
    my $hash = $self->master_hash;
    my @keys = keys %{$hash};
    die 'error master methode to_hash: ' if !scalar @keys;
    return $hash;
}

# [ 0, 1 ];
# my $deleted_to_ids = $master->deleted->to_ids;
sub to_ids {
    my $self = shift;
    my $hash = $self->master_hash;
    my @keys = keys %{$hash};
    die 'error master methode to_ids: ' if !scalar @keys;
    my @sort_keys = sort { $a <=> $b } @keys;
    return \@sort_keys;
}

# [
#     +{ id => 0, name => 'not_deleted', },
#     +{ id => 1, name => 'deleted', },
# ]
# my $deleted_sort_to_hash = $master->deleted->sort_to_hash;
sub sort_to_hash {
    my $self = shift;
    my $hash = $self->master_hash;
    my @keys = keys %{$hash};
    die 'error master methode sort_to_hash: ' if !scalar @keys;
    my @sort_keys = sort { $a <=> $b } @keys;
    my $sort_hash;
    for my $key (@sort_keys) {
        push @{$sort_hash}, +{ id => $key, name => $hash->{$key} };
    }
    return $sort_hash;
}

1;

@@ util_pm
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -base;
use Time::Piece;
use Exporter 'import';
our @EXPORT_OK = qw{
    now_datetime
};

# use <%= $args->{appname} %>::Util qw{now_datetime};
#
# '2017-11-11 13:43:10'
# my $datatime = now_datetime();
sub now_datetime {
    my $t    = localtime;
    my $date = $t->date;
    my $time = $t->time;
    return "$date $time";
}

1;

@@ t_util_pm
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base -base;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};
use <%= $args->{appname} %>::DB;

sub init {
    my $self = shift;
    $ENV{MOJO_MODE} = 'testing';
    my $t = Test::Mojo->new('<%= $args->{appname} %>');
    die 'not testing mode' if $t->app->mode ne 'testing';

    # test DB
    # $t->app->commands->run('generatemore', 'sqlitedb');
    # $t->app->helper(
    #     test_db => sub { <%= $args->{appname} %>::DB->new( +{ conf => $t->app->config } ) }
    # );
    return $t;
}

1;

@@ sql
DROP TABLE IF EXISTS user;
CREATE TABLE user (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    login_id        TEXT,
    password        TEXT,
    approved        INTEGER,
    deleted         INTEGER,
    created_ts      TEXT,
    modified_ts     TEXT
);

@@ controller
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base '<%= $args->{appname} %>::Controller::Base';

sub index {
    my $self = shift;
    $self->render(text => 'index');
}

1;

@@ test
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Mojo::Util qw{dumper};
use t::Util;

my $test_util = t::Util->new();
my $t         = $test_util->init;

ok(1);

done_testing();

@@ index
%% layout '';
%% title '';

@@ model
% my $args = shift;
package <%= $args->{class} %>;
use Mojo::Base '<%= $args->{appname} %>::Model::Base';

sub index {
    my $self = shift;
    return;
}

1;

@@ doc
% my $args = shift;
# NAME

<%= $args->{name} %> - <%= $args->{appname} %>

# SYNOPSIS

## URL

# DESCRIPTION

# TODO

```
- GET - `/example/create` - create
- GET - `/example/search` - search
- GET - `/example` - index
- GET - `/example/:id/edit` - edit
- GET - `/example/:id` - show
- POST - `/example` - store
- POST - `/example/:id/update` - update
- POST - `/example/:id/remove` - remove
```

# SEE ALSO

- `lib/<%= $args->{controller} %>` -
- `lib/<%= $args->{model} %>` -
- `templates/<%= $args->{templates} %>` -
- `t/<%= $args->{test} %>` -
