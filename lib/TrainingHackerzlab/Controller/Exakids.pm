package TrainingHackerzlab::Controller::Exakids;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

sub index {
    my $self        = shift;
    my $model       = $self->model->exakids;
    my $to_template = $model->to_template_index;
    $self->stash(
        %{$to_template},
        template => 'exakids/index',
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;

}

1;
