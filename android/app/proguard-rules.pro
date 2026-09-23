# uCrop (image_cropper) references OkHttp for remote-URI loads.
# Keep these so R8 does not fail the Play Store release minify step.
-dontwarn okhttp3.Call
-dontwarn okhttp3.Dispatcher
-dontwarn okhttp3.OkHttpClient
-dontwarn okhttp3.Request$Builder
-dontwarn okhttp3.Request
-dontwarn okhttp3.Response
-dontwarn okhttp3.ResponseBody
-dontwarn okhttp3.**
-dontwarn okio.**

-keep class com.yalantis.ucrop.** { *; }
-keep interface com.yalantis.ucrop.** { *; }
