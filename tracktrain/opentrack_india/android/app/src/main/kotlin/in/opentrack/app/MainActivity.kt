package `in`.opentrack.app

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.os.Build
import android.telephony.CellIdentityGsm
import android.telephony.CellIdentityLte
import android.telephony.CellIdentityNr
import android.telephony.CellIdentityWcdma
import android.telephony.CellInfo
import android.telephony.CellInfoGsm
import android.telephony.CellInfoLte
import android.telephony.CellInfoNr
import android.telephony.CellInfoWcdma
import android.telephony.TelephonyManager
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Hosts two platform channels:
 *
 *  - `in.opentrack/cell_info`  : serving-cell identities (MCC/MNC/LAC/CID)
 *    from TelephonyManager for the offline Cell Tower tracking mode.
 *  - `in.opentrack/tracking`   : starts/stops the location foreground
 *    service that keeps the Dart geofence loop alive with the screen off.
 */
class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CELL_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getServingCellInfo" -> result.success(readCellInfo())
                    else -> result.notImplemented()
                }
            }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TRACKING_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startForeground" -> {
                        TrackingForegroundService.start(this)
                        result.success(true)
                    }
                    "stopForeground" -> {
                        TrackingForegroundService.stop(this)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    @SuppressLint("MissingPermission")
    private fun readCellInfo(): List<Map<String, Any?>> {
        val hasLocation = ContextCompat.checkSelfPermission(
            this,
            Manifest.permission.ACCESS_FINE_LOCATION,
        ) == PackageManager.PERMISSION_GRANTED
        if (!hasLocation) return emptyList()

        val telephony = getSystemService(TELEPHONY_SERVICE) as? TelephonyManager
            ?: return emptyList()

        return try {
            telephony.allCellInfo
                ?.mapNotNull { describe(it) }
                ?: emptyList()
        } catch (t: Throwable) {
            // OEMs occasionally throw inside telephony internals; cell mode
            // simply becomes unavailable instead of crashing the app.
            emptyList()
        }
    }

    private fun describe(info: CellInfo): Map<String, Any?>? {
        val described: Map<String, Any?>? = when (info) {
            is CellInfoGsm -> {
                val identity: CellIdentityGsm = info.cellIdentity
                mapOf(
                    "tech" to "GSM",
                    "mcc" to numericFor(
                        { identity.mccString },
                        { gsmMccLegacy(identity) },
                    ),
                    "mnc" to numericFor(
                        { identity.mncString },
                        { gsmMncLegacy(identity) },
                    ),
                    "lac" to identity.lac,
                    "cid" to identity.cid,
                    "signalDbm" to info.cellSignalStrength.dbm,
                )
            }
            is CellInfoLte -> {
                val identity: CellIdentityLte = info.cellIdentity
                mapOf(
                    "tech" to "LTE",
                    "mcc" to numericFor(
                        { identity.mccString },
                        { lteMccLegacy(identity) },
                    ),
                    "mnc" to numericFor(
                        { identity.mncString },
                        { lteMncLegacy(identity) },
                    ),
                    "lac" to identity.tac,
                    "cid" to identity.ci,
                    "signalDbm" to info.cellSignalStrength.dbm,
                )
            }
            is CellInfoWcdma -> {
                val identity: CellIdentityWcdma = info.cellIdentity
                mapOf(
                    "tech" to "WCDMA",
                    "mcc" to numericFor(
                        { identity.mccString },
                        { wcdmaMccLegacy(identity) },
                    ),
                    "mnc" to numericFor(
                        { identity.mncString },
                        { wcdmaMncLegacy(identity) },
                    ),
                    "lac" to identity.lac,
                    "cid" to identity.cid,
                    "signalDbm" to info.cellSignalStrength.dbm,
                )
            }
            else -> describeNewRadio(info)
        }

        if (described == null) return null

        val lac = described["lac"] as? Int ?: Int.MAX_VALUE
        val cid = described["cid"] as? Int ?: Int.MAX_VALUE
        if (lac == Int.MAX_VALUE || cid == Int.MAX_VALUE || lac < 0 || cid < 0) {
            return null
        }
        return described
    }

    /**
     * 5G NR cells live behind an API 29 gate so the CellInfoNr class is never
     * resolved on older devices.
     */
    private fun describeNewRadio(info: CellInfo): Map<String, Any?>? {
        if (Build.VERSION.SDK_INT < 29) return null
        val nr = info as? CellInfoNr ?: return null
        val identity = nr.cellIdentity as? CellIdentityNr ?: return null
        return mapOf(
            "tech" to "NR",
            "mcc" to identity.mccString?.toIntOrNull(),
            "mnc" to identity.mncString?.toIntOrNull(),
            "lac" to identity.tac,
            "cid" to (identity.nci and 0x7FFFFFFF).toInt(),
            "signalDbm" to nr.cellSignalStrength.dbm,
        )
    }

    // Pre-API 28 fallbacks return Int directly.
    @Suppress("DEPRECATION")
    private fun gsmMccLegacy(identity: CellIdentityGsm): Int = identity.mcc
    @Suppress("DEPRECATION")
    private fun gsmMncLegacy(identity: CellIdentityGsm): Int = identity.mnc
    @Suppress("DEPRECATION")
    private fun lteMccLegacy(identity: CellIdentityLte): Int = identity.mcc
    @Suppress("DEPRECATION")
    private fun lteMncLegacy(identity: CellIdentityLte): Int = identity.mnc
    @Suppress("DEPRECATION")
    private fun wcdmaMccLegacy(identity: CellIdentityWcdma): Int = identity.mcc
    @Suppress("DEPRECATION")
    private fun wcdmaMncLegacy(identity: CellIdentityWcdma): Int = identity.mnc

    /**
     * Resolves MCC/MNC across the API-28 string-getter boundary. Lambdas keep
     * both paths lazy so no method from the wrong API level is ever touched.
     */
    private fun numericFor(modern: () -> String?, legacy: () -> Int): Int? {
        return if (Build.VERSION.SDK_INT >= 28) {
            modern()?.toIntOrNull()
        } else {
            legacy().takeIf { it != Int.MAX_VALUE }
        }
    }

    private companion object {
        const val CELL_CHANNEL = "in.opentrack/cell_info"
        const val TRACKING_CHANNEL = "in.opentrack/tracking"
    }
}
