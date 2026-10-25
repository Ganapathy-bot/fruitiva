import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _background = Color(0xFF101A16);
const _surface = Color(0xFF142E24);
const _raised = Color(0xFF174C38);
const _orange = Color(0xFFF4A340);
const _green = Color(0xFF4F8A54);
const _coral = Color(0xFFF07855);
const _white = Color(0xFFFFF9EF);
const _muted = Color(0xFFA9B8AE);
const _line = Color(0x26A9B8AE);

void main() {
  runApp(const FruitivaApp());
}

class FruitivaApp extends StatefulWidget {
  const FruitivaApp({super.key});

  @override
  State<FruitivaApp> createState() => _FruitivaAppState();
}

class _FruitivaAppState extends State<FruitivaApp> {
  static const _savedKey = 'fruitiva-saved-recipes';
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();
  int _screen = 0;
  Set<String> _savedRecipes = {};
  bool _loadingSaved = true;

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _savedRecipes = preferences.getStringList(_savedKey)?.toSet() ?? {};
      _loadingSaved = false;
    });
  }

  Future<void> _toggleSaved(String name) async {
    final next = {..._savedRecipes};
    final nowSaved = !next.remove(name);
    if (nowSaved) next.add(name);
    setState(() => _savedRecipes = next);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_savedKey, next.toList());
    if (!mounted) return;
    _messengerKey.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(nowSaved ? '$name saved.' : '$name removed from saved.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _raised,
        ),
      );
  }

  void _navigateTo(int screen) {
    setState(() => _screen = screen);
  }

  void _openSweets() {
    setState(() => _screen = 4);
  }

  @override
  Widget build(BuildContext context) {
    final selectedNav = _screen == 4 ? 0 : _screen;
    final pages = <Widget>[
      HomeScreen(onNavigate: _navigateTo, onOpenSweets: _openSweets),
      ToffeeScreen(
        savedRecipes: _savedRecipes,
        onToggleSaved: _toggleSaved,
      ),
      ProcessLabScreen(
        savedRecipes: _savedRecipes,
        onToggleSaved: _toggleSaved,
      ),
      SavedScreen(
        savedRecipes: _savedRecipes,
        loading: _loadingSaved,
        onToggleSaved: _toggleSaved,
        onOpenSweets: _openSweets,
        onNavigate: _navigateTo,
      ),
      SweetsScreen(
        savedRecipes: _savedRecipes,
        onToggleSaved: _toggleSaved,
      ),
    ];

    return MaterialApp(
      title: 'FRUITIVA — From Fresh Fruit to Delicious Products',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _background,
        colorScheme: const ColorScheme.dark(
          primary: _orange,
          onPrimary: _background,
          secondary: _green,
          surface: _surface,
          onSurface: _white,
          error: _coral,
        ),
        fontFamily: 'Manrope',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: _white, height: 1.5),
          bodyMedium: TextStyle(color: _white, height: 1.45),
          bodySmall: TextStyle(color: _muted, height: 1.45),
          titleLarge: TextStyle(
            color: _white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.16,
          ),
          titleMedium: TextStyle(
            color: _white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.25,
          ),
          titleSmall: TextStyle(
            color: _white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
          labelLarge: TextStyle(fontWeight: FontWeight.w800),
        ),
        snackBarTheme: const SnackBarThemeData(
          contentTextStyle: TextStyle(color: _white),
        ),
      ),
      home: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const FruitivaHeader(),
              Expanded(
                child: IndexedStack(
                  index: _screen,
                  children: pages,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: FruitivaNavigationBar(
          selectedIndex: selectedNav,
          onSelected: _navigateTo,
        ),
      ),
    );
  }
}

class FruitivaHeader extends StatelessWidget {
  const FruitivaHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _orange,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _orange.withValues(alpha: 0.16),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.auto_awesome, color: _background, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FRUITIVA',
                  style: TextStyle(
                    color: _white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    letterSpacing: 2.2,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'From Fresh Fruit to Delicious Products',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FruitivaNavigationBar extends StatelessWidget {
  const FruitivaNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (Icons.home_outlined, 'Home'),
    (Icons.auto_awesome_outlined, 'Recipes'),
    (Icons.science_outlined, 'Process Lab'),
    (Icons.favorite_border, 'Saved'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xF214201A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _muted.withValues(alpha: 0.18)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x44000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(6),
        child: Row(
          children: List.generate(_items.length, (index) {
            final selected = selectedIndex == index;
            final item = _items[index];
            return Expanded(
              child: Semantics(
                button: true,
                selected: selected,
                label: item.$2,
                child: InkWell(
                  onTap: () => onSelected(index),
                  borderRadius: BorderRadius.circular(15),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    constraints: const BoxConstraints(minHeight: 58),
                    decoration: BoxDecoration(
                      color: selected
                          ? _orange.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.$1,
                          color: selected ? _orange : _muted,
                          size: 20,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: selected ? _orange : _muted,
                            fontSize: 10,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onNavigate,
    required this.onOpenSweets,
    super.key,
  });

  final ValueChanged<int> onNavigate;
  final VoidCallback onOpenSweets;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        Container(
          height: 272,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: _orange.withValues(alpha: 0.22)),
            image: const DecorationImage(
              image: AssetImage('site/public/assets/mango-toffee.jpg'),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x25303A31),
                  Color(0xB9101A16),
                  Color(0xF5101A16),
                ],
                stops: [0, 0.49, 1],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const _Eyebrow('FRUIT PROCESSING, MADE PRACTICAL'),
                  const SizedBox(height: 10),
                  Text('Turn Fruits into Value',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 30,
                          )),
                  const SizedBox(height: 8),
                  const Text(
                    'Explore recipes, processing techniques and small-scale food production.',
                    style: TextStyle(color: _white, fontSize: 13, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  _PrimaryButton(
                    label: 'Explore recipes',
                    icon: Icons.arrow_forward,
                    onPressed: () => onNavigate(1),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 27),
        const _SectionTitle(title: 'Explore by product'),
        const SizedBox(height: 12),
        _CategoryCard(
          image: 'site/public/assets/mango-toffee.jpg',
          imageLabel: 'Artisanal fruit toffees',
          category: 'TOFFEE',
          title: 'Fruit Toffees',
          description: 'Explore 6 fruit varieties',
          onTap: () => onNavigate(1),
        ),
        const SizedBox(height: 10),
        _CategoryCard(
          image: 'site/public/assets/fruit-bar-tray.jpg',
          imageLabel: 'Fruit bars on a drying tray',
          category: 'FRUIT BARS',
          title: 'Fruit Bars',
          description: 'Banana and mango fruit bars',
          onTap: () => onNavigate(2),
        ),
        const SizedBox(height: 10),
        _CategoryCard(
          image: 'site/public/assets/aonla-burfi.jpg',
          imageLabel: 'Aonla laddus and burfi',
          category: 'FRUIT SWEETS',
          title: 'Traditional Sweets',
          description: 'Aonla, papaya and carrot sweets',
          onTap: onOpenSweets,
        ),
        const SizedBox(height: 27),
        Row(
          children: [
            const Expanded(child: _SectionTitle(title: 'Learn the Process')),
            TextButton(
              onPressed: () => onNavigate(2),
              child: const Text(
                'Open Process Lab',
                style: TextStyle(color: _orange, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const _ProcessOverview(),
        const SizedBox(height: 27),
        const _SectionTitle(title: 'Featured Recipe'),
        const SizedBox(height: 12),
        _FeaturedRecipe(onPressed: () => onNavigate(1)),
      ],
    );
  }
}

class _Recipe {
  const _Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.ingredients,
    required this.steps,
    this.image,
    this.imageLabel = '',
    this.keyValues = const [],
  });

  /// Storage key used for saved recipes (kept stable for older saves).
  final String id;
  final String name;
  final String category;
  final String? image;
  final String imageLabel;
  final List<(String, String)> ingredients;
  final List<String> steps;
  final List<(String, String)> keyValues;
}

const _pulpyFoodsIntro =
    'Pulpy foods have great potential and offer lot of opportunities for preparing diversified products. Many groups of products are prepared from pulpy fruits. They are highly nutritive products compared to sugar-boiled confectioneries available in the market. Therefore, these products have scope for cottage and small-scale industry.';

const _toffeeIntro =
    'Toffee can be prepared from various fruits such as aonla, bael, mango, guava, banana, papaya, etc. Ingredients for toffee are fruit pulp, sugar, glucose, skimmed milk powder and butter. Essence and colour can also be added. Recipe and technique for preparation of toffee from different fruits are as under:';

const _fruitBarIntro =
    'This delicious specialty product is prepared by drying fruit pulp after mixing suitable ingredients. Fruit bars are a source of carbohydrates, minerals and vitamins. Fruit bars can be prepared from pulpy fruits such as mango, banana, guava, aonla, papaya, etc. Fruit bars are used as ingredients in confectionery, ice cream and bread spread. Recipe and technique for preparation of fruit bar are given below:';

const _sweetIntro =
    'Sweet can be prepared from various fruits such as aonla, papaya, etc., and vegetables such as carrot, pointed gourd, etc. Recipe and technique for preparation of some sweets are as under:';

const _toffeeRecipes = [
  _Recipe(
    id: 'Aonla Toffee',
    name: 'Aonla Toffee',
    category: 'TOFFEE',
    ingredients: [
      ('Aonla pulp', '1 kg'),
      ('Sugar', '750 g'),
      ('Glucose', '100 g'),
      ('Skim milk powder', '150 g'),
      ('Butter', '50 g'),
    ],
    steps: [
      'Pulp.',
      'Heating.',
      'Concentrating up to one-third volume.',
      'Mixing with sugar, glucose, butter and milk powder.',
      'Cooking up to compact solid mass.',
      'Removing from fire.',
      'Adding colour and essence.',
      'Mixing.',
      'Spreading mass uniformly (0.5–0.75 cm thickness) on a table with stainless steel top/tray smeared with butter.',
      'Allow to cool and set 2–4 hours.',
      'Cutting into cubes.',
      'Wrapping in butter paper.',
      'Storage.',
    ],
    keyValues: [
      ('Concentration', 'Up to one-third volume'),
      ('Sheet thickness', '0.5–0.75 cm'),
      ('Cool and set', '2–4 hours'),
    ],
  ),
  _Recipe(
    id: 'Bael Toffee',
    name: 'Bael Toffee',
    category: 'TOFFEE',
    ingredients: [
      ('Pulp', '1 kg'),
      ('Sugar', '400 g'),
      ('Glucose', '50 g'),
      ('Skim milk powder', '100 g'),
      ('Butter', '80 g'),
    ],
    steps: [
      'Pulp.',
      'Cooking up to 1/3.',
      'Mixing of sugar, glucose, milk powder and ½ amount of butter.',
      'Cooking up to end point.',
      'Addition of remaining half of butter.',
      'Cooking up to desired consistency (83% TSS).',
      'Addition of sulphur dioxide (1000–1500 ppm).',
      'Spread on aluminium tray (in 0.5 cm thickness).',
      'Cooling.',
      'Cutting.',
      'Drying at 60 °C for 4 hours (9–10% moisture).',
      'Packing in polythene pouches.',
      'Storage.',
    ],
    keyValues: [
      ('Concentration', 'Up to 1/3'),
      ('Desired consistency', '83% TSS'),
      ('Sulphur dioxide', '1000–1500 ppm'),
      ('Sheet thickness', '0.5 cm'),
      ('Drying', '60 °C for 4 hours (9–10% moisture)'),
    ],
  ),
  _Recipe(
    id: 'Guava Toffee',
    name: 'Guava Toffee',
    category: 'TOFFEE',
    ingredients: [
      ('Guava pulp', '1 kg'),
      ('Sugar', '0.75 kg'),
      ('Butter', '100 g'),
      ('Glucose', '100 g'),
      ('Skimmed milk powder', '150 g'),
    ],
    steps: [
      'Firm ripe fruit.',
      'Washing.',
      'Cutting into pieces.',
      'Boiling with water (1:1 ratio).',
      'Sieving (Removal of seeds).',
      'Pulp.',
      'Heating/cooking to one-third volume.',
      'Mixing with sugar and glucose and heating.',
      'Addition of butter.',
      'Cooking till sufficient solid.',
      'Addition of milk powder (by dissolving in little water).',
      'Addition of colour and essence.',
      'Mixing.',
      'Transferring the mass in tray smeared with butter.',
      'Spread mass uniformly (0.5–0.75 cm thick layer).',
      'Cooling (4–5 hours).',
      'Cutting into pieces of suitable size.',
      'Wrapping in butter or moisture-proof paper.',
      'Packing in jars.',
      'Capping/sealing.',
      'Storage.',
    ],
    keyValues: [
      ('Boiling with water', '1:1 ratio'),
      ('Concentration', 'One-third volume'),
      ('Layer thickness', '0.5–0.75 cm'),
      ('Cooling', '4–5 hours'),
    ],
  ),
  _Recipe(
    id: 'Mango Toffee',
    name: 'Mango Toffee',
    category: 'TOFFEE',
    image: 'site/public/assets/mango-toffee.jpg',
    imageLabel: 'Golden mango toffee',
    ingredients: [
      ('Mango pulp', '1 kg'),
      ('Sugar', '600 g'),
      ('Glucose', '100 g'),
      ('Skim milk powder', '160 g'),
      ('Butter or hydrogenated fat', '100 g'),
    ],
    steps: [
      'Ripe mangoes.',
      'Washing.',
      'Peeling.',
      'Pulping.',
      'Cooking or concentrating (in steam-jacketed kettle) to one-third of original volume.',
      'Addition of other ingredients and mixing.',
      'Continue cooking till desired consistency.',
      'Transferring to a smooth surface container (smeared lightly with fat).',
      'Spreading into thin sheet (0.5–0.75 cm thick).',
      'Allowing to cool and set.',
      'Solid sheet cut into toffee.',
      'Wrapping in tissue paper.',
      'Packing in airtight jar or tins.',
      'Storage.',
    ],
    keyValues: [
      ('Concentration', 'One-third of original volume (steam-jacketed kettle)'),
      ('Sheet thickness', '0.5–0.75 cm'),
    ],
  ),
  _Recipe(
    id: 'Banana Toffee',
    name: 'Banana Toffee',
    category: 'TOFFEE',
    ingredients: [
      ('Banana pulp', '1 kg'),
      ('Sugar', '750 g'),
      ('Glucose', '100 g'),
      ('Skimmed milk powder', '150 g'),
      ('Butter or ghee', '70 g'),
    ],
    steps: [
      'Ripe banana.',
      'Washing.',
      'Peeling.',
      'Pulping.',
      'Sieving (30 mesh sieve).',
      'Concentrating pulp (steam-jacketed kettle) to one-third of its original volume.',
      'Addition of all ingredients (sugar, glucose, skimmed milk powder, butter).',
      'Mixing.',
      'Cooking continues to final weight (one-fifth of the fruit pulp taken).',
      'Transferring cooked mass to a smooth-surface tray smeared with fat (flavouring matter is added at this stage).',
      'Spreading into a thin (0.5–0.75 cm) sheet.',
      'Allowing to cool and set (2 hours).',
      'Solid sheet cut into pieces of toffee size.',
      'Drying at 50–55 °C to a final moisture of 5–6%.',
      'Wrapping in butter paper.',
      'Filling in jars or tins.',
      'Sealing.',
      'Storage.',
    ],
    keyValues: [
      ('Sieve', '30 mesh'),
      ('Concentration', 'One-third of original volume'),
      ('Final weight', 'One-fifth of the fruit pulp taken'),
      ('Sheet thickness', '0.5–0.75 cm'),
      ('Cool and set', '2 hours'),
      ('Drying', '50–55 °C to a final moisture of 5–6%'),
    ],
  ),
  _Recipe(
    id: 'Papaya Toffee',
    name: 'Papaya Toffee',
    category: 'TOFFEE',
    ingredients: [
      ('Pulp', '1 kg'),
      ('Sugar', '600 g'),
      ('Glucose', '100 g'),
      ('Skim milk powder', '160 g'),
      ('Butter or fat', '100 g'),
    ],
    steps: [
      'Ripe fruit.',
      'Washing.',
      'Peeling.',
      'Cutting into halves and removal of seed.',
      'Passing through pulper.',
      'Pulp.',
      'Cooking up to one-third.',
      'Mix other ingredients.',
      'Cooking up to desired consistency (till it starts leaving the side of container).',
      'Transferring on smooth surface or tray smeared with fat.',
      'Spreading the mass (in thickness of 0.5–0.75 cm).',
      'Allowing to set.',
      'Cutting the sheet into pieces of toffee size.',
      'Wrapping in butter paper.',
      'Filling in glass jar or tin.',
      'Sealing.',
      'Storage.',
    ],
    keyValues: [
      ('Concentration', 'Up to one-third'),
      ('End point', 'Till it starts leaving the side of container'),
      ('Sheet thickness', '0.5–0.75 cm'),
    ],
  ),
];

const _fruitBarRecipes = [
  _Recipe(
    id: 'Banana Fruit Bar',
    name: 'Banana Fruit Bar',
    category: 'FRUIT BAR',
    image: 'site/public/assets/fruit-bar-tray.jpg',
    imageLabel: 'Fruit bars on a drying tray',
    ingredients: [
      ('Banana pulp', '1 kg'),
      ('Sugar', '100 g'),
      ('Citric acid', '2 g'),
      ('KMS', '1 g'),
    ],
    steps: [
      'Ripe fruit.',
      'Washing.',
      'Peeling.',
      'Pulping.',
      'Pulp.',
      'Heating (83 °C for 10 minutes).',
      'Mixing with sugar, citric acid and KMS.',
      'Spreading on tray.',
      'Drying in cross-flow drier at 60 °C until it can be taken out in the form of a sheet.',
      'Cutting of sheets into small bars.',
      'Wrapping in cellophane paper.',
      'Packing in polythene pouches.',
      'Storage.',
    ],
    keyValues: [
      ('Heating', '83 °C for 10 minutes'),
      (
        'Drying',
        'Cross-flow drier at 60 °C until it can be taken out as a sheet'
      ),
    ],
  ),
  _Recipe(
    id: 'Mango Fruit Bar',
    name: 'Mango Fruit Bar',
    category: 'FRUIT BAR',
    image: 'site/public/assets/fruit-bar-tray.jpg',
    imageLabel: 'Fruit bars on a drying tray',
    ingredients: [
      ('Mango pulp', '1 kg'),
      ('Sugar', '150 g'),
      ('Citric acid', '1 g'),
      ('KMS', '1 g'),
    ],
    steps: [
      'Ripe mangoes (pulpy varieties).',
      'Washing.',
      'Peeling.',
      'Pulping.',
      'Mixing with sugar, citric acid and KMS.',
      'Spreading on trays.',
      'Drying in cross-flow air dryer.',
      'Cutting into small bars.',
      'Wrapping (cellophane paper).',
      'Packing in polythene pouches.',
      'Storage.',
    ],
    keyValues: [
      ('Drying', 'Cross-flow air dryer (temperature and time not specified)'),
    ],
  ),
];

const _sweetRecipes = [
  _Recipe(
    id: 'Aonla Laddu & Burfi',
    name: 'Aonla Laddu and Burfi',
    category: 'SWEET',
    image: 'site/public/assets/aonla-burfi.jpg',
    imageLabel: 'Green-golden aonla laddus and burfi',
    ingredients: [
      ('Aonla shred', '1 kg'),
      ('Sugar', '1 kg'),
      ('Water', '0.5 litre'),
      ('Melon seeds', '100 g'),
    ],
    steps: [
      'Aonla fruit.',
      'Washing.',
      'Grating into shreds.',
      'Little drying/squeezing.',
      'Adding in sugar syrup.',
      'Cooking up to desired consistency.',
      'Addition of melon seed.',
      'Making in shape of Laddu or Burfi.',
      'Little drying in shade.',
      'Packing in polythene bag/cardboard box.',
      'Storing.',
    ],
  ),
  _Recipe(
    id: 'Papaya Burfi',
    name: 'Papaya Sweet (Burfi)',
    category: 'SWEET',
    image: 'site/public/assets/papaya-burfi.jpg',
    imageLabel: 'Orange papaya burfi with coconut',
    ingredients: [
      ('Papaya', '1 kg'),
      ('Sugar', '750 g'),
      ('Cardamom (small) powder', '10 g'),
      ('Coconut shreds', '20 g'),
    ],
    steps: [
      'Mature but unripe papaya.',
      'Washing.',
      'Peeling.',
      'Cutting into halves.',
      'Removal of seeds.',
      'Grating into shreds.',
      'Addition of sugar.',
      'Cooking with stirring.',
      'When mixture starts leaving the container surface, add cardamom and coconut shreds.',
      'Mix thoroughly.',
      'Transferring the mass on smooth surface of tray smeared with fat.',
      'Spread in desired thickness and allow to set.',
      'Spread some coconut shreds over it.',
      'Cutting into shape of Burfi.',
      'Pack in attractive cardboard box (sweets dibba).',
      'Use or sale.',
    ],
  ),
  _Recipe(
    id: 'Carrot Burfi',
    name: 'Carrot Burfi',
    category: 'SWEET',
    image: 'site/public/assets/carrot-burfi.jpg',
    imageLabel: 'Carrot burfi garnished with cashews and raisins',
    ingredients: [
      ('Carrot', '1 kg'),
      ('Sugar', '450 g'),
      ('Milk', '0.5 litre'),
      ('Fat (ghee)', '200 g'),
      ('Dry fruits (cashew nut, raisins)', '50 g'),
      ('Cardamom', '1 g'),
    ],
    steps: [
      'Orange-yellow variety of carrot.',
      'Scrapping.',
      'Washing.',
      'Grating.',
      'Cooking with milk till dryness of milk.',
      'Frying in fat (ghee).',
      'Addition of sugar, dry fruits and cardamom.',
      'Spreading in trays after smearing fat.',
      'Allow to set.',
      'Cutting into shape of Burfi.',
      'Packing in cardboard box.',
      'Sale/Use.',
    ],
  ),
];

const _allRecipes = [..._toffeeRecipes, ..._fruitBarRecipes, ..._sweetRecipes];

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Eyebrow(title),
          for (final paragraph in paragraphs) ...[
            const SizedBox(height: 8),
            Text(
              paragraph,
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipePlaceholder extends StatelessWidget {
  const _RecipePlaceholder({required this.name, this.height = 154});

  final String name;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_raised, _orange.withValues(alpha: 0.35)],
        ),
      ),
      alignment: Alignment.center,
      child: Semantics(
        label: '$name (no photo)',
        child: const Icon(Icons.cookie_outlined, color: _white, size: 44),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaved, required this.onPressed});

  final bool isSaved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isSaved ? 'Remove from saved recipes' : 'Save recipe',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: _background,
        foregroundColor: isSaved ? _orange : _white,
        side: BorderSide(
          color: isSaved
              ? _orange.withValues(alpha: 0.7)
              : _muted.withValues(alpha: 0.12),
        ),
      ),
      icon: Icon(isSaved ? Icons.favorite : Icons.favorite_border, size: 19),
    );
  }
}

class _RecipeDetail extends StatelessWidget {
  const _RecipeDetail({
    required this.recipe,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final _Recipe recipe;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            height: 188,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (recipe.image != null)
                  Image.asset(recipe.image!,
                      fit: BoxFit.cover, semanticLabel: recipe.imageLabel)
                else
                  _RecipePlaceholder(name: recipe.name, height: 188),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x00101A16), Color(0xD9101A16)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const _Eyebrow('SELECTED FORMULATION'),
                            const SizedBox(height: 4),
                            Text(
                              recipe.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontSize: 21),
                            ),
                          ],
                        ),
                      ),
                      _SaveButton(isSaved: isSaved, onPressed: onToggleSaved),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        _IngredientCard(
          title: 'Recipe',
          badge: recipe.category,
          ingredients: recipe.ingredients,
        ),
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Technique'),
        const SizedBox(height: 10),
        for (var i = 0; i < recipe.steps.length; i++) ...[
          _NumberedStep(number: i + 1, text: recipe.steps[i]),
          if (i != recipe.steps.length - 1) const SizedBox(height: 9),
        ],
        if (recipe.keyValues.isNotEmpty) ...[
          const SizedBox(height: 16),
          _TechnicalCard(
            icon: Icons.straighten,
            title: 'Key process values',
            value: recipe.keyValues
                .map((entry) => '${entry.$1}: ${entry.$2}')
                .join('\n'),
          ),
        ],
      ],
    );
  }
}

class ToffeeScreen extends StatefulWidget {
  const ToffeeScreen({
    required this.savedRecipes,
    required this.onToggleSaved,
    super.key,
  });

  final Set<String> savedRecipes;
  final ValueChanged<String> onToggleSaved;

  @override
  State<ToffeeScreen> createState() => _ToffeeScreenState();
}

class _ToffeeScreenState extends State<ToffeeScreen> {
  int _selected = 3; // Mango

  @override
  Widget build(BuildContext context) {
    final recipe = _toffeeRecipes[_selected];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        const _Eyebrow('RECIPE STUDIO'),
        const SizedBox(height: 6),
        Text('Toffee Recipe Studio',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text(
          'Six fruits. Six formulations. One learning experience.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 14),
        const _IntroCard(
          title: 'PULPY FRUIT PRODUCTS · TOFFEE',
          paragraphs: [_pulpyFoodsIntro, _toffeeIntro],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _toffeeRecipes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final fruit =
                  _toffeeRecipes[index].name.replaceAll(' Toffee', '');
              final selected = index == _selected;
              return ChoiceChip(
                label: Text(fruit),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) => setState(() => _selected = index),
                backgroundColor: _surface,
                selectedColor: _orange.withValues(alpha: 0.18),
                side: BorderSide(
                  color: selected ? _orange.withValues(alpha: 0.75) : _line,
                ),
                labelStyle: TextStyle(
                  color: selected ? _orange : _muted,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _RecipeDetail(
          recipe: recipe,
          isSaved: widget.savedRecipes.contains(recipe.id),
          onToggleSaved: () => widget.onToggleSaved(recipe.id),
        ),
        const SizedBox(height: 25),
        const _SectionTitle(title: 'Explore Other Toffees'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _toffeeRecipes.length; i++)
              if (i != _selected)
                _FruitPill(
                  fruit: _toffeeRecipes[i].name.replaceAll(' Toffee', ''),
                  onTap: () => setState(() => _selected = i),
                ),
          ],
        ),
      ],
    );
  }
}

class ProcessLabScreen extends StatefulWidget {
  const ProcessLabScreen({
    required this.savedRecipes,
    required this.onToggleSaved,
    super.key,
  });

  final Set<String> savedRecipes;
  final ValueChanged<String> onToggleSaved;

  @override
  State<ProcessLabScreen> createState() => _ProcessLabScreenState();
}

class _ProcessLabScreenState extends State<ProcessLabScreen> {
  bool _mangoSelected = false;

  @override
  Widget build(BuildContext context) {
    final recipe = _fruitBarRecipes[_mangoSelected ? 1 : 0];
    final other = _fruitBarRecipes[_mangoSelected ? 0 : 1];
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        const _Eyebrow('PROCESSING LAB'),
        const SizedBox(height: 6),
        Text('Fruit Bar Processing Lab',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text(
          'From fruit pulp to naturally colorful fruit sheets.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 14),
        const _IntroCard(
          title: 'FRUIT BAR',
          paragraphs: [_fruitBarIntro],
        ),
        const SizedBox(height: 16),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              label: Text('BANANA FRUIT BAR'),
            ),
            ButtonSegment(
              value: true,
              label: Text('MANGO FRUIT BAR'),
            ),
          ],
          selected: {_mangoSelected},
          onSelectionChanged: (selection) =>
              setState(() => _mangoSelected = selection.first),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected)
                    ? _orange.withValues(alpha: 0.2)
                    : _surface),
            foregroundColor: WidgetStateProperty.resolveWith((states) =>
                states.contains(WidgetState.selected) ? _orange : _muted),
            side: WidgetStateProperty.resolveWith((states) => BorderSide(
                  color: states.contains(WidgetState.selected)
                      ? _orange.withValues(alpha: 0.65)
                      : _muted.withValues(alpha: 0.16),
                )),
          ),
        ),
        const SizedBox(height: 13),
        const _ProductionLine(),
        const SizedBox(height: 13),
        _RecipeDetail(
          recipe: recipe,
          isSaved: widget.savedRecipes.contains(recipe.id),
          onToggleSaved: () => widget.onToggleSaved(recipe.id),
        ),
        const SizedBox(height: 16),
        _IngredientCard(
          title: other.name,
          badge: 'ALSO AVAILABLE',
          ingredients: other.ingredients,
          note: 'Switch above to see the full ${other.name} technique.',
        ),
      ],
    );
  }
}

class SweetsScreen extends StatelessWidget {
  const SweetsScreen({
    required this.savedRecipes,
    required this.onToggleSaved,
    super.key,
  });

  final Set<String> savedRecipes;
  final ValueChanged<String> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        const _Eyebrow('TRADITIONAL RECIPES'),
        const SizedBox(height: 6),
        Text('Traditional Sweets Kitchen',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text(
          'Fruit-based recipes with a traditional touch.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 14),
        const _IntroCard(title: 'SWEET', paragraphs: [_sweetIntro]),
        const SizedBox(height: 16),
        for (var i = 0; i < _sweetRecipes.length; i++) ...[
          _SweetRecipeCard(
            recipe: _sweetRecipes[i],
            index: i + 1,
            isSaved: savedRecipes.contains(_sweetRecipes[i].id),
            onToggleSaved: () => onToggleSaved(_sweetRecipes[i].id),
          ),
          if (i != _sweetRecipes.length - 1) const SizedBox(height: 13),
        ],
        const SizedBox(height: 8),
        const Text(
          'Traditional recipes. Scientific processing. Value-added products.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _muted,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class SavedScreen extends StatelessWidget {
  const SavedScreen({
    required this.savedRecipes,
    required this.loading,
    required this.onToggleSaved,
    required this.onOpenSweets,
    required this.onNavigate,
    super.key,
  });

  final Set<String> savedRecipes;
  final bool loading;
  final ValueChanged<String> onToggleSaved;
  final VoidCallback onOpenSweets;
  final ValueChanged<int> onNavigate;

  @override
  Widget build(BuildContext context) {
    final available = _allRecipes
        .where((recipe) => savedRecipes.contains(recipe.id))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
      children: [
        const _Eyebrow('YOUR COLLECTION'),
        const SizedBox(height: 6),
        Text('Saved Recipes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        const Text(
          'Your favorite fruit recipes, ready when you are.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
        const SizedBox(height: 18),
        if (loading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(color: _orange),
            ),
          )
        else if (available.isEmpty)
          _NoticeCard(
            title: 'No saved recipes yet',
            body:
                'Tap the heart on any toffee, fruit bar or sweet recipe to keep it here.',
            action: _PrimaryButton(
              label: 'Explore fruit sweets',
              icon: Icons.arrow_forward,
              onPressed: onOpenSweets,
            ),
          )
        else
          for (final recipe in available) ...[
            _SweetRecipeCard(
              recipe: recipe,
              index: _allRecipes.indexOf(recipe) + 1,
              isSaved: true,
              onToggleSaved: () => onToggleSaved(recipe.id),
            ),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 10),
        _CategoryCard(
          image: 'site/public/assets/mango-toffee.jpg',
          imageLabel: 'Golden mango toffee',
          category: 'RECIPE STUDIO',
          title: 'Fruit Toffees',
          description: 'Open all 6 toffee formulations',
          onTap: () => onNavigate(1),
        ),
      ],
    );
  }
}

class _SweetRecipeCard extends StatelessWidget {
  const _SweetRecipeCard({
    required this.recipe,
    required this.index,
    required this.isSaved,
    required this.onToggleSaved,
  });

  final _Recipe recipe;
  final int index;
  final bool isSaved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _muted.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            image: true,
            label: recipe.imageLabel,
            child: recipe.image == null
                ? _RecipePlaceholder(name: recipe.name)
                : Image.asset(
                    recipe.image!,
                    width: double.infinity,
                    height: 154,
                    fit: BoxFit.cover,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Eyebrow(
                              '${recipe.category} · RECIPE ${index.toString().padLeft(2, '0')}'),
                          const SizedBox(height: 5),
                          Text(
                            recipe.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontSize: 17),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip:
                          isSaved ? 'Remove from saved recipes' : 'Save recipe',
                      onPressed: onToggleSaved,
                      style: IconButton.styleFrom(
                        backgroundColor: _background,
                        foregroundColor: isSaved ? _orange : _white,
                        side: BorderSide(
                          color: isSaved
                              ? _orange.withValues(alpha: 0.7)
                              : _muted.withValues(alpha: 0.12),
                        ),
                      ),
                      icon: Icon(
                        isSaved ? Icons.favorite : Icons.favorite_border,
                        size: 19,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Recipe',
                  style: TextStyle(
                    color: _white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                for (final ingredient in recipe.ingredients)
                  _IngredientRow(
                    name: ingredient.$1,
                    quantity: ingredient.$2,
                  ),
                const SizedBox(height: 5),
                Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                    listTileTheme: const ListTileThemeData(
                      minVerticalPadding: 0,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(bottom: 8),
                    collapsedIconColor: _orange,
                    iconColor: _orange,
                    title: const Text(
                      'Technique',
                      style: TextStyle(
                        color: _orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    children: [
                      for (var i = 0; i < recipe.steps.length; i++) ...[
                        _NumberedStep(number: i + 1, text: recipe.steps[i]),
                        if (i != recipe.steps.length - 1)
                          const SizedBox(height: 7),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientCard extends StatelessWidget {
  const _IngredientCard({
    required this.title,
    required this.badge,
    required this.ingredients,
    this.note,
  });

  final String title;
  final String badge;
  final List<(String, String)> ingredients;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child:
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              _Eyebrow(badge),
            ],
          ),
          const SizedBox(height: 5),
          for (final ingredient in ingredients)
            _IngredientRow(
              name: ingredient.$1,
              quantity: ingredient.$2,
            ),
          if (note != null) ...[
            const SizedBox(height: 8),
            Text(note!, style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.name, required this.quantity});

  final String name;
  final String quantity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                Text(name, style: const TextStyle(color: _white, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Text(
            quantity,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: _orange,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.image,
    required this.imageLabel,
    required this.category,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String image;
  final String imageLabel;
  final String category;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(color: _muted.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  image,
                  width: 104,
                  height: 90,
                  fit: BoxFit.cover,
                  semanticLabel: imageLabel,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Eyebrow(category),
                    const SizedBox(height: 4),
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: _orange),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedRecipe extends StatelessWidget {
  const _FeaturedRecipe({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.asset(
              'site/public/assets/mango-toffee.jpg',
              width: 105,
              height: 122,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Eyebrow('SWEET & FRUITY'),
                const SizedBox(height: 5),
                Text('Mango Toffee',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                const Text(
                  'A step-by-step guide from mango pulp to wrapped toffee.',
                  style: TextStyle(color: _muted, fontSize: 11),
                ),
                const SizedBox(height: 11),
                _PrimaryButton(
                  label: 'View recipe',
                  icon: Icons.arrow_forward,
                  onPressed: onPressed,
                  compact: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessOverview extends StatelessWidget {
  const _ProcessOverview();

  static const _steps = [
    (Icons.spa_outlined, 'Fresh Fruit', 'Select & wash'),
    (Icons.blender_outlined, 'Pulp Prep', 'Peel & pulp'),
    (Icons.local_fire_department_outlined, 'Cooking', 'Mix & cook'),
    (Icons.cookie_outlined, 'Shape or Dry', 'Make the product'),
    (Icons.inventory_2_outlined, 'Packaging', 'Wrap & pack'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _steps.map((step) {
        return SizedBox(
          width: (MediaQuery.sizeOf(context).width - 52) / 3,
          child: _SurfaceCard(
            padding: const EdgeInsets.all(11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(step.$1, color: _orange, size: 22),
                const SizedBox(height: 8),
                Text(step.$2,
                    style: const TextStyle(
                        color: _white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11)),
                const SizedBox(height: 3),
                Text(step.$3,
                    style: const TextStyle(color: _muted, fontSize: 9)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ProductionLine extends StatelessWidget {
  const _ProductionLine();

  static const _stages = [
    (Icons.spa_outlined, 'Fresh fruit'),
    (Icons.blender_outlined, 'Pulp'),
    (Icons.layers_outlined, 'Spread sheet'),
    (Icons.grid_on_outlined, 'Dried sheet'),
    (Icons.inventory_2_outlined, 'Wrapped bars'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < _stages.length; index++) ...[
            if (index > 0)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Icon(Icons.arrow_forward, color: _orange, size: 15),
              ),
            Container(
              width: 79,
              constraints: const BoxConstraints(minHeight: 86),
              decoration: BoxDecoration(
                color: _surface,
                border: Border.all(color: _muted.withValues(alpha: 0.14)),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_stages[index].$1, color: _orange, size: 21),
                  const SizedBox(height: 7),
                  Text(
                    _stages[index].$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _muted.withValues(alpha: 0.12)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              number.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: _orange,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                text,
                style:
                    const TextStyle(color: _white, fontSize: 12, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicalCard extends StatelessWidget {
  const _TechnicalCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _orange.withValues(alpha: 0.45)),
        gradient: LinearGradient(
          colors: [
            _orange.withValues(alpha: 0.13),
            _surface,
          ],
        ),
      ),
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _orange, size: 23),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: _white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        color: _muted, fontSize: 13, height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FruitPill extends StatelessWidget {
  const _FruitPill({required this.fruit, required this.onTap});

  final String fruit;
  final VoidCallback onTap;

  static const _icons = {
    'Aonla': Icons.circle,
    'Bael': Icons.spa_outlined,
    'Guava': Icons.local_florist_outlined,
    'Banana': Icons.eco_outlined,
    'Papaya': Icons.circle_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(_icons[fruit] ?? Icons.circle, color: _green, size: 17),
      label: Text(fruit),
      backgroundColor: _surface,
      side: BorderSide(color: _muted.withValues(alpha: 0.14)),
      labelStyle: const TextStyle(color: _white, fontWeight: FontWeight.w700),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.title,
    required this.body,
    this.action,
  });

  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      padding: const EdgeInsets.all(17),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 7),
          Text(body, style: const TextStyle(color: _muted, fontSize: 13)),
          if (action != null) ...[
            const SizedBox(height: 14),
            action!,
          ],
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _muted.withValues(alpha: 0.14)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 22,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: _orange,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.compact = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: _orange,
        foregroundColor: _background,
        minimumSize: Size(compact ? 0 : 48, compact ? 40 : 48),
        padding: EdgeInsets.symmetric(horizontal: compact ? 12 : 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: TextStyle(
          fontSize: compact ? 11 : 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
