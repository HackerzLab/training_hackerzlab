package TrainingHackerzlab::Model::Hackerz::Question;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

has [qw{is_question_choice is_question_form is_question_survey}] => undef;

# 問題画面パラメーター
sub to_template_think {
    my $self = shift;

    my $think = +{
        question => undef,
        hint     => undef,
        choice   => undef,
        survey   => undef,
    };

    my $cond = +{
        id      => $self->req_params->{question_id},
        deleted => 0,
    };

    my $row = $self->db->teng->single( 'question', $cond );
    return $think if !$row;
    $think->{question} = $row->get_columns;

    $self->_analysis_pattern($row);

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

    $cond = +{
        question_id => $self->req_params->{question_id},
        deleted     => 0,
    };

    my @choice_rows = $self->db->teng->search( 'choice', $cond );

    my $choice = +{};
    for my $choice_row (@choice_rows) {
        $choice->{ $choice_row->answer_val } = $choice_row->answer_text;
    }
    $think->{choice} = $choice;

    my $survey_row = $self->db->teng->single( 'survey', $cond );
    return $think if !$survey_row;
    $think->{survey} = $survey_row->get_columns;

    return $think;
}

sub _analysis_pattern {
    my $self = shift;
    my $row  = shift;
    return $self->is_question_form(1)   if $row->pattern eq 10;
    return $self->is_question_choice(1) if $row->pattern eq 20;
    return $self->is_question_survey(1) if $row->pattern eq 30;
    return;
}

1;
