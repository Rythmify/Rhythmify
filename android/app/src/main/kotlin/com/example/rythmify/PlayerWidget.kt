package com.example.rythmify

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Build
import android.view.KeyEvent
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.net.URL

class PlayerWidget : AppWidgetProvider() {

    companion object {
        const val ACTION_PREV = "com.example.rythmify.WIDGET_PREV"
        const val ACTION_PLAY_PAUSE = "com.example.rythmify.WIDGET_PLAY_PAUSE"
        const val ACTION_NEXT = "com.example.rythmify.WIDGET_NEXT"

        // home_widget writes to this SharedPreferences file
        private const val PREFS_NAME = "HomeWidgetPreferences"

        fun triggerUpdate(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(ComponentName(context, PlayerWidget::class.java))
            if (ids.isEmpty()) return
            val intent = Intent(context, PlayerWidget::class.java).apply {
                action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
            }
            context.sendBroadcast(intent)
        }

        fun updateWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            val title = prefs.getString("track_title", "No track playing") ?: "No track playing"
            val artist = prefs.getString("artist_name", "") ?: ""
            val isPlaying = prefs.getBoolean("is_playing", false)
            val isLiked = prefs.getBoolean("is_liked", false)
            val artUrl = prefs.getString("art_url", null)

            val views = RemoteViews(context.packageName, R.layout.player_widget)
            views.setTextViewText(R.id.widget_artist, artist)
            views.setTextViewText(R.id.widget_title, title)
            views.setImageViewResource(
                R.id.widget_btn_play_pause,
                if (isPlaying) R.drawable.ic_widget_pause else R.drawable.ic_widget_play
            )
            views.setImageViewResource(
                R.id.widget_btn_like,
                if (isLiked) R.drawable.ic_favorite else R.drawable.ic_favorite_border
            )

            val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
            else
                PendingIntent.FLAG_UPDATE_CURRENT

            views.setOnClickPendingIntent(R.id.widget_btn_prev, broadcast(context, ACTION_PREV, flags))
            views.setOnClickPendingIntent(R.id.widget_btn_play_pause, broadcast(context, ACTION_PLAY_PAUSE, flags))
            views.setOnClickPendingIntent(R.id.widget_btn_next, broadcast(context, ACTION_NEXT, flags))

            val likeIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("rythmify://widget?action=like")
            )
            views.setOnClickPendingIntent(R.id.widget_btn_like, likeIntent)

            val openPlayerIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("rythmify://player")
            )
            views.setOnClickPendingIntent(R.id.widget_album_art, openPlayerIntent)
            views.setOnClickPendingIntent(R.id.widget_text_area, openPlayerIntent)

            manager.updateAppWidget(widgetId, views)

            // Async album art load — update again once the bitmap is ready
            if (!artUrl.isNullOrBlank()) {
                CoroutineScope(Dispatchers.IO).launch {
                    val bitmap = loadBitmap(artUrl)
                    if (bitmap != null) {
                        withContext(Dispatchers.Main) {
                            views.setImageViewBitmap(R.id.widget_album_art, bitmap)
                            manager.updateAppWidget(widgetId, views)
                        }
                    }
                }
            }
        }

        private fun broadcast(context: Context, action: String, flags: Int): PendingIntent {
            val intent = Intent(context, PlayerWidget::class.java).apply { this.action = action }
            return PendingIntent.getBroadcast(context, action.hashCode(), intent, flags)
        }

        private fun loadBitmap(url: String): Bitmap? = try {
            BitmapFactory.decodeStream(URL(url).openStream())
        } catch (_: Exception) {
            null
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        appWidgetIds.forEach { updateWidget(context, appWidgetManager, it) }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_PREV -> mediaKey(context, KeyEvent.KEYCODE_MEDIA_PREVIOUS)
            ACTION_PLAY_PAUSE -> mediaKey(context, KeyEvent.KEYCODE_MEDIA_PLAY_PAUSE)
            ACTION_NEXT -> mediaKey(context, KeyEvent.KEYCODE_MEDIA_NEXT)
        }
    }

    private fun mediaKey(context: Context, keyCode: Int) {
        for (action in listOf(KeyEvent.ACTION_DOWN, KeyEvent.ACTION_UP)) {
            val intent = Intent(context, com.ryanheise.audioservice.MediaButtonReceiver::class.java).apply {
                this.action = Intent.ACTION_MEDIA_BUTTON
                putExtra(Intent.EXTRA_KEY_EVENT, KeyEvent(action, keyCode))
            }
            context.sendBroadcast(intent)
        }
    }
}
