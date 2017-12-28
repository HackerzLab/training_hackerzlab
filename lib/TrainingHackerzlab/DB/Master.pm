package TrainingHackerzlab::DB::Master;
use Mojo::Base -base;

has [qw{master_hash master_constant_hash}];

sub auth {
    my $self = shift;
    my $hash = +{
        0 => 'ユーザーが存在しません',
        1 => 'パスワードが違います',
        2 => 'ログインしました',
        3 => 'プロフィールを登録してください',
        4 => 'ログアウトしました',
    };

    my $constant = +{
        NOT_LOGIN_ID   => 0,
        NOT_PASSWORD   => 1,
        IS_LOGIN       => 2,
        IS_FIRST_LOGIN => 3,
        IS_LOGOUT      => 4,
    };

    $self->master_hash($hash);
    $self->master_constant_hash($constant);
    return $self;
}

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
