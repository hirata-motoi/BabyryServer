# controller

# debug obj
sampleData =
  data:
    entries: [
      {
        uploaded_at: 1391285273
        fullsize_image_url: "https:#bebyry-image-upload.s3.amazonaws.com/test/baby.jpg?AWSAccessKeyId=AKIAI\nEOGXXLOVEP76RXQ&Expires=1389538722&Signature=DEz13W56O9MKcA%2FTHNJCTRnaMeU%3D"
        comments: [
          {
            created_at: 1391285273
            comment_id: 9999
            comment: "ないす笑顔！"
            user_id: 111
            user_name: "taro"
          }
          {
            created_at: 1391285273
            comment_id: 110110
            comment: "将来大物になるぞ"
            user_id: 113
            user_name: "jiro"
          }
        ]
        fullsize_image_size:
          y: 480
          x: 320

        stamps: [
          {
            stamp_icon_url: "http:#icon_url1"
            stamp_id: 11111
          }
          {
            stamp_icon_url: "http:#icon_url2"
            stamp_id: 11112
          }
          {
            stamp_icon_url: "http:#icon_url3"
            stamp_id: 11113
          }
        ]
        thumbnail_image_url: "https:#bebyry-image-upload.s3.amazonaws.com/test/baby.jpg?AWSAccessKeyId=AKIAIEOGXXLOVEP76RXQ&Expires=1389538722&Signature=DEz13W56O9MKcA%2FTHNJCTRnaMeU%3D"
        thumbnail_image_size:
          y: 220
          x: 140

        image_id: 100
        uploaed_by: 112
        shared_users: [
          {
            user_type: "self", # 自分
            user_id: 111
            user_name: "taro"
          }
          {
            user_type: "uploader", # 写真をuploadしたユーザ
            user_id: 112
            user_name: "hanako"
          }
          {
            user_type: "",  # 共有されている第三者
            user_id: 113
            user_name: "jiro"
          }
        ]
        has_comments: true
      }
    ]

	metadata:
		count: 10
		page: 1
		condition: # 検索条件のパラメータ
			stamp_id: 0
			uploaded_by: 0

for [ 0 .. 10 ]
  entries = _.clone(sampleData.data.entries[0])
  entries.image_id += sampleData.data.entries.length
  sampleData.data.entries.push entries

class App
  # `new App()`すると呼び出される (coffeescript syntax)
  # backboneの場合はinitializeでもOK
  constructor: (config) ->
    $.getJSON(Babyry.Config.ENTRY_URL).done(_.bind((res)-> # deferred
      if res.data.entries.length is 0
        res = sampleData

      @entries  = new Babyry.Collection.Entries(sampleData.data.entries)
      @metadata = res.metadata

      @entriesView = new Babyry.View.Entries(@entries)

      @entriesView.render()

    , @))

window.Babyry.App = App
