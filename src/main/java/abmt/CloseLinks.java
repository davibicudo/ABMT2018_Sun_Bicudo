package abmt;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Scanner;

import org.matsim.api.core.v01.Id;
import org.matsim.api.core.v01.Scenario;
import org.matsim.api.core.v01.network.Link;
import org.matsim.api.core.v01.network.Network;
import org.matsim.core.config.ConfigUtils;
import org.matsim.core.network.io.NetworkReaderMatsimV1;
import org.matsim.core.network.io.NetworkWriter;
import org.matsim.core.scenario.ScenarioUtils;

public class CloseLinks {

	public static void main(String[] args) throws FileNotFoundException {
		String path = "original-input-data/ile_de_france_network_simplified.xml.gz";
		String output = "simulation_input/network_closedRoads.xml.gz";
		String linksToClosePath = "analysis/links2close.txt";
		
		Scenario scenario = ScenarioUtils.createScenario(ConfigUtils.createConfig());
		new NetworkReaderMatsimV1(scenario.getNetwork()).readFile(path);
		Network network = scenario.getNetwork();
		
		Scanner s = new Scanner(new File(linksToClosePath));
		ArrayList<Id<Link>> linksToClose = new ArrayList<>();
		while (s.hasNext()){
		    linksToClose.add(Id.createLinkId(s.next().trim()));
		}
		s.close();
		
		for (Id<Link> id : linksToClose) {
			Link link = network.getLinks().get(id);
			link.setAllowedModes(new HashSet<>());
			link.setCapacity(0.0);
		}
		
		new NetworkWriter(network).write(output);
	}

}