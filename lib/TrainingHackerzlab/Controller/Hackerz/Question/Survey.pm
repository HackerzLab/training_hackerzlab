package TrainingHackerzlab::Controller::Hackerz::Question::Survey;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';
use Mojo::Util qw{dumper};

# クラッキング用特別画面
sub cracking {
    my $self   = shift;
    my $params = +{
        collected_id => $self->stash->{collected_id},
        sort_id      => $self->stash->{sort_id},
        user_id      => $self->login_user->id,
    };

    my $hackerz           = $self->model->hackerz;
    my $model             = $hackerz->question->req_params($params);
    my $to_template_think = $model->to_template_think;

    # クラッキングの解答
    my $survey_answer;
    my $secret_password;
    if ( $self->req->method eq 'POST' ) {
        my $req_params    = $self->req->params->to_hash;
        my $survey_params = +{
            secret_id       => $req_params->{secret_id},
            secret_password => $req_params->{secret_password},
            question_id     => $req_params->{question_id},
        };
        my $survey = $hackerz->question->survey->req_params($survey_params);
        $survey_answer   = $survey->survey;
        $secret_password = $req_params->{secret_password};
    }

    $self->stash(
        %{$to_template_think},
        survey_answer   => $survey_answer,
        secret_password => $secret_password,
        template        => 'hackerz/question/survey/cracking',
        format          => 'html',
        handler         => 'ep',
    );
    $self->render();
    return;
}

# クラッキングリスト用特別画面
sub cracking_from_list {
    my $self   = shift;
    my $params = +{
        collected_id => $self->stash->{collected_id},
        sort_id      => $self->stash->{sort_id},
        user_id      => $self->login_user->id,
    };

    my $hackerz           = $self->model->hackerz;
    my $model             = $hackerz->question->req_params($params);
    my $to_template_think = $model->to_template_think;

    # クラッキングの解答
    my $survey_answer;
    my $secret_password;
    if ( $self->req->method eq 'POST' ) {
        my $req_params    = $self->req->params->to_hash;
        my $survey_params = +{
            secret_id       => $req_params->{secret_id},
            secret_password => $req_params->{secret_password},
            question_id     => $req_params->{question_id},
        };
        my $survey = $hackerz->question->survey->req_params($survey_params);
        $survey_answer   = $survey->survey;
        $secret_password = $req_params->{secret_password};
    }

    $self->stash(
        %{$to_template_think},
        survey_answer   => $survey_answer,
        secret_password => $secret_password,
        template        => 'hackerz/question/survey/cracking_from_list',
        format          => 'html',
        handler         => 'ep',
    );
    $self->render();
    return;
}

# 改ざん用ページ
sub exploits {
    my $self   = shift;
    my $params = +{ question_id => $self->stash->{id}, };
    my $model  = $self->model->hackerz->question->req_params($params);
    my $to_template_think = $model->to_template_think;
    my $code              = 'foooo';
    $self->stash(
        code => $code,
        %{$to_template_think},
        template => 'hackerz/question/survey/exploits',
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

1;
