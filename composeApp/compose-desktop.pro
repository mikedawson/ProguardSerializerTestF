#BEGIN : Kotlinx Serialization rules as per https://github.com/Kotlin/kotlinx.serialization/blob/master/rules/common.pro
# Keep `Companion` object fields of serializable classes.
# This avoids serializer lookup through `getDeclaredClasses` as done for named companion objects.
-if @kotlinx.serialization.Serializable class **
-keepclassmembers class <1> {
    static <1>$Companion Companion;
}

# Keep `serializer()` on companion objects (both default and named) of serializable classes.
-if @kotlinx.serialization.Serializable class ** {
    static **$* *;
}
-keepclassmembers class <2>$<3> {
    kotlinx.serialization.KSerializer serializer(...);
}

# Keep `INSTANCE.serializer()` of serializable objects.
-if @kotlinx.serialization.Serializable class ** {
    public static ** INSTANCE;
}
-keepclassmembers class <1> {
    public static <1> INSTANCE;
    kotlinx.serialization.KSerializer serializer(...);
}

# @Serializable and @Polymorphic are used at runtime for polymorphic serialization.
-keepattributes RuntimeVisibleAnnotations,AnnotationDefault

# Don't print notes about potential mistakes or omissions in the configuration for kotlinx-serialization classes
# See also https://github.com/Kotlin/kotlinx.serialization/issues/1900
-dontnote kotlinx.serialization.**

# Serialization core uses `java.lang.ClassValue` for caching inside these specified classes.
# If there is no `java.lang.ClassValue` (for example, in Android), then R8/ProGuard will print a warning.
# However, since in this case they will not be used, we can disable these warnings
-dontwarn kotlinx.serialization.internal.ClassValueReferences

# END: Kotlinx Serialization rules

# BEGIN OKHTTP rules
# JSR 305 annotations are for embedding nullability information.
-dontwarn javax.annotation.**

# A resource is loaded with a relative path so the package of this class must be preserved.
-keeppackagenames okhttp3.internal.publicsuffix.*
-adaptresourcefilenames okhttp3/internal/publicsuffix/PublicSuffixDatabase.gz

# Animal Sniffer compileOnly dependency to ensure APIs are compatible with older versions of Java.
-dontwarn org.codehaus.mojo.animal_sniffer.*

# OkHttp platform used only on JVM and when Conscrypt and other security providers are available.
-dontwarn okhttp3.internal.platform.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# END OKHTTP Rules

### Begin KTOR https://github.com/ktorio/ktor/blob/main/ktor-utils/jvm/resources/META-INF/proguard/ktor.pro

# Most of volatile fields are updated with AtomicFU and should not be mangled/removed
-keepclassmembers class io.ktor.** {
    volatile <fields>;
}

-keepclassmembernames class io.ktor.** {
    volatile <fields>;
}

# client engines are loaded using ServiceLoader so we need to keep them
-keep class io.ktor.client.engine.** implements io.ktor.client.HttpClientEngineContainer


### END KTOR https://github.com/ktorio/ktor/blob/main/ktor-utils/jvm/resources/META-INF/proguard/ktor.pro

# There are rules for ktor server,  but these should not be applicable to client, and
# they don't fix the client .body call issue https://github.com/ktorio/ktor-documentation/blob/2.3.7/codeSnippets/snippets/proguard/proguard.pro

# KTOR Client users service provision to load - so these classes must not be obfuscated
-keep class io.ktor.client.engine.okhttp.OkHttp { * ; }
-keep class io.ktor.client.engine.okhttp.OkHttpEngineContainer { * ; }
-keep interface io.ktor.client.HttpClientEngineContainer { * ; }



# Stuff relating to logging factory - required as soon as you add ktor to the classpath
-keep class org.slf4j.**

-keep class ch.qos.** { *; }
-dontwarn org.apache.tools.ant.taskdefs.compilers.**
-dontwarn org.codehaus.janino.AntCompilerAdapter
