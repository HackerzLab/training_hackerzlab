package TrainingHackerzlab::Command::generatemore::sqlitedb;
use Mojo::Base 'Mojolicious::Command';
use File::Temp;
binmode STDIN,  ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';

has description => 'TrainingHackerzlab create database';
has usage => sub { shift->extract_usage };
has [qw{}];

sub run {
    my $self = shift;
    my $conf = $self->app->config;

    # sqlite3 のみ
    die 'not existence database_app' if !$conf->{database_app};
    die 'not support database_app'   if $conf->{database_app} ne 'sqlite';

    # データベースファイル作成
    $self->_create_databese_file;

    # スキーマー更新
    $self->_import_schema;

    # サンプルデータ読み込み
    $self->_import_file_csv;
    return;
}

# データベースファイル作成 (存在しない場合のみ)
sub _create_databese_file {
    my $self = shift;
    my $conf = $self->app->config;
    return if -f $conf->{database_file};
    $self->write_file( $conf->{database_file}, '' );
    return;
}

# スキーマー更新
# 例: sqlite3 ./training_hackerzlab.development.db < ./training_hackerzlab_schema.sql
sub _import_schema {
    my $self   = shift;
    my $conf   = $self->app->config;
    my $db     = $conf->{database_file};
    my $schema = $conf->{schema_file};
    die 'not existence schema file' if !-f $schema;

    # system コマンドは失敗すると true
    my $cmd = "sqlite3 $db < $schema";
    system $cmd and die "Couldn'n run: $cmd ($!)";
    return;
}

# サンプルデータ読み込み
# 例: sqlite3 ./training_hackerzlab.development.db < ./sqlite_cmd.txt
# cat sqlite_cmd.txt
# .separator ,
# .import ./training_hackerzlab/script/../idXrCFxLjl/user.csv user
# (テーブルの数だけ)
sub _import_file_csv {
    my $self = shift;
    my $home = $self->app->home;

    # 一時利用のディレクトリ、利用後消滅
    my $home_path = $home->to_string;
    my $ft        = File::Temp->newdir( DIR => $home_path, CLEANUP => 1 );
    my $ft_dir    = $ft->dirname;

    # sqlite コマンド用ファイルデータ
    my $sqlite_cmd_txt = ".mode csv\n";

    # オリジナルサンプルをコピー
    for my $file_org ( $home->path('db')->list->each ) {

        # .csv の場合だけ
        my $basename = $file_org->basename;
        my $tablename = $file_org->basename( $file_org->to_string, '.csv' );
        next if $basename eq $tablename;

        # カラム情報を削除 (最初の2行不要)
        my $fh = $file_org->open('<');
        my $data;
        while ( my $row = <$fh> ) {
            next if $. <= 2;
            $row =~ s/[\r\n]+//g;
            chomp $row;
            $data .= $row . "\n";
        }

        # インポート用ファイル
        my $filename = Mojo::File->new($ft_dir)->child($basename)->to_string;
        $self->write_file( $filename, $data );
        $sqlite_cmd_txt .= qq{.import $filename $tablename} . "\n";
    }
    my $path_cmd        = Mojo::File->new($ft_dir)->child('sqlite_cmd.txt');
    my $sqlite_cmd_file = $path_cmd->to_string;
    $self->write_file( $sqlite_cmd_file, $sqlite_cmd_txt );

    # 例: sqlite3 ./training_hackerzlab.development.db < ./sqlite_cmd.txt
    my $db  = $self->app->config->{database_file};
    my $cmd = "sqlite3 $db < $sqlite_cmd_file";
    system $cmd and die "Couldn'n run: $cmd ($!)";
    return;
}

1;

__END__

=encoding utf8

=head1 NAME

TrainingHackerzlab::Command::generatemore::sqlitedb - TrainingHackerzlab create sqlite3 database

=head1 SYNOPSIS

  Usage: carton exec -- script/training_hackerzlab generatemore sqlitedb [OPTIONS]

  Options:
    -m, --mode   Does something.

    # 開発用 (mode 指定なし) -> /db/training_hackerzlab.development.db
    $ carton exec -- script/training_hackerzlab generatemore sqlitedb

    # 本番用 -> /db/training_hackerzlab.production.db
    $ carton exec -- script/training_hackerzlab generatemore sqlitedb --mode production

    # テスト用 -> /db/training_hackerzlab.testing.db
    $ carton exec -- script/training_hackerzlab generatemore sqlitedb --mode testing

    # 開発用 -> /db/training_hackerzlab.development.db
    $ carton exec -- script/training_hackerzlab generatemore sqlitedb --mode development

=head1 DESCRIPTION

=cut
