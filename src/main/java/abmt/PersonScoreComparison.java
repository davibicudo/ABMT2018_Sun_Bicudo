package abmt;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Scanner;

import org.matsim.api.core.v01.Id;
import org.matsim.api.core.v01.Scenario;
import org.matsim.api.core.v01.network.Link;
import org.matsim.api.core.v01.population.Leg;
import org.matsim.api.core.v01.population.Person;
import org.matsim.api.core.v01.population.PlanElement;
import org.matsim.api.core.v01.population.Population;
import org.matsim.core.config.ConfigUtils;
import org.matsim.core.population.io.PopulationReader;
import org.matsim.core.population.routes.NetworkRoute;
import org.matsim.core.scenario.ScenarioUtils;

public class PersonScoreComparison {

	public static void main(String[] args) throws IOException {
		// read closed links
		String closedLinksPath = "analysis/links2close.txt";
		Scanner s = new Scanner(new File(closedLinksPath));
		HashSet<Id<Link>> closedLinks = new HashSet<>();
		while (s.hasNext()){
		    closedLinks.add(Id.createLinkId(s.next().trim()));
		}
		s.close();
		
		// find persons who previously used closed links and get their score
		String outputBaseline = "analysis/simulation_output_baseline";
		Population popBaseline = readPopulation(outputBaseline+"/output_plans.xml.gz");
		HashMap<Id<Person>, Double> affectedPersonsBaseline = new HashMap<>();
		for (Person person : popBaseline.getPersons().values()) {
			for (PlanElement pe : person.getSelectedPlan().getPlanElements()) {
				if (pe instanceof Leg) {
					NetworkRoute route = (NetworkRoute) ((Leg) pe).getRoute();
					if (!Collections.disjoint(closedLinks, route.getLinkIds())) {
						affectedPersonsBaseline.put(person.getId(), person.getSelectedPlan().getScore());
					}
				}
			}
		}
		
		// find same persons and scores in the other scenarios
		String outputClosedRoads = "analysis/simulation_output_closedRoads";
		Population popClosedRoads = readPopulation(outputClosedRoads+"/output_plans.xml.gz");
		HashMap<Id<Person>, Double> affectedPersonsClosedRoads = new HashMap<>();
		for (Id<Person> person : affectedPersonsBaseline.keySet()) {
			affectedPersonsClosedRoads.put(person, 
					popClosedRoads.getPersons().get(person).getSelectedPlan().getScore());
		}
		String outputWTime = "analysis/simulation_output_WTime";
		Population popWTime = readPopulation(outputWTime+"/output_plans.xml.gz");
		HashMap<Id<Person>, Double> affectedPersonsWTime = new HashMap<>();
		for (Id<Person> person : affectedPersonsBaseline.keySet()) {
			affectedPersonsWTime.put(person, 
					popWTime.getPersons().get(person).getSelectedPlan().getScore());
		}

		// write scores to CSV
		String outputPath = "analysis/scoreComparison.csv";
		BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(outputPath)));
		writer.write("personId;scoreBaseline;scoreClosedRoads;scoreWTime\n");
		writer.flush();
		for (Id<Person> person : affectedPersonsBaseline.keySet()) {
			writer.write(person + ";" +
					String.valueOf(affectedPersonsBaseline.get(person)) + ";" +
					String.valueOf(affectedPersonsClosedRoads.get(person)) + ";" +
					String.valueOf(affectedPersonsWTime.get(person)) + ";" +
					"\n");
			writer.flush();
		}
		writer.close();
	}
	
	public static Population readPopulation(String path) {
		Scenario scenario = ScenarioUtils.createScenario(ConfigUtils.createConfig());
		new PopulationReader(scenario).readFile(path);
		return scenario.getPopulation();
	}
	

}
