+{
    '/register' => +{
        controller => 'Register', action => 'index',
    },
    '/register/execute' => +{
        controller => 'Register', action => 'execute',
        filter => [qw/validate_password/],
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
    },
    '/withdraw' => +{
        controller => 'Register', action => 'withdraw',
    },
    '/withdraw/execute' => +{
        controller => 'Register', action => 'withdraw_execute',
    }
}

