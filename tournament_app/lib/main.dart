import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

// Import all screens for navigation
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/sports_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/tournament_detail_screen.dart';
import 'screens/team_detail_screen.dart';
import 'screens/player_detail_screen.dart';
import 'screens/match_detail_screen.dart';
import 'screens/news_list_screen.dart';
import 'screens/news_detail_screen.dart';
import 'screens/search_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/my_teams_list_screen.dart';
import 'screens/create_edit_team_screen.dart';
import 'screens/add_edit_player_screen.dart';
import 'screens/tournament_registration_screen.dart';
import 'screens/video_highlights_screen.dart';
import 'screens/shop_screen.dart';
// import 'screens/shop_products_screen.dart'; // Removed duplicate
// import 'screens/product_detail_screen.dart'; // Removed unused
import 'screens/my_rewards_screen.dart';
import 'screens/points_history_screen.dart';
import 'screens/earn_points_guide_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Thiết lập thanh trạng thái
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'TDSports',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
          onGenerateRoute: _onGenerateRoute,
        );
      },
    );
  }

  // Define route names as constants
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeForgotPassword = '/forgot-password';
  static const String routeDashboard = '/dashboard';
  static const String routeSportsList = '/sports-list';
  static const String routeProfile = '/profile';
  static const String routeEditProfile = '/edit-profile';
  static const String routeChangePassword = '/change-password';
  static const String routeTournamentDetail = '/tournament-detail';
  static const String routeTeamDetail = '/team-detail';
  static const String routePlayerDetail = '/player-detail';
  static const String routeMatchDetail = '/match-detail';
  static const String routeNewsList = '/news';
  static const String routeNewsDetail = '/news-detail';
  static const String routeSearch = '/search';
  static const String routeSettingsScreen = '/settings-screen';
  static const String routeNotifications = '/notifications';
  static const String routeMyTeamsList = '/my-teams-list';
  static const String routeCreateTeam = '/create-team';
  static const String routeEditTeam = '/edit-team';
  static const String routeAddPlayer = '/add-player';
  static const String routeEditPlayer = '/edit-player';
  static const String routeTournamentRegistration = '/tournament-registration';
  static const String routeVideoHighlights = '/video-highlights';
  static const String routeShop = '/shop';
  // static const String routeShopProducts = '/shop-products'; // Removed duplicate
  static const String routeProductDetail = '/product-detail';
  static const String routeMyRewards = '/my-rewards';
  static const String routePointsHistory = '/points-history';
  static const String routeEarnPointsGuide = '/earn-points-guide';

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case routeLogin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case routeRegister:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      
      case routeForgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case routeDashboard:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
      
      case routeSportsList:
        return MaterialPageRoute(builder: (_) => const SportsListScreen());
      
      case routeProfile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case routeEditProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      
      case routeChangePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      
      case routeTournamentDetail:
        if (args?['tournamentId'] != null) {
          return MaterialPageRoute(
            builder: (_) => TournamentDetailScreen(
              tournamentId: args!['tournamentId'] as int,
            ),
          );
        }
        break;
      
      case routeTeamDetail:
        if (args?['teamId'] != null) {
          return MaterialPageRoute(
            builder: (_) => TeamDetailScreen(teamId: args!['teamId'] as int),
          );
        }
        break;
      
      case routePlayerDetail:
        if (args?['playerId'] != null) {
          return MaterialPageRoute(
            builder: (_) => PlayerDetailScreen(playerId: args!['playerId'] as int),
          );
        }
        break;
      
      case routeMatchDetail:
        if (args?['matchId'] != null) {
          return MaterialPageRoute(
            builder: (_) => MatchDetailScreen(matchId: args!['matchId'] as int),
          );
        }
        break;
      
      case routeNewsList:
        return MaterialPageRoute(builder: (_) => const NewsListScreen());
      
      case routeNewsDetail:
        if (args?['newsId'] != null) {
          return MaterialPageRoute(
            builder: (_) => NewsDetailScreen(newsId: args!['newsId'] as int),
          );
        }
        break;
      
      case routeSearch:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      
      case routeSettingsScreen:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      
      case routeNotifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      
      case routeMyTeamsList:
        return MaterialPageRoute(builder: (_) => const MyTeamsListScreen());
      
      case routeCreateTeam:
        return MaterialPageRoute(builder: (_) => const CreateEditTeamScreen());
      
      case routeEditTeam:
        if (args?['team'] != null) {
          return MaterialPageRoute(
            builder: (_) => CreateEditTeamScreen(
              team: args!['team'] as Map<String, dynamic>,
            ),
          );
        }
        break;
      
      case routeAddPlayer:
        if (args?['teamId'] != null && args?['teamName'] != null) {
          return MaterialPageRoute(
            builder: (_) => AddEditPlayerScreen(
              teamId: args!['teamId'] as int,
              teamName: args['teamName'] as String,
            ),
          );
        }
        break;
      
      case routeEditPlayer:
        if (args?['teamId'] != null && 
            args?['teamName'] != null && 
            args?['player'] != null) {
          return MaterialPageRoute(
            builder: (_) => AddEditPlayerScreen(
              teamId: args!['teamId'] as int,
              teamName: args['teamName'] as String,
              player: args['player'] as Map<String, dynamic>,
            ),
          );
        }
        break;
      
      case routeTournamentRegistration:
        if (args?['tournamentId'] != null && args?['tournamentName'] != null) {
          return MaterialPageRoute(
            builder: (_) => TournamentRegistrationScreen(
              tournamentId: args!['tournamentId'] as int,
              tournamentName: args['tournamentName'] as String,
            ),
          );
        }
        break;
      
      case routeVideoHighlights:
        return MaterialPageRoute(
          builder: (_) => VideoHighlightsScreen(
            tournamentId: args?['tournamentId'] as int?,
            searchQuery: args?['searchQuery'] as String?,
          ),
        );
      
      case routeShop:
        return MaterialPageRoute(builder: (_) => const ShopScreen());
      
      // case routeShopProducts:
      //   return MaterialPageRoute(builder: (_) => const ShopProductsScreen());
      
      case routeProductDetail:
        // This route is usually pushed directly with MaterialPageRoute from ShopScreen
        // but we keep it here for completeness if needed with arguments
        return null;
      
      case routeMyRewards:
        return MaterialPageRoute(builder: (_) => const MyRewardsScreen());
      
      case routePointsHistory:
        return MaterialPageRoute(builder: (_) => const PointsHistoryScreen());

      case routeEarnPointsGuide:
        return MaterialPageRoute(builder: (_) => const EarnPointsGuideScreen());

      default:
        return null;
    }

    // If we got here, the arguments were invalid
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Navigation Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Invalid arguments for route: ${settings.name}',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
