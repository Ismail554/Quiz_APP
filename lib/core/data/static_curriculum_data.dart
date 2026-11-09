import 'package:flutter/material.dart';
import 'package:geography_geyser/core/data/static_questions_bank.dart';
import 'package:geography_geyser/models/v2_curriculum_models.dart';

class StaticCurriculumData {
  StaticCurriculumData._();

  /// Complete Edexcel A-Level Geography Specification Hierarchy
  /// Group A (5 modules, 3 EQs each: EQ1, EQ2, EQ3)
  /// Group B (7 modules, 4 EQs each: EQ1, EQ2, EQ3, EQ4)
  static final List<SpecModuleItem> allModules = [
    // =========================================================================
    // GROUP A — 3 Enquiry Questions (EQ1, EQ2, EQ3)
    // =========================================================================
    _buildModule(
      id: 'tectonics',
      name: 'Tectonics',
      shortTitle: 'Tectonic Processes & Hazards',
      subtitle: 'Plate boundaries, PAR & Swiss Cheese models, disaster governance',
      paperLabel: 'Paper 1 • Topic 1',
      group: ModuleGroup.groupA,
      icon: Icons.volcano_rounded,
      accentColor: const Color(0xFFEF4444),
      eqTitles: const [
        ('Why are some locations more at risk from tectonic hazards?', 'Plate boundaries, Benioff zones, tsunami & volcanic processes'),
        ('Why do some tectonic hazards develop into disasters?', 'PAR Model, Degg’s Model, Swiss Cheese Model & vulnerability'),
        ('How successful is the management of tectonic hazards and disasters?', 'Park’s Curve, mitigation, prediction & governance'),
      ],
    ),
    _buildModule(
      id: 'carbon',
      name: 'Carbon',
      shortTitle: 'The Carbon Cycle & Energy Security',
      subtitle: 'Geological vs biological pumps, energy pathways & climate feedbacks',
      paperLabel: 'Paper 1 • Topic 6',
      group: ModuleGroup.groupA,
      icon: Icons.bolt_rounded,
      accentColor: const Color(0xFFF59E0B),
      eqTitles: const [
        ('How does the carbon cycle operate to maintain planetary health?', 'Slow geological vs fast biological carbon stores & fluxes'),
        ('What are the consequences for people and the environment of our increasing demand for energy?', 'Energy security, pathways, OPEC, unconventional fossil fuels & renewables'),
        ('How are the carbon and water cycles linked to the global climate system?', 'Feedback loops, permafrost, ocean acidification, mitigation & adaptation'),
      ],
    ),
    _buildModule(
      id: 'water',
      name: 'Water',
      shortTitle: 'The Water Cycle & Water Insecurity',
      subtitle: 'Drainage basins, storm hydrographs, ENSO & transboundary conflicts',
      paperLabel: 'Paper 1 • Topic 5',
      group: ModuleGroup.groupA,
      icon: Icons.water_drop_rounded,
      accentColor: const Color(0xFF0284C7),
      eqTitles: const [
        ('What are the processes operating within the hydrological cycle from global to local scale?', 'Global water budgets, drainage basin systems, water balance & hydrographs'),
        ('What factors influence the hydrological system over short- and long-term timescales?', 'Droughts, ENSO cycles, storm events & human abstraction impacts'),
        ('How does water insecurity occur and why is it becoming such a global issue for the 21st century?', 'Falkenmark scarcity, transboundary Nile/Mekong geopolitics & mega-dams'),
      ],
    ),
    _buildModule(
      id: 'globalisation',
      name: 'Globalisation',
      shortTitle: 'Globalisation & Interdependence',
      subtitle: 'Time-space compression, IGOs (IMF/WB/WTO), TNCs & global shift',
      paperLabel: 'Paper 2 • Topic 3',
      group: ModuleGroup.groupA,
      icon: Icons.public_rounded,
      accentColor: const Color(0xFF0EA5E9),
      eqTitles: const [
        ('What are the causes of globalisation and why has it accelerated in recent decades?', 'Time-space compression, ICT, IMF/World Bank/WTO, FDI & trade blocs'),
        ('What are the impacts of globalisation for countries, different groups of people and cultures?', 'Global shift to Asia, switched-on vs switched-off places, megacities & cultural diffusion'),
        ('What are the consequences of globalisation for global development and the physical environment?', 'Development gap, Gini coefficient, ecological footprints & localism/transition towns'),
      ],
    ),
    _buildModule(
      id: 'superpowers',
      name: 'Superpowers',
      shortTitle: 'Superpowers & Geopolitics',
      subtitle: 'Hard vs soft power, Mackinder Heartland, BRI & contested spheres',
      paperLabel: 'Paper 2 • Topic 7',
      group: ModuleGroup.groupA,
      icon: Icons.shield_rounded,
      accentColor: const Color(0xFF6366F1),
      eqTitles: const [
        ('What are superpowers and how have they developed over time?', 'Hard vs soft power, Mackinder’s Heartland, colonial empires to multipolarity'),
        ('What are the impacts of superpowers on the global economy, political systems and the physical environment?', 'TNC dominance, IGOs, cultural hegemony & carbon resource footprints'),
        ('What spheres of influence are contested by superpowers and what are the implications of this?', 'South China Sea, Arctic resources, Belt & Road Initiative & Middle East tensions'),
      ],
    ),

    // =========================================================================
    // GROUP B — 4 Enquiry Questions (EQ1, EQ2, EQ3, EQ4)
    // =========================================================================
    _buildModule(
      id: 'coasts',
      name: 'Coasts',
      shortTitle: 'Coastal Landscapes & Change',
      subtitle: 'Concordant/discordant geology, sediment cells, Holderness & Odisha ICZM',
      paperLabel: 'Paper 1 • Topic 2B',
      group: ModuleGroup.groupB,
      icon: Icons.waves_rounded,
      accentColor: const Color(0xFF0891B2),
      eqTitles: const [
        ('Why are coastal landscapes different and what processes cause these differences?', 'Littoral zones, concordant/discordant geology, wave energy & cliff profiles'),
        ('How do characteristic coastal landforms contribute to coastal landscapes?', 'Marine erosion, longshore drift, sediment cells & subaerial mass movement'),
        ('How do coastal erosion and sea level change alter the physical characteristics of coastlines?', 'Eustatic/isostatic change, submergent/emergent coasts & storm surges'),
        ('How can coastlines be managed to meet the needs of all players?', 'Hard vs soft engineering, Shoreline Management Plans (SMPs) & ICZM'),
      ],
    ),
    _buildModule(
      id: 'glaciers',
      name: 'Glaciers',
      shortTitle: 'Glaciated Landscapes & Change',
      subtitle: 'Pleistocene ice ages, glacial mass balance, corries & fragile environments',
      paperLabel: 'Paper 1 • Topic 2A',
      group: ModuleGroup.groupB,
      icon: Icons.ac_unit_rounded,
      accentColor: const Color(0xFF38BDF8),
      eqTitles: const [
        ('How has climate changeouden influenced the formation of glaciated landscapes over time?', 'Pleistocene Milankovitch cycles, periglacial permafrost & alpine systems'),
        ('What processes operate within glacier systems?', 'Glacial mass balance, accumulation/ablation, basal sliding & internal deformation'),
        ('How do glacial processes contribute to the formation of glacial landforms and landscapes?', 'Corries, arêtes, U-shaped troughs, drumlins, erratics & fluvioglacial eskers'),
        ('How are glaciated landscapes used and managed today?', 'Hydroelectric power, alpine tourism, outburst floods & conservation'),
      ],
    ),
    _buildModule(
      id: 'regenerating_places',
      name: 'Regenerating Places',
      shortTitle: 'Regenerating Places',
      subtitle: 'Deindustrialisation, spiral of decline, IMD, urban & rural rebranding',
      paperLabel: 'Paper 2 • Topic 4A',
      group: ModuleGroup.groupB,
      icon: Icons.location_city_rounded,
      accentColor: const Color(0xFF10B981),
      eqTitles: const [
        ('How and why do places vary?', 'Economic sector shifts, employment structure, demographics & Index of Multiple Deprivation'),
        ('Why might regeneration be needed?', 'Deindustrialisation, spiral of decline, rural marginalisation & lived experience'),
        ('How is regeneration managed?', 'National infrastructure, Enterprise Zones, flagship rebranding & community-led schemes'),
        ('How successful is regeneration?', 'Evaluating economic, social & environmental outcomes across diverse stakeholders'),
      ],
    ),
    _buildModule(
      id: 'diverse_places',
      name: 'Diverse Places',
      shortTitle: 'Diverse Places',
      subtitle: 'Rural-urban dynamics, lived experience, demographic change & cohesion',
      paperLabel: 'Paper 2 • Topic 4B',
      group: ModuleGroup.groupB,
      icon: Icons.groups_rounded,
      accentColor: const Color(0xFF8B5CF6),
      eqTitles: const [
        ('How do population structures vary?', 'Rural-urban continuum, internal/international migration & demographic structure'),
        ('How do different people view living spaces?', 'Lived experience, identity, insider/outsider perceptions & statistical crime/media data'),
        ('Why are there demographic and ethnic tensions in some places?', 'Cultural change, gentrification, counter-urbanisation & pressure on services'),
        ('How successfully are cultural and demographic issues managed?', 'Local vs national stakeholders, urban assimilation & sustainable community cohesion'),
      ],
    ),
    _buildModule(
      id: 'migration',
      name: 'Migration',
      shortTitle: 'Migration, Identity & Sovereignty',
      subtitle: 'Lee’s model, Schengen borders, refugee flows, nationalism & contested states',
      paperLabel: 'Paper 2 • Topic 8B',
      group: ModuleGroup.groupB,
      icon: Icons.flight_takeoff_rounded,
      accentColor: const Color(0xFFEC4899),
      eqTitles: const [
        ('What are the impacts of globalisation on international migration?', 'Push/pull mechanics, economic migrants, refugees, remittances & Schengen mobility'),
        ('How are nation states defined and how have they evolved in a globalising world?', 'Sovereignty, post-colonial borders, cultural homogeneity & disputed territories'),
        ('What are the impacts of global organisations on managing global issues and conflicts?', 'UN, IMF, NATO, Geneva Conventions & environmental/geopolitical treaties'),
        ('What are the threats to national sovereignty in a more globalised world?', 'Separatism, nationalism, tax havens, foreign ownership & uneven development'),
      ],
    ),
    _buildModule(
      id: 'health',
      name: 'Health',
      shortTitle: 'Global Health & Development',
      subtitle: 'Epidemiological transition, Preston Curve, WHO governance & health inequality',
      paperLabel: 'Paper 2 • Topic 8A (Part 1)',
      group: ModuleGroup.groupB,
      icon: Icons.health_and_safety_rounded,
      accentColor: const Color(0xFF14B8A6),
      eqTitles: const [
        ('What is human development and why do levels vary from place to place?', 'HDI, education, UNESCO, Preston Curve & life expectancy variations'),
        ('Why do health and life expectancy vary between and within countries?', 'Epidemiological transition, infectious vs non-communicable disease & deprivation'),
        ('How do global organisations and governments manage global health risks?', 'WHO, MSF, pharmaceutical TNCs, vaccination campaigns & pandemic response'),
        ('How successful are health interventions in eradicating disease and extending longevity?', 'Evaluating malaria/HIV eradication, clean water sanitation & healthcare equity'),
      ],
    ),
    _buildModule(
      id: 'hhri',
      name: 'Human Rights & Intervention (HHRI)',
      shortTitle: 'Human Rights & Intervention (HHRI)',
      subtitle: 'UDHR, ECHR, gender & indigenous rights, geopolitical aid & military intervention',
      paperLabel: 'Paper 2 • Topic 8A (Part 2)',
      group: ModuleGroup.groupB,
      icon: Icons.balance_rounded,
      accentColor: const Color(0xFFD97706),
      eqTitles: const [
        ('Why do human rights vary from place to place?', 'UDHR, ECHR, Geneva Conventions, corruption (CPI) & post-colonial governance'),
        ('How do differences in human rights affect gender equality and indigenous groups?', 'Gender Inequality Index (GII), education access & indigenous land rights'),
        ('Why are human rights used as arguments for political and military intervention?', 'Responsibility to Protect (R2P), development aid, trade embargoes & military action'),
        ('What are the outcomes of geopolitical interventions in terms of human development and human rights?', 'Measuring success via democratic institutions, sovereignty & civilian protection'),
      ],
    ),
  ];

  static List<SpecModuleItem> get groupAModules =>
      allModules.where((m) => m.group == ModuleGroup.groupA).toList();

  static List<SpecModuleItem> get groupBModules =>
      allModules.where((m) => m.group == ModuleGroup.groupB).toList();

  static SpecModuleItem? findModuleById(String? id) {
    if (id == null || id.isEmpty) return null;
    final clean = id.toLowerCase().trim();
    for (final m in allModules) {
      if (m.id.toLowerCase() == clean ||
          m.name.toLowerCase() == clean ||
          m.name.toLowerCase().contains(clean) ||
          clean.contains(m.id.toLowerCase())) {
        return m;
      }
    }
    return null;
  }

  static EnquiryQuestionItem? findEqById(String moduleId, int eqNumber) {
    final module = findModuleById(moduleId);
    if (module == null) return null;
    for (final eq in module.enquiryQuestions) {
      if (eq.eqNumber == eqNumber) return eq;
    }
    return module.enquiryQuestions.isNotEmpty
        ? module.enquiryQuestions.first
        : null;
  }

  static SubQuizItem? findSubQuizById(String? quizId) {
    if (quizId == null || quizId.isEmpty) return null;
    final clean = quizId.toLowerCase().trim();
    for (final module in allModules) {
      for (final eq in module.enquiryQuestions) {
        for (final sub in eq.subQuizzes) {
          if (sub.id.toLowerCase() == clean) return sub;
        }
      }
    }
    return null;
  }

  static SpecModuleItem _buildModule({
    required String id,
    required String name,
    required String shortTitle,
    required String subtitle,
    required String paperLabel,
    required ModuleGroup group,
    required IconData icon,
    required Color accentColor,
    required List<(String, String)> eqTitles,
  }) {
    final eqList = <EnquiryQuestionItem>[];
    for (var i = 0; i < eqTitles.length; i++) {
      final eqNum = i + 1;
      final eqId = '${id}_eq$eqNum';
      final questions =
          StaticQuestionsBank.getQuestionsForTopic(id, eqNumber: eqNum);

      final subQuizzes = <SubQuizItem>[
        SubQuizItem(
          id: '${eqId}_foundation',
          moduleId: id,
          moduleName: name,
          eqId: eqId,
          eqNumber: eqNum,
          title: 'EQ$eqNum Core Concepts & Terminology',
          topicSummary: 'AO1 knowledge check on ${eqTitles[i].$2}',
          difficulty: QuizDifficulty.easy,
          estimatedMinutes: 5,
          questions: questions,
        ),
        SubQuizItem(
          id: '${eqId}_casestudies',
          moduleId: id,
          moduleName: name,
          eqId: eqId,
          eqNumber: eqNum,
          title: 'EQ$eqNum Place-Based Case Studies',
          topicSummary: 'Comparative players, data & real-world examples for $name',
          difficulty: QuizDifficulty.medium,
          estimatedMinutes: 10,
          questions: questions.reversed.toList(),
        ),
        SubQuizItem(
          id: '${eqId}_synoptic',
          moduleId: id,
          moduleName: name,
          eqId: eqId,
          eqNumber: eqNum,
          title: 'EQ$eqNum 12-Mark Assess & Exam Mastery',
          topicSummary: 'High-tariff AO2 evaluation & Perspective Method practice',
          difficulty: QuizDifficulty.hard,
          estimatedMinutes: 15,
          questions: questions,
        ),
      ];

      eqList.add(
        EnquiryQuestionItem(
          id: eqId,
          moduleId: id,
          moduleName: name,
          eqNumber: eqNum,
          title: eqTitles[i].$1,
          keyFocus: eqTitles[i].$2,
          subQuizzes: subQuizzes,
        ),
      );
    }

    return SpecModuleItem(
      id: id,
      name: name,
      shortTitle: shortTitle,
      subtitle: subtitle,
      paperLabel: paperLabel,
      group: group,
      icon: icon,
      accentColor: accentColor,
      enquiryQuestions: eqList,
    );
  }
}
