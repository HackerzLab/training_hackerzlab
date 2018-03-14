package TrainingHackerzlab::Model::Hackerz::Question::Survey;
use Mojo::Base 'TrainingHackerzlab::Model::Base';

sub survey {
    my $self = shift;
    return 1 if !$self->req_params->{secret_id};
    return 2 if !$self->req_params->{secret_password};
    my $cond = +{
        secret_id       => $self->req_params->{secret_id},
        secret_password => $self->req_params->{secret_password},
        question_id     => $self->req_params->{question_id},
        deleted         => 0,
    };
    my $row = $self->db->teng->single( 'survey', $cond );
    return 3 if !$row;
    return 'success';
}

1;
