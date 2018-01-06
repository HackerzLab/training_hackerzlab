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
    return $self->_choice          if $model->is_question_choice;
    return $self->_form            if $model->is_question_form;
    return $self->_survey          if $model->is_question_survey;
    return $self->_survey_and_file if $model->is_question_survey_and_file;
    return $self->_explain if $model->is_question_explain;

    # 存在しない問題の場合
    $self->render( template => 'hackerz/question/index', );
    return;
}

# form -> 問題文に対して入力フォームにテキスト入力で解答
sub _form {
    my $self = shift;
    $self->render( template => 'hackerz/question/form', );
    return;
}

# choice -> 問題文に対して答えを4択から選択して解答
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

# survey_and_file -> 調査するページとファイルダウンロード
sub _survey_and_file {
    my $self = shift;
    $self->render( template => 'hackerz/question/survey_and_file', );
    return;
}

# explain -> 問題とその詳細から解答を導き出してテキスト入力で解答
sub _explain {
    my $self = shift;
    $self->render( template => 'hackerz/question/explain', );
    return;
}

1;
