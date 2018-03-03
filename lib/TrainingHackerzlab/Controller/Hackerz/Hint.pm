package TrainingHackerzlab::Controller::Hackerz::Hint;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

sub opened {
    my $self = shift;

    my $res = +{
        status      => 500,
        hint_opened => +{
            id => undef,
        },
    };

    my $params  = $self->req->params->to_hash;
    my $hackerz = $self->model->hackerz;
    my $hint    = $hackerz->hint->req_params($params);

    # 簡易的なバリデート
    if ($hint->has_error_easy) {
        $self->render(json => $res);
        return;
    }

    # DB 登録実行
    my $hint_id = $hint->opened;

    # 履歴を返却
    $res = +{
        %{$res},
        status => 200,
        hint_opened => +{
            id => $hint_id,
        },
    };
    $self->render(json => $res);
    return;
}

1;
