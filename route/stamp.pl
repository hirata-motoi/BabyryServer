+{
    '/stamp/attach.json' => +{
        controller => 'Stamp', action => 'attach',
        filters => [qw/validator/],
    },
    '/stamp/list.json' => +{
        controller => 'Stamp', action => 'list',
    },
}


