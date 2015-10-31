use Config;
use HTML::Template;

unit class Site::Template;

has $.file;

multi method render(*%params) {
    self.render(%params);
}

multi method render(%params) {
    my $base = Config.get('template-base');
    my $fullpath = $.file;
    unless $.file ~~ /^\// {
        $fullpath = $base ~ '/' ~ $.file;
    }
    my $template = HTML::Template.from_file($fullpath);
    %params<TMPL_PATH> = $base ~ '/';
    $template.with_params(%params);
    return $template.output;
}
