import 'package:geography_geyser/models/quiz_model.dart';

class StaticQuestionsBank {
  StaticQuestionsBank._();

  static List<QuestionModel> getQuestionsForTopic(
    String moduleId, {
    int eqNumber = 1,
    String? customPrefix,
  }) {
    final normalized = moduleId.toLowerCase();
    if (normalized.contains('tectonic')) return _tectonicsQuestions(eqNumber);
    if (normalized.contains('carbon')) return _carbonQuestions(eqNumber);
    if (normalized.contains('water')) return _waterQuestions(eqNumber);
    if (normalized.contains('global')) return _globalisationQuestions(eqNumber);
    if (normalized.contains('superpower')) return _superpowersQuestions(eqNumber);
    if (normalized.contains('coast')) return _coastsQuestions(eqNumber);
    if (normalized.contains('glacier')) return _glaciersQuestions(eqNumber);
    if (normalized.contains('regenerat')) return _regenerationQuestions(eqNumber);
    if (normalized.contains('diverse')) return _diversePlacesQuestions(eqNumber);
    if (normalized.contains('migrat')) return _migrationQuestions(eqNumber);
    if (normalized.contains('health')) return _healthQuestions(eqNumber);
    if (normalized.contains('hhri') || normalized.contains('human')) {
      return _hhriQuestions(eqNumber);
    }
    return _synopticQuestions();
  }

  static QuestionModel _q(
    String id,
    String text,
    String o1,
    String o2,
    String o3,
    String o4,
    String correct,
  ) {
    return QuestionModel(
      id: id,
      questionText: text,
      options: QuestionOptions(
        option1: o1,
        option2: o2,
        option3: o3,
        option4: o4,
      ),
      correctAnswer: correct,
    );
  }

  static List<QuestionModel> _tectonicsQuestions(int eq) => [
        _q(
          'tec_${eq}_1',
          'In the Pressure and Release (PAR) model, how is Disaster Risk formulated?',
          'Risk = (Hazard × Vulnerability) ÷ Capacity to Cope',
          'Risk = Hazard + Tectonic Magnitude × Depth',
          'Risk = Vulnerability ÷ (Plate Velocity × Governance)',
          'Risk = Capacity to Cope − Root Causes',
          'option1',
        ),
        _q(
          'tec_${eq}_2',
          'Which geophysical boundary drives high-magnitude megathrust earthquakes and tsunamis in subduction zones?',
          'Convergent (destructive) oceanic-continental/oceanic boundary',
          'Divergent mid-ocean ridge spreading centre',
          'Conservative transform fault system',
          'Intraplate hot-spot mantle plume',
          'option1',
        ),
        _q(
          'tec_${eq}_3',
          'In Degg’s Model of disaster overlap, when does a natural hazard become a disaster?',
          'Only when a geophysical event intersects with a vulnerable human population',
          'Whenever an earthquake exceeds 6.0 on the Moment Magnitude Scale',
          'When primary volcanic tephra reaches the stratosphere',
          'When insurance losses exceed 1% of national GDP',
          'option1',
        ),
        _q(
          'tec_${eq}_4',
          'What does the "Swiss Cheese Model" illustrate in Geography Geyser’s tectonic governance analysis?',
          'Multiple layers of hazard mitigation where aligned weaknesses allow a disaster to occur',
          'Porous limestone karst topography near volcanic calderas',
          'Vesicular basalt cooling rates at constructive boundaries',
          'Liquefaction cavities in unconsolidated coastal alluvium',
          'option1',
        ),
        _q(
          'tec_${eq}_5',
          'According to Park’s Disaster Response Curve, which stage involves restoring permanent infrastructure to reduce future vulnerability?',
          'Reconstruction and long-term mitigation ("Build Back Better")',
          'Relief and immediate search-and-rescue operations',
          'Temporary rehabilitation and emergency shelter',
          'Pre-disaster equilibrium baseline',
          'option1',
        ),
        _q(
          'tec_${eq}_6',
          'Which secondary tectonic hazard occurs when saturated, unconsolidated sediments lose shear strength during seismic shaking?',
          'Soil liquefaction',
          'Pyroclastic density current (nuée ardente)',
          'Jökulhlaup glacial outburst flood',
          'P-wave crustal compression',
          'option1',
        ),
      ];

  static List<QuestionModel> _carbonQuestions(int eq) => [
        _q(
          'car_${eq}_1',
          'Which carbon store operates over the slowest geological timescale (100–200 million years)?',
          'Lithosphere sedimentary carbonate rocks and fossil fuels',
          'Surface ocean dissolved inorganic carbon',
          'Terrestrial biosphere tropical rainforest biomass',
          'Atmospheric carbon dioxide reservoir',
          'option1',
        ),
        _q(
          'car_${eq}_2',
          'What is the primary mechanism of the oceanic "biological pump"?',
          'Phytoplankton sequestering carbon via photosynthesis and sinking to deep ocean sediments',
          'Thermohaline circulation upwelling warm water at the equator',
          'Chemical weathering of terrestrial silicate rocks by acid rain',
          'Outgassing of CO₂ at submarine hydrothermal vents',
          'option1',
        ),
        _q(
          'car_${eq}_3',
          'In Carbon EQ2 (Energy Security), what defines a country’s "Energy Pathway"?',
          'The physical supply routes (pipelines, LNG tankers, grids) linking energy producers to consumers',
          'The domestic per-capita kilocalorie consumption index',
          'The ratio of nuclear power to solar photovoltaic capacity',
          'The geological depth of unconventional shale gas seams',
          'option1',
        ),
        _q(
          'car_${eq}_4',
          'How does thawing Arctic permafrost act as a positive climate feedback loop?',
          'Microbial decomposition releases stored methane (CH₄) and CO₂, amplifying greenhouse warming',
          'Increased snow cover raises surface albedo and cools the polar troposphere',
          'Boreal forest expansion absorbs excess anthropogenic emissions',
          'Meltwater increases ocean salinity and accelerates the Gulf Stream',
          'option1',
        ),
        _q(
          'car_${eq}_5',
          'Which unconventional fossil fuel extraction in the Athabasca Basin carries high environmental and EROI costs?',
          'Tar sands (bitumen) surface mining and steam-assisted drainage',
          'Deep-water sub-salt offshore drilling',
          'Tidal barrage kinetic harvesting',
          'Geothermal binary-cycle reinjection',
          'option1',
        ),
        _q(
          'car_${eq}_6',
          'Which strategy represents carbon mitigation rather than climate adaptation?',
          'Carbon Capture and Storage (CCS) combined with afforestation and renewable transition',
          'Constructing elevated storm-surge barriers in low-lying deltas',
          'Breeding drought-resistant GM cereal crops in the Sahel',
          'Managed realignment of eroding soft-rock coastlines',
          'option1',
        ),
      ];

  static List<QuestionModel> _waterQuestions(int eq) => [
        _q(
          'wat_${eq}_1',
          'In a drainage basin system, which flux transfers water from the soil store into underlying permeable rock strata?',
          'Percolation',
          'Interception storage',
          'Throughfall',
          'Saturated overland flow',
          'option1',
        ),
        _q(
          'wat_${eq}_2',
          'How does El Niño (ENSO warm phase) typically affect hydrological patterns across the Pacific basin?',
          'Triggers drought in Australia/Indonesia and intense rainfall/flooding along western South America',
          'Causes severe monsoon flooding in Queensland and drought in Peru',
          'Stops all tropical cyclone formation in the Indian Ocean',
          'Permanently reverses the North Atlantic Drift',
          'option1',
        ),
        _q(
          'wat_${eq}_3',
          'According to the Falkenmark Indicator, when is a country classified as experiencing "Absolute Water Scarcity"?',
          'When renewable freshwater availability falls below 500 m³ per person per year',
          'When annual precipitation is less than 1,500 mm per year',
          'When agricultural irrigation exceeds 20% of river discharge',
          'When domestic water tariffs exceed 2% of household income',
          'option1',
        ),
        _q(
          'wat_${eq}_4',
          'Why is transboundary management of the River Nile geopolitically contested between Ethiopia, Sudan, and Egypt?',
          'Upstream impoundment at the Grand Ethiopian Renaissance Dam (GERD) affects downstream flow security',
          'Salinisation of Lake Victoria has halted all commercial shipping',
          'Melting Himalayan glaciers feed 90% of the White Nile',
          'The Helsinki Rules prohibit any hydroelectric power generation in Africa',
          'option1',
        ),
        _q(
          'wat_${eq}_5',
          'How does rapid urbanisation alter a storm hydrograph?',
          'Impermeable surfaces shorten lag time and increase peak discharge (flashy hydrograph)',
          'Urban drainage lengthens lag time and flattens the rising limb',
          'Baseflow increases while stormflow disappears completely',
          'Evapotranspiration doubles across tarmac surfaces',
          'option1',
        ),
      ];

  static List<QuestionModel> _globalisationQuestions(int eq) => [
        _q(
          'glo_${eq}_1',
          'What term did David Harvey coin to describe how jet aviation, containerisation, and fibre-optic ICT reduce the friction of distance?',
          'Time-space compression',
          'Glocalisation',
          'Cumulative causation',
          'Import substitution industrialisation',
          'option1',
        ),
        _q(
          'glo_${eq}_2',
          'Which trio of post-WWII Bretton Woods institutions promote global free trade, financial stability, and development loans?',
          'IMF, World Bank, and WTO',
          'NATO, ASEAN, and OPEC',
          'UNHCR, WHO, and UNESCO',
          'G7, BRICS, and Mercosur',
          'option1',
        ),
        _q(
          'glo_${eq}_3',
          'What is "Glocalisation" in Transnational Corporation (TNC) strategy?',
          'Adapting global brand products to suit local cultural, religious, and dietary preferences',
          'Relocating all headquarters to landlocked developing nations',
          'Imposing identical standardised menus without regional modification',
          'Nationalising foreign-owned assembly plants',
          'option1',
        ),
        _q(
          'glo_${eq}_4',
          'Why are landlocked Sub-Saharan countries like Chad or Central African Republic often described as "switched-off" places?',
          'Lack of coastline, weak infrastructure, political instability, and low FDI inflows limit global integration',
          'High trade tariffs imposed by the European Union Single Market',
          'Over-reliance on quaternary biotechnology exports',
          'Complete absence of natural mineral or agricultural resources',
          'option1',
        ),
        _q(
          'glo_${eq}_5',
          'What does the KOF Index measure in comparative geography?',
          'Economic, social, and political dimensions of globalisation across countries',
          'Income inequality within a single metropolitan area',
          'Carbon intensity per unit of manufacturing GDP',
          'Tectonic seismic vulnerability in megacities',
          'option1',
        ),
      ];

  static List<QuestionModel> _superpowersQuestions(int eq) => [
        _q(
          'sup_${eq}_1',
          'According to Joseph Nye, what distinguishes "Soft Power" from "Hard Power"?',
          'Soft power shapes preferences through cultural appeal, diplomacy, and values rather than military coercion',
          'Soft power relies on naval blockades and economic sanctions',
          'Soft power measures nuclear warhead stockpiles and troop deployment',
          'Soft power refers exclusively to cyber-warfare capabilities',
          'option1',
        ),
        _q(
          'sup_${eq}_2',
          'In Halford Mackinder’s Heartland Theory, why was control of Eastern Europe and Eurasia considered pivotal?',
          'Whoever rules the landlocked Eurasian Heartland commands the "World-Island" and global dominance',
          'Tropical island archipelagos control all global airfreight corridors',
          'Antarctic ice shelves hold the world’s largest oil reserves',
          'South American river basins determine global naval supremacy',
          'option1',
        ),
        _q(
          'sup_${eq}_3',
          'How does China’s Belt and Road Initiative (BRI) expand its geopolitical sphere of influence?',
          'Through strategic infrastructure loans, ports, railways, and trade corridors across Asia, Africa, and Europe',
          'By establishing NATO military bases in the North Atlantic',
          'By abolishing all state-owned enterprises in Beijing',
          'By replacing the Yuan with the Euro for domestic trade',
          'option1',
        ),
        _q(
          'sup_${eq}_4',
          'Why is the South China Sea a major 21st-century geopolitical flashpoint?',
          'Overlapping EEZ claims ("Nine-Dash Line"), artificial island militarisation, and vital global shipping lanes',
          'Melting sea ice has opened the Northwest Passage through the region',
          'Complete depletion of all offshore hydrocarbon reserves in 1990',
          'Disputes over freshwater glacial runoff from the Andes',
          'option1',
        ),
        _q(
          'sup_${eq}_5',
          'In Wallerstein’s World Systems Theory, what is the role of "Semi-Periphery" nations (e.g., Brazil, India, China)?',
          'Dynamic emerging economies with both manufacturing export growth and growing core characteristics',
          'Economies restricted solely to subsistence nomadic pastoralism',
          'Post-industrial nations with zero primary or secondary sector output',
          'Uninhabited polar territories governed by international treaties',
          'option1',
        ),
      ];

  static List<QuestionModel> _coastsQuestions(int eq) => [
        _q(
          'coa_${eq}_1',
          'What geological arrangement characterises a "Concordant (Dalmatian/Haff)" coastline such as Lulworth Cove?',
          'Rock strata run parallel to the coastline, with a resistant outer band protecting softer rock behind',
          'Alternating bands of hard and soft rock meet the coast at right angles (90°)',
          'Purely volcanic basalt columns formed by rapid submarine cooling',
          'Horizontal glacial till sheets with zero lithological variation',
          'option1',
        ),
        _q(
          'coa_${eq}_2',
          'How many major self-contained littoral sediment cells exist around the coastline of England and Wales?',
          '11 major sediment cells',
          '3 major sediment cells',
          '28 major sediment cells',
          '50 major sediment cells',
          'option1',
        ),
        _q(
          'coa_${eq}_3',
          'Why is the Holderness Coast in East Yorkshire one of Europe’s fastest-eroding coastlines (~1.8–2m/year)?',
          'Unconsolidated boulder clay (till) cliffs face high-energy North Sea fetch waves and rotational slumping',
          'Tectonic subduction is rapidly sinking the Yorkshire landmass',
          'Coral reef bleaching has removed offshore wave protection',
          'Tropical cyclones strike the Humber Estuary every summer',
          'option1',
        ),
        _q(
          'coa_${eq}_4',
          'What is the difference between Eustatic and Isostatic sea-level change?',
          'Eustatic is global sea-level change (thermal expansion/ice melt); Isostatic is local land-level readjustment',
          'Eustatic is local tectonic uplift; Isostatic is global ocean warming',
          'Eustatic occurs only in lakes; Isostatic occurs only in trenches',
          'Both terms refer exclusively to daily lunar tidal ranges',
          'option1',
        ),
        _q(
          'coa_${eq}_5',
          'In Odisha, India, how does Integrated Coastal Zone Management (ICZM) sustainably reduce cyclone storm-surge risk?',
          'Restoring mangrove forests as natural bio-shields alongside community early-warning shelters',
          'Building continuous 20-metre concrete seawalls along the entire state',
          'Dredging all offshore sandbars to deepen nearshore waves',
          'Relocating the entire population of Odisha to the Himalayas',
          'option1',
        ),
      ];

  static List<QuestionModel> _glaciersQuestions(int eq) => [
        _q(
          'gla_${eq}_1',
          'What drives "Basal Sliding" in temperate (warm-based) valley glaciers?',
          'Meltwater at the pressure-melting point lubricates the ice-bedrock interface, reducing friction',
          'Sub-zero permafrost freezes the glacier permanently to the valley floor',
          'Wind-blown loess accumulation on the snout surface',
          'Solar radiation melting only the top 2 cm of firn snow',
          'option1',
        ),
        _q(
          'gla_${eq}_2',
          'When does a glacier have a positive net mass balance?',
          'When annual snow/ice accumulation in the upper zone exceeds ablation (melting/calving) in the lower zone',
          'When summer ablation exceeds winter snowfall for a decade',
          'When the equilibrium line altitude (ELA) rises above the mountain summit',
          'When terminal moraines are eroded by meltwater streams',
          'option1',
        ),
        _q(
          'gla_${eq}_3',
          'Which erosional processes work together to carve an armchair-shaped Corrie (Cirque) hollow?',
          'Freeze-thaw weathering (nivation), plucking on the backwall, and rotational abrasion',
          'Fluvial saltation, chemical carbonation, and longshore drift',
          'Aeolian deflation and barchan dune migration',
          'Subaerial biological chelation and soil creep',
          'option1',
        ),
        _q(
          'gla_${eq}_4',
          'How do stratified fluvioglacial deposits (eskers, kames, outwash plains) differ from glacial till?',
          'Fluvioglacial deposits are sorted, rounded, and layered by meltwater; glacial till is unsorted and angular',
          'Fluvioglacial deposits are angular boulder clay; till is finely sorted by wind',
          'Both are identical and contain no rock fragments larger than silt',
          'Fluvioglacial landforms only form in arid hot deserts',
          'option1',
        ),
      ];

  static List<QuestionModel> _regenerationQuestions(int eq) => [
        _q(
          'reg_${eq}_1',
          'What triggers the "Spiral of Decline" in deindustrialised urban or post-mining rural places?',
          'Factory/mine closures → structural unemployment → out-migration of skilled youth → falling tax base & deprivation',
          'Rapid growth of quaternary tech hubs and rising house prices',
          'High levels of international tourist spending in national parks',
          'Decentralisation of government ministries to regional cities',
          'option1',
        ),
        _q(
          'reg_${eq}_2',
          'Which official UK tool measures relative deprivation across 7 domains (income, employment, health, education, crime, housing, environment)?',
          'Index of Multiple Deprivation (IMD)',
          'Gross National Happiness Index',
          'Mercalli Intensity Scale',
          'Falkenmark Water Stress Index',
          'option1',
        ),
        _q(
          'reg_${eq}_3',
          'What is the difference between "Re-imaging" and "Rebranding" a place during regeneration?',
          'Rebranding creates a new external marketing identity; Re-imaging physically transforms the built environment and perception',
          'They are legal terms for demolishing greenbelt farmland',
          'Re-imaging only applies to coastal defenses; Rebranding only applies to agriculture',
          'Both require banning all private-sector investment',
          'option1',
        ),
        _q(
          'reg_${eq}_4',
          'Why can flagship urban regeneration (e.g., London Docklands / Olympic Park) create conflict among local stakeholders?',
          'Gentrification and rising rents can price out long-standing working-class residents despite economic growth',
          'Regeneration always reduces public transport connectivity',
          'Local councils lose all ability to collect council tax',
          'Environmental air quality always worsens when brownfield sites are cleaned',
          'option1',
        ),
      ];

  static List<QuestionModel> _diversePlacesQuestions(int eq) => [
        _q(
          'div_${eq}_1',
          'How does counter-urbanisation change the demographic profile of accessible rural commuter villages?',
          'In-migration of affluent families and retirees raises average age and house prices, pressuring young locals',
          'Population density exceeds 15,000 people per km² overnight',
          'All agricultural land is converted into heavy steelworks',
          'Birth rates become the highest in the country',
          'option1',
        ),
        _q(
          'div_${eq}_2',
          'What factors shape a person’s "lived experience" and perception of a place?',
          'Age, ethnicity, gender, socio-economic status, length of residence, and media representations',
          'Only the underlying bedrock geology of the postcode',
          'Distance from the Prime Meridian in Greenwich',
          'Annual mean barometric pressure',
          'option1',
        ),
        _q(
          'div_${eq}_3',
          'Why do inner-city gateway neighbourhoods often exhibit low fertility mortality ratios and high ethnic diversity?',
          'Inflows of young working-age international and internal migrants seeking employment, universities, and social networks',
          'Mandatory government relocation of rural pensioners',
          'Complete absence of rental housing in urban centres',
          'Suburban greenbelt laws prohibiting family households in cities',
          'option1',
        ),
        _q(
          'div_${eq}_4',
          'How can local authorities and community groups foster social cohesion in rapidly changing diverse places?',
          'Inclusive community spaces, intercultural events, language support, and equitable affordable housing provision',
          'Segregating public transport by postcode income bracket',
          'Closing all public libraries and youth centres',
          'Privatising all municipal parks',
          'option1',
        ),
      ];

  static List<QuestionModel> _migrationQuestions(int eq) => [
        _q(
          'mig_${eq}_1',
          'In Lee’s Migration Model, what lies between the origin (push factors) and destination (pull factors)?',
          'Intervening obstacles (e.g., border controls, cost, physical distance, legal barriers)',
          'Tectonic Benioff zones',
          'Demographic transition stage 5',
          'Isostatic rebound thresholds',
          'option1',
        ),
        _q(
          'mig_${eq}_2',
          'What distinguishes an economic migrant from a refugee under the 1951 UN Refugee Convention?',
          'Refugees flee a well-founded fear of persecution, conflict, or violence; economic migrants move voluntarily to improve livelihoods',
          'Economic migrants travel only by sea; refugees travel only by air',
          'Refugees cannot cross international borders',
          'Economic migrants are prohibited from sending remittances',
          'option1',
        ),
        _q(
          'mig_${eq}_3',
          'How does the Schengen Agreement reshape border sovereignty within participating European states?',
          'Abolishes internal passport checks to enable free movement of people while strengthening external frontier controls',
          'Requires a separate visa for every cross-border train journey',
          'Replaces all national parliaments with the IMF',
          'Bans all non-European trade',
          'option1',
        ),
        _q(
          'mig_${eq}_4',
          'Why can post-colonial borders in Africa (e.g., drawn at the 1884 Berlin Conference) fuel contemporary conflict?',
          'Geometric borders divided ethnic/linguistic groups and forced rival nations into single states without consent',
          'They followed natural drainage basin watersheds too closely',
          'They created countries with identical climate zones',
          'They granted automatic UN Security Council vetoes to every state',
          'option1',
        ),
      ];

  static List<QuestionModel> _healthQuestions(int eq) => [
        _q(
          'hea_${eq}_1',
          'What shift occurs during Omran’s "Epidemiological Transition Model" as a country develops economically?',
          'Disease burden shifts from infectious/communicable diseases of infancy to chronic non-communicable diseases (cancer, CHD) of old age',
          'Life expectancy drops from 80 years to 35 years',
          'Waterborne cholera replaces cardiovascular disease in post-industrial nations',
          'All viral pathogens disappear without vaccination',
          'option1',
        ),
        _q(
          'hea_${eq}_2',
          'What does the "Preston Curve" demonstrate about the relationship between GDP per capita and life expectancy?',
          'Rapid gains in life expectancy at low income levels that plateau at higher income levels (diminishing returns)',
          'A negative linear correlation where wealthier countries have lower life expectancy',
          'Zero relationship between healthcare spending and infant mortality',
          'Life expectancy depends exclusively on latitude',
          'option1',
        ),
        _q(
          'hea_${eq}_3',
          'How do the World Health Organization (WHO) and NGOs like Médecins Sans Frontières (MSF) differ in global health governance?',
          'WHO sets global health treaties, surveillance, and vaccination standards; MSF delivers rapid front-line emergency medical care',
          'WHO operates private luxury hospitals; MSF manufactures pharmaceutical patents',
          'Both organisations only operate inside G7 nations',
          'Neither organisation responds to epidemic outbreaks',
          'option1',
        ),
        _q(
          'hea_${eq}_4',
          'Why do significant health inequalities persist between affluent and deprived wards within advanced economies like the UK?',
          'Socio-economic deprivation, housing quality, diet, occupational hazards, and lifestyle risk factors create a "postcode lottery"',
          'Public hospitals are legally barred from treating low-income postcodes',
          'Infectious malaria is endemic in northern UK cities',
          'Clean piped drinking water is unavailable in urban areas',
          'option1',
        ),
      ];

  static List<QuestionModel> _hhriQuestions(int eq) => [
        _q(
          'hhr_${eq}_1',
          'Which milestone 1948 document established 30 universal human rights articles adopted by the UN General Assembly?',
          'Universal Declaration of Human Rights (UDHR)',
          'Treaty of Westphalia',
          'Kyoto Protocol',
          'Antarctic Treaty System',
          'option1',
        ),
        _q(
          'hhr_${eq}_2',
          'Why is the "Responsibility to Protect" (R2P) doctrine controversial in international geopolitics?',
          'It tensions state sovereignty against humanitarian intervention, and UN Security Council vetoes can block action selectively',
          'It requires every country to abolish its national military',
          'It applies only to deep-sea fishing disputes',
          'It prohibits any humanitarian aid delivery during famines',
          'option1',
        ),
        _q(
          'hhr_${eq}_3',
          'Why can bilateral development aid ("tied aid") be criticised compared to multilateral community-led aid?',
          'Tied aid often serves donor geopolitical interests or requires purchasing donor-country goods rather than meeting poorest local needs',
          'Bilateral aid is illegal under WTO rules',
          'Multilateral aid can never fund schools or clinics',
          'Tied aid only funds glacial research',
          'option1',
        ),
        _q(
          'hhr_${eq}_4',
          'In evaluating geopolitical interventions (EQ4), what key indicators show long-term success rather than short-term stability?',
          'Democratic governance, independent judiciary, gender equality, reduced corruption (CPI), and sustained human rights protection',
          'Short-term GDP spikes from foreign military spending alone',
          'Suspension of all elections and press freedom',
          'Dependence on permanent emergency food rations',
          'option1',
        ),
      ];

  static List<QuestionModel> _synopticQuestions() => [
        _q(
          'syn_1',
          'In Edexcel A-Level Geography Paper 3, who are the three core "Players" you should connect across every synoptic issue?',
          'Governments/IGOs, TNCs/Businesses, and Local Communities/NGOs',
          'Igneous, Sedimentary, and Metamorphic rocks',
          'Producers, Primary Consumers, and Decomposers',
          'Atmosphere, Hydrosphere, and Lithosphere',
          'option1',
        ),
        _q(
          'syn_2',
          'In Geography Geyser’s "Perspective Method" for 12-mark & 20-mark Assess essays, what dimensions build a Level 4 evaluative conclusion?',
          'Spatial scale (local vs global), temporal scale (short-term vs long-term), stakeholder attitudes, and development context',
          'Listing 15 memorised statistics without explaining any geographical mechanism',
          'Writing a 2-page introduction defining every word in the question',
          'Drawing a sketch map without any analytical paragraphs',
          'option1',
        ),
        _q(
          'syn_3',
          'When answering an 8-mark "Analyse" data-response question, what is the golden rule taught on Geography Geyser?',
          'Spot overall trends, cluster patterns, identify anomalies, manipulate data (ranges/ratios), and link directly to geographical theory',
          'Describe every bar on the graph one by one in chronological order',
          'Ignore the resource figure and write a memorised case study essay',
          'Only state the highest value and move to the next question',
          'option1',
        ),
        _q(
          'syn_4',
          'How do climate change (Carbon/Water) and geopolitical Superpowers intersect in the Arctic?',
          'Retreating sea ice opens shipping routes and hydrocarbon reserves, triggering contested EEZ claims while threatening indigenous ecosystems',
          'Melting ice increases Arctic albedo and halts all naval navigation',
          'The Arctic Council has banned all scientific research above 66°N',
          'Permafrost thaw has eliminated all geopolitical interest in the region',
          'option1',
        ),
        _q(
          'syn_5',
          'What does "Futures and Uncertainties" mean in Edexcel synoptic geography?',
          'Evaluating how business-as-usual, mitigation, and radical transition scenarios create diverging environmental and socio-economic outcomes',
          'Predicting the exact day and hour of future magnitude 9.0 earthquakes',
          'Assuming population and GDP growth remain static forever',
          'Ignoring feedback loops in physical systems',
          'option1',
        ),
      ];
}
