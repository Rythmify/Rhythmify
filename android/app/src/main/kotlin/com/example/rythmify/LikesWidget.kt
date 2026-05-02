package com.example.rythmify

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.PorterDuff
import android.graphics.PorterDuffXfermode
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.URL

class LikesWidget : AppWidgetProvider() {

    enum class LayoutType { ROW, FEATURE, MINI }

    companion object {
        private const val PREFS_NAME = "HomeWidgetPreferences"
        const val MAX_TRACKS = 5

        private val TRACK_VIEW_IDS = listOf(
            R.id.likes_track_0, R.id.likes_track_1, R.id.likes_track_2,
            R.id.likes_track_3, R.id.likes_track_4
        )

        fun triggerUpdate(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, LikesWidget::class.java))
            if (ids.isEmpty()) return
            val intent = Intent(context, LikesWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            context.sendBroadcast(intent)
        }

        fun updateWidget(
            context: Context,
            manager: AppWidgetManager,
            widgetId: Int,
            // MAX values = actual available space; defaults assume a medium-size placement
            width: Int = 300,
            height: Int = 150
        ) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val trackCount = minOf(prefs.getInt("likes_track_count", 0), MAX_TRACKS)
            val userId = prefs.getString("likes_user_id", "") ?: ""
            val pfpUrl = prefs.getString("likes_pfp_url", null)

            val layout = chooseLayout(width, height)
            val views = when (layout) {
                LayoutType.MINI -> buildMiniViews(context, prefs, trackCount)
                LayoutType.ROW -> buildRowViews(context, prefs, trackCount, userId, width)
                LayoutType.FEATURE -> buildFeatureViews(context, prefs, trackCount, userId)
            }

            manager.updateAppWidget(widgetId, views)

            // Async: fetch bitmaps and re-draw
            CoroutineScope(Dispatchers.IO).launch {
                val pfpBitmap = if (!pfpUrl.isNullOrBlank()) loadCircleBitmap(pfpUrl) else null
                val artUrls = (0 until trackCount).map { i ->
                    prefs.getString("likes_track_${i}_art", null)
                }
                val artBitmaps = artUrls.map { url ->
                    if (!url.isNullOrBlank()) loadBitmap(url) else null
                }

                withContext(Dispatchers.Main) {
                    when (layout) {
                        LayoutType.ROW -> {
                            pfpBitmap?.let { views.setImageViewBitmap(R.id.likes_pfp, it) }
                            val n = tracksToShow(width, trackCount)
                            artBitmaps.forEachIndexed { i, bmp ->
                                if (i < n && bmp != null) {
                                    views.setImageViewBitmap(TRACK_VIEW_IDS[i], bmp)
                                }
                            }
                        }
                        LayoutType.FEATURE -> {
                            pfpBitmap?.let { views.setImageViewBitmap(R.id.likes_pfp, it) }
                            artBitmaps.firstOrNull()?.let {
                                views.setImageViewBitmap(R.id.likes_feature_art, it)
                            }
                        }
                        LayoutType.MINI -> {
                            artBitmaps.firstOrNull()?.let {
                                views.setImageViewBitmap(R.id.likes_mini_art, it)
                            }
                        }
                    }
                    manager.updateAppWidget(widgetId, views)
                }
            }
        }

        // width/height = MAX dimensions (available space) from the options bundle.
        // ROW: compact height (1 cell ≈ 60-100dp). MINI: narrow width (1 cell ≈ 60-100dp).
        private fun chooseLayout(width: Int, height: Int): LayoutType = when {
            width < 130 -> LayoutType.MINI
            height < 130 -> LayoutType.ROW
            else -> LayoutType.FEATURE
        }

        // On a 360dp screen the 4-cell full-width widget is ~288dp — well under 300.
        // Lower thresholds to match real device grid sizes.
        private fun tracksToShow(width: Int, totalCount: Int): Int {
            val maxByWidth = when {
                width >= 250 -> 5
                width >= 160 -> 2
                else -> 1
            }
            return minOf(maxByWidth, totalCount)
        }

        private fun buildRowViews(
            context: Context,
            prefs: android.content.SharedPreferences,
            trackCount: Int,
            userId: String,
            width: Int
        ): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.likes_widget_row)
            val n = tracksToShow(width, trackCount)

            // views.setOnClickPendingIntent(R.id.likes_root, openLikesIntent(context))
            // views.setOnClickPendingIntent(R.id.likes_pfp, openProfileIntent(context, userId))

            TRACK_VIEW_IDS.forEachIndexed { i, viewId ->
                if (i < n) {
                    views.setViewVisibility(viewId, View.VISIBLE)
                    // val trackId = prefs.getString("likes_track_${i}_id", null)
                    // views.setOnClickPendingIntent(viewId, trackIntent(context, trackId))
                } else {
                    views.setViewVisibility(viewId, View.GONE)
                }
            }

            return views
        }

        private fun buildFeatureViews(
            context: Context,
            prefs: android.content.SharedPreferences,
            trackCount: Int,
            userId: String
        ): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.likes_widget_feature)

            // views.setOnClickPendingIntent(R.id.likes_root, openLikesIntent(context))
            // views.setOnClickPendingIntent(R.id.likes_pfp, openProfileIntent(context, userId))

            // val trackId = if (trackCount > 0) prefs.getString("likes_track_0_id", null) else null
            // views.setOnClickPendingIntent(R.id.likes_feature_art, trackIntent(context, trackId))

            return views
        }

        private fun buildMiniViews(
            context: Context,
            prefs: android.content.SharedPreferences,
            trackCount: Int
        ): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.likes_widget_mini)

            // views.setOnClickPendingIntent(R.id.likes_root, openLikesIntent(context))

            // val trackId = if (trackCount > 0) prefs.getString("likes_track_0_id", null) else null
            // views.setOnClickPendingIntent(R.id.likes_mini_art, trackIntent(context, trackId))

            return views
        }

        private fun openLikesIntent(context: Context): PendingIntent =
            HomeWidgetLaunchIntent.getActivity(
                context, MainActivity::class.java,
                Uri.parse("rythmify://likes_open")
            )

        private fun openProfileIntent(context: Context, userId: String): PendingIntent =
            HomeWidgetLaunchIntent.getActivity(
                context, MainActivity::class.java,
                Uri.parse("rythmify://likes_profile?userId=${Uri.encode(userId)}")
            )

        private fun trackIntent(context: Context, trackId: String?): PendingIntent {
            val uri = if (!trackId.isNullOrBlank())
                Uri.parse("rythmify://likes_track?id=${Uri.encode(trackId)}")
            else Uri.parse("rythmify://likes_open")
            return HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, uri)
        }

        private fun loadBitmap(url: String): Bitmap? = try {
            BitmapFactory.decodeStream(URL(url).openStream())
        } catch (_: Exception) {
            null
        }

        private fun loadCircleBitmap(url: String): Bitmap? {
            val bmp = loadBitmap(url) ?: return null
            val size = minOf(bmp.width, bmp.height)
            val output = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(output)
            val paint = Paint(Paint.ANTI_ALIAS_FLAG)
            canvas.drawCircle(size / 2f, size / 2f, size / 2f, paint)
            paint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_IN)
            val scaled = Bitmap.createScaledBitmap(bmp, size, size, true)
            canvas.drawBitmap(scaled, 0f, 0f, paint)
            return output
        }
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        appWidgetIds.forEach { id ->
            val opts = appWidgetManager.getAppWidgetOptions(id)
            val w = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH, 300)
            val h = opts.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 150)
            updateWidget(context, appWidgetManager, id, w, h)
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        val w = newOptions.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_WIDTH, 300)
        val h = newOptions.getInt(AppWidgetManager.OPTION_APPWIDGET_MAX_HEIGHT, 150)
        updateWidget(context, appWidgetManager, appWidgetId, w, h)
    }
}
