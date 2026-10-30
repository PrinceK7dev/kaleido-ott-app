import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// In-memory preference storage avoids requiring an external plugin.
class LocalPreferences {
  static final Map<String, List<String>> _values = {};

  static Future<LocalPreferences> getInstance() async => LocalPreferences();

  List<String>? getStringList(String key) => _values[key];

  Future<bool> setStringList(String key, List<String> value) async {
    _values[key] = List<String>.of(value);
    return true;
  }
}

// ───────────────────────── Theme tokens ─────────────────────────
const bg = Color(0xFF0F1020);
const surface = Color(0xFF191B33);
const surface2 = Color(0xFF23264A);
const muted = Color(0xFF9A9CC0);
const accent = Color(0xFFFF5A7A);
const accent2 = Color(0xFFFFB347);

// ───────────────────────── Data ─────────────────────────
class Show {
  final int id, year, minutes;
  final String title, genre, rating, desc;
  final bool series;
  final Color a, b;
  const Show(
    this.id,
    this.title,
    this.genre,
    this.year,
    this.rating,
    this.minutes,
    this.a,
    this.b,
    this.desc, {
    this.series = false,
  });
}

const shows = <Show>[
  Show(
    1,
    'Midnight Harbor',
    'Thriller',
    2026,
    '16+',
    118,
    Color(0xFF2B1055),
    Color(0xFFFF5A7A),
    'A night-shift ferry captain finds a sealed crate that someone is willing to kill for.',
  ),
  Show(
    2,
    'Saffron Skies',
    'Romance',
    2025,
    '13+',
    104,
    Color(0xFFFF8A3D),
    Color(0xFF8E2DE2),
    'Two rival kite makers in Jaipur are forced to share a stall during the festival season.',
  ),
  Show(
    3,
    'The Last Orbit',
    'Sci-Fi',
    2026,
    '13+',
    132,
    Color(0xFF0F2027),
    Color(0xFF2C91C8),
    'With fuel for one return trip, a crew of four must decide who stays behind.',
  ),
  Show(
    4,
    'Rooftop Kings',
    'Drama',
    2025,
    '16+',
    48,
    Color(0xFF42275A),
    Color(0xFFE8A33D),
    'Season 1. Five friends run a street-food empire from the rooftops of Mumbai.',
    series: true,
  ),
  Show(
    5,
    'Dark Tide',
    'Thriller',
    2026,
    '18+',
    52,
    Color(0xFF000428),
    Color(0xFF1D976C),
    'Season 2. The coastline gives up another body, and the town stops talking.',
    series: true,
  ),
  Show(
    6,
    'Laugh Track',
    'Comedy',
    2025,
    '13+',
    24,
    Color(0xFFF7971E),
    Color(0xFFD4145A),
    "Season 3. A failing sitcom writers' room has one week to save the show.",
    series: true,
  ),
  Show(
    7,
    'Paper Lanterns',
    'Anime',
    2024,
    '7+',
    25,
    Color(0xFFEE0979),
    Color(0xFF3A1C71),
    'A girl who can hear lanterns whisper sets out to find the festival that never ends.',
    series: true,
  ),
  Show(
    8,
    'Iron Meridian',
    'Action',
    2026,
    '16+',
    126,
    Color(0xFF232526),
    Color(0xFFE5383B),
    'A retired rail marshal has one train and six hours to stop a heist across the desert.',
  ),
  Show(
    9,
    'Quiet Valley',
    'Documentary',
    2025,
    '7+',
    86,
    Color(0xFF134E5E),
    Color(0xFF71B280),
    'A year with the last shepherds of the Spiti valley, filmed in every season.',
  ),
  Show(
    10,
    'Neon Alley',
    'Sci-Fi',
    2026,
    '16+',
    45,
    Color(0xFF8E2DE2),
    Color(0xFF00C6FF),
    'Season 1. A courier hacks her own memory to outrun the city that owns it.',
    series: true,
  ),
  Show(
    11,
    'Home for Monsoon',
    'Family',
    2024,
    '7+',
    98,
    Color(0xFF2193B0),
    Color(0xFFFFD89B),
    "Three siblings spend one rainy summer rebuilding their grandmother's house.",
  ),
  Show(
    12,
    'Cold Case Café',
    'Comedy',
    2025,
    '13+',
    30,
    Color(0xFFC31432),
    Color(0xFF240B36),
    'Season 1. A café owner and a retired detective solve crimes between orders.',
    series: true,
  ),
];

Show byId(int id) => shows.firstWhere((s) => s.id == id);
String dur(int m) => m >= 60 ? '${m ~/ 60}h ${m % 60}m' : '${m}m';
String clock(double s) =>
    '${s ~/ 60}:${(s % 60).floor().toString().padLeft(2, '0')}';

// ───────────────────────── State ─────────────────────────
class AppState extends ChangeNotifier {
  Set<int> list = {2, 8};
  Map<int, double> progress = {1: .62, 5: .3, 10: .15};
  LocalPreferences? _p;

  Future<void> load() async {
    _p = await LocalPreferences.getInstance();
    final l = _p!.getStringList('list');
    if (l != null) list = l.map(int.parse).toSet();
    final pr = _p!.getStringList('progress');
    if (pr != null) {
      progress = {
        for (final s in pr)
          int.parse(s.split(':')[0]): double.parse(s.split(':')[1]),
      };
    }
    notifyListeners();
  }

  void _save() {
    _p?.setStringList('list', list.map((e) => '$e').toList());
    _p?.setStringList(
      'progress',
      progress.entries.map((e) => '${e.key}:${e.value}').toList(),
    );
    notifyListeners();
  }

  void toggle(int id) {
    list.contains(id) ? list.remove(id) : list.add(id);
    _save();
  }

  void setProgress(int id, double f) {
    if (f > .97) {
      progress.remove(id);
    } else if (f > .01) {
      progress[id] = f;
    }
    _save();
  }

  void clearHistory() {
    progress.clear();
    _save();
  }
}

final app = AppState();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await app.load();
  runApp(const KaleidoApp());
}

class KaleidoApp extends StatelessWidget {
  const KaleidoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Kaleido',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        surface: bg,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: bg,
        indicatorColor: surface2,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    ),
    home: const Shell(),
  );
}

// ───────────────────────── Shell ─────────────────────────
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: app,
      builder: (_, __) => Scaffold(
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: tab,
            children: const [HomeTab(), SearchTab(), ListTab(), ProfileTab()],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: tab,
          onDestinationSelected: (i) => setState(() => tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border),
              selectedIcon: Icon(Icons.bookmark),
              label: 'My List',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Shared widgets ─────────────────────────
class Poster extends StatelessWidget {
  final Show s;
  final double? w, h;
  final double fontSize, radius;
  final double? progress;
  final int? rank;
  const Poster(
    this.s, {
    super.key,
    this.w,
    this.h,
    this.fontSize = 15,
    this.radius = 12,
    this.progress,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [s.a, s.b],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(38),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(165)],
                  ),
                ),
              ),
            ),
            if (rank != null)
              Positioned(
                top: 8,
                left: 10,
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  10,
                  10,
                  10,
                  progress != null ? 12 : 10,
                ),
                child: Text(
                  s.title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: -.3,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (progress != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 3,
                  backgroundColor: Colors.white24,
                  color: accent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class TitleCard extends StatelessWidget {
  final Show s;
  final double w, h;
  final bool showProgress;
  final int? rank;
  const TitleCard(
    this.s, {
    super.key,
    this.w = 118,
    this.h = 170,
    this.showProgress = false,
    this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: s.title,
      child: GestureDetector(
        onTap: () => showDetail(context, s),
        child: SizedBox(
          width: w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Poster(
                s,
                w: w,
                h: h,
                progress: showProgress ? app.progress[s.id] : null,
                rank: rank,
              ),
              const SizedBox(height: 6),
              Text(
                '${s.genre} · ${s.series ? 'Series' : dur(s.minutes)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: muted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Rail extends StatelessWidget {
  final String title;
  final List<Show> items;
  final bool wide, ranked, showProgress;
  const Rail(
    this.title,
    this.items, {
    super.key,
    this.wide = false,
    this.ranked = false,
    this.showProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: wide ? 142 : 202,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => TitleCard(
                items[i],
                w: wide ? 200 : 118,
                h: wide ? 112 : 170,
                showProgress: showProgress,
                rank: ranked ? i + 1 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void snack(BuildContext c, String m) {
  ScaffoldMessenger.of(c)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(m),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

// ───────────────────────── Home ─────────────────────────
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});
  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const genres = [
    'All',
    'Movies',
    'Series',
    'Thriller',
    'Sci-Fi',
    'Comedy',
    'Anime',
    'Documentary',
  ];
  String filter = 'All';

  bool ok(Show s) =>
      filter == 'All' ||
      (filter == 'Movies' && !s.series) ||
      (filter == 'Series' && s.series) ||
      s.genre == filter;

  @override
  Widget build(BuildContext context) {
    final f = shows.where(ok).toList();
    final trending = [...f]
      ..sort(
        (a, b) =>
            b.year != a.year ? b.year.compareTo(a.year) : a.id.compareTo(b.id),
      );
    final cont = app.progress.keys.map(byId).toList();
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShaderMask(
                  shaderCallback: (r) => const LinearGradient(
                    colors: [accent, accent2],
                  ).createShader(r),
                  child: const Text(
                    'kaleido',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.5,
                      color: Colors.white,
                    ),
                  ),
                ),
                const CircleAvatar(
                  radius: 17,
                  backgroundColor: accent2,
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: Color(0xFF1A1020),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: genres.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ChoiceChip(
                label: Text(genres[i]),
                selected: filter == genres[i],
                onSelected: (_) => setState(() => filter = genres[i]),
                showCheckmark: false,
                shape: const StadiumBorder(),
                side: BorderSide.none,
                backgroundColor: surface,
                selectedColor: Colors.white,
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: filter == genres[i] ? bg : Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: HeroCarousel()),
        SliverToBoxAdapter(
          child: Column(
            children: [
              if (filter == 'All')
                Rail('Continue watching', cont, wide: true, showProgress: true),
              Rail('Trending now', trending, ranked: true),
              Rail('New series', f.where((s) => s.series).toList()),
              Rail('Movies for tonight', f.where((s) => !s.series).toList()),
              if (f.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'Nothing in this category yet. Pick another one above.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

class HeroCarousel extends StatefulWidget {
  const HeroCarousel({super.key});
  @override
  State<HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<HeroCarousel> {
  final ctrl = PageController(viewportFraction: .92);
  final picks = [shows[0], shows[7], shows[4]];
  int page = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!ctrl.hasClients) return;
      ctrl.animateToPage(
        (page + 1) % picks.length,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = (MediaQuery.of(context).size.height * .55).clamp(320.0, 440.0);
    return Column(
      children: [
        SizedBox(
          height: h,
          child: PageView.builder(
            controller: ctrl,
            itemCount: picks.length,
            onPageChanged: (i) => setState(() => page = i),
            itemBuilder: (_, i) {
              final s = picks[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => showDetail(context, s),
                  child: Stack(
                    children: [
                      Poster(s, h: h, fontSize: 34, radius: 20),
                      Positioned(
                        left: 20,
                        right: 20,
                        bottom: 56,
                        child: Text(
                          '${s.genre} · ${s.year} · ${s.rating} · ${s.series ? 'Series' : dur(s.minutes)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 12,
                        child: Row(
                          children: [
                            FilledButton.icon(
                              onPressed: () => openPlayer(context, s),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: bg,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ListenableBuilder(
                              listenable: app,
                              builder: (_, __) => FilledButton.tonalIcon(
                                onPressed: () {
                                  app.toggle(s.id);
                                  snack(
                                    context,
                                    app.list.contains(s.id)
                                        ? 'Added to My List'
                                        : 'Removed from My List',
                                  );
                                },
                                icon: Icon(
                                  app.list.contains(s.id)
                                      ? Icons.check
                                      : Icons.add,
                                ),
                                label: const Text('My List'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < picks.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == page ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == page ? accent : surface2,
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

// ───────────────────────── Search / List / Profile ─────────────────────────
class SearchTab extends StatefulWidget {
  const SearchTab({super.key});
  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String q = '';
  @override
  Widget build(BuildContext context) {
    final r = shows
        .where(
          (s) => '${s.title} ${s.genre} ${s.series ? 'series' : 'movie'}'
              .toLowerCase()
              .contains(q.toLowerCase()),
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: TextField(
            onChanged: (v) => setState(() => q = v),
            decoration: InputDecoration(
              hintText: 'Search titles, genres, series',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: r.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'No match for “$q”. Try a genre like Thriller or Comedy.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: muted),
                  ),
                )
              : PosterGrid(r, title: q.isEmpty ? 'Browse all' : 'Results'),
        ),
      ],
    );
  }
}

class PosterGrid extends StatelessWidget {
  final List<Show> items;
  final String title;
  const PosterGrid(this.items, {super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 14,
              childAspectRatio: .52,
            ),
            itemCount: items.length,
            itemBuilder: (_, i) => LayoutBuilder(
              builder: (_, c) =>
                  TitleCard(items[i], w: c.maxWidth, h: c.maxWidth * 1.45),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class ListTab extends StatelessWidget {
  const ListTab({super.key});
  @override
  Widget build(BuildContext context) {
    final items = app.list.map(byId).toList();
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'Your list is empty. Tap My List on any title to save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: PosterGrid(items, title: 'My List'),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 12),
        const Center(
          child: CircleAvatar(
            radius: 36,
            backgroundColor: accent2,
            child: Text(
              'A',
              style: TextStyle(
                fontSize: 28,
                color: Color(0xFF1A1020),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Aarav',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ),
        const Center(
          child: Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text(
              'Premium · Mobile',
              style: TextStyle(color: muted, fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const ListTile(
                title: Text('Video quality'),
                trailing: Text('Auto', style: TextStyle(color: muted)),
              ),
              const Divider(height: 1),
              const ListTile(
                title: Text('Download over Wi-Fi only'),
                trailing: Text('On', style: TextStyle(color: muted)),
              ),
              const Divider(height: 1),
              const ListTile(
                title: Text('Subtitles'),
                trailing: Text('English', style: TextStyle(color: muted)),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Clear watch history'),
                trailing: Text(
                  '${app.progress.length} titles',
                  style: const TextStyle(color: muted),
                ),
                onTap: () {
                  app.clearHistory();
                  snack(context, 'Watch history cleared');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Detail sheet ─────────────────────────
void showDetail(BuildContext context, Show s) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: bg,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetCtx) => ListenableBuilder(
      listenable: app,
      builder: (_, __) {
        final inList = app.list.contains(s.id);
        final resume = app.progress.containsKey(s.id);
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Poster(s, w: double.infinity, h: 220, fontSize: 30, radius: 18),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        s.rating,
                        style: const TextStyle(color: muted, fontSize: 12),
                      ),
                    ),
                    Text(
                      '${s.year}',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    Text(
                      s.genre,
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                    Text(
                      s.series
                          ? 'Series · ${s.minutes}m episodes'
                          : dur(s.minutes),
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          openPlayer(context, s);
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: Text(resume ? 'Resume' : 'Play'),
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        onPressed: () => app.toggle(s.id),
                        icon: Icon(inList ? Icons.check : Icons.add),
                        label: Text(inList ? 'In list' : 'My List'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  s.desc,
                  style: const TextStyle(
                    color: muted,
                    height: 1.6,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ───────────────────────── Player ─────────────────────────
void openPlayer(BuildContext c, Show s) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => PlayerPage(s)));

class PlayerPage extends StatefulWidget {
  final Show s;
  const PlayerPage(this.s, {super.key});
  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late final double total = widget.s.minutes * 60.0;
  late double pos = (app.progress[widget.s.id] ?? 0) * total;
  bool playing = true;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    // Demo player: advances 30s of "video" per real second.
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (playing) setState(() => pos = (pos + 30).clamp(0, total));
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    final id = widget.s.id, f = pos / total;
    scheduleMicrotask(() => app.setProgress(id, f));
    super.dispose();
  }

  void seek(double v) => setState(() => pos = v.clamp(0, total));

  @override
  Widget build(BuildContext context) {
    final s = widget.s;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [s.a, Colors.black],
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    s.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Close player',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    s.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD000000)],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Slider(
                      value: pos.clamp(0, total),
                      max: total,
                      onChanged: seek,
                      activeColor: accent,
                      inactiveColor: Colors.white24,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            clock(pos),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            clock(total),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 34,
                          tooltip: 'Back 5 minutes',
                          onPressed: () => seek(pos - 300),
                          icon: const Icon(Icons.replay_5),
                        ),
                        const SizedBox(width: 20),
                        IconButton.filled(
                          iconSize: 36,
                          tooltip: playing ? 'Pause' : 'Play',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: () => setState(() => playing = !playing),
                          icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          iconSize: 34,
                          tooltip: 'Forward 5 minutes',
                          onPressed: () => seek(pos + 300),
                          icon: const Icon(Icons.forward_5),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
