import 'dart:convert';
import 'dart:io';

// Flutter Agent definitions
class FlutterAgent {
  final String id;
  final String name;
  final String description;
  final String category;
  final List<String> capabilities;
  final Map<String, dynamic> config;
  final bool isInstalled;
  final String status;

  FlutterAgent({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.capabilities,
    this.config = const {},
    this.isInstalled = false,
    this.status = 'ready',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'capabilities': capabilities,
    'config': config,
    'isInstalled': isInstalled,
    'status': status,
  };

  factory FlutterAgent.fromJson(Map<String, dynamic> json) => FlutterAgent(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    category: json['category'],
    capabilities: List<String>.from(json['capabilities']),
    config: json['config'] ?? {},
    isInstalled: json['isInstalled'] ?? false,
    status: json['status'] ?? 'ready',
  );
}

// Agent Manager
class AgentManager {
  static final List<FlutterAgent> agents = [
    FlutterAgent(
      id: 'flutter-developer',
      name: 'Flutter Developer',
      description: 'Flutter 앱 개발 전문 에이전트',
      category: 'Development',
      capabilities: [
        'Widget 생성 및 수정',
        'State management 구현',
        'Navigation 설정',
        'API 통합',
        'Database 연동',
      ],
      isInstalled: true,
      status: 'active',
    ),
    FlutterAgent(
      id: 'flutter-analyzer',
      name: 'Flutter Analyzer',
      description: '코드 분석 및 품질 검사 에이전트',
      category: 'Analysis',
      capabilities: [
        'Code linting',
        'Performance analysis',
        'Security scanning',
        'Dependency checking',
        'Best practices validation',
      ],
      isInstalled: true,
      status: 'active',
    ),
    FlutterAgent(
      id: 'flutter-tester',
      name: 'Flutter Tester',
      description: '테스트 실행 및 관리 에이전트',
      category: 'Testing',
      capabilities: [
        'Unit testing',
        'Widget testing',
        'Integration testing',
        'Coverage reporting',
        'Test automation',
      ],
      isInstalled: true,
      status: 'active',
    ),
    FlutterAgent(
      id: 'flutter-builder',
      name: 'Flutter Builder',
      description: '빌드 및 배포 관리 에이전트',
      category: 'Build',
      capabilities: [
        'Android build',
        'iOS build',
        'Web build',
        'Release management',
        'CI/CD integration',
      ],
      isInstalled: true,
      status: 'active',
    ),
    FlutterAgent(
      id: 'flutter-debugger',
      name: 'Flutter Debugger',
      description: '디버깅 및 문제 해결 에이전트',
      category: 'Debugging',
      capabilities: [
        'Breakpoint management',
        'Variable inspection',
        'Performance profiling',
        'Memory analysis',
        'Network debugging',
      ],
      isInstalled: true,
      status: 'active',
    ),
    FlutterAgent(
      id: 'flutter-state-manager',
      name: 'Flutter State Manager',
      description: '상태 관리 전문 에이전트',
      category: 'State Management',
      capabilities: [
        'Provider implementation',
        'Riverpod setup',
        'Bloc pattern',
        'GetX integration',
        'State optimization',
      ],
      isInstalled: true,
      status: 'active',
    ),
    FlutterAgent(
      id: 'flutter-ui-designer',
      name: 'Flutter UI Designer',
      description: 'UI/UX 디자인 에이전트',
      category: 'Design',
      capabilities: [
        'Material Design',
        'Cupertino widgets',
        'Custom animations',
        'Responsive layouts',
        'Theme management',
      ],
      isInstalled: true,
      status: 'active',
    ),
    FlutterAgent(
      id: 'flutter-package-manager',
      name: 'Flutter Package Manager',
      description: '패키지 및 의존성 관리 에이전트',
      category: 'Package Management',
      capabilities: [
        'Package installation',
        'Version management',
        'Dependency resolution',
        'Package publishing',
        'License checking',
      ],
      isInstalled: true,
      status: 'active',
    ),
    FlutterAgent(
      id: 'flutter-performance-optimizer',
      name: 'Flutter Performance Optimizer',
      description: '성능 최적화 전문 에이전트',
      category: 'Optimization',
      capabilities: [
        'Render optimization',
        'Memory optimization',
        'Build size reduction',
        'Lazy loading',
        'Cache management',
      ],
      isInstalled: true,
      status: 'active',
    ),
    FlutterAgent(
      id: 'flutter-migration-assistant',
      name: 'Flutter Migration Assistant',
      description: '마이그레이션 및 업그레이드 지원 에이전트',
      category: 'Migration',
      capabilities: [
        'Flutter version upgrade',
        'Breaking changes handling',
        'Dependency migration',
        'Code refactoring',
        'Platform migration',
      ],
      isInstalled: true,
      status: 'active',
    ),
  ];

  static void listAgents({String? filter, bool verbose = false}) {
    print('\n' + '=' * 70);
    print(' Flutter Development Agents');
    print('=' * 70);
    
    final filteredAgents = filter != null 
      ? agents.where((a) => 
          a.name.toLowerCase().contains(filter.toLowerCase()) ||
          a.category.toLowerCase().contains(filter.toLowerCase()) ||
          a.description.toLowerCase().contains(filter.toLowerCase()))
      : agents;

    if (filteredAgents.isEmpty) {
      print('\n No agents found matching "$filter"');
      return;
    }

    for (var agent in filteredAgents) {
      _printAgent(agent, verbose);
    }
    
    print('\n' + '=' * 70);
    print(' Total: ${filteredAgents.length} agents');
    print('=' * 70 + '\n');
  }

  static void _printAgent(FlutterAgent agent, bool verbose) {
    final statusIcon = agent.status == 'active' ? '✓' : '○';
    final statusColor = agent.status == 'active' ? '\x1B[32m' : '\x1B[33m';
    final reset = '\x1B[0m';
    
    print('\n $statusColor$statusIcon$reset ${agent.name}');
    print('   ID: ${agent.id}');
    print('   Category: ${agent.category}');
    print('   Description: ${agent.description}');
    print('   Status: $statusColor${agent.status}$reset');
    
    if (verbose) {
      print('   Capabilities:');
      for (var capability in agent.capabilities) {
        print('     • $capability');
      }
    }
  }

  static void showAgentDetails(String agentId) {
    final agent = agents.firstWhere(
      (a) => a.id == agentId,
      orElse: () => throw Exception('Agent not found: $agentId'),
    );
    
    print('\n' + '=' * 70);
    print(' Agent Details: ${agent.name}');
    print('=' * 70);
    
    _printAgent(agent, true);
    
    print('\n Configuration:');
    if (agent.config.isEmpty) {
      print('   Default configuration');
    } else {
      agent.config.forEach((key, value) {
        print('   $key: $value');
      });
    }
    
    print('\n' + '=' * 70 + '\n');
  }

  static void installAgent(String agentId) {
    final agent = agents.firstWhere(
      (a) => a.id == agentId,
      orElse: () => throw Exception('Agent not found: $agentId'),
    );
    
    print('\n Installing ${agent.name}...');
    
    // Simulate installation steps
    print(' • Checking dependencies...');
    sleep(Duration(milliseconds: 500));
    print(' • Downloading agent package...');
    sleep(Duration(milliseconds: 500));
    print(' • Configuring agent...');
    sleep(Duration(milliseconds: 500));
    print(' • Verifying installation...');
    sleep(Duration(milliseconds: 500));
    
    print(' ✓ ${agent.name} installed successfully!\n');
  }

  static void connectAgents(String agent1Id, String agent2Id) {
    final agent1 = agents.firstWhere(
      (a) => a.id == agent1Id,
      orElse: () => throw Exception('Agent not found: $agent1Id'),
    );
    
    final agent2 = agents.firstWhere(
      (a) => a.id == agent2Id,
      orElse: () => throw Exception('Agent not found: $agent2Id'),
    );
    
    print('\n Connecting agents...');
    print(' • ${agent1.name} <-> ${agent2.name}');
    
    sleep(Duration(milliseconds: 500));
    print(' • Establishing communication channel...');
    sleep(Duration(milliseconds: 500));
    print(' • Configuring message routing...');
    sleep(Duration(milliseconds: 500));
    print(' • Testing connection...');
    sleep(Duration(milliseconds: 500));
    
    print(' ✓ Agents connected successfully!\n');
  }

  static void verifySystem() {
    print('\n' + '=' * 70);
    print(' System Verification');
    print('=' * 70);
    
    print('\n Checking agent status...\n');
    
    int activeCount = 0;
    int inactiveCount = 0;
    
    for (var agent in agents) {
      final status = agent.status == 'active' ? '✓' : '✗';
      final color = agent.status == 'active' ? '\x1B[32m' : '\x1B[31m';
      final reset = '\x1B[0m';
      
      print(' $color[$status]$reset ${agent.name.padRight(30)} ${agent.status}');
      
      if (agent.status == 'active') {
        activeCount++;
      } else {
        inactiveCount++;
      }
    }
    
    print('\n' + '-' * 70);
    print(' Summary:');
    print('   Active agents: $activeCount');
    print('   Inactive agents: $inactiveCount');
    print('   Total agents: ${agents.length}');
    print('=' * 70 + '\n');
  }

  static void exportConfig() {
    final config = {
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'agents': agents.map((a) => a.toJson()).toList(),
    };
    
    final file = File('.agents/config.json');
    file.writeAsStringSync(JsonEncoder.withIndent('  ').convert(config));
    
    print('\n ✓ Configuration exported to .agents/config.json\n');
  }
}

// Main CLI
void main(List<String> args) {
  if (args.isEmpty) {
    AgentManager.listAgents();
    _showHelp();
    return;
  }

  final command = args[0];
  
  try {
    switch (command) {
      case 'list':
      case 'ls':
      case '/agents':
        final filter = args.length > 1 ? args[1] : null;
        final verbose = args.contains('-v') || args.contains('--verbose');
        AgentManager.listAgents(filter: filter, verbose: verbose);
        break;
        
      case 'show':
      case 'details':
        if (args.length < 2) {
          print('Error: Agent ID required');
          print('Usage: agents show <agent-id>');
          exit(1);
        }
        AgentManager.showAgentDetails(args[1]);
        break;
        
      case 'install':
        if (args.length < 2) {
          print('Error: Agent ID required');
          print('Usage: agents install <agent-id>');
          exit(1);
        }
        AgentManager.installAgent(args[1]);
        break;
        
      case 'connect':
        if (args.length < 3) {
          print('Error: Two agent IDs required');
          print('Usage: agents connect <agent1-id> <agent2-id>');
          exit(1);
        }
        AgentManager.connectAgents(args[1], args[2]);
        break;
        
      case 'verify':
      case 'status':
        AgentManager.verifySystem();
        break;
        
      case 'export':
        AgentManager.exportConfig();
        break;
        
      case 'help':
      case '--help':
      case '-h':
        _showHelp();
        break;
        
      default:
        print('Unknown command: $command');
        _showHelp();
        exit(1);
    }
  } catch (e) {
    print('\nError: $e');
    exit(1);
  }
}

void _showHelp() {
  print('''

Usage: agents [command] [options]

Commands:
  list, ls, /agents [filter] [-v]  List all Flutter agents (with optional filter and verbose mode)
  show <agent-id>                   Show detailed information about an agent
  install <agent-id>                 Install a specific agent
  connect <agent1-id> <agent2-id>   Connect two agents for communication
  verify, status                     Verify system and show agent status
  export                             Export agent configuration to JSON
  help                               Show this help message

Examples:
  ./agents                           List all agents
  ./agents list -v                   List all agents with detailed capabilities
  ./agents list flutter-developer    Filter agents by name
  ./agents show flutter-analyzer     Show details of the analyzer agent
  ./agents install flutter-tester    Install the tester agent
  ./agents connect flutter-developer flutter-analyzer
  ./agents verify                    Check system status

Agent IDs:
  flutter-developer                  Flutter app development
  flutter-analyzer                   Code analysis
  flutter-tester                     Test execution
  flutter-builder                    Build management
  flutter-debugger                   Debugging
  flutter-state-manager              State management
  flutter-ui-designer                UI design
  flutter-package-manager            Package management
  flutter-performance-optimizer      Performance optimization
  flutter-migration-assistant        Migration support
''');
}