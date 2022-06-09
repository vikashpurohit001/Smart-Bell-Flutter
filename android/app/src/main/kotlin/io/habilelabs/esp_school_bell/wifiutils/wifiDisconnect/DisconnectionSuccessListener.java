package io.habilelabs.esp_school_bell.wifiutils.wifiDisconnect;

import androidx.annotation.NonNull;

public interface DisconnectionSuccessListener {
    void success();

    void failed(@NonNull DisconnectionErrorCode errorCode);
}