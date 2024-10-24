module fxhelloworld {
    requires java.logging;
    requires java.prefs;
    requires javafx.controls;
    requires javafx.graphics;
    requires javafx.fxml;
    requires java.desktop;

    requires static lombok;
    requires java.net.http;

    exports ch.nostromo.fxhelloworld;
    exports ch.nostromo.fxhelloworld.fxui;

    opens ch.nostromo.fxhelloworld;
    opens ch.nostromo.fxhelloworld.fxui;

}