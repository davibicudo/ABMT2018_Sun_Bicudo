package abmt;

import java.io.IOException;

import ch.ethz.matsim.baseline_scenario.analysis.trips.run.ConvertTripsFromEvents;

public class Events2Trips {

	public static void main(String[] args) throws IOException {
		String outputFolderPath = "analysis/simulation_output_WTime";
		
		String networkPath = outputFolderPath + "/output_network.xml.gz";
		String eventsPath  = outputFolderPath + "/output_events.xml.gz";
		String outputTripsPath = outputFolderPath.replaceAll("simulation_output_", "") + ".csv";
		ConvertTripsFromEvents.main(new String[] {networkPath, eventsPath, outputTripsPath});
	}

}
