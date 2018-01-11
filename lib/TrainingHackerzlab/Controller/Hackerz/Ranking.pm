package TrainingHackerzlab::Controller::Hackerz::Ranking;
use Mojo::Base 'TrainingHackerzlab::Controller::Base';

# 総合ランキング (ログイン中)
sub index {
    my $self = shift;
    # $self->render(
    #     template => 'hackerz/ranking/index',
    #     format   => 'html',
    #     handler  => 'ep',
    #     rankings => $self->_dummy_ranking_data(),
    # );
    my $model  = $self->model->hackerz->ranking;
    my $to_template_index = $model->to_template_index;
    $self->stash(
        rankings => $to_template_index,
        format   => 'html',
        handler  => 'ep',
    );
    $self->render();
    return;
}

sub _dummy_ranking_data {
    my $self = shift;
    my $hash = [
        +{  rank  => 1,
            name  => 'Kaoru Nagashima',
            score => 134,
        },
        +{  rank  => 2,
            name  => 'kondo',
            score => 130,
        },
        +{  rank  => 3,
            name  => 'yamamoto soichiro',
            score => 130,
        },
        +{  rank  => 4,
            name  => 'koba',
            score => 128,
        },
        +{  rank  => 5,
            name  => '井上信之',
            score => 108,
        },
        +{  rank  => 6,
            name  => 'shinnosuke kanou',
            score => 98,
        },
        +{  rank  => 7,
            name  => 'たこたろう',
            score => 98,
        },
        +{  rank  => 8,
            name  => '川上',
            score => 50,
        },
        +{  rank  => 9,
            name  => 'あきこ・さくと',
            score => 46,
        },
        +{  rank  => 10,
            name  => 'Yuito',
            score => 44,
        },
        +{  rank  => 11,
            name  => '秀一郎',
            score => 44,
        },
        +{  rank  => 12,
            name  => '10ma',
            score => 40,
        },
        +{  rank  => 13,
            name  => 'KOKI',
            score => 30,
        },
        +{  rank  => 14,
            name  => 'るい',
            score => 30,
        },
        +{  rank  => 15,
            name  => 'やまもと　ちか',
            score => 20,
        },
        +{  rank  => 16,
            name  => '瀬里勝幸',
            score => 20,
        },
        +{  rank  => 17,
            name  => 'hiramatsu',
            score => 0,
        },
        +{  rank  => 18,
            name  => 'yosizuka',
            score => 0,
        },
    ];
    return $hash;
}

1;
