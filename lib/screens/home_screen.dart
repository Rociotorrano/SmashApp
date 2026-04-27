import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:pantheon/models/user_model.dart';
import 'package:pantheon/services/auth_service.dart';
import 'package:pantheon/services/chat_service.dart';
import 'package:pantheon/theme.dart';
import 'package:pantheon/screens/find_players_screen.dart';
import 'package:pantheon/services/ad_service.dart';
import 'package:pantheon/services/notificaciones_estado_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  Timer? _notifTimer;

  @override
  void initState() {
    super.initState();
    if (!AdService().isPremium) {
      _loadBannerAd();
      AdService().loadInterstitialAd();
    }

    // Carga inicial de notificaciones
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificacionesEstadoService>().actualizarContador();
    });

    // Timer para refrescar contador cada 60 segundos
    _notifTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (mounted) {
        context.read<NotificacionesEstadoService>().actualizarContador();
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _notifTimer?.cancel();
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = AdService().createBannerAd(
      onAdLoaded: (ad) {
        setState(() {
          _isBannerAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('BannerAd failed to load: $error');
        setState(() {
          _isBannerAdLoaded = false;
        });
      },
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final showAds = !AdService().isPremium;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ProfileView(user: user, isVisible: _selectedIndex == 0),
          const FindPlayersScreen(),
          ChatListView(isVisible: _selectedIndex == 2),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showAds && _isBannerAdLoaded && _bannerAd != null)
            SafeArea(
              child: Container(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                      width: 0.5)),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              selectedItemColor: AppColors.neonGreen,
              unselectedItemColor: AppColors.textGrey,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_tennis),
                  label: 'Perfil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Buscar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat_bubble_outline),
                  label: 'Chat',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  final UserModel user;
  final bool isVisible;

  const ProfileView({super.key, required this.user, this.isVisible = true});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.darkSurface,
                    AppColors.darkCard,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Text(
                      'Hola ${user.name}',
                      style: context.textStyles.headlineLarge?.copyWith(
                        color: AppColors.neonGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '¿Donde jugamos hoy?',
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: AppColors.textLight.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Consumer<NotificacionesEstadoService>(
              builder: (context, estado, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_none,
                          color: AppColors.textLight),
                      onPressed: () async {
                        await context.push('/notificaciones');
                        if (context.mounted) {
                          context
                              .read<NotificacionesEstadoService>()
                              .actualizarContador();
                        }
                      },
                    ),
                    if (estado.noLeidas > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            estado.noLeidas > 9 ? '+9' : '${estado.noLeidas}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.settings, color: AppColors.textLight),
              onPressed: () => context.push('/edit-profile'),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eventos',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const EventCard(title: 'Mpc mundo padel la costa'),
                  const SizedBox(height: 32),
                  Text(
                    'Clubs',
                    style: context.textStyles.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CourtsCarousel(isVisible: isVisible),
                ],
              ),
            ),
          ),
        ],
      );
  }
}

class EventCard extends StatelessWidget {
  final String title;

  const EventCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkSurface,
              AppColors.darkCard,
            ],
          ),
        ),
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.event,
                    color: AppColors.electricBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: context.textStyles.titleLarge?.copyWith(
                      color: AppColors.electricBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.textGrey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Próximamente',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textGrey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Torneo nacional',
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ClubCard extends StatelessWidget {
  final String name;

  const ClubCard({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.electricBlue.withValues(alpha: 0.8),
                Colors.purple.withValues(alpha: 0.8),
              ],
            ),
          ),
          padding: AppSpacing.paddingMd,
          alignment: Alignment.center,
          child: Text(
            name,
            style: context.textStyles.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class CourtsCarousel extends StatefulWidget {
  final bool isVisible;

  const CourtsCarousel({super.key, this.isVisible = true});

  @override
  State<CourtsCarousel> createState() => _CourtsCarouselState();
}

class _CourtsCarouselState extends State<CourtsCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> _courts = [
    {
      'name': 'Zeus Club Deportivo',
      'address': 'Tierra del fuego 1915',
      'locality': 'Mar de Ajó',
    },
    {
      'name': 'Cortaderas',
      'address': 'Salta 98',
      'locality': 'Mar de Ajó',
    },
    {
      'name': 'El Klú',
      'address': 'Calle 16',
      'locality': 'Santa Teresita',
    },
    {
      'name': 'Padel Golf Club',
      'address': 'Golf Club Santa Teresita',
      'locality': 'Santa Teresita',
    },
    {
      'name': 'Cocodrilo Padel',
      'address': 'Calle 36 E/ 8 y 9',
      'locality': 'Santa Teresita',
    },
    {
      'name': 'Arena 21 Padel',
      'address': '21 y Garay',
      'locality': 'San Bernardo',
    },
    {
      'name': 'Passing.padel',
      'address': 'Santiago del Estero 4665',
      'locality': 'La Lucila',
    },
    {
      'name': 'Padel Center',
      'address': 'Av 94',
      'locality': 'Mar del Tuyú',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    if (widget.isVisible) {
      _startAutoScroll();
    }
  }

  @override
  void didUpdateWidget(CourtsCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _startAutoScroll();
      } else {
        _timer?.cancel();
      }
    }
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < _courts.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index);
        },
        itemCount: _courts.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CourtCard(
              name: _courts[index]['name']!,
              address: _courts[index]['address']!,
              locality: _courts[index]['locality']!,
            ),
          );
        },
      ),
    );
  }
}

class CourtCard extends StatelessWidget {
  final String name;
  final String address;
  final String locality;

  const CourtCard({
    super.key,
    required this.name,
    required this.address,
    required this.locality,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.darkSurface,
              AppColors.darkCard,
            ],
          ),
        ),
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sports_tennis,
                    color: AppColors.neonGreen,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: context.textStyles.titleLarge?.copyWith(
                      color: AppColors.neonGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.textGrey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.place,
                  color: AppColors.textGrey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  locality,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: AppColors.electricBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatListView extends StatefulWidget {
  final bool isVisible;

  const ChatListView({super.key, this.isVisible = false});

  @override
  State<ChatListView> createState() => _ChatListViewState();
}

class _ChatListViewState extends State<ChatListView> {
  // We use ChatService state now

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) {
      _loadConnections();
    }
  }

  @override
  void didUpdateWidget(ChatListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _loadConnections();
    }
  }

  Future<void> _loadConnections() async {
    final chatService = context.read<ChatService>();
    if (!chatService.isLoading && chatService.connections.isEmpty) {
      await chatService.loadConnections();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuchar cambios para refrescar si es necesario
    final chatService = context.watch<ChatService>();
    final connections = chatService.connections;
    final isLoading = chatService.isLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Chat'),
        centerTitle: true,
      ),
      body: isLoading && connections.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : connections.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: AppColors.textGrey,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No tienes conversaciones',
                        style: context.textStyles.titleLarge?.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: connections.length,
                  itemBuilder: (context, index) {
                    final connection = connections[index];
                    final user = connection.otherUser;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.textGrey.withValues(alpha: 0.1),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.darkSurface,
                          backgroundImage: user.profileImageUrl != null
                              ? NetworkImage(user.profileImageUrl!)
                              : null,
                          child: user.profileImageUrl == null
                              ? Text(user.name.substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                      color: AppColors.neonGreen,
                                      fontWeight: FontWeight.bold))
                              : null,
                        ),
                        title: Text(
                          user.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          connection.lastMessage ?? '¡Nuevo match! Di hola 👋',
                          style: TextStyle(
                              color: connection.lastMessage == null
                                  ? AppColors.neonGreen.withValues(alpha: 0.8)
                                  : AppColors.textGrey),
                        ),
                        trailing: Icon(Icons.chevron_right,
                            color: AppColors.textGrey),
                        onTap: () {
                          context.push('/chat/${user.id}');
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class ConversationItem extends StatelessWidget {
  final UserModel user;
  final dynamic lastMessage;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const ConversationItem({
    super.key,
    required this.user,
    required this.lastMessage,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.textGrey.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.ballYellow.withValues(alpha: 0.3),
                    AppColors.padelBlue.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Icon(
                Icons.person,
                size: 32,
                color: AppColors.ballYellow,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: context.textStyles.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage != null
                        ? lastMessage.message
                        : '¡Nuevo match! Di hola 👋',
                    style: context.textStyles.bodyMedium?.copyWith(
                      color: AppColors.textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textGrey,
            ),
          ],
        ),
      ),
    );
  }
}
