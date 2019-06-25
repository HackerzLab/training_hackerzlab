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
    return $to_template;
}

sub to_template_edit {
    my $self        = shift;
    my $to_template = +{};
    return $to_template;
}

1;
