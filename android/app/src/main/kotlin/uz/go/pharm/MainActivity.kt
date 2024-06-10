package uz.go.pharm


import androidx.annotation.NonNull
import com.facebook.FacebookSdk
import com.facebook.LoggingBehavior
import com.yandex.mapkit.MapKitFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MapKitFactory.setApiKey("c2270c63-ab7b-463b-b6d7-20821d098826");
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        FacebookSdk.setIsDebugEnabled(true)
        FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS)
    }
}
