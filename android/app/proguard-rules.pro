# --------------------------------------
# Stripe related rules
# --------------------------------------
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# --------------------------------------
# Razorpay related rules
# --------------------------------------
-keepattributes *Annotation*
-dontwarn com.razorpay.**
-keep class com.razorpay.** {*;}
-optimizations !method/inlining/
-keepclasseswithmembers class * {
  public void onPayment*(...);
}

# --------------------------------------
# Gson DateTypeAdapter fix
# Required to prevent R8 from removing this class
# --------------------------------------
-keep class com.google.gson.internal.bind.DateTypeAdapter { *; }
-dontwarn com.google.gson.internal.bind.DateTypeAdapter