package Mojolicious::Command::generate::doc;
use Mojo::Base 'Mojolicious::Command';
use Mojo::Util qw{class_to_file};

has description => 'Generate create doc';
has usage => sub { shift->extract_usage };
has [qw{}];

sub run {
    my $self = shift;
    my $home = $self->app->home;

    # app 自身のクラス名取得
    die 'Can not get class name!' if $home->path('lib')->list->size ne 1;
    my $appclass = $home->path('lib')->list->first->basename('.pm');
    my $appname  = class_to_file $appclass;

    # doc/deploy.md
    my $deploy_file = 'deploy.md';
    $self->render_to_rel_file( 'deploy', "doc/$deploy_file", $appname );
    return;
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Command::generate::doc - Generate create doc

=head1 SYNOPSIS

  Usage: carton exec -- script/app generate doc [OPTIONS]

  Options:
    -m, --mode   Does something.

    $ carton exec -- script/app generate doc

=head1 DESCRIPTION

=cut

__DATA__

@@ deploy
% my $app = shift;
# NAME

deploy - <%= $app %>

# SYNOPSIS

## CONTRACT

- example
- example
- example

## ADDRESS

- vps: example
- v4: example
- v6: example

## USER

See separately password

```
root
id: example
id: example
```

## UPDATE

1. step
1. step
1. step

```
$ carton exec -- hypnotoad script/<%= $app %>
```

## START

### APP SERVER

```
$ carton exec -- hypnotoad script/<%= $app %>
```

### WEB SERVER

```
# nginx
# nginx -s quit
```

# DESCRIPTION

## OVERALL FLOW

1. step
1. step
1. step

## PREPARE

- example
- example
- example

## SETUP

### STEP - example

__reference link__

- [example](https://example) - example

# TODO

- example

# SEE ALSO

- <http://example> - example
- <http://example> - example
- <http://example> - example
