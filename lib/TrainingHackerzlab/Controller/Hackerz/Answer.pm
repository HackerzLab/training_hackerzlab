package TrainingHackerzlab::Controller::Hackerz::Answer;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# 解答一覧画面
sub list {
    my $self = shift;
    $self->render(
        template => 'hackerz/answer/list',
        format   => 'html',
        handler  => 'ep',
        rows     => $self->_dummy_list_data(),
    );
    return;
}

# 解答結果画面
sub score {
    my $self = shift;
    $self->render( text => 'score' );
    return;
}

# 回答を送信したぞ画面
sub result {
    my $self = shift;
    $self->render( text => 'result' );
    return;
}

# 解答内容送信
sub store {
    my $self = shift;
    $self->render( text => 'store' );
    return;
}

sub _dummy_list_data {
    my $self = shift;
    my $hash = [
        +{  question => 1,
            answer   => 'dddd',
        },
        +{  question => 2,
            answer   => 'sdffff',
        },
        +{  question => 3,
            answer   => 'tcp',
        },
    ];
    return $hash;
}

1;
