package TrainingHackerzlab::Controller::Hackerz::Hint;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

sub opened {
    my $self = shift;

    my $params  = $self->req->params->to_hash;
    my $hackerz = $self->model->hackerz;
    my $hint    = $hackerz->hint->req_params($params);

    # 簡易的なバリデート
    if ($hint->has_error_easy) {
        return;
    }

    # DB 登録実行
    my $hint_id = $hint->opened;

    # $self->render(json => {hint_opened => []});
    return;
}

1;
