use Web::RF;
use Site::Template;

use Auth::PAM::Simple;

unit class Page::Login is Web::RF::Controller;

method display_login($return) {
    return [ 200, [ 'Content-Type' => 'text/html' ],
            [ Site::Template.new(:file('login.tmpl'))
                            .render(return => $return) ]];
}

multi method handle(Get :$request!) {
    my $params = $request.parameters;

    return self.display_login($params<return>);
}

multi method handle(Post :$request!) {
    my $params = $request.parameters;

    if authenticate('login', $params<user>, $params<password>) {
        $request.set-user-id($params<user>);
        my $return = $params<return>;
        return Web::RF::Redirect.go(:code(302), :url($return || '/'));
    }
    return self.display_login($params<return>);
}
