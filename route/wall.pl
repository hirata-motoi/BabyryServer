+{
    '/' => +{
        controller => 'Wall', action => 'index',
    },
    '/detail/:id' => +{
        controller => 'Wall', action => 'detail',
    },
    '/json_validate_sample' => +{
        controller => 'Wall', action => 'json_validate_sample',
        filters => [qw/validator/]
    }
}

