+{
    '/register' => +{
        controller => 'Register', action => 'index',
    },
    '/register/execute' => +{
        controller => 'Register', action => 'execute',
        filter => [qw/validate_password/],
    },
    '/register/verify' => +{
        controller => 'Register', action => 'verify',
    },
    '/login' => +{
        controller => 'Login', action => 'index',
    },
    '/login/execute' => +{
        controller => 'Login', action => 'execute',
    },
    '/logout' => +{
        controller => 'Login', action => 'logout',
    },
    '/register/devicetoken' => +{
        controller => 'Register', action => 'devicetoken',
    }
}

