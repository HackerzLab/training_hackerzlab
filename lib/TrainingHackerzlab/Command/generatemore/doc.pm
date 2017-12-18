package TrainingHackerzlab::Command::generatemore::doc;
use Mojo::Base 'Mojolicious::Command';
use Mojo::Util qw{dumper class_to_file class_to_path};

has description => 'TrainingHackerzlab create doc';
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

TrainingHackerzlab::Command::generatemore::doc - TrainingHackerzlab create doc

=head1 SYNOPSIS

  Usage: carton exec -- script/training_hackerzlab generatemore doc [OPTIONS]

  Options:
    -m, --mode   Does something.

    $ carton exec -- script/training_hackerzlab generatemore doc

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
