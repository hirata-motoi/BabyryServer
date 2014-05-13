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
    },
    # 分かりづらいけどパスワード忘れた時のエンドポイント
    '/register/password_change' => +{
        controller => 'Register', action => 'password_change',
    },
    '/register/password_change_execute' => +{
        controller => 'Register', action => 'password_change_execute',
    },
    # 分かりづらいけどパスワード覚えてる偉い人用、その上でパスワード変えたい意識高い人用
    '/register/new_password_change' => +{
        controller => 'Register', action => 'new_password_change',
    },
    '/register/new_password_change_execute' => +{
        controller => 'Register', action => 'new_password_change_execute',
    }
}

