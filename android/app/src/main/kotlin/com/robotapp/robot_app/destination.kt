package com.robotapp.robot_app

data class Feature(
    val type: String,
    val geometry: Geometry,
    val properties: Properties
)

data class Geometry(
    val type: String,
    val coordinates: List<Double>
)

data class Properties(
    val index: Int,
    val pointIndex: Int,
    val name: String,
    val guidePointName: String,
    val description: String,
    val direction: String,
    val intersectionName: String,
    val nearPoiName: String,
    val nearPoiX: String,
    val nearPoiY: String,
    val crossName: String,
    val turnType: Int,
    val pointType: String
)


data class Destination(
    val type: String,
    val features: Array<Feature>,
)

