package io.habilelabs.esp_school_bell.wifiutils.wifiRemove;

import androidx.annotation.NonNull;

public interface RemoveSuccessListener {
    void success();

    void failed(@NonNull RemoveErrorCode errorCode);
}
