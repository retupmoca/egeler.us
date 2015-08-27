unit class Site;

use Web::Request;
use Render::HTML;
use Session;
use Config;

use Page::NotFound;
use Page::Redirect;
use Page::Login;

use Section::SAML;
use Section::Blog;

has @!dispatch-list;
has $!sessions;

submethod BUILD() {
    # redirect retupmoca.com to andrew's blog posts
    @!dispatch-list.push([-> $r, $s { $r.host eq 'retupmoca.com' },
                             Page::Redirect.new(:code(301), :url('https://egeler.us/u/andrew')));
    # ensure that we are https and on egeler.us
    @!dispatch-list.push([-> $r, $s { 
                                        if $r.host ne 'egeler.us'
                                           || $r.proto ne 'https' {
                                            True;
                                        }
                                        else {
                                            False;
                                        }
                                    },
                                    Page::Redirect.new(:code(301),
                                                       :url('https://egeler.us/'))]);

    # we have no homepage; redirect to the blog
    @!dispatch-list.push([
        -> $r, $s {
            $r.uri eq '/';
        }, Page::Redirect.new(:code(302), :url('/blog'))]);
    @!dispatch-list.push([
        -> $r, $s {
            $r.uri ~~ /^\/login/;
        }, Page::Login]);
    @!dispatch-list.push(Section::Blog.dispatch('/blog'));
    @!dispatch-list.push(Section::SAML.dispatch('/saml2'));
    @!dispatch-list.push([-> $r, $s { True }, Page::NotFound]);

    $!sessions = SessionManager.new;
}

method handle(%env) {
    # TODO: put basic system load checker / fast-path bailout here
    # (not that this is ever going to get more than about 5 pageviews...ever)
    # if load-high return [ 503, [], [ 'oh god it burns' ]];

    my $request = Web::Request.new(%env);
    my $session = $!sessions.load($request.cookies<session>);
    my @headers;
    unless $session {
        $session = $!sessions.create();
        @headers.push('Set-Cookie' => 'session=' ~ $session.id ~ '; path=/');
    }

    my $page;
    for @!dispatch-list {
        # if this call does anything beyond a simple true/false check,
        # then you're doing it Wrong(tm)
        if $_[0].($request, $session) {
            # $_[1] wants to process this request

            if $_[1].defined {
                $page = $_[1];
            }
            else {
                $page = $_[1].new(:$request, :$session);
            }

            if $page {
                # and it wants to render the page
                last;
            }
            else {
                # ...but declines to render the page - continue searching
                # for a page display
                next;
            }
        }
    }

    my $template-base = Config.get('template-base');
    my $render = Render::HTML.new(:$template-base,
                                  :$page,
                                  :@headers);
    return $render.output;

    CATCH {
        default {
            # display_errors = On
            # TODO: Stop being PHP. Nobody likes that guy.
            return [500, [ 'Content-Type' => 'text/plain' ],
                         [ $_ ~ "\n" ~ $_.backtrace ]];
        }
    }
}
