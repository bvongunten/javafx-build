package ch.nostromo.fxhelloworld.fxui;

import javafx.application.Platform;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;

public class MainController {


    @FXML
    void onQuit(ActionEvent event) {
        Platform.exit();
    }

}
