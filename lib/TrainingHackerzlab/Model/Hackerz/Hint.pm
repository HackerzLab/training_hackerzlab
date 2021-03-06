package TrainingHackerzlab::Model::Hackerz::Hint;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

# 簡易的なバリデート
sub has_error_easy {
    my $self   = shift;
    my $params = $self->req_params;
    my $master = $self->db->master;
    return 1 if !$params->{hint_id};
    return 1 if !$params->{opened};
    return 1 if !$params->{user_id};
    return 1 if !$params->{collected_id};

    # 二重登録防止
    my $cond = +{
        user_id      => $params->{user_id},
        hint_id      => $params->{hint_id},
        collected_id => $params->{collected_id},
        deleted      => $self->db->master->deleted->constant('NOT_DELETED'),
    };
    my $hint_opened = $self->db->teng->single( 'hint_opened', $cond );
    return 1 if $hint_opened;

    # 解答済みの場合はヒントの開封履歴をとらない
    my $hint_cond = +{
        id      => $params->{hint_id},
        deleted => $self->db->master->deleted->constant('NOT_DELETED'),
    };
    my $hint_row = $self->db->teng->single( 'hint', $hint_cond );
    return 1
        if $hint_row->is_answer_ended( $params->{user_id}, $params->{collected_id} );
    return;
}

sub opened {
    my $self   = shift;
    my $master = $self->db->master;
    my $params = +{
        user_id      => $self->req_params->{user_id},
        hint_id      => $self->req_params->{hint_id},
        collected_id => $self->req_params->{collected_id},
        opened       => $self->req_params->{opened},
        deleted      => $master->deleted->constant('NOT_DELETED'),
    };
    return $self->db->teng_fast_insert( 'hint_opened', $params );
}

1;
