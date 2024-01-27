import androidx.compose.desktop.ui.tooling.preview.Preview
import androidx.compose.runtime.Composable
import androidx.compose.ui.window.Window
import androidx.compose.ui.window.application
import entities.AnEntity
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.runBlocking
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.mockwebserver.MockResponse
import okhttp3.mockwebserver.MockWebServer

fun main() = application {
    val json = Json { encodeDefaults = true }
    val entity = AnEntity(name = "Hello World")
    val entityJsonStr = json.encodeToString(entity)
    println("entity json = $entityJsonStr")
    val entityFromSerial: AnEntity = json.decodeFromString(entityJsonStr)
    println("entity = $entityFromSerial name=${entityFromSerial.name}")

    val mockWebServer = MockWebServer()
    mockWebServer.enqueue(MockResponse()
        .setHeader("content-type", "application/json")
        .setBody(entityJsonStr))
    mockWebServer.start()

    val okHttpClient = OkHttpClient.Builder().build()
    val httpClient = HttpClient(io.ktor.client.engine.okhttp.OkHttp) {
        install(io.ktor.client.plugins.contentnegotiation.ContentNegotiation) {
            json(json)
        }

        engine {
            preconfigured = okHttpClient
        }
    }
    println("Requesting entity over http")
    val entityFromHttp: AnEntity = runBlocking {
        httpClient.get(mockWebServer.url("/").toString()).body()
    }
    println("From http over ktor: $entityFromHttp")

    Window(onCloseRequest = ::exitApplication, title = "ProguardSerializerTestF") {
        App()
    }
}

@Preview
@Composable
fun AppDesktopPreview() {
    App()
}