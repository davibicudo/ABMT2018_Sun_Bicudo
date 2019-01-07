package org.matsim.network;

import java.util.HashSet;

import org.matsim.api.core.v01.Id;
import org.matsim.api.core.v01.Scenario;
import org.matsim.api.core.v01.network.Link;
import org.matsim.api.core.v01.network.Network;
import org.matsim.core.config.ConfigUtils;
import org.matsim.core.network.io.NetworkReaderMatsimV1;
import org.matsim.core.network.io.NetworkWriter;
import org.matsim.core.scenario.ScenarioUtils;

public class CloseLinks {

	public static void main(String[] args) {
		String path = "original-input-data/ile_de_france_network_simplified.xml.gz";
		String output = "simulation_input/network_closedRoads.xml.gz";
		
		Scenario scenario = ScenarioUtils.createScenario(ConfigUtils.createConfig());
		new NetworkReaderMatsimV1(scenario.getNetwork()).readFile(path);
		Network network = scenario.getNetwork();
		String[] linkIds = new String[] {
				"432525-432552","378901-219082","215563-432524","77417","77414","529627",
				"383318-514882","240395","319528","179601-204222","525852","496522","496523",
				"209518","247139","334430","563213","563209","563210","563230","563214","563215",
				"79963","563230","79960","79960","563221-563212","563218","563231","563205","563206",
				"563231","563221-563212","563225","199-608079","450308","346923","240977",
				"327433-437443-389258","240122","499496-226050","250643","240276","240277",
				"247122-3887","240278","240279","448845","589946","448844","496526","589952",
				"448846-589949","448843","455368-236178-602113","287613","287614","416986","287615",
				"287616","159385","159386","272529","272530","159387","159388","512036","600093",
				"159389","159390","272531","272532","306474","600092","527253","527254","600097",
				"600104","236003","236004","79429","460880-556287","79427-79428","402812","6931",
				"6932","6933","600119","6934","6935","6936",
				//newly closed links
				"510840","510839","600095-155904","310145","600106-155909-600094"

		};
		
		for (String id : linkIds) {
			Link link = network.getLinks().get(Id.createLinkId(id));
			link.setAllowedModes(new HashSet<>());
			link.setCapacity(0.0);
		}
		
		new NetworkWriter(network).write(output);
	}

}