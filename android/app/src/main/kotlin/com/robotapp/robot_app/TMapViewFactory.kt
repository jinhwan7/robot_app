package com.robotapp.robot_app


import android.content.Context
import android.util.Log
import android.view.View
import com.skt.tmap.TMapView
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory


class TMapViewFactory(private val tMapView: TMapView) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d("TMapViewFactory", "Creating TMapView with viewId: $viewId")

        tMapView.setSKTMapApiKey("G47hiGFOOG1mZzstLLeHP342E38U3AT92zGGgq6Q")


//        tMapView.setOnMapReadyListener(object : TMapView.OnMapReadyListener {
//            override fun onMapReady() {
//                Log.d("TMapViewFactory", "TMapView is ready")
//                // 여기에 맵 로딩이 완료된 후 수행할 작업을 구현합니다.
//            }
//        })

        return TMapViewPlatformView(tMapView)
    }

}

class TMapViewPlatformView(private val view: View) : PlatformView {
    override fun getView(): View {
//        Log.d("TMapView_GETVIEW", "이게 몇번 나오나?")
        return view
    }

    override fun dispose() {}
}
