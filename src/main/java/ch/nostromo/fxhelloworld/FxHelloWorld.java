package ch.nostromo.fxhelloworld;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

import java.io.IOException;

public class FxHelloWorld extends Application {


    /*
     * (non-Javadoc)
     * 
     * @see javafx.application.Application#start(javafx.stage.Stage)
     */
    @Override
    public void start(Stage primaryStage) throws IOException {

        FXMLLoader fxmlLoader = new FXMLLoader(FxHelloWorld.class.getResource("/fxml/Main.fxml"));
        Parent root = fxmlLoader.load();

        primaryStage.setTitle("FXHelloWorld");
        primaryStage.setScene(new Scene(root));
        primaryStage.show();

    }

    /**
     * The main method.
     *
     * @param args
     *            the arguments
     */
    public static void main(String[] args) {
        launch(args);
    }
    
}
