package ink.bop.demo

import android.app.Activity
import android.os.Bundle
import android.view.Gravity
import android.widget.ScrollView
import android.widget.TextView
import ink.bop.data.BopDataClient

class MainActivity : Activity() {
    override fun onCreate(state: Bundle?) {
        super.onCreate(state)
        val text = TextView(this).apply { text = "Loading BOP Data…"; textSize = 16f; setPadding(32, 32, 32, 32); gravity = Gravity.START }
        setContentView(ScrollView(this).apply { addView(text) })
        Thread {
            val message = try {
                val client = BopDataClient()
                val entry = client.listDatasets().getJSONArray("datasets").getJSONObject(0)
                val dataset = client.getDataset(entry.getString("canonicalId"))
                "${dataset.optString("canonicalId")}\n\nData\n${dataset.opt("data")}\n\nFreshness\n${dataset.opt("freshness")}\n\nProvenance\n${dataset.opt("provenance")}"
            } catch (e: Exception) { "Unable to load BOP Data. Check your connection and try again." }
            runOnUiThread { if (!isFinishing && !isDestroyed) text.text = message }
        }.start()
    }
}
