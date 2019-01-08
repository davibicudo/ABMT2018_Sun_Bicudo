// script to load Via scenario quickly
path = "/Users/bicudo/git/ABMT2018_Sun_Bicudo/analysis/";

// load datasets 
scenarios = ["baseline", "closedRoads", "WTime"];
scenario = scenarios[2];

network = via.createDataset(path + "simulation_output_" + scenario + "/output_network.xml.gz");
events = via.createDataset(path + "simulation_output_" + scenario + "/output_events.xml.gz");

// create layers
networkLayer = via.createLayer("network", network);

via.getOverlay("clock").setVisible(false);
via.getOverlay("logo").setVisible(false);
via.getOverlay("north arrow").setVisible(false);
via.getOverlay("legend").setVisible(true);

via.sleep(1000);

// zoom to desired location
via.setTime("08:00:00");
via.getView().zoomTo(648357, 6860501, 653995, 6863648);
via.view.resize(1110, 620);
