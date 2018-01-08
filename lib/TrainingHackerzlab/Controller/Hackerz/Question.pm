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
        template => $model->select_template,
        user     => $self->login_user->get_columns,
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

1;
