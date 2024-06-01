package com.robotapp.robot_app

//import okhttp3.*

//import android.R
import android.graphics.Bitmap
import android.graphics.BitmapFactory;
import android.util.Log
import com.skt.tmap.TMapView
import com.skt.tmap.overlay.TMapMarkerItem
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.robotapp.robot_app/tmap"
    private lateinit var tMapView: TMapView

//    private val client = OkHttpClient()

//    override fun onCreate(savedInstanceState: Bundle?) {
//        super.onCreate(savedInstanceState)
//        tMapView = TMapView(this)
//        tMapView.setSKTMapApiKey("G47hiGFOOG1mZzstLLeHP342E38U3AT92zGGgq6Q")
//        setContentView(tMapView)
//    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tMapView = TMapView(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "initializeTMap" -> {
                    val apiKey = call.argument<String>("apiKey")
                    if (apiKey != null) {
                        initializeTMap(apiKey)
                        result.success("TMap Initialized")
                    } else {
                        result.error("UNAVAILABLE", "API key not available.", null)
                    }
                }

                "markCurrentPosition" -> {
                    val latitude = call.argument<Double>("latitude")
                    val longitude = call.argument<Double>("longitude")

//                    Log.d("markCurrentPosition","$longitude")
                    if (latitude != null && longitude != null) {
                        markCurrentPosition(latitude, longitude)
                        result.success("Current position marked")
                    } else {
                        result.error("UNAVAILABLE", "Position data not available.", null)
                    }


                }

//                "showMap" -> {
//                    showMap()
//                    result.success("Map displayed")
//                }

//                "findPedestrianRoute" -> {
//                    val startX = call.argument<Double>("startX") ?: 0.0
//                    val startY = call.argument<Double>("startY") ?: 0.0
//                    val endX = call.argument<Double>("endX") ?: 0.0
//                    val endY = call.argument<Double>("endY") ?: 0.0
//                    findPedestrianRoute(startX, startY, endX, endY, result)
//                }

                else -> {
                    result.notImplemented()
                }
            }
        }
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory("tmap-view", TMapViewFactory(tMapView))

    }

    private fun initializeTMap(apiKey: String) {
        runOnUiThread {
            tMapView = TMapView(this@MainActivity)
            tMapView.setSKTMapApiKey(apiKey)
//            setContentView(tMapView)

        }

    }

    private fun markCurrentPosition(latitude: Double, longitude: Double) {
        val tItem = TMapMarkerItem()

        tItem.setId("marker1")

        val bitmap: Bitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.point)
        tItem.setIcon(bitmap)
        tItem.setTMapPoint(latitude, longitude)


        tMapView.addTMapMarkerItem(tItem)
        tMapView.setCenterPoint(latitude, longitude, true)

//        val tMapPoint = TMapPoint(latitude, longitude)
//        val markerItem = TMapMarkerItem()
//        markerItem.tMapPoint = tMapPoint
//        markerItem.name = "Current Location"
    }
//    private fun showMap() {
//        // TMapView 초기화 및 표시
//        runOnUiThread {
//            tMapView = TMapView(this)
//            tMapView.setSKTMapApiKey("YOUR_TMAP_API_KEY")
//            setContentView(tMapView)
//        }
//    }
//    private fun findPedestrianRoute(startX: Double, startY: Double, endX: Double, endY: Double, result: MethodChannel.Result) {
//        val url = "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1&format=json"
//
//        val json = JSONObject()
//        json.put("startX", startX.toString())
//        json.put("startY", startY.toString())
//        json.put("endX", endX.toString())
//        json.put("endY", endY.toString())
//        json.put("reqCoordType", "WGS84GEO")
//        json.put("resCoordType", "EPSG3857")
//        json.put("startName", "출발지")
//        json.put("endName", "도착지")
//
//        val body = RequestBody.create(MediaType.parse("application/json; charset=utf-8"), json.toString())
//        val request = Request.Builder()
//            .url(url)
//            .addHeader("appKey", "G47hiGFOOG1mZzstLLeHP342E38U3AT92zGGgq6Q")
//            .post(body)
//            .build()
//
//        client.newCall(request).enqueue(object : Callback {
//            override fun onFailure(call: Call, e: IOException) {
//                result.error("HTTP_ERROR", e.message, null)
//            }
//
//            override fun onResponse(call: Call, response: Response) {
//                if (response.isSuccessful) {
//                    val responseBody = response.body()?.string()
//                    if (responseBody != null) {
//                        val jsonObject = JSONObject(responseBody)
//                        val features = jsonObject.getJSONArray("features")
//
//                        runOnUiThread {
//                            drawRoute(features)
//                        }
//
//                        result.success("Route found and displayed")
//                    } else {
//                        result.error("NO_RESPONSE", "No response from server", null)
//                    }
//                } else {
//                    result.error("HTTP_ERROR", "HTTP error code: ${response.code()}", null)
//                }
//            }
//        })
//    }
//
//    private fun drawRoute(features: JSONArray) {
//        val path = ArrayList<TMapPoint>()
//
//        for (i in 0 until features.length()) {
//            val feature = features.getJSONObject(i)
//            val geometry = feature.getJSONObject("geometry")
//            val coordinates = geometry.getJSONArray("coordinates")
//
//            for (j in 0 until coordinates.length()) {
//                val coord = coordinates.getJSONArray(j)
//                val point = TMapPoint(coord.getDouble(1), coord.getDouble(0))
//                path.add(point)
//            }
//        }
//
//        val polyline = TMapPolyLine()
//        polyline.lineColor = Color.RED
//        polyline.lineWidth = 2
//        polyline.addLinePoint(path)
//
//        tMapView.addTMapPolyLine("Line1", polyline)
//    }
//}
}