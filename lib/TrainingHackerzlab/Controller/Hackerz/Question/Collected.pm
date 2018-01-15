package TrainingHackerzlab::Controller::Hackerz::Question::Collected;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

sub show {
    my $self = shift;

    my $params           = +{ collected_id => $self->stash->{id}, };
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

1;
