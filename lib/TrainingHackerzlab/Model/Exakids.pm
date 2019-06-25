package TrainingHackerzlab::Model::Exakids;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

sub to_template_index {
    my $self = shift;
    my $to_template = +{ exakids_users => [] };

    # エクサキッズ対象ユーザー
    my $exa_ids = $self->conf->{exa_ids};
    my @exakids_users
        = $self->db->teng->search( 'user', +{ id => $exa_ids } );
    for my $user (@exakids_users) {
        push @{ $to_template->{exakids_users} }, $user->get_columns;
    }
    return $to_template;
}

sub to_template_menu {
    my $self        = shift;
    my $to_template = +{};

    # 解答者
    my $exa_ids_entry = $self->conf->{exa_ids_entry};
    my @exakids_users
        = $self->db->teng->search( 'user', +{ id => $exa_ids_entry } );
    my $entry_users_data = [];
    my $count            = 0;
    my $line             = [];
    for my $row (@exakids_users) {
        $count = $count + 1;
        if ( $count == 1 ) {
            push @{$line}, $row->get_columns;
            next;
        }
        if ( $count == 2 ) {
            push @{$line},             $row->get_columns;
            push @{$entry_users_data}, $line;
            $line  = [];
            $count = 0;
            next;
        }
    }
    $to_template->{entry_users_data} = $entry_users_data;
    return $to_template;
}

1;
