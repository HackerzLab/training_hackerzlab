package TrainingHackerzlab::Controller::Hackerz::Question::Collected;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

sub show {
    my $self = shift;

    my $params = +{
        collected_id => $self->stash->{id},
        user_id      => $self->login_user->id,
    };
    my $hackerz          = $self->model->hackerz;
    my $collected        = $hackerz->question->collected->req_params($params);
    my $to_template_show = $collected->to_template_show;

    $self->stash(
        %{$to_template_show},
        user     => $self->login_user->get_columns,
        template => 'hackerz/question/collected/show',
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

# 各問題集経由の問題画面
sub think {
    my $self   = shift;
    my $params = +{
        collected_id => $self->stash->{collected_id},
        sort_id      => $self->stash->{sort_id},
        user_id      => $self->login_user->id,
    };
    my $hackerz           = $self->model->hackerz;
    my $question          = $hackerz->question->req_params($params);
    my $to_template_think = $question->to_template_think;
    $self->stash(
        %{$to_template_think},
        template => $question->select_template,
        user     => $self->login_user->get_columns,
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

1;
