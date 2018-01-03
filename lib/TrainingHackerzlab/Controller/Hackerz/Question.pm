package TrainingHackerzlab::Controller::Hackerz::Question;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# 各問題画面
sub think {
    my $self   = shift;
    my $params = +{ question_id => $self->stash->{id}, };
    my $model  = $self->model->hackerz->question->req_params($params);
    my $to_template_think = $model->to_template_think;
    $self->stash($to_template_think);
    $self->render(
        template => 'hackerz/question/think',
        format   => 'html',
        handler  => 'ep',
    );
    return;
}

1;
