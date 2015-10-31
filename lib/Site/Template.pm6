use Config;

unit class Site::Template;

has $.file;

method render(*%params) {
    self.render(%params);
}

method render(%params) {
    my $base = Config.get('template-base');
    my $template = HTML::Template.from_file($base ~ '/' ~ $.file);
    $template.with_params(%params);
    return $template.output;
}
