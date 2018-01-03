package TrainingHackerzlab::Model::Hackerz::Question;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

# 問題画面パラメーター
sub to_template_think {
    my $self = shift;

    my $think = +{
        question => undef,
        hint     => undef,
    };

    my $cond = +{
        id      => $self->req_params->{question_id},
        deleted => 0,
    };

    my $row = $self->db->teng->single( 'question', $cond );
    return $think if !$row;
    $think->{question} = $row->get_columns;

    $cond = +{
        question_id => $self->req_params->{question_id},
        deleted     => 0,
    };

    my @hint_rows = $self->db->teng->search( 'hint', $cond );

    my $hint = +{};
    for my $hint_row (@hint_rows) {
        $hint->{ $hint_row->level } = $hint_row->hint;
    }
    $think->{hint} = $hint;
    return $think;
}

1;
