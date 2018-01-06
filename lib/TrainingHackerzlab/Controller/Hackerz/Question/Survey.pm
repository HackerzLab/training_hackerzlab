package TrainingHackerzlab::Controller::Hackerz::Question::Survey;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# クラッキング用特別画面
sub cracking {
    my $self   = shift;
    my $params = +{ question_id => $self->stash->{id}, };
    my $model  = $self->model->hackerz->question->req_params($params);
    my $to_template_think = $model->to_template_think;
    $self->stash(
        %{$to_template_think},
        template => 'hackerz/question/survey/cracking',
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

# クラッキングリスト用特別画面
sub cracking_from_list {
    my $self   = shift;
    my $params = +{ question_id => $self->stash->{id}, };
    my $model  = $self->model->hackerz->question->req_params($params);
    my $to_template_think = $model->to_template_think;
    $self->stash(
        %{$to_template_think},
        template => 'hackerz/question/survey/cracking_from_list',
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

1;
