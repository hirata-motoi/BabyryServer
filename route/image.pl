+{
    '/image/upload' => +{
        controller => 'Image', action => 'image_upload',
    },
    '/image/upload_sample_form' => +{
        controller => 'Image', action => 'image_upload_sample_form',
    },
    '/image/web/upload.json' => +{
        controller => 'Image', action => 'web_upload',
    }
    '/image/web/submit.json' => +{
        controller => 'Image', action => 'web_submit',
    }
}

