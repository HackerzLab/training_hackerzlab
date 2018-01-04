package TrainingHackerzlab::Controller::Hackerz::Question;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# 各問題画面
sub think {
    my $self   = shift;
    my $params = +{ question_id => $self->stash->{id}, };
    my $model  = $self->model->hackerz->question->req_params($params);
    my $to_template_think = $model->to_template_think;
    $self->stash(
        %{$to_template_think},
        format  => 'html',
        handler => 'ep',
    );
    return $self->_choice if $model->is_question_choice;
    return $self->_form   if $model->is_question_form;
    return $self->_survey if $model->is_question_survey;
    return;
}

# pattern form -> 問題文に対して入力フォームにテキスト入力で解答
sub _form {
    my $self = shift;
    $self->render( template => 'hackerz/question/form', );
    return;
}

# pattern choice -> 問題文に対して答えを4択から選択して解答
sub _choice {
    my $self = shift;
    $self->render( template => 'hackerz/question/choice', );
    return;
}

# survey -> 調査するページから解答を導き出してテキスト入力で解答
sub _survey {
    my $self = shift;
    $self->render( template => 'hackerz/question/survey', );
    return;
}

1;
