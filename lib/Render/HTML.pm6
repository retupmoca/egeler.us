unit class Render::HTML;

use HTML::Template;

has $.template-base;
has $.page;
has @.headers;

method output() {
    my $body = '';
    my %data = $.page.data;
    if $.page.html-template -> $tfile is copy {
        unless $tfile ~~ /^\// {
            $tfile = $.template-base ~ '/' ~ $tfile;
            %data<TMPL_PATH> = $.template-base ~ '/';
        }
        my $template
          = HTML::Template.from_file($tfile);
        $template.with_params(%data);
        $body = $template.output;
    }
    elsif $.page.html-data -> $tdata {
        $body = $tdata;
    }
    my $type = $.page.html-type || 'text/html; charset=utf-8';
    return [ $.page.html-status,
             [ 'Content-Type' => $type,
               @.headers,
               $.page.html-headers ],
             [ $body ]
           ];
}
