package GUI;

import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class Main extends Application{
    public static void main(){
        launch();
    }

    @Override
    public void start(Stage stage) throws Exception {
        Parent root = FXMLLoader.load(getClass().getResource("GUI/Home.fxml"));
        Scene scene = new Scene(root);
        String css = this.getClass().getResource("GUI/style.css").toExternalForm();
        scene.getStylesheets().add(css);
        stage.setTitle("Project2022-2023");
        stage.setWidth(1920);
        stage.setHeight(1080);

        stage.setScene(scene);
        stage.show();
    }
}