+{
    '/stamp/attach.json' => +{
        controller => 'Stamp', action => 'attach',
        filters => [qw/validator/],
    },
    '/stamp/detach.json' => +{
        controller => 'Stamp', action => 'detach',
        filters => [qw/validator/],
    },
    '/stamp/list.json' => +{
        controller => 'Stamp', action => 'list',
    },
}


