package Test::Mojo::Role::Template;
use Mojo::Base -role;
use Test::More;
use Mojo::Util qw{dumper};

# input 入力フォームの値を取得
sub get_input_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    # input text 取得
    my $text_params = $self->_get_input_text_val( $dom, $form );

    # input password 取得
    my $password_params = $self->_get_input_password_val( $dom, $form );

    # input radio 取得
    my $radio_params = $self->_get_input_radio_val( $dom, $form );

    # input hidden 取得
    my $hidden_params = $self->_get_input_hidden_val( $dom, $form );

    # textarea 取得
    my $textarea_params = $self->_get_textarea_val( $dom, $form );

    my $params = +{
        %{$text_params},     %{$radio_params}, %{$hidden_params},
        %{$textarea_params}, %{$password_params},
    };
    return $params;
}

# dom に値を埋め込み
sub input_val_in_dom {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;
    my $data = shift;

    # input text
    $dom = $self->_text_val_in_dom( $dom, $form, $data );

    # input password
    $dom = $self->_password_val_in_dom( $dom, $form, $data );

    # input radio
    $dom = $self->_radio_val_in_dom( $dom, $form, $data );

    # textarea
    $dom = $self->_textarea_val_in_dom( $dom, $form, $data );

    return $dom;
}

# input text 入力フォームの値を取得
sub _get_input_text_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form input[type=text]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        $params->{$name} = $e->val;
    }
    return $params;
}

# input password 入力フォームの値を取得
sub _get_input_password_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form input[type=password]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        $params->{$name} = $e->val;
    }
    return $params;
}

# input radio 入力フォームの値を取得
sub _get_input_radio_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form input[type=radio]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        my $tag = $e->to_string;
        if ( $tag =~ /checked/ ) {
            $params->{$name} = $e->val;
        }
    }
    return $params;
}

# input hidden 入力フォームの値を取得
sub _get_input_hidden_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form input[type=hidden]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        $params->{$name} = $e->val;
    }
    return $params;
}

# textarea 入力フォームの値を取得
sub _get_textarea_val {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $params = +{};
    for my $e ( $dom->find("$form textarea")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        $params->{$name} = $e->val;
    }
    return $params;
}

# input text の name を全て取得
sub _get_input_text_names {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $names;
    for my $e ( $dom->find("$form input[type=text]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        push @{$names}, $name;
    }
    return $names;
}

# input password の name を全て取得
sub _get_input_password_names {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $names;
    for my $e ( $dom->find("$form input[type=password]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        push @{$names}, $name;
    }
    return $names;
}

# input radio の name を全て取得
sub _get_input_radio_names {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $names;
    for my $e ( $dom->find("$form input[type=radio]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        push @{$names}, $name;
    }

    # 重複している name を解消
    if ($names) {
        my $collection = Mojo::Collection->new( @{$names} );
        $names = $collection->uniq->to_array;
    }
    return $names;
}

# textarea の name を全て取得
sub _get_textarea_names {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;

    my $names;
    for my $e ( $dom->find("$form textarea")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        push @{$names}, $name;
    }
    return $names;
}

# input text 値の埋め込み
sub _text_val_in_dom {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;
    my $data = shift;

    my $names = $self->_get_input_text_names( $dom, $form );
    for my $name ( @{$names} ) {
        my $val = $data->{$name};
        $dom->at("$form input[name=$name]")->attr( +{ value => $val } );
    }
    return $dom;
}

# input password 値の埋め込み
sub _password_val_in_dom {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;
    my $data = shift;

    my $names = $self->_get_input_password_names( $dom, $form );
    for my $name ( @{$names} ) {
        my $val = $data->{$name};
        $dom->at("$form input[name=$name]")->attr( +{ value => $val } );
    }
    return $dom;
}

# input radio 値の埋め込み
sub _radio_val_in_dom {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;
    my $data = shift;

    my $names = $self->_get_input_radio_names( $dom, $form );

    # checked をはずす
    for my $e ( $dom->find("$form input[type=radio][checked]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        delete $e->attr->{checked};
    }

    for my $name ( @{$names} ) {
        my $val = $data->{$name};
        $dom->at("$form input[name=$name][value=$val]")
            ->attr( 'checked' => undef );
    }
    return $dom;
}

# textarea 値の埋め込み
sub _textarea_val_in_dom {
    my $self = shift;
    my $dom  = shift;
    my $form = shift;
    my $data = shift;

    my $names = $self->_get_textarea_names( $dom, $form );
    for my $name ( @{$names} ) {
        my $val = $data->{$name};
        $dom->at("$form textarea[name=$name]")->content($val);
    }
    return $dom;
}

1;

__END__
