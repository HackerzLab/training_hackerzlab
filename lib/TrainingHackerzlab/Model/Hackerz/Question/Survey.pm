package TrainingHackerzlab::Model::Hackerz::Question::Survey;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

sub index {
    my $self = shift;
    return;
}

sub survey {
    my $self = shift;

    my $survey = 1;
    return $survey if !$self->req_params->{secret_id};

    $survey = 2;
    return $survey if !$self->req_params->{secret_password};

    my $cond = +{
        secret_id       => $self->req_params->{secret_id},
        secret_password => $self->req_params->{secret_password},
        deleted         => 0,
    };
    my $row = $self->db->teng->single( 'survey', $cond );

    $survey = 3;
    return $survey if !$row;

    $survey = 'success';
    return $survey;
}

1;
