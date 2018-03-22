package Mojolicious::Command::generate::etc;
use Mojo::Base 'Mojolicious::Command';
use Mojo::Util qw{class_to_file};

has description => 'Generate create etc';
has usage => sub { shift->extract_usage };
has [qw{}];

sub run {
    my $self = shift;
    my $home = $self->app->home;

    # app 自身のクラス名取得
    die 'Can not get class name!' if $home->path('lib')->list->size ne 1;
    my $appclass = $home->path('lib')->list->first->basename('.pm');
    my $appname  = class_to_file $appclass;

    # etc/nginx.conf
    my $nginx_file = 'nginx.conf';
    $self->render_to_rel_file( 'nginx', "etc/$nginx_file" );

    # etc/app.common.conf ..
    my $modenames = [qw{common development production testing}];
    for my $modename ( @{$modenames} ) {
        my $file = "$appname.$modename.conf";
        $self->render_to_rel_file( 'conf', "etc/$file" );
    }
    return;
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Command::generate::etc - Generate create etc

=head1 SYNOPSIS

  Usage: carton exec -- script/app generate etc [OPTIONS]

  Options:
    -m, --mode   Does something.

    $ carton exec -- script/app generate etc

    # 設定 (config) 一式

=head1 DESCRIPTION

=cut

__DATA__

@@ nginx
# app server
upstream example-app {
  server 127.0.0.1:8080;
}

# http://example.com (http://***.***.***.**:80)
server {
  listen 80;
  server_name example.com;
  location / {
    proxy_pass http://example-app;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
  }
}

# For example, change to an arbitrary name
# example CentOS6
# ln -s /home/example/example/etc/nginx.conf /etc/nginx/conf.d/example.conf

@@ conf
+{};
