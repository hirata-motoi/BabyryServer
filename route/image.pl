+{
    '/image/upload_sample_form' => +{
        controller => 'Image', action => 'image_upload_sample_form',
    },
    '/image/submit_sample_form' => +{
        controller => 'Image', action => 'image_submit_sample_form',
    },
    '/image/comment_sample_form' => +{
        controller => 'Image', action => 'image_comment_sample_form',
    },
    '/image/web/upload' => +{
        controller => 'Image', action => 'web_upload',
    },
    '/image/web/upload_execute.json' => +{
        controller => 'Image', action => 'web_upload_execute',
    },
    '/image/web/submit.json' => +{
        controller => 'Image', action => 'web_submit',
    },
    '/image/web/remove.json' => +{
        controller => 'Image', action => 'web_remove',
    },
    '/image/comment.json' => +{
        controller => 'Image', action => 'comment',
    },
    '/image/child/attach.json' => +{
        controller => 'Image', action => 'child_attach',
    },
    '/image/child/detach.json' => +{
        controller => 'Image', action => 'child_detach',
    },
}

