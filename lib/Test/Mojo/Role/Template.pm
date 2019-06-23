package Test::Mojo::Role::Template;
use Mojo::Base -role;
use Test::More;
use Mojo::Util qw{dumper};

# input 入力フォームの値を取得
sub get_input_val {
    my ( $self, $dom, $form ) = @_;

    # 取得 input, text, password, radio, checkbox, select, hidden, textarea
    my $text     = $self->_get_val( $dom, $form, 'input[type=text]' );
    my $password = $self->_get_val( $dom, $form, 'input[type=password]' );
    my $radio    = $self->_get_val( $dom, $form, 'input[type=radio]' );
    my $checkbox = $self->_get_val( $dom, $form, 'input[type=checkbox]' );
    my $select   = $self->_get_val( $dom, $form, 'select' );
    my $hidden   = $self->_get_val( $dom, $form, 'input[type=hidden]' );
    my $textarea = $self->_get_val( $dom, $form, 'textarea' );

    my $params = +{
        %{$text},     %{$radio},    %{$hidden},
        %{$textarea}, %{$password}, %{$select},
        %{$checkbox},
    };
    return $params;
}

# dom に値を埋め込み
sub input_val_in_dom {
    my ( $self, $dom, $form, $data ) = @_;

    # 埋込 input text, password, radio, checkbox, select, textarea
    $dom = $self->_val_in_dom( $dom, $form, $data, 'input[type=text]' );
    $dom = $self->_val_in_dom( $dom, $form, $data, 'input[type=password]' );
    $dom = $self->_val_in_dom( $dom, $form, $data, 'input[type=radio]' );
    $dom = $self->_val_in_dom( $dom, $form, $data, 'input[type=checkbox]' );
    $dom = $self->_val_in_dom( $dom, $form, $data, 'select' );
    $dom = $self->_val_in_dom( $dom, $form, $data, 'textarea' );
    return $dom;
}

# input 取得
# my $params = $self->_get_val( $dom, $form, 'input[type=text]');
sub _get_val {
    my ( $self, $dom, $form, $type ) = @_;
    my $params = +{};

    # エレメントの構造がそれぞれ違う
    return $self->_get_input_radio_val( $dom, $form, $type )
        if $type eq 'input[type=radio]';

    return $self->_get_input_checkbox_val( $dom, $form, $type )
        if $type eq 'input[type=checkbox]';

    return $self->_get_input_select_val( $dom, $form, $type )
        if $type eq 'select';

    for my $e ( $dom->find("$form $type")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        $params->{$name} = $e->val;
    }
    return $params;
}

# input radio 入力フォームの値を取得
sub _get_input_radio_val {
    my ( $self, $dom, $form, $type ) = @_;

    my $params = +{};
    for my $e ( $dom->find("$form $type")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        my $tag = $e->to_string;
        if ( $tag =~ /checked/ ) {
            $params->{$name} = $e->val;
        }
    }
    return $params;
}

# input checkbox 入力フォームの値を取得
sub _get_input_checkbox_val {
    my ( $self, $dom, $form, $type ) = @_;

    my $params = +{};
    for my $e ( $dom->find("$form $type")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        my $tag = $e->to_string;
        if ( $tag =~ /checked/ ) {
            push @{$params->{$name}}, $e->val;
        }
    }

    # 配列が一つの場合はスカラーで返却(実際の挙動に合わせる)
    for my $key (keys %{$params}) {
        my $val = $params->{$key};
        next if ref $val ne 'ARRAY';
        next if scalar @{$val} ne 1;
        $params->{$key} = shift @{$params->{$key}};
    }
    return $params;
}

# input select 入力フォームの値を取得
sub _get_input_select_val {
    my ( $self, $dom, $form, $type ) = @_;

    my $params = +{};
    for my $e ( $dom->find("$form $type")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        my $tag = $e->to_string;
        if ( $tag =~ /selected/ ) {
            $params->{$name} = $e->at('option[selected=selected]')->val;
        }
    }
    return $params;
}

# input 値の埋め込み
# $dom = $self->_val_in_dom( $dom, $form, $data, 'input[type=text]' );
sub _val_in_dom {
    my ( $self, $dom, $form, $data, $type ) = @_;

    # name 情報取得
    my $names;
    for my $e ( $dom->find("$form $type")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        push @{$names}, $name;
    }

    # エレメントの構造がそれぞれ違う
    return $self->_radio_val_in_dom( $dom, $form, $data, $type, $names )
        if $type eq 'input[type=radio]';
    return $self->_checkbox_val_in_dom( $dom, $form, $data, $type, $names )
        if $type eq 'input[type=checkbox]';
    return $self->_select_val_in_dom( $dom, $form, $data, $type, $names )
        if $type eq 'select';
    return $self->_textarea_val_in_dom( $dom, $form, $data, $type, $names )
        if $type eq 'textarea';

    # name ごとに値を埋め込み
    for my $name ( @{$names} ) {
        next if ref $data->{$name} eq 'ARRAY';
        my $val = $data->{$name};
        $dom->at("$form input[name=$name]")->attr( +{ value => $val } );
    }
    return $dom;
}

# name 情報取得
sub _get_names {
    my ( $self, $dom, $form, $type ) = @_;
    my $names;
    for my $e ( $dom->find("$form $type")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        push @{$names}, $name;
    }
    return $names;
}

# input radio 値の埋め込み
sub _radio_val_in_dom {
    my ( $self, $dom, $form, $data, $type, $names ) = @_;

    # 重複している name を解消
    if ($names) {
        my $collection = Mojo::Collection->new( @{$names} );
        $names = $collection->uniq->to_array;
    }

    # checked をはずす
    for my $e ( $dom->find("$form input[type=radio][checked]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        delete $e->attr->{checked};
    }

    for my $name ( @{$names} ) {
        next if ref $data->{$name} eq 'ARRAY';
        my $val = $data->{$name};
        $dom->at("$form input[name=$name][value=$val]")
            ->attr( 'checked' => undef );
    }
    return $dom;
}

# input checkbox 値の埋め込み
sub _checkbox_val_in_dom {
    my ( $self, $dom, $form, $data, $type, $names ) = @_;

    # 重複している name を解消
    if ($names) {
        my $collection = Mojo::Collection->new( @{$names} );
        $names = $collection->uniq->to_array;
    }

    # checked をはずす
    for my $e ( $dom->find("$form input[type=checkbox][checked]")->each ) {
        my $name = $e->attr('name');
        next if !$name;
        delete $e->attr->{checked};
    }

    # checkbox は複数指定できる
    for my $name ( @{$names} ) {
        my @values;
        if (ref $data->{$name} eq 'ARRAY') {
            @values = @{$data->{$name}};
            for my $val (@values) {
                $dom->at("$form input[name=$name][value=$val]")
                    ->attr( 'checked' => undef );
            }
        }
        else {
            my $val = $data->{$name};
            $dom->at("$form input[name=$name][value=$val]")
                ->attr( 'checked' => undef );
        }
    }
    return $dom;
}

# input select 値の埋め込み
sub _select_val_in_dom {
    my ( $self, $dom, $form, $data, $type, $names ) = @_;

    # selected をはずす
    for my $e ( $dom->find("$form select")->each ) {
        my $name = $e->attr('name');
        next if !$name;

        # select は入れ子になっている事に注意
        for my $option_e ( $e->find('option')->each ) {
            delete $option_e->attr->{selected};
        }
    }

    for my $name ( @{$names} ) {
        next if ref $data->{$name} eq 'ARRAY';
        my $val = $data->{$name};
        $dom->at("$form select[name=$name] option[value=$val]")
            ->attr( +{ selected => "selected" } );
    }
    return $dom;
}

# textarea 値の埋め込み
sub _textarea_val_in_dom {
    my ( $self, $dom, $form, $data, $type, $names ) = @_;

    for my $name ( @{$names} ) {
        next if ref $data->{$name} eq 'ARRAY';
        my $val = $data->{$name};
        $dom->at("$form textarea[name=$name]")->content($val);
    }
    return $dom;
}

1;

__END__
