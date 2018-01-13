package TrainingHackerzlab::Controller::Hackerz::Ranking;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# 総合ランキング (ログイン中)
sub index {
    my $self              = shift;
    my $model             = $self->model->hackerz->ranking;
    my $to_template_index = $model->to_template_index;
    $self->stash(
        rankings => $to_template_index,
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

1;
